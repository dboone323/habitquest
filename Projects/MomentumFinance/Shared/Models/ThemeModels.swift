import Foundation
import SwiftUI

// MARK: - Theme Types

public enum ThemeMode: String, CaseIterable, Sendable {
    case light
    case dark
    case system

    public var displayName: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .system: "System"
        }
    }

    public var icon: String {
        switch self {
        case .light: "sun.max"
        case .dark: "moon"
        case .system: "gearshape"
        }
    }
}

public struct ColorDefinitions: Sendable {
    public static let primary = Color.blue
    public static let secondary = Color.gray
    public static let accent = Color.orange
    public static let error = Color.red
    public static let warning = Color.orange
    public static let success = Color.green
    public static let info = Color.blue

    // Functions to match the expected interface
    public static func background(_ mode: ThemeMode) -> Color {
        switch mode {
        case .light:
            Color.white
        case .dark:
            Color.black
        case .system:
            Color.primary.opacity(0.05)
        }
    }

    public static func surface(_ mode: ThemeMode) -> Color {
        switch mode {
        case .light:
            Color.gray.opacity(0.1)
        case .dark:
            Color.gray.opacity(0.2)
        case .system:
            Color.primary.opacity(0.1)
        }
    }

    public static func secondaryBackground(_ mode: ThemeMode) -> Color {
        switch mode {
        case .light:
            Color.gray.opacity(0.05)
        case .dark:
            Color.gray.opacity(0.15)
        case .system:
            Color.secondary.opacity(0.05)
        }
    }

    public static func groupedBackground(_ mode: ThemeMode) -> Color {
        switch mode {
        case .light:
            Color(red: 0.95, green: 0.95, blue: 0.97)
        case .dark:
            Color(red: 0.11, green: 0.11, blue: 0.12)
        case .system:
            Color.gray.opacity(0.03)
        }
    }

    public static func cardBackground(_ mode: ThemeMode) -> Color {
        switch mode {
        case .light:
            Color.white
        case .dark:
            Color(red: 0.17, green: 0.17, blue: 0.18)
        case .system:
            Color.primary.opacity(0.02)
        }
    }

    public static let categoryColors: [Color] = [
        Color.orange, // food
        Color.blue, // transport
        Color.purple, // entertainment
        Color.green, // shopping
        Color.red, // bills
        Color.mint, // income
        Color.teal, // savings
        Color.gray, // other
    ]

    // Additional methods for complex color system
    public static func text(_ type: TextType, _ mode: ThemeMode) -> Color {
        switch (type, mode) {
        case (.primary, .light):
            Color.black
        case (.primary, .dark):
            Color.white
        case (.secondary, _):
            Color.gray
        case (.tertiary, _):
            Color.gray.opacity(0.6)
        default:
            Color.primary
        }
    }

    public static func accent(_ type: AccentType, _: ThemeMode) -> Color {
        switch type {
        case .primary:
            Color.blue
        case .secondary:
            Color.orange
        }
    }

    public static func financial(_ type: FinancialType, _: ThemeMode) -> Color {
        switch type {
        case .income:
            Color.green
        case .expense:
            Color.red
        case .savings:
            Color.blue
        case .warning:
            Color.orange
        case .critical:
            Color.red
        }
    }

    public static func budget(_ type: BudgetType, _: ThemeMode) -> Color {
        switch type {
        case .under:
            Color.green
        case .near:
            Color.orange
        case .over:
            Color.red
        }
    }

    public init() {}
}

// Supporting enums for ColorDefinitions
public enum TextType: Sendable {
    case primary, secondary, tertiary
}

public enum AccentType: Sendable {
    case primary, secondary
}

public enum FinancialType: Sendable {
    case income, expense, savings, warning, critical
}

public enum BudgetType: Sendable {
    case under, near, over
}

// MARK: - Dark Mode Preference

public enum DarkModePreference: String, CaseIterable, Sendable {
    case light
    case dark
    case system

    public var displayName: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .system: "System"
        }
    }
}
