//
//  BlinkCardUXView.swift
//  BlinkCardUX
//
//  Created by Toni Kreso on 17.12.2025..
//

import SwiftUI

import BlinkCard

/// Main scanning view.
/// This view consists of `CameraView` and `Reticle`.
///
/// For `UIEvent` stream, and UX logic, see ``ScanningUXModel``.
public struct BlinkCardUXView: View, ScanningUXProtocol {
    typealias GenericContentView = AnyView
    typealias ScanResult = BlinkCardScanningResult
    typealias AlertType = BlinkCardScanningAlertType
    typealias UXModel = BlinkCardUXModel
    typealias EventType = BlinkCardUIEvent
    typealias ReticleStateMachineType = BlinkCardReticleStateMachine
    @ObservedObject var viewModel: BlinkCardUXModel

    var onboardingSteps: [any OnboardingStepProtocol] { Array(BlinkCardOnboardingStep.allCases) }
    
    let theme = BlinkCardTheme.shared
    
    public init(viewModel: BlinkCardUXModel) {
        self.viewModel = viewModel
    }
    
    var onboardingAlert: OnboardingAlertContent {
        OnboardingAlertContent(
            title: "mb_blinkcard_onboarding_dialog_title",
            description: "mb_blinkcard_onboarding_dialog_message",
            image: Image.scanNumberFirstImage
        )
    }

    public var body: some View {
        MainView(reticleStateMachine: viewModel.reticleStateMachine, isTorchOn: $viewModel.isTorchOn, showToast: $viewModel.isToastVisible, showSheet: $viewModel.showSheet, showLicenseErrorAlert: $viewModel.showLicenseErrorAlert, flashlightWarningMessage: "mb_blinkcard_flashlight_warning_message".localizedString)
    }
}
