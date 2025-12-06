@testable import HabitQuest
import XCTest
import SwiftUI

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
        XCTAssertEqual(themeManager.currentTheme.name, "Default")
    }

    // MARK: - Theme Switching Tests

    func testSwitchTheme() {
        let initialThemeName = themeManager.currentTheme.name

        // Switch to dark theme
        themeManager.setTheme(.dark)

        XCTAssertNotEqual(themeManager.currentTheme.name, initialThemeName)
        XCTAssertEqual(themeManager.currentTheme.name, "Dark")
    }

    func testThemeColors() {
        let theme = Theme.sunset

        themeManager.setTheme(theme)

        XCTAssertEqual(themeManager.currentTheme.primaryColor, Theme.sunset.primaryColor)
        XCTAssertEqual(themeManager.currentTheme.secondaryColor, Theme.sunset.secondaryColor)
    }

    func testCustomTheme() {
        let customTheme = Theme(
            name: "Custom",
            primaryColor: .red,
            secondaryColor: .blue,
            accentColor: .yellow,
            backgroundColor: .white,
            secondaryBackgroundColor: .gray,
            textColor: .black,
            secondaryTextColor: .gray
        )

        themeManager.setTheme(customTheme)

        XCTAssertEqual(themeManager.currentTheme.name, "Custom")
        XCTAssertEqual(themeManager.currentTheme.primaryColor, .red)
    }
}
