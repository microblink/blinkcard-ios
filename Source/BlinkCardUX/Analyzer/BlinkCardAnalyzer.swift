//
//  BlinkCardAnalyzer.swift
//  BlinkCardUX
//
//  Created by Toni Kreso on 17.12.2025..
//

import Foundation
import AVFoundation
import CoreVideo

import BlinkCard

public actor BlinkCardEventStream: EventStream {
    private let events: AsyncStream<[BlinkCardUIEvent]>
    private let continuation: AsyncStream<[BlinkCardUIEvent]>.Continuation
    
    public init() {
        var continuation: AsyncStream<[BlinkCardUIEvent]>.Continuation!
        self.events = AsyncStream { continuation = $0 }
        self.continuation = continuation
    }
    
    deinit {
        self.continuation.finish()
    }
    
    /// Sends UI events to the stream.
    /// - Parameter events: Array of UI events to be processed
    public func send(_ events: [BlinkCardUIEvent]) {
        continuation.yield(events)
    }
    
    /// The underlying async stream of UI events.
    public var stream: AsyncStream<[BlinkCardUIEvent]> {
        events
    }
}

public actor BlinkCardAnalyzer: CameraFrameAnalyzer {
    
    public typealias Event = BlinkCardUIEvent
    
    public typealias Result = ScanningResult<BlinkCardScanningResult, BlinkCardScanningAlertType>
    public typealias Frame = CameraFrame
    
    private let session: BlinkCardSession
    private let eventStream: BlinkCardEventStream
    private let translator: BlinkCardUXTranslator = BlinkCardUXTranslator()
    private var scanningDone = false
    private var paused = false
    private var resultContinuation: CheckedContinuation<Result, Never>?
    
    public private(set) var stepTimeoutDuration: TimeInterval
    public private(set) var inactivityTimeoutDuration: TimeInterval
    
    private var stepTimerTask: Task<Void, Never>?
    private var inactivityTimerTask: Task<Void, Never>?

    private var stepTimerStartDate: Date?
    private var stepTimerInterval: TimeInterval?
    
    /// Last event batch sent to the stream; used to detect UI state changes.
    private var lastSentEvents: [BlinkCardUIEvent] = []
    
    /// Creates a new document verification analyzer.
    /// - Parameters:
    ///   - sdk: The document verification SDK instance
    ///   - captureSessionSettings: Settings for the capture session
    ///   - eventStream: Stream to receive UI events during scanning
    ///   - classFilter: Class filter to filter document classes based on country, region, and document type
    public init(
        sdk: BlinkCardSdk,
        blinkCardSessionSettings: BlinkCardSessionSettings = BlinkCardSessionSettings(inputImageSource: .video),
        eventStream: BlinkCardEventStream
    ) async throws {
        self.session = try await sdk.createScanningSession(sessionSettings: blinkCardSessionSettings)
        self._sessionNumber = await session.getSessionNumber()
        self.eventStream = eventStream
        self.stepTimeoutDuration = blinkCardSessionSettings.stepTimeoutDuration
        self.inactivityTimeoutDuration = blinkCardSessionSettings.inactivityTimeoutDuration
    }
    
    private let _sessionNumber: Int
        
    nonisolated public var sessionNumber: Int {
        return _sessionNumber
    }
        
    /// Processes a camera frame for document analysis.
    /// - Parameter image: The camera frame to analyze
    public func analyze(image: Frame) async {
        guard !paused else { return }
        
        if stepTimerTask == nil {
            resumeStepTimer()
        }
        
        if inactivityTimerTask == nil {
            await startInactivityTimer(inactivityTimeoutDuration)
        }
        
        let inputImage = InputImage(cameraFrame: image)
        
        do {
            let frameProcessResult = try await session.process(inputImage: inputImage)
            
            let events = translator.translate(frameProcessResult: frameProcessResult, scanningSettings: session.settings.scanningSettings)
            
            if events != lastSentEvents {
                lastSentEvents = events
                await startInactivityTimer(inactivityTimeoutDuration)
            }
            
            await eventStream.send(events)
            
            if frameProcessResult.processResult?.resultCompleteness.scanningStatus == .cardScanned {
                guard !scanningDone else { return }
                scanningDone = true
                Task { @ProcessingActor in
                    let sessionResult = session.getResult()
                    await finishScanning(with: .completed(sessionResult))
                }
            }
        } catch {
            resultContinuation?.resume(returning: .cancelled)
        }
    }
    
    private func finishScanning(with result: ScanningResult<BlinkCardScanningResult, BlinkCardScanningAlertType>) {
        cancelAllTimers()
        resultContinuation?.resume(returning: result)
        resultContinuation = nil
    }
    
    /// Cancels the current document scanning session.
    public func cancel() {
        self.session.cancelActiveProcessing()
    }
    
    /// Returns the final result of the scanning session.
    public func result() async -> ScanningResult<BlinkCardScanningResult, BlinkCardScanningAlertType> {
        await withCheckedContinuation { continuation in
            self.resultContinuation = continuation
        }
    }
    
    /// Pauses the document analysis.
    public func pause() {
        self.paused = true
        self.cancel()
        freezeStepTimerRemaining()
        cancelAllTimers()
    }
    
    private func freezeStepTimerRemaining() {
        guard let startDate = stepTimerStartDate, let interval = stepTimerInterval else { return }
        stepTimerInterval = max(0, interval - Date().timeIntervalSince(startDate))
        stepTimerStartDate = nil
    }
    
    /// Resumes the document analysis after being paused.
    public func resume() {
        guard paused else { return }
        self.session.resumeActiveProcessing()
        paused = false
    }
    
    /// Restarts the document analysis after being paused.
    public func restart() throws {
        Task { @ProcessingActor in
            try self.session.reset()
        }
        translator.resetState()
        lastSentEvents = []
        cancelAllTimers()
        stepTimerStartDate = nil
        stepTimerInterval = nil
        resume()
    }
    
    public func resetStepTimer() {
        stepTimerTask?.cancel()
        stepTimerTask = nil
        stepTimerStartDate = nil
        stepTimerInterval = nil
        if !paused {
            startStepTimer(stepTimeoutDuration)
        }
    }
    
    public func end() {
        pause()
        resultContinuation?.resume(returning: .ended)
        resultContinuation = nil
    }
    
    /// Stream of UI events generated during document analysis.
    nonisolated public var events: any EventStream<BlinkCardUIEvent> {
        eventStream
    }
    
    private func startStepTimer(_ interval: TimeInterval) {
        guard interval > 0.0 else { return }
        stepTimerTask?.cancel()
        stepTimerStartDate = Date()
        stepTimerInterval = interval
        stepTimerTask = Task() { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                let nanoseconds = UInt64(interval * Double(NSEC_PER_SEC))
                try? await Task.sleep(nanoseconds: nanoseconds)
                if !Task.isCancelled {
                    await scanInterrupted(with: .timeout)
                }
            }
        }
    }
    
    /// Starts (or restarts) the inactivity timer.
    /// Must be called every time the UI state changes (i.e. a new distinct event batch).
    private func startInactivityTimer(_ interval: TimeInterval) async {
        guard inactivityTimeoutDuration > 0 else { return }
        inactivityTimerTask?.cancel()
        inactivityTimerTask = Task { [weak self] in
            guard let self else { return }
            let nanoseconds = UInt64(interval * Double(NSEC_PER_SEC))
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            await self.scanInterrupted(with: .inactivityTimeout)
        }
    }
    
    private func cancelAllTimers() {
        stepTimerTask?.cancel()
        stepTimerTask = nil
        inactivityTimerTask?.cancel()
        inactivityTimerTask = nil
    }
    
    private func resumeStepTimer() {
        guard stepTimerTask == nil else { return }
        if let interval = stepTimerInterval {
            stepTimerInterval = nil
            if interval <= 0 {
                scanInterrupted(with: .timeout)
            } else {
                startStepTimer(interval)
            }
        } else {
            startStepTimer(stepTimeoutDuration)
        }
    }
    
    private func cancelInactivityTimer() {
        inactivityTimerTask?.cancel()
        inactivityTimerTask = nil
    }
    
    private func scanInterrupted(with alertType: BlinkCardScanningAlertType) {
        pause()
        resultContinuation?.resume(returning: .interrupted(alertType))
        resultContinuation = nil
        
        Task {
            if sessionNumber > 0 {
                switch alertType {
                case .timeout:
                    let pinglet = UxEventPinglet(eventType: .steptimeout)
                    await PingManager.shared.addPinglet(pinglet: pinglet, sessionNumber: sessionNumber)
                case .inactivityTimeout:
                    let pinglet = UxEventPinglet(eventType: .inactivitytimeout)
                    await PingManager.shared.addPinglet(pinglet: pinglet, sessionNumber: sessionNumber)
                }
            }
            await PingManager.shared.sendPinglets()
        }
    }
}
