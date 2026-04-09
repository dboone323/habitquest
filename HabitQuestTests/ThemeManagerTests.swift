import SwiftUI
import XCTest
@testable import HabitQuest

@MainActor
final class ThemeManagerTests: XCTestCase {
    var themeManager: ThemeManager!

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
        XCTAssertEqual(themeManager.colorScheme, .dark)

        // Set to light mode
        themeManager.isDarkMode = false
        XCTAssertEqual(themeManager.colorScheme, .light)
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
}
