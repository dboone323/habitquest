import Foundation
import SwiftUI

// Platform color helpers (now internal for cross-file use)
func platformBackgroundColor() -> Color {
    #if os(iOS)
    return Color(.systemBackground)
    #elseif os(macOS)
    return Color(nsColor: .windowBackgroundColor)
    #else
    return Color.white
    #endif
}

func platformGrayColor() -> Color {
    #if os(iOS)
    return Color(.systemGray6)
    #elseif os(macOS)
    return Color.gray.opacity(0.2)
    #else
    return Color.gray.opacity(0.2)
    #endif
}

func platformSecondaryGrayColor() -> Color {
    #if os(iOS)
    return Color(.systemGray5)
    #elseif os(macOS)
    return Color.gray.opacity(0.15)
    #else
    return Color.gray.opacity(0.15)
    #endif
}

public enum ThemeMode: String, CaseIterable, Identifiable, Hashable {
    case light, dark, system
    public var id: String { rawValue }
    var displayName: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .system: "System"
        }
    }

    var icon: String {
        switch self {
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        case .system: "gearshape.fill"
        }
    }
}

public enum DarkModePreference: String, CaseIterable {
    case system, light, dark
    var displayName: String { rawValue.capitalized }
}

public enum ThemeScheme { case light, dark }
public enum TextLevel { case primary, secondary, tertiary }
public enum AccentLevel { case primary, secondary }
public enum FinancialType { case income, expense, savings, warning, critical }
public enum BudgetStatus { case under, near, over }

enum ColorDefinitions {
    static func text(_ level: TextLevel, _ mode: ThemeScheme) -> Color {
        switch (level, mode) {
        case (.primary, .light): Color(hex: "000000").opacity(0.87)
        case (.primary, .dark): Color(hex: "FFFFFF").opacity(0.87)
        case (.secondary, .light): Color(hex: "000000").opacity(0.60)
        case (.secondary, .dark): Color(hex: "FFFFFF").opacity(0.60)
        case (.tertiary, .light): Color(hex: "000000").opacity(0.38)
        case (.tertiary, .dark): Color(hex: "FFFFFF").opacity(0.38)
        }
    }

    static func accent(_ level: AccentLevel, _ mode: ThemeScheme) -> Color {
        switch (level, mode) {
        case (.primary, _): Color(hex: "0073E6")
        case (.secondary, .light): Color(hex: "5E35B1")
        case (.secondary, .dark): Color(hex: "9575CD")
        }
    }

    static func financial(_ type: FinancialType, _ mode: ThemeScheme) -> Color {
        switch (type, mode) {
        case (.income, .light): Color(hex: "4CAF50")
        case (.income, .dark): Color(hex: "81C784")
        case (.expense, .light): Color(hex: "F44336")
        case (.expense, .dark): Color(hex: "E57373")
        case (.savings, .light): Color(hex: "2196F3")
        case (.savings, .dark): Color(hex: "64B5F6")
        case (.warning, .light): Color(hex: "FF9800")
        case (.warning, .dark): Color(hex: "FFB74D")
        case (.critical, .light): Color(hex: "D32F2F")
        case (.critical, .dark): Color(hex: "EF5350")
        }
    }

    static func budget(_ status: BudgetStatus, _ mode: ThemeScheme) -> Color {
        switch (status, mode) {
        case (.under, .light): Color(hex: "43A047")
        case (.under, .dark): Color(hex: "66BB6A")
        case (.near, .light): Color(hex: "FB8C00")
        case (.near, .dark): Color(hex: "FFA726")
        case (.over, .light): Color(hex: "E53935")
        case (.over, .dark): Color(hex: "EF5350")
        }
    }

    static var categoryColors: [Color] {
        [
            "4285F4", "EA4335", "FBBC05", "34A853", "AA46BE", "26C6DA", "FB8C00", "8D6E63",
            "D81B60", "5C6BC0", "607D8B", "C5E1A5",
        ].map { Color(hex: $0) }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
