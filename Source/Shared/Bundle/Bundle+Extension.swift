//
//  Bundle+Extension.swift
//  DocumentVerificationUX
//
//  Created by Jura Skrlec on 12.02.2025..
//

import Foundation

extension Bundle {
    static var frameworkBundle: Bundle {
#if SWIFT_PACKAGE
        return .module
#else
        return Bundle(for: Camera.self)
#endif
    }

    /// Host-app provided bundle containing translations that override the SDK's
    /// built-in strings. When set, localized lookups first search this bundle and
    /// fall back to `frameworkBundle` for any key that isn't found here.
    nonisolated(unsafe) static var customLocalizationBundle: Bundle?

    /// Optional `.strings`/`.stringsdict` table name to use inside
    /// `customLocalizationBundle`. Defaults to `nil` (the `Localizable` table).
    nonisolated(unsafe) static var customLocalizationTable: String?

    /// Language code (e.g. `"de"`, `"en-GB"`) that forces the SDK's UI language
    /// regardless of the device's system settings. Set to `nil` to follow the
    /// system language (the default behaviour).
    nonisolated(unsafe) static var languageOverride: String? {
        didSet { languageBundleCache.removeAll() }
    }

    /// Caches the resolved `.lproj` sub-bundles so we don't hit the filesystem on
    /// every string lookup. Cleared whenever `languageOverride` changes.
    nonisolated(unsafe) private static var languageBundleCache: [String: Bundle] = [:]

    /// Returns the `.lproj` sub-bundle of `base` for `languageOverride`, or `base`
    /// itself when there's no override or the language isn't compiled into `base`.
    static func localizationBundle(for base: Bundle) -> Bundle {
        guard let language = languageOverride else { return base }

        let key = "\(ObjectIdentifier(base).hashValue)|\(language)"
        if let cached = languageBundleCache[key] { return cached }

        guard let path = base.path(forResource: language, ofType: "lproj"),
              let languageBundle = Bundle(path: path) else {
            return base
        }

        languageBundleCache[key] = languageBundle
        return languageBundle
    }

    /// Character direction of the forced language, or `nil` when no override is
    /// active (in which case layout should follow the system).
    static var overrideCharacterDirection: Locale.LanguageDirection? {
        guard let language = languageOverride else { return nil }
        return Locale.Language(identifier: language).characterDirection
    }

    func localizedString(forKey key: String) -> String {
        self.localizedString(forKey: key, value: nil, table: nil)
    }
}

extension String {
    var localizedString: String {
        // Sentinel used to detect a missing key so we can fall back to the SDK bundle.
        let notFound = "\u{0}"

        if let customBundle = Bundle.customLocalizationBundle {
            let value = Bundle.localizationBundle(for: customBundle).localizedString(
                forKey: self,
                value: notFound,
                table: Bundle.customLocalizationTable
            )
            if value != notFound {
                return value
            }
        }

        return Bundle.localizationBundle(for: .frameworkBundle).localizedString(forKey: self)
    }
}
