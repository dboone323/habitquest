//
//  ColorTheme.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Observation
import SwiftUI
#if os(iOS)
<<<<<<< HEAD
import UIKit
#endif

/// ColorTheme provides a consistent color palette across the app with proper dark mode support
=======
    import UIKit
#endif

/// ColorTheme provides a consistent color palette across the app with proper dark mode support
/// 
/// This main coordinator delegates to focused component implementations:
/// - ColorDefinitions: Static color definitions for light and dark schemes
/// - ThemeEnums: Type definitions and mode enums
/// - ColorExtensions: Hex string initialization and utilities
/// - ColorThemePreview: Debug and development tools
>>>>>>> 1cf3938 (Create working state for recovery)
@Observable
@MainActor
final class ColorTheme {
    static let shared = ColorTheme()

    // MARK: - Theme Configuration

    /// The current theme mode
    private(set) var currentThemeMode: ThemeMode = .system

    /// Updates the theme mode
<<<<<<< HEAD
    /// <#Description#>
    /// - Returns: <#description#>
=======
>>>>>>> 1cf3938 (Create working state for recovery)
    func setThemeMode(_ mode: ThemeMode) {
        self.currentThemeMode = mode
    }

    /// Returns if the current effective color scheme is dark
    var isDarkMode: Bool {
        switch currentThemeMode {
        case .light:
            return false
        case .dark:
            return true
        case .system:
            #if os(iOS)
<<<<<<< HEAD
            return UITraitCollection.current.userInterfaceStyle == .dark
            #elseif os(macOS)
            return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            #else
            return false
=======
                return UITraitCollection.current.userInterfaceStyle == .dark
            #elseif os(macOS)
                return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            #else
                return false
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }
    }

<<<<<<< HEAD
    // MARK: - Semantic Colors

    // Background colors
    var background: Color {
        themeColor(light: .background(.light), dark: .background(.dark))
    }

    var secondaryBackground: Color {
        themeColor(light: .secondaryBackground(.light), dark: .secondaryBackground(.dark))
    }

    var groupedBackground: Color {
        themeColor(light: .groupedBackground(.light), dark: .groupedBackground(.dark))
    }

