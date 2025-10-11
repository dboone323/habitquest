import Foundation
import OSLog
import os

//
//  ThemePersistence.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

/// Handles persistent storage of theme preferences
enum ThemePersistence {
    private static let themePreferenceKey = "com.momentumfinance.themeMode"

    /// Save the theme preference to UserDefaults
    static func saveThemePreference(_ mode: ThemeMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: self.themePreferenceKey)
        os_log("Saved theme preference: %@", log: .default, type: .info, mode.rawValue)
    }

    /// Load the saved theme preference
    static func loadThemePreference() -> ThemeMode {
        let savedValue = UserDefaults.standard.string(forKey: self.themePreferenceKey)

        // If we have a saved value, try to create a ThemeMode from it
        if let savedValue,
           let mode = ThemeMode(rawValue: savedValue) {
            os_log("Loaded saved theme preference: %@", log: .default, type: .info, mode.rawValue)
            return mode
        }

        // Default to system theme if nothing saved
        let defaultMode = ThemeMode.system
        os_log(
            "No saved theme preference found, using default: %@", log: .default, type: .info,
            defaultMode.rawValue
        )
        return defaultMode
    }

    /// Clear the saved theme preference
    static func clearThemePreference() {
        UserDefaults.standard.removeObject(forKey: self.themePreferenceKey)
        os_log("Cleared theme preference", log: .default, type: .info)
    }
}
