//
//  BlinkCardTheme.swift
//  BlinkCardUX
//
//  Created by Toni Kreso on 17.12.2025..
//

import SwiftUI

public final class BlinkCardTheme: UXThemeProtocol {
    public static let shared = BlinkCardTheme()
    
    private init() {}
    
    // theme for tutorial alert
    // title
    public var alertTitleColor: Color = .mbPrimary
    public var alertTitleFont: Font = .headline
    // description
    public var alertDescriptionColor: Color = .primary
    public var alertDescriptionFont: Font = .footnote
    // button
    public var alertButtonColor: Color = .mbSecondary
    public var alertButtonFont: Font = .headline
    // background
    public var alertBackgroundColor: Color = .mbBackground
    
    // theme for onboarding sheet
    // title
    public var onboardingSheetTitleColor: Color = .mbPrimary
    public var onboardingSheetTitleFont: Font = .title2
    // description
    public var onboardingSheetDescriptionColor: Color = .primary
    public var onboardingSheetDescriptionFont: Font = .subheadline
    // navigation buttons
    public var onboardingSheetButtonColor: Color = .mbSecondary
    public var onboardingSheetButtonFont: Font = .headline
    // indicator
    public var onboardingSheetPageIndicatorColor: Color = .mbSecondary
    // background
    public var onboardingSheetBackgroundColor: Color = .mbBackground
    
    // reticle tooltip text
    public var reticleTooltipFont: Font = .callout
    
    // help button
    public var helpButtonForegroundColor: Color = .mbSecondary
    public var helpButtonBackgroundColor: Color = .mbHelpBackground
    
    // help button tooltip
    public var helpButtonTooltipForegroundColor: Color = .white
    public var helpButtonTooltipBackgroundColor: Color = .mbNeedHelpTooltipBackground
    
    // Toast
    public var toastBackgroundColor: Color = .mbToastBackground

    // MARK: - Custom localization

    /// A bundle from the host app containing translations that override the SDK's
    /// built-in strings.
    ///
    /// Provide the keys you want to override (e.g. `mb_back_instructions`) in your
    /// own `Localizable.xcstrings`/`.strings` file. For any key that is missing in
    /// this bundle, the SDK falls back to its built-in translation, so you only
    /// need to supply the strings you actually want to change.
    ///
    /// Example:
    /// ```swift
    /// BlinkCardTheme.shared.localizationBundle = .main
    /// ```
    public var localizationBundle: Bundle? {
        get { Bundle.customLocalizationBundle }
        set { Bundle.customLocalizationBundle = newValue }
    }

    /// Optional strings table name inside ``localizationBundle``.
    ///
    /// Leave `nil` to use the default `Localizable` table. Set this when your
    /// overrides live in a separate table (e.g. `"BlinkCard"` for `BlinkCard.strings`).
    public var localizationTableName: String? {
        get { Bundle.customLocalizationTable }
        set { Bundle.customLocalizationTable = newValue }
    }

    /// Forces the SDK's UI language regardless of the device's system settings,
    /// e.g. `"de"` or `"en-GB"`. The language must be present in the SDK's
    /// bundled translations (or in ``localizationBundle``); otherwise the SDK
    /// falls back to the system language. Right-to-left languages (Arabic,
    /// Hebrew, …) also flip the scanning UI's layout direction.
    ///
    /// Set to `nil` to follow the system language (the default). Configure this
    /// before presenting the scanning UI.
    public var language: String? {
        get { Bundle.languageOverride }
        set { Bundle.languageOverride = newValue }
    }
}
