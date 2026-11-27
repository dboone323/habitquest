//
// ThemeManager.swift
// HabitQuestCore
//

import Combine
import SwiftUI

/// Appearance mode options for the app theme.
public enum ThemeAppearanceMode: String, CaseIterable, Sendable, Identifiable {
    case system
    case light
    case dark

    public var id: String {
        rawValue
    }

    public var displayName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

/// Observable manager for persistent theme settings (System/Light/Dark mode).
@MainActor
public final class ThemeManager: ObservableObject, Sendable {
    public static let shared = ThemeManager()

    private static let isDarkModeKey = "isDarkMode"
    private static let appearanceModeKey = "themeAppearanceMode"

    @Published public var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: Self.isDarkModeKey)
            let expectedMode: ThemeAppearanceMode = isDarkMode ? .dark : .light
            if appearanceMode != expectedMode {
                appearanceMode = expectedMode
            }
        }
    }

    @Published public var appearanceMode: ThemeAppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: Self.appearanceModeKey)
            switch appearanceMode {
            case .light:
                if isDarkMode {
                    isDarkMode = false
                }
            case .dark:
                if !isDarkMode {
                    isDarkMode = true
                }
            case .system:
                break
            }
        }
    }

    public init() {
        let savedDarkMode = UserDefaults.standard.object(forKey: Self.isDarkModeKey) as? Bool ?? true
        self.isDarkMode = savedDarkMode
        if let rawMode = UserDefaults.standard.string(forKey: Self.appearanceModeKey),
           let mode = ThemeAppearanceMode(rawValue: rawMode)
        {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .system
        }
    }

    /// Whether the theme follows the system appearance.
    public var isSystem: Bool {
        appearanceMode == .system
    }

    /// Computes the SwiftUI color scheme based on the current mode.
    public var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    /// Preferred color scheme to apply at the app root (`nil` when following system).
    public var preferredColorScheme: ColorScheme? {
        isSystem ? nil : colorScheme
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
