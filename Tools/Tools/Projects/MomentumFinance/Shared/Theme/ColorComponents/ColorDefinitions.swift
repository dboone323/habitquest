//
//  ColorDefinitions.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// Static color definitions for light and dark theme schemes
enum ColorDefinitions {

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

    // MARK: - Category Colors (Chart Colors)

    static var categoryColors: [Color] {
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
            Color(hex: "C5E1A5"), // Light Green
        ]
    }
}
