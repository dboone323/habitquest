@testable import HabitQuest
import XCTest
import SwiftUI

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
    
    func testDefaultTheme() {
        // Should have a default theme set
        XCTAssertFalse(themeManager.currentTheme.id.uuidString.isEmpty)
    }
    
    // MARK: - Theme Switching Tests
    
    func testSwitchTheme() {
        let initialTheme = themeManager.currentTheme
        
        // Create a new theme
        let newTheme = Theme(
            name: "Test Theme",
            primaryColor: .blue,
            secondaryColor: .green
        )
        
        themeManager.setTheme(newTheme)
        
        XCTAssertNotEqual(themeManager.currentTheme.id, initialTheme.id)
        XCTAssertEqual(themeManager.currentTheme.name, "Test Theme")
    }
    
    func testThemeColors() {
        let theme = Theme(
            name: "Color Test",
            primaryColor: .red,
            secondaryColor: .blue
        )
        
        themeManager.setTheme(theme)
        
        XCTAssertEqual(themeManager.currentTheme.primaryColor, .red)
        XCTAssertEqual(themeManager.currentTheme.secondaryColor, .blue)
    }
    
    // MARK: - Theme Persistence Tests
    
    func testThemePersistence() {
        let customTheme = Theme(
            name: "Persistent Theme",
            primaryColor: .purple,
            secondaryColor: .orange
        )
        
        themeManager.setTheme(customTheme)
        themeManager.saveCurrentTheme()
        
        // Create new instance to test persistence
        let newManager = ThemeManager()
        newManager.loadSavedTheme()
        
        XCTAssertEqual(newManager.currentTheme.name, "Persistent Theme")
    }
    
    // MARK: - System Theme Tests
    
    func testSystemThemeDetection() {
        #if os(iOS)
        // Test that theme manager can detect system light/dark mode
        let isDarkMode = themeManager.isSystemDarkMode()
        XCTAssertNotNil(isDarkMode)
        #endif
    }
    
    // MARK: - Theme Preview Tests
    
    func testThemePreviewGeneration() {
        let preview = themeManager.generatePreview(for: themeManager.currentTheme)
        XCTAssertNotNil(preview)
    }
    
    // MARK: - Custom Theme Tests
    
    func testCustomThemeCreation() {
        let customTheme = themeManager.createCustomTheme(
            name: "My Custom Theme",
            primary: .green,
            secondary: .yellow
        )
        
        XCTAssertEqual(customTheme.name, "My Custom Theme")
        XCTAssertEqual(customTheme.primaryColor, .green)
        XCTAssertEqual(customTheme.secondaryColor, .yellow)
    }
    
    func testAvailableThemes() {
        let themes = themeManager.availableThemes
        XCTAssertGreaterThan(themes.count, 0)
    }
    
    // MARK: - Theme Validation Tests
    
    func testThemeValidation() {
        let validTheme = Theme(
            name: "Valid",
            primaryColor: .blue,
            secondaryColor: .red
        )
        
        XCTAssertTrue(themeManager.isThemeValid(validTheme))
    }
}
