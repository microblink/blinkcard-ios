// Created by Toni Krešo on 20.3.2025.. 
// Copyright (c) 2025 Microblink Ltd. All rights reserved.

// ANY UNAUTHORIZED USE OR SALE, DUPLICATION, OR DISTRIBUTION 
// OF THIS PROGRAM OR ANY OF ITS PARTS, IN SOURCE OR BINARY FORMS, 
// WITH OR WITHOUT MODIFICATION, WITH THE PURPOSE OF ACQUIRING 
// UNLAWFUL MATERIAL OR ANY OTHER BENEFIT IS PROHIBITED! 
// THIS PROGRAM IS PROTECTED BY COPYRIGHT LAWS AND YOU MAY NOT 
// REVERSE ENGINEER, DECOMPILE, OR DISASSEMBLE IT.

import AVFoundation
import Foundation
import Combine
import BlinkCard
import BlinkCardUX

@MainActor
public final class CustomScanningViewModel: ObservableObject {
  
    let camera: Camera = Camera()
    let analyzer: BlinkCardAnalyzer
    @Published var instructionText: String = "Scan the first side"
    @Published public var scanningResult: BlinkCardScanningResult?
    @Published public var roi: RegionOfInterest = RegionOfInterest()
    private var paused = false
    
    private var eventHandlingTask: Task<Void, Never>?
    
    public init(analyzer: BlinkCardAnalyzer) {
        self.analyzer = analyzer
        startEventHandling()
    }

    func pauseScanning() {
        Task {
            await analyzer.cancel()
        }
    }

    func setInstructionText(text: String) {
        instructionText = text
    }
    
    func closeButtonTapped() {
        pauseScanning()
        scanningResult = nil
    }
    
    // - MARK: Analyze
    public func analyze() async {
        Task {
            let result = await analyzer.result()
            switch result {
            case .completed(let scanningResult):
                self.scanningResult = scanningResult
            case .cancelled, .interrupted(_), .ended:
                break
            }
        }
        
        for await frame in await camera.sampleBuffer {
            await analyzer.analyze(image: CameraFrame(buffer: frame.buffer, roi: roi, orientation: camera.orientation.toCameraFrameVideoOrientation()))
        }
    }
    
    private func startEventHandling() {
        eventHandlingTask = Task {
            for await events in await analyzer.events.stream {
                if events.contains(.requestSecondSide) {
                    instructionText = "Scan the second side"
                } else if events.contains(.fieldIdentificationFailed) {
                    instructionText = "Field identification failed"
                } else if events.contains(.wrongSide) {
                    instructionText = "Wrong side"
                } else if events.contains(.imageReturnFailed) {
                    instructionText = "Image return failed"
                } else if events.contains(.tooClose) {
                    instructionText = "Too close"
                } else if events.contains(.tooFar) {
                    instructionText = "Too far"
                } else if events.contains(.tilt) {
                    instructionText = "Tilt"
                } else if events.contains(.tooCloseToEdge) {
                    instructionText = "Too close to edge"
                } else if events.contains(.notFullyVisible) {
                    instructionText = "Not fully visible"
                } else if events.contains(.blur) {
                    instructionText = "blur"
                }
            }
        }
    }
    
    func stopEventHandling() {
        eventHandlingTask?.cancel()
    }
}
