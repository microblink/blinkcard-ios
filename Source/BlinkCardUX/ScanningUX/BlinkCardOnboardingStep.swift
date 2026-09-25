// Created by Toni Krešo on 13.02.2026.. 
// Copyright (c) 2026 Microblink Ltd. All rights reserved.

// ANY UNAUTHORIZED USE OR SALE, DUPLICATION, OR DISTRIBUTION 
// OF THIS PROGRAM OR ANY OF ITS PARTS, IN SOURCE OR BINARY FORMS, 
// WITH OR WITHOUT MODIFICATION, WITH THE PURPOSE OF ACQUIRING 
// UNLAWFUL MATERIAL OR ANY OTHER BENEFIT IS PROHIBITED! 
// THIS PROGRAM IS PROTECTED BY COPYRIGHT LAWS AND YOU MAY NOT 
// REVERSE ENGINEER, DECOMPILE, OR DISASSEMBLE IT.

import SwiftUI

enum BlinkCardOnboardingStep: Int, OnboardingStepProtocol {
    case cardNumber, allFieldsVisible, harshLight, keepStill
    
    var id: Int { rawValue }
    
    var image: Image {
        switch self {
        case .cardNumber:
            return Image.cardNumberImage
        case .allFieldsVisible:
            return Image.allCardFieldsVisibleImage
        case .harshLight:
            return Image.harshLightCardImage
        case .keepStill:
            return Image.keepCardStillImage
        }
    }
    
    var title: String {
        switch self {
        case .cardNumber:
            return "mb_blinkcard_help_screen_title1"
        case .allFieldsVisible:
            return "mb_blinkcard_help_screen_title2"
        case .harshLight:
            return "mb_blinkcard_help_screen_title3"
        case .keepStill:
            return "mb_blinkcard_help_screen_title4"
        }
    }
    
    var description: String {
        switch self {
        case .cardNumber:
            return "mb_blinkcard_help_screen_msg1"
        case .allFieldsVisible:
            return "mb_blinkcard_help_screen_msg2"
        case .harshLight:
            return "mb_blinkcard_help_screen_msg3"
        case .keepStill:
            return "mb_blinkcard_help_screen_msg4"
        }
    }
}