    var cardBackground: Color {
        themeColor(light: .cardBackground(.light), dark: .cardBackground(.dark))
=======
    // MARK: - Semantic Colors (Delegate to ColorDefinitions)

    // Background colors
    var background: Color {
        themeColor(light: ColorDefinitions.background(.light), dark: ColorDefinitions.background(.dark))
    }

    var secondaryBackground: Color {
        themeColor(light: ColorDefinitions.secondaryBackground(.light), dark: ColorDefinitions.secondaryBackground(.dark))
    }

    var groupedBackground: Color {
        themeColor(light: ColorDefinitions.groupedBackground(.light), dark: ColorDefinitions.groupedBackground(.dark))
    }

    var cardBackground: Color {
        themeColor(light: ColorDefinitions.cardBackground(.light), dark: ColorDefinitions.cardBackground(.dark))
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    // Text colors
    var primaryText: Color {
<<<<<<< HEAD
        themeColor(light: .text(.primary, .light), dark: .text(.primary, .dark))
    }

    var secondaryText: Color {
        themeColor(light: .text(.secondary, .light), dark: .text(.secondary, .dark))
    }

    var tertiaryText: Color {
        themeColor(light: .text(.tertiary, .light), dark: .text(.tertiary, .dark))
=======
        themeColor(light: ColorDefinitions.text(.primary, .light), dark: ColorDefinitions.text(.primary, .dark))
    }

    var secondaryText: Color {
        themeColor(light: ColorDefinitions.text(.secondary, .light), dark: ColorDefinitions.text(.secondary, .dark))
    }

    var tertiaryText: Color {
        themeColor(light: ColorDefinitions.text(.tertiary, .light), dark: ColorDefinitions.text(.tertiary, .dark))
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    // Accent colors
    var accentPrimary: Color {
<<<<<<< HEAD
        themeColor(light: .accent(.primary, .light), dark: .accent(.primary, .dark))
    }

    var accentSecondary: Color {
        themeColor(light: .accent(.secondary, .light), dark: .accent(.secondary, .dark))
=======
        themeColor(light: ColorDefinitions.accent(.primary, .light), dark: ColorDefinitions.accent(.primary, .dark))
    }

    var accentSecondary: Color {
        themeColor(light: ColorDefinitions.accent(.secondary, .light), dark: ColorDefinitions.accent(.secondary, .dark))
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    // Financial colors
    var income: Color {
<<<<<<< HEAD
        themeColor(light: .financial(.income, .light), dark: .financial(.income, .dark))
    }

    var expense: Color {
        themeColor(light: .financial(.expense, .light), dark: .financial(.expense, .dark))
    }

    var savings: Color {
        themeColor(light: .financial(.savings, .light), dark: .financial(.savings, .dark))
    }

    var warning: Color {
        themeColor(light: .financial(.warning, .light), dark: .financial(.warning, .dark))
    }

    var critical: Color {
        themeColor(light: .financial(.critical, .light), dark: .financial(.critical, .dark))
=======
        themeColor(light: ColorDefinitions.financial(.income, .light), dark: ColorDefinitions.financial(.income, .dark))
    }

    var expense: Color {
        themeColor(light: ColorDefinitions.financial(.expense, .light), dark: ColorDefinitions.financial(.expense, .dark))
    }

    var savings: Color {
        themeColor(light: ColorDefinitions.financial(.savings, .light), dark: ColorDefinitions.financial(.savings, .dark))
    }

    var warning: Color {
        themeColor(light: ColorDefinitions.financial(.warning, .light), dark: ColorDefinitions.financial(.warning, .dark))
    }

    var critical: Color {
        themeColor(light: ColorDefinitions.financial(.critical, .light), dark: ColorDefinitions.financial(.critical, .dark))
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    // Budget progress colors
    var budgetUnder: Color {
<<<<<<< HEAD
        themeColor(light: .budget(.under, .light), dark: .budget(.under, .dark))
    }

    var budgetNear: Color {
        themeColor(light: .budget(.near, .light), dark: .budget(.near, .dark))
    }

    var budgetOver: Color {
        themeColor(light: .budget(.over, .light), dark: .budget(.over, .dark))
=======
        themeColor(light: ColorDefinitions.budget(.under, .light), dark: ColorDefinitions.budget(.under, .dark))
    }

    var budgetNear: Color {
        themeColor(light: ColorDefinitions.budget(.near, .light), dark: ColorDefinitions.budget(.near, .dark))
    }

    var budgetOver: Color {
        themeColor(light: ColorDefinitions.budget(.over, .light), dark: ColorDefinitions.budget(.over, .dark))
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    // Category colors - used for visualizations and charts
    var categoryColors: [Color] {
<<<<<<< HEAD
        [
            Color(hex: "4285F4"), // Blue
            Color(hex: "EA4335"), // Red
            Color(hex: "FBBC05"), // Yellow
            Color(hex: "34A853"), // Green
            Color(hex: "AA46BE"), // Purple
            Color(hex: "26C6DA"), // Cyan
            Color(hex: "FB8C00"), // Orange
            Color(hex: "8D6E63"), // Brown
            Color(hex: "D81B60"), // Pink
            Color(hex: "5C6BC0"), // Indigo
            Color(hex: "607D8B"), // Blue Grey
            Color(hex: "C5E1A5") // Light Green
        ]
=======
        ColorDefinitions.categoryColors
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    // MARK: - Helper Methods

    /// Returns the appropriate color based on the current theme mode
    private func themeColor(light: Color, dark: Color) -> Color {
        switch currentThemeMode {
        case .light:
            return light
        case .dark:
            return dark
        case .system:
            #if os(iOS)
<<<<<<< HEAD
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
=======
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
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }
    }
}
<<<<<<< HEAD

// MARK: - Theme Mode

/// Represents the app's theme mode
enum ThemeMode: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light:
            "Light"
        case .dark:
            "Dark"
        case .system:
            "System"
        }
    }

    var icon: String {
        switch self {
        case .light:
            "sun.max.fill"
        case .dark:
            "moon.fill"
        case .system:
            "gearshape.fill"
        }
    }
}

// MARK: - Color Extensions

extension Color {
    // MARK: - Background Colors

    static func background(_ mode: ThemeScheme) -> Color {
        switch mode {
        case .light:
            Color(hex: "F9F9F9") // Very light grey
        case .dark:
            Color(hex: "121212") // Very dark grey
        }
    }

    static func secondaryBackground(_ mode: ThemeScheme) -> Color {
        switch mode {
        case .light:
            Color(hex: "F0F0F0") // Light grey
        case .dark:
            Color(hex: "1E1E1E") // Dark grey
        }
    }

    static func groupedBackground(_ mode: ThemeScheme) -> Color {
        switch mode {
        case .light:
            Color(hex: "EFEFF4") // iOS grouped background light
        case .dark:
            Color(hex: "1C1C1E") // iOS grouped background dark
        }
    }

    static func cardBackground(_ mode: ThemeScheme) -> Color {
        switch mode {
        case .light:
            Color.white
        case .dark:
            Color(hex: "2A2A2A") // Dark card background
        }
    }

    // MARK: - Text Colors

    static func text(_ level: TextLevel, _ mode: ThemeScheme) -> Color {
        switch (level, mode) {
        case (.primary, .light):
            Color(hex: "000000").opacity(0.87) // Black with 87% opacity
        case (.primary, .dark):
            Color(hex: "FFFFFF").opacity(0.87) // White with 87% opacity
        case (.secondary, .light):
            Color(hex: "000000").opacity(0.60) // Black with 60% opacity
        case (.secondary, .dark):
            Color(hex: "FFFFFF").opacity(0.60) // White with 60% opacity
        case (.tertiary, .light):
            Color(hex: "000000").opacity(0.38) // Black with 38% opacity
        case (.tertiary, .dark):
            Color(hex: "FFFFFF").opacity(0.38) // White with 38% opacity
        }
    }

    // MARK: - Accent Colors

    static func accent(_ level: AccentLevel, _ mode: ThemeScheme) -> Color {
        switch (level, mode) {
        case (.primary, .light), (.primary, .dark):
            Color(hex: "0073E6") // Blue accent that works in both themes

        case (.secondary, .light):
            Color(hex: "5E35B1") // Deep purple
        case (.secondary, .dark):
            Color(hex: "9575CD") // Light purple for dark mode
        }
    }

    // MARK: - Financial Colors

    static func financial(_ type: FinancialType, _ mode: ThemeScheme) -> Color {
        switch (type, mode) {
        case (.income, .light):
            Color(hex: "4CAF50") // Green
        case (.income, .dark):
            Color(hex: "81C784") // Lighter green for dark mode
        case (.expense, .light):
            Color(hex: "F44336") // Red
        case (.expense, .dark):
            Color(hex: "E57373") // Lighter red for dark mode
        case (.savings, .light):
            Color(hex: "2196F3") // Blue
        case (.savings, .dark):
            Color(hex: "64B5F6") // Lighter blue for dark mode
        case (.warning, .light):
            Color(hex: "FF9800") // Orange
        case (.warning, .dark):
            Color(hex: "FFB74D") // Lighter orange for dark mode
        case (.critical, .light):
            Color(hex: "D32F2F") // Deep red
        case (.critical, .dark):
            Color(hex: "EF5350") // Lighter deep red for dark mode
        }
    }

    // MARK: - Budget Colors

    static func budget(_ status: BudgetStatus, _ mode: ThemeScheme) -> Color {
        switch (status, mode) {
        case (.under, .light):
            Color(hex: "43A047") // Green
        case (.under, .dark):
            Color(hex: "66BB6A") // Lighter green for dark mode
        case (.near, .light):
            Color(hex: "FB8C00") // Orange
        case (.near, .dark):
            Color(hex: "FFA726") // Lighter orange for dark mode
        case (.over, .light):
            Color(hex: "E53935") // Red
        case (.over, .dark):
            Color(hex: "EF5350") // Lighter red for dark mode
        }
    }

    // MARK: - Hex Initializer

    /// Initialize a Color from a hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255,
            )
    }
}

// MARK: - Helper Enums

/// Theme scheme (light/dark)
enum ThemeScheme {
    case light
    case dark
}

/// Text emphasis levels
enum TextLevel {
    case primary
    case secondary
    case tertiary
}

/// Accent color levels
enum AccentLevel {
    case primary
    case secondary
}

/// Financial color types
enum FinancialType {
    case income
    case expense
    case savings
    case warning
    case critical
}

/// Budget status colors
enum BudgetStatus {
    case under
    case near
    case over
}

// MARK: - Preview Extensions

extension ColorTheme {
    static var preview: ColorTheme {
        let theme = ColorTheme()
        return theme
    }

    static var previewDark: ColorTheme {
        let theme = ColorTheme()
        theme.setThemeMode(.dark)
        return theme
    }
}

#if DEBUG
struct ColorThemePreview: View {
    @State private var theme = ColorTheme.shared
    @State private var selectedMode: ThemeMode = .system

    var body: some View {
        NavigationStack {
            List {
                Section("Theme Mode") {
                    Picker("Theme Mode", selection: $selectedMode) {
                        ForEach(ThemeMode.allCases) { mode in
                            Label(mode.displayName, systemImage: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedMode) { _, newValue in
                        theme.setThemeMode(newValue)
                    }
                }

                Section("Background Colors") {
                    colorRow("Background", color: theme.background)
                    colorRow("Secondary Background", color: theme.secondaryBackground)
                    colorRow("Grouped Background", color: theme.groupedBackground)
                    colorRow("Card Background", color: theme.cardBackground)
                }

                Section("Text Colors") {
                    colorRow("Primary Text", color: theme.primaryText)
                    colorRow("Secondary Text", color: theme.secondaryText)
                    colorRow("Tertiary Text", color: theme.tertiaryText)
                }

                Section("Accent Colors") {
                    colorRow("Primary Accent", color: theme.accentPrimary)
                    colorRow("Secondary Accent", color: theme.accentSecondary)
                }

                Section("Financial Colors") {
                    colorRow("Income", color: theme.income)
                    colorRow("Expense", color: theme.expense)
                    colorRow("Savings", color: theme.savings)
                    colorRow("Warning", color: theme.warning)
                    colorRow("Critical", color: theme.critical)
                }

                Section("Budget Colors") {
                    colorRow("Under Budget", color: theme.budgetUnder)
                    colorRow("Near Budget", color: theme.budgetNear)
                    colorRow("Over Budget", color: theme.budgetOver)
                }

                Section("Category Colors") {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(0 ..< theme.categoryColors.count, id: \.self) { index in
                                Circle()
                                    .fill(theme.categoryColors[index])
                                    .frame(width: 40, height: 40)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 60)
                }
            }
            .navigationTitle("Color Theme")
        }
    }

    private func colorRow(_ name: String, color: Color) -> some View {
        HStack {
            Text(name)
            Spacer()
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    ColorThemePreview()
}
#endif
=======
>>>>>>> 1cf3938 (Create working state for recovery)
