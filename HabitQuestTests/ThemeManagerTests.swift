
import HabitQuestCore

import SwiftUI
import XCTest
@testable import HabitQuest

@MainActor
final class ThemeManagerTests: XCTestCase {
    var themeManager: HabitQuestCore.ThemeManager!

    override func setUp() {
        super.setUp()
        themeManager = ThemeManager()
    }

    override func tearDown() {
        themeManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(themeManager)
        XCTAssertNotNil(themeManager.currentTheme)
    }

    // MARK: - Theme Toggle Tests

    func testToggleTheme() {
        let initialDarkMode = themeManager.isDarkMode

        themeManager.toggleTheme()

        XCTAssertNotEqual(themeManager.isDarkMode, initialDarkMode)
    }

    func testColorScheme() {
        // Set to dark mode
        themeManager.isDarkMode = true
        XCTAssertEqual(themeManager.colorScheme, ColorScheme.dark)

        // Set to light mode
        themeManager.isDarkMode = false
        XCTAssertEqual(themeManager.colorScheme, ColorScheme.light)
    }

    func testThemeColors() {
        let theme = themeManager.currentTheme

        XCTAssertEqual(theme.primaryColor, .blue)
        XCTAssertNotNil(theme.backgroundColor)
        XCTAssertNotNil(theme.textColor)
        XCTAssertNotNil(theme.secondaryTextColor)
    }

    func testIsDarkModePersistence() {
        // Since ThemeManager uses @AppStorage, we can test defaults behavior
        let initialDefaultsMode = UserDefaults.standard.bool(forKey: "isDarkMode")

        themeManager.isDarkMode.toggle()

        // Assert it changed
        XCTAssertNotEqual(UserDefaults.standard.bool(forKey: "isDarkMode"), initialDefaultsMode)

        // Reset state
        themeManager.isDarkMode = initialDefaultsMode
    }

    // MARK: - Issue #72: Appearance Mode & Preferred Color Scheme Tests

    func testAppearanceModeSystemLightDarkAndPersistence() {
        let defaults = UserDefaults.standard
        let originalMode = defaults.object(forKey: "themeAppearanceMode")
        let originalDark = defaults.object(forKey: "isDarkMode")
        defer {
            if let originalMode {
                defaults.set(originalMode, forKey: "themeAppearanceMode")
            } else {
                defaults.removeObject(forKey: "themeAppearanceMode")
            }
            if let originalDark {
                defaults.set(originalDark, forKey: "isDarkMode")
            } else {
                defaults.removeObject(forKey: "isDarkMode")
            }
        }

        themeManager.appearanceMode = .system
        XCTAssertTrue(themeManager.isSystem)
        XCTAssertNil(themeManager.preferredColorScheme)

        themeManager.appearanceMode = .light
        XCTAssertFalse(themeManager.isSystem)
        XCTAssertFalse(themeManager.isDarkMode)
        XCTAssertEqual(themeManager.colorScheme, .light)
        XCTAssertEqual(themeManager.preferredColorScheme, .light)

        let reloadedLight = ThemeManager()
        XCTAssertEqual(reloadedLight.appearanceMode, .light)
        XCTAssertEqual(reloadedLight.preferredColorScheme, .light)

        themeManager.appearanceMode = .dark
        XCTAssertFalse(themeManager.isSystem)
        XCTAssertTrue(themeManager.isDarkMode)
        XCTAssertEqual(themeManager.colorScheme, .dark)
        XCTAssertEqual(themeManager.preferredColorScheme, .dark)

        let reloadedDark = ThemeManager()
        XCTAssertEqual(reloadedDark.appearanceMode, .dark)
        XCTAssertEqual(reloadedDark.preferredColorScheme, .dark)
    }
}
