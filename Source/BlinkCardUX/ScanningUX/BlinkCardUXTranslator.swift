//
//  BlinkCardUXTranslator.swift
//  BlinkCardUX
//
//  Created by Toni Kreso on 17.12.2025..
//

import BlinkCard

final class BlinkCardUXTranslator {
    
    private var backSideDispatched: Bool = false
    
    func translate(frameProcessResult: FrameProcessResult, scanningSettings: ScanningSettings) -> [BlinkCardUIEvent] {
        var events: [BlinkCardUIEvent] = []
        
        if frameProcessResult.processResult?.resultCompleteness.scanningStatus == .sideScanned && !backSideDispatched {
            backSideDispatched = true
            events.append(.requestSecondSide)
        }
        
        switch frameProcessResult.processResult?.inputImageAnalysisResult.processingStatus {
        case .scanningWrongSide:
            events.append(.wrongSide)
        case .fieldIdentificationFailed:
            events.append(.fieldIdentificationFailed)
        case .imagePreprocessingFailed:
            if frameProcessResult.processResult?.inputImageAnalysisResult.blurDetectionStatus == .detected &&
                scanningSettings.skipImagesWithBlur {
                events.append(.blur)
            }
        case .imageReturnFailed:
            events.append(.imageReturnFailed)
        default:
            break
        }
        
        switch frameProcessResult.processResult?.inputImageAnalysisResult.detectionStatus {
        case .cameraTooFar:
            events.append(.tooFar)
        case .cameraTooClose:
            events.append(.tooClose)
        case .cameraAngleTooSteep:
            events.append(.tilt)
        case .documentTooCloseToCameraEdge:
            events.append(.tooCloseToEdge)
        case .documentPartiallyVisible:
            events.append(.notFullyVisible)
        default: break
        }
        
        return events
    }
    
    func resetState() {
        backSideDispatched = false
    }
}
