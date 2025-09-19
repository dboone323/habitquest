import Observation
import os
import OSLog
import SwiftUI

//
//  ThemeManager.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

/// ThemeManager extends ColorTheme with persistence and dynamic typography
@MainActor
@Observable
final class ThemeManager {
    @MainActor static let shared = ThemeManager()
    private let theme = ColorTheme.shared

    // MARK: - Theme Preference Management

    /// Initialize with saved preferences
    private init() {
        // Load the saved theme preference on initialization
        let savedTheme = ThemePersistence.loadThemePreference()
        self.theme.setThemeMode(savedTheme)
        os_log(
            "Initialized ThemeManager with saved mode: %@", log: .default, type: .info,
            savedTheme.rawValue
        )
    }

    /// Updates the theme mode with persistence
    /// <#Description#>
    /// - Returns: <#description#>
    func setAndSaveThemeMode(_ mode: ThemeMode) {
        self.theme.setThemeMode(mode)
        // Save the theme preference
        ThemePersistence.saveThemePreference(mode)
        os_log("Theme mode changed and saved: %@", log: .default, type: .info, mode.rawValue)
    }

    /// Get the current theme mode
    var currentThemeMode: ThemeMode {
        self.theme.currentThemeMode
    }

    // MARK: - Dynamic Typography Support

    /// Standard font sizes with semantic meaning
    struct FontSizes {
        let title1: CGFloat = 28
        let title2: CGFloat = 22
        let title3: CGFloat = 20
        let headline: CGFloat = 17
        let body: CGFloat = 16
        let callout: CGFloat = 15
        let subheadline: CGFloat = 14
        let footnote: CGFloat = 13
        let caption1: CGFloat = 12
        let caption2: CGFloat = 11
    }

    /// Standard text styles that support Dynamic Type
    enum TextStyle {
        case largeTitle, title1, title2, title3
        case headline, subheadline
        case body, callout
        case footnote, caption1, caption2

        /// Get the corresponding SwiftUI Font
        var font: Font {
            switch self {
            case .largeTitle:
                .largeTitle
            case .title1:
                .title
            case .title2:
                .title2
            case .title3:
                .title3
            case .headline:
                .headline
            case .subheadline:
                .subheadline
            case .body:
                .body
            case .callout:
                .callout
            case .footnote:
                .footnote
            case .caption1:
                .caption
            case .caption2:
                .caption2
            }
        }
    }

    /// Font sizes with semantic meaning
    let fontSizes = FontSizes()

    /// Get a dynamic font with specified style
    /// <#Description#>
    /// - Returns: <#description#>
    func font(_ style: TextStyle, weight: Font.Weight = .regular, design: Font.Design = .default)
        -> Font {
        let baseFont = style.font

        // Apply weight modifier
        return baseFont.weight(weight)
    }

    /// Get a dynamic font with specific size
    /// <#Description#>
    /// - Returns: <#description#>
    func dynamicFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default)
        -> Font {
        Font.system(size: size, weight: weight, design: design)
    }

    /// Scale factor for dynamic type based on system settings
    var fontScaleFactor: CGFloat {
        #if os(iOS)
            return UIFontMetrics.default.scaledValue(for: 1.0)
        #else
            return 1.0 // Default for macOS
        #endif
    }

    // MARK: - Animation Support for Theme Changes

    /// The animation to use when switching themes
    var themeChangeAnimation: Animation {
        .easeInOut(duration: 0.3)
    }

    /// Apply theme change with animation
    /// <#Description#>
    /// - Returns: <#description#>
    func animateThemeChange(_ mode: ThemeMode) {
        withAnimation(self.themeChangeAnimation) {
            self.setAndSaveThemeMode(mode)
        }
    }
}
