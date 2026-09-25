//
//  DeviceLookup.swift
//  DocumentVerification
//
//  Created by Jura Skrlec on 06.12.2024..
//  Copyright (c) Microblink. All rights reserved.
//  This code is provided for use as-is and may not be copied, modified, or redistributed.
//

import AVFoundation
import Combine

/// An object that retrieves camera.
final class DeviceLookup {
    
    // Default to back camera as preferred
    private var preferredPosition: AVCaptureDevice.Position = .back
    
    var backCamera: AVCaptureDevice {
        get throws {
            
            if let tripleCamera = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
                return tripleCamera
            }
            
            if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)  {
                return backCamera
            }
            
            throw CameraError.videoDeviceUnavailable
        }
    }
    
    var frontCamera: AVCaptureDevice {
        get throws {
            if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                return frontCamera
            }
            throw CameraError.videoDeviceUnavailable
        }
    }
    
    /// Updates the preferred camera position
    func setPreferredPosition(_ position: AVCaptureDevice.Position) {
        preferredPosition = position
    }
}
