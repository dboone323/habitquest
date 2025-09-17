//
//  ColorTheme.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Observation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// ColorTheme provides a consistent color palette across the app with proper dark mode support
///
/// This main coordinator delegates to focused component implementations:
/// - ColorDefinitions: Static color definitions for light and dark schemes
/// - ThemeEnums: Type definitions and mode enums
/// - ColorExtensions: Hex string initialization and utilities
/// - ColorThemePreview: Debug and development tools
@Observable
@MainActor
final class ColorTheme {
    static let shared = ColorTheme()

    // MARK: - Theme Configuration

    /// The current theme mode
    private(set) var currentThemeMode: ThemeMode = .system

    /// Updates the theme mode
    func setThemeMode(_ mode: ThemeMode) {
        self.currentThemeMode = mode
    }

    /// Returns if the current effective color scheme is dark
    var isDarkMode: Bool {
        switch self.currentThemeMode {
        case .light:
            return false
        case .dark:
            return true
        case .system:
            #if os(iOS)
            return UITraitCollection.current.userInterfaceStyle == .dark
            #elseif os(macOS)
            return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            #else
            return false
            #endif
        }
    }

    // MARK: - Semantic Colors (Delegate to ColorDefinitions)

    // Background colors
    var background: Color {
        self.themeColor(light: ColorDefinitions.background(.light), dark: ColorDefinitions.background(.dark))
    }

    var secondaryBackground: Color {
        self.themeColor(light: ColorDefinitions.secondaryBackground(.light), dark: ColorDefinitions.secondaryBackground(.dark))
    }

    var groupedBackground: Color {
        self.themeColor(light: ColorDefinitions.groupedBackground(.light), dark: ColorDefinitions.groupedBackground(.dark))
    }

    var cardBackground: Color {
        self.themeColor(light: ColorDefinitions.cardBackground(.light), dark: ColorDefinitions.cardBackground(.dark))
    }

    var primaryBackground: Color {
        self.background
    }

    // Text colors
    var primaryText: Color {
        self.themeColor(light: ColorDefinitions.text(.primary, .light), dark: ColorDefinitions.text(.primary, .dark))
    }

    var secondaryText: Color {
        self.themeColor(light: ColorDefinitions.text(.secondary, .light), dark: ColorDefinitions.text(.secondary, .dark))
    }

    var tertiaryText: Color {
        self.themeColor(light: ColorDefinitions.text(.tertiary, .light), dark: ColorDefinitions.text(.tertiary, .dark))
    }

    // Accent colors
    var accentPrimary: Color {
        self.themeColor(light: ColorDefinitions.accent(.primary, .light), dark: ColorDefinitions.accent(.primary, .dark))
    }

    var accentSecondary: Color {
        self.themeColor(light: ColorDefinitions.accent(.secondary, .light), dark: ColorDefinitions.accent(.secondary, .dark))
    }

    // Financial colors
    var income: Color {
        self.themeColor(light: ColorDefinitions.financial(.income, .light), dark: ColorDefinitions.financial(.income, .dark))
    }

    var expense: Color {
        self.themeColor(light: ColorDefinitions.financial(.expense, .light), dark: ColorDefinitions.financial(.expense, .dark))
    }

    var savings: Color {
        self.themeColor(light: ColorDefinitions.financial(.savings, .light), dark: ColorDefinitions.financial(.savings, .dark))
    }

    var warning: Color {
        self.themeColor(light: ColorDefinitions.financial(.warning, .light), dark: ColorDefinitions.financial(.warning, .dark))
    }

    var critical: Color {
        self.themeColor(light: ColorDefinitions.financial(.critical, .light), dark: ColorDefinitions.financial(.critical, .dark))
    }

    // Budget progress colors
    var budgetUnder: Color {
        self.themeColor(light: ColorDefinitions.budget(.under, .light), dark: ColorDefinitions.budget(.under, .dark))
    }

    var budgetNear: Color {
        self.themeColor(light: ColorDefinitions.budget(.near, .light), dark: ColorDefinitions.budget(.near, .dark))
    }

    var budgetOver: Color {
        self.themeColor(light: ColorDefinitions.budget(.over, .light), dark: ColorDefinitions.budget(.over, .dark))
    }

    // Category colors - used for visualizations and charts
    var categoryColors: [Color] {
        ColorDefinitions.categoryColors
    }

    // MARK: - Helper Methods

    /// Returns the appropriate color based on the current theme mode
    private func themeColor(light: Color, dark: Color) -> Color {
        switch self.currentThemeMode {
        case .light:
            return light
        case .dark:
            return dark
        case .system:
            #if os(iOS)
            return Color(uiColor: UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    UIColor(dark)
                default:
                    UIColor(light)
                }
            })
            #else
            // On macOS, use system appearance
            return dark // Simplified for now - could be improved with NSAppearance detection
            #endif
        }
    }
}
