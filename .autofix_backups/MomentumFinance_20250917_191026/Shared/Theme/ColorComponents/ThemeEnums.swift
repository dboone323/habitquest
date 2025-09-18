//
//  ThemeEnums.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation

/// Type definitions and enums for theme system
public struct ThemeEnums {
    // This serves as a namespace for theme-related enums
}

// MARK: - Theme Mode

/// Represents the app's theme mode
public enum ThemeMode: String, CaseIterable, Identifiable, Hashable {
    case light
    case dark
    case system

    public var id: String { rawValue }

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

// MARK: - Theme Scheme

/// Theme scheme (light/dark)
public enum ThemeScheme {
    case light
    case dark
}

// MARK: - Text Levels

/// Text emphasis levels
public enum TextLevel {
    case primary
    case secondary
    case tertiary
}

// MARK: - Accent Levels

/// Accent color levels
public enum AccentLevel {
    case primary
    case secondary
}

// MARK: - Financial Types

/// Financial color types
public enum FinancialType {
    case income
    case expense
    case savings
    case warning
    case critical
}

// MARK: - Budget Status

/// Budget status colors
public enum BudgetStatus {
    case under
    case near
    case over
}
