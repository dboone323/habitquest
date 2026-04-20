//
// ThemeManager.swift
// HabitQuestCore
//

import Combine
import SwiftUI

/// Observable manager for persistent theme settings (Dark/Light mode).
@MainActor
public final class ThemeManager: ObservableObject, Sendable {
    public static let shared = ThemeManager()
    
    @Published public var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    public init() {
        self.isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
    }

    /// Computes the SwiftUI color scheme based on the current mode.
    public var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    /// Toggles between dark and light modes.
    public func toggleTheme() {
        isDarkMode.toggle()
    }

    /// Provides the active theme configuration.
    public var currentTheme: HabitTheme {
        isDarkMode ? .dark : .light
    }
}

/// Represents a visual theme for the HabitQuest application.
public struct HabitTheme: Sendable {
    public let backgroundColor: Color
    public let primaryColor: Color
    public let textColor: Color
    public let secondaryTextColor: Color
    public let cardBackground: Color

    public static var dark: HabitTheme {
        HabitTheme(
            backgroundColor: Color(red: 0.05, green: 0.05, blue: 0.07),
            primaryColor: Color(red: 0.4, green: 0.6, blue: 1.0),
            textColor: .white,
            secondaryTextColor: Color(white: 0.7),
            cardBackground: Color(white: 0.12)
        )
    }

    public static var light: HabitTheme {
        HabitTheme(
            backgroundColor: Color(white: 0.98),
            primaryColor: Color.blue,
            textColor: .black,
            secondaryTextColor: Color(white: 0.4),
            cardBackground: .white
        )
    }
}
