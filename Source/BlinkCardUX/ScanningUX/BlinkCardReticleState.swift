//  Created by Toni Kreso on 11.02.2026..
//  Copyright (c) Microblink. All rights reserved.
//  This code is provided for use as-is and may not be copied, modified, or redistributed.
//

public enum BlinkCardReticleState: ReticleStateProtocol {
    case first
    case second
    case detecting
    case flip
    case error(String)
    case inactive
    
    public static var initialState: BlinkCardReticleState {
        .first
    }
    
    public static var inactiveState: BlinkCardReticleState {
        .inactive
    }
    
    public var text: String? {
        switch self {
        case .first:
            return "mb_blinkcard_first_side_instructions"
        case .second:
            return "mb_blinkcard_other_side_instructions"
        case .flip:
            return "mb_blinkcard_scanning_wrong_side"
        case .error(let message):
            return message
        case .detecting, .inactive:
            return nil
        }
    }
    
    public var duration: Double {
        switch self {
        case .first, .second:
            2.0
        case .detecting:
            1.5
        case .error(_):
            3.0
        case .flip, .inactive:
            0.0
        }
    }
    
    public var shouldExpire: Bool {
        switch self {
        case .first, .second, .detecting, .inactive, .flip:
            return false
        case .error(_):
            return true
        }
    }
    
    public var canBeFallback: Bool {
        switch self {
        case .first, .second:
            return true
        case .flip, .inactive, .error(_), .detecting:
            return false
        }
    }
    
    public var isErrorState: Bool {
        switch self {
        case .error(_):
            return true
        default:
            return false
        }
    }
    
    public var reticleStateAppearance: ReticleStateAppearance {
        switch self {
        case .inactive, .flip:
            return .empty
        case .error(_):
            return .error
        case .detecting:
            return .detecting
        case .first, .second:
            return .spinning
        }
    }
}

