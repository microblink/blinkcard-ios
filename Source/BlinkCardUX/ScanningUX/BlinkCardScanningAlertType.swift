//  Created by Toni Kreso on 17.12.2025..
//  Copyright (c) Microblink. All rights reserved.
//  This code is provided for use as-is and may not be copied, modified, or redistributed.
//

import BlinkCard

/// Scanning alert type
public enum BlinkCardScanningAlertType: Int, Sendable, AlertTypeProtocol {
    public var id: Int { rawValue }
    
    /// Scanning session timed out due to scan not being finished in time.
    case timeout
    /// Scanning session timed out due to scan being inactive.
    case inactivityTimeout
    
    public var title: String {
        switch self {
        case .timeout, .inactivityTimeout:
            return "mb_blinkcard_recognition_timeout_dialog_title".localizedString
        }
    }
    
    public var description: String {
        switch self {
        case .timeout, .inactivityTimeout:
            return "mb_blinkcard_recognition_timeout_dialog_message".localizedString
        }
    }
    
    public var buttonTitle: String {
        switch self {
        case .timeout, .inactivityTimeout:
            return "mb_blinkcard_recognition_timeout_dialog_retry_button".localizedString
        }
    }
    
    public var pingletAlertType: UxEventPinglet.AlertType {
        switch self {
        case .timeout:
            return .steptimeout
        case .inactivityTimeout:
            return .inactivitytimeout
        }
    }
}
