//
//  MissingTypes.swift
//  MomentumFinance
//
//  Temporary file to resolve missing type definitions
//  These should eventually be moved to proper module files
//

import Foundation
import OSLog
import SwiftUI
import UserNotifications

// MARK: - Theme Types

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

/// Theme scheme (light/dark)
public enum ThemeScheme {
    case light
    case dark
}

/// Text emphasis levels
public enum TextLevel {
    case primary
    case secondary
    case tertiary
}

/// Accent color levels
public enum AccentLevel {
    case primary
    case secondary
}

/// Financial color types
public enum FinancialType {
    case income
    case expense
    case savings
    case warning
    case critical
}

/// Budget status colors
public enum BudgetStatus {
    case under
    case near
    case over
}

/// Static color definitions for light and dark theme schemes
enum ColorDefinitions {

    // MARK: - Text Colors

    static func text(_ level: TextLevel, _ mode: ThemeScheme) -> Color {
        switch (level, mode) {
        case (.primary, .light):
            Color(hex: "000000").opacity(0.87)
        case (.primary, .dark):
            Color(hex: "FFFFFF").opacity(0.87)
        case (.secondary, .light):
            Color(hex: "000000").opacity(0.60)
        case (.secondary, .dark):
            Color(hex: "FFFFFF").opacity(0.60)
        case (.tertiary, .light):
            Color(hex: "000000").opacity(0.38)
        case (.tertiary, .dark):
            Color(hex: "FFFFFF").opacity(0.38)
        }
    }

    // MARK: - Accent Colors

    static func accent(_ level: AccentLevel, _ mode: ThemeScheme) -> Color {
        switch (level, mode) {
        case (.primary, .light), (.primary, .dark):
            Color(hex: "0073E6")
        case (.secondary, .light):
            Color(hex: "5E35B1")
        case (.secondary, .dark):
            Color(hex: "9575CD")
        }
    }

    // MARK: - Financial Colors

    static func financial(_ type: FinancialType, _ mode: ThemeScheme) -> Color {
        switch (type, mode) {
        case (.income, .light):
            Color(hex: "4CAF50")
        case (.income, .dark):
            Color(hex: "81C784")
        case (.expense, .light):
            Color(hex: "F44336")
        case (.expense, .dark):
            Color(hex: "E57373")
        case (.savings, .light):
            Color(hex: "2196F3")
        case (.savings, .dark):
            Color(hex: "64B5F6")
        case (.warning, .light):
            Color(hex: "FF9800")
        case (.warning, .dark):
            Color(hex: "FFB74D")
        case (.critical, .light):
            Color(hex: "D32F2F")
        case (.critical, .dark):
            Color(hex: "EF5350")
        }
    }

    // MARK: - Budget Colors

    static func budget(_ status: BudgetStatus, _ mode: ThemeScheme) -> Color {
        switch (status, mode) {
        case (.under, .light):
            Color(hex: "43A047")
        case (.under, .dark):
            Color(hex: "66BB6A")
        case (.near, .light):
            Color(hex: "FB8C00")
        case (.near, .dark):
            Color(hex: "FFA726")
        case (.over, .light):
            Color(hex: "E53935")
        case (.over, .dark):
            Color(hex: "EF5350")
        }
    }

    // MARK: - Category Colors

    static var categoryColors: [Color] {
        [
            Color(hex: "4285F4"),
            Color(hex: "EA4335"),
            Color(hex: "FBBC05"),
            Color(hex: "34A853"),
            Color(hex: "AA46BE"),
            Color(hex: "26C6DA"),
            Color(hex: "FB8C00"),
            Color(hex: "8D6E63"),
            Color(hex: "D81B60"),
            Color(hex: "5C6BC0"),
            Color(hex: "607D8B"),
            Color(hex: "C5E1A5"),
        ]
    }
}

// MARK: - Transaction Filter Types

public enum TransactionFilter: String, CaseIterable {
    case all
    case income
    case expense
    case transfer
    case thisWeek
    case thisMonth
    case lastMonth
    case thisYear
    case custom

    var displayName: String {
        switch self {
        case .all: "All"
        case .income: "Income"
        case .expense: "Expenses"
        case .transfer: "Transfers"
        case .thisWeek: "This Week"
        case .thisMonth: "This Month"
        case .lastMonth: "Last Month"
        case .thisYear: "This Year"
        case .custom: "Custom"
        }
    }
}

// MARK: - Financial Insight Types

public struct FinancialInsight: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let priority: InsightPriority
    public let type: InsightType
    public let createdAt: Date
    public let actionUrl: String?

    public init(title: String, description: String, priority: InsightPriority, type: InsightType, actionUrl: String? = nil) {
        self.title = title
        self.description = description
        self.priority = priority
        self.type = type
        self.createdAt = Date()
        self.actionUrl = actionUrl
    }
}

public enum InsightPriority: String, CaseIterable {
    case low, medium, high, critical

    var displayName: String {
        rawValue.capitalized
    }
}

public enum InsightType: String, CaseIterable {
    case spending, budgeting, savings, investment, debt, general

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Notification Types

public struct ScheduledNotification: Identifiable {
    public let id = UUID()
    public let title: String
    public let body: String
    public let scheduledDate: Date
    public let category: String
    public let userInfo: [String: Any]

    public init(title: String, body: String, scheduledDate: Date, category: String, userInfo: [String: Any] = [:]) {
        self.title = title
        self.body = body
        self.scheduledDate = scheduledDate
        self.category = category
        self.userInfo = userInfo
    }
}

// MARK: - Data Import Types

public struct ImportResult {
    public let success: Bool
    public let itemsImported: Int
    public let errors: [String]
    public let warnings: [String]

    public init(success: Bool, itemsImported: Int, errors: [String] = [], warnings: [String] = []) {
        self.success = success
        self.itemsImported = itemsImported
        self.errors = errors
        self.warnings = warnings
    }
}

// MARK: - Color Extension

extension Color {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
