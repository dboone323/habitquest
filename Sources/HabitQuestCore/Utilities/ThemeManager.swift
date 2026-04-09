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
}
