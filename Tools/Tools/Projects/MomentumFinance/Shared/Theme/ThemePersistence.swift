import Foundation
import os
import OSLog

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
<<<<<<< HEAD
    // Uses static Logger methods directly
=======
    private static let logger = Logger()
>>>>>>> 1cf3938 (Create working state for recovery)

    /// Save the theme preference to UserDefaults
    static func saveThemePreference(_ mode: ThemeMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: themePreferenceKey)
        os_log("Saved theme preference: %@", log: .default, type: .info, mode.rawValue)
    }

    /// Load the saved theme preference
    static func loadThemePreference() -> ThemeMode {
        let savedValue = UserDefaults.standard.string(forKey: themePreferenceKey)

        // If we have a saved value, try to create a ThemeMode from it
        if let savedValue,
<<<<<<< HEAD
           let mode = ThemeMode(rawValue: savedValue) {
=======
           let mode = ThemeMode(rawValue: savedValue)
        {
>>>>>>> 1cf3938 (Create working state for recovery)
            os_log("Loaded saved theme preference: %@", log: .default, type: .info, mode.rawValue)
            return mode
        }

        // Default to system theme if nothing saved
        let defaultMode = ThemeMode.system
        os_log("No saved theme preference found, using default: %@", log: .default, type: .info, defaultMode.rawValue)
        return defaultMode
    }

    /// Clear the saved theme preference
    static func clearThemePreference() {
        UserDefaults.standard.removeObject(forKey: themePreferenceKey)
        os_log("Cleared theme preference", log: .default, type: .info)
    }
}
