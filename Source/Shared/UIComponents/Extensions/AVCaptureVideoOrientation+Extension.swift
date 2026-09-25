//
//  AVCaptureVideoOrientation+Extension.swift
//  DocumentVerificationUX
//
//  Created by Jura Skrlec on 19.02.2025..
//

import AVFoundation

#if BLINKIDVERIFYUX
import BlinkIDVerify
#elseif BLINKIDUX
import BlinkID
#elseif BLINKCARDUX
import BlinkCard
#endif

extension AVCaptureVideoOrientation {
    public func toCameraFrameVideoOrientation() -> CameraFrameVideoOrientation {
        switch self {
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .landscapeLeft: return .landscapeLeft
            case .landscapeRight: return .landscapeRight
            @unknown default: return .portrait
        }
    }

    public static func fromCameraFrameVideoOrientation(_ orientation: CameraFrameVideoOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .landscapeLeft: return .landscapeLeft
            case .landscapeRight: return .landscapeRight
            @unknown default: return .portrait
        }
    }
}
