import SwiftUI
import Combine

/// Theme manager for HabitQuest
/// Provides centralized theme management with support for multiple themes
public class ThemeManager: ObservableObject {
    @Published public var currentTheme: Theme
    
    public init(theme: Theme = .default) {
        self.currentTheme = theme
    }
    
    /// Switch to a different theme
    public func setTheme(_ theme: Theme) {
        withAnimation(.easeInOut) {
            currentTheme = theme
        }
    }
}

/// Theme definition for HabitQuest
public struct Theme {
    public let name: String
    public let primaryColor: Color
    public let secondaryColor: Color
    public let accentColor: Color
    public let backgroundColor: Color
    public let secondaryBackgroundColor: Color
    public let textColor: Color
    public let secondaryTextColor: Color
    
    /// Default light theme
    public static let `default` = Theme(
        name: "Default",
        primaryColor: .blue,
        secondaryColor: .cyan,
        accentColor: .green,
        backgroundColor: Color(white: 0.98),
        secondaryBackgroundColor: .white,
        textColor: .black,
        secondaryTextColor: .gray
    )
    
    /// Dark theme
    public static let dark = Theme(
        name: "Dark",
        primaryColor: Color(hex: "64B5F6"),
        secondaryColor: Color(hex: "4FC3F7"),
        accentColor: Color(hex: "81C784"),
        backgroundColor: Color(white: 0.1),
        secondaryBackgroundColor: Color(white: 0.15),
        textColor: .white,
        secondaryTextColor: Color(white: 0.7)
    )
    
    /// Sunset theme
    public static let sunset = Theme(
        name: "Sunset",
        primaryColor: Color(hex: "FF7043"),
        secondaryColor: Color(hex: "FFAB91"),
        accentColor: Color(hex: "FFD54F"),
        backgroundColor: Color(hex: "FFF3E0"),
        secondaryBackgroundColor: .white,
        textColor: Color(hex: "3E2723"),
        secondaryTextColor: Color(hex: "6D4C41")
    )
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize Color from hex string
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
