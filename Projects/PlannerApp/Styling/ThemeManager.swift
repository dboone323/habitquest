// PlannerApp/Styling/ThemeManager.swift

import Combine
import Foundation
import SwiftUI

// Include Theme from the same Styling directory
// Include AppSettingKeys from Utilities directory

// Removed @MainActor since Theme properties are no longer main actor isolated
public class ThemeManager: ObservableObject {
    // Published property holding the currently active theme. Views observe this.
    // Initialize by finding the theme matching the name currently stored in UserDefaults.
    @Published var currentTheme: Theme

    // Public property to allow external access to current theme name for UI binding
    public var currentThemeName: String = Theme.defaultTheme.name {
        didSet {
            self.updateCurrentTheme()
        }
    }

    private var isTesting: Bool

    init(testing: Bool = false) {
        self.isTesting = testing

        if testing {
            // In testing mode, use default theme without accessing UserDefaults
            self.currentTheme = Theme.defaultTheme
            print("ThemeManager initialized in testing mode. Current theme: \(self.currentTheme.name)")
        } else {
            // Initialize with the current theme from UserDefaults
            let savedThemeName = UserDefaults.standard.string(forKey: AppSettingKeys.themeColorName)
            self.currentTheme = Theme.availableThemes.first {
                $0.name == savedThemeName
            } ?? Theme.defaultTheme

            // Set the currentThemeName to match the loaded theme (this will trigger didSet)
            self.currentThemeName = self.currentTheme.name

            print("ThemeManager initialized. Current theme loaded: \(self.currentTheme.name)")
        }
    }

    // Finds the Theme struct corresponding to the name stored in `currentThemeName`
    // and updates the `currentTheme` published property if it has changed.
    private func updateCurrentTheme() {
        // Find the theme matching the name stored in `currentThemeName`.
        let newTheme = Theme.availableThemes.first { $0.name == self.currentThemeName } ?? Theme.defaultTheme

        // Only update the published property if the theme actually changed.
        // This prevents unnecessary UI refreshes if the picker selects the current theme again.
        if newTheme != self.currentTheme {
            self.currentTheme = newTheme
            print("Theme updated to: \(self.currentTheme.name)") // For debugging
        }
    }

    // Static computed property to easily get the names of available themes,
    // useful for populating Pickers in the UI.
    static var availableThemeNames: [String] {
        Theme.availableThemes.map(\.name)
    }

    // Manually set a theme (used by ThemePreviewView)
    func setTheme(_ theme: Theme) {
        self.currentThemeName = theme.name
        // The didSet observer will trigger updateCurrentTheme automatically
    }
}

// MARK: - Object Pooling (Removed - unused and causing concurrency issues)

// Object pooling was removed as it was unused and caused concurrency-safety issues
// with Swift 6's stricter concurrency checking.
