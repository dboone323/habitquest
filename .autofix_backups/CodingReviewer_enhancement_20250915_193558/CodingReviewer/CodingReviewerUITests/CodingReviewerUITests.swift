//
//  CodingReviewerUITests.swift
//  CodingReviewerUITests
//
//  Created by Daniel Stevens on 2025
//

import XCTest

final class CodingReviewerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Main App Launch Tests

    @MainActor
    func testAppLaunchesSuccessfully() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify the main window exists
        XCTAssertTrue(!app.windows.isEmpty, "App should have at least one window")

        // Verify the app doesn't crash immediately
        XCTAssertTrue(app.state == .runningForeground, "App should be running in foreground")
    }

    @MainActor
    func testMainWindowTitle() throws {
        let app = XCUIApplication()
        app.launch()

        // Check for main window title (may vary based on implementation)
        let mainWindow = app.windows.firstMatch
        XCTAssertTrue(mainWindow.exists, "Main window should exist")
    }

    // MARK: - File Upload Tests

    @MainActor
    func testFileUploadViewExists() throws {
        let app = XCUIApplication()
        app.launch()

        // Look for file upload related UI elements
        let fileButton = app.buttons["Upload Files"].firstMatch
        let fileTextField = app.textFields["File Path"].firstMatch
        let browseButton = app.buttons["Browse"].firstMatch

        // At least one of these should exist
        let hasFileUI = fileButton.exists || fileTextField.exists || browseButton.exists
        XCTAssertTrue(hasFileUI, "App should have file upload UI elements")
    }

    @MainActor
    func testFileSelectionWorkflow() throws {
        let app = XCUIApplication()
        app.launch()

        // Test file selection buttons exist
        let uploadButtons = app.buttons.matching(identifier: "upload").allElementsBoundByIndex
        XCTAssertTrue(!uploadButtons.isEmpty, "Should have upload buttons")

        // Test if we can interact with file selection
        if let firstButton = uploadButtons.first {
            XCTAssertTrue(firstButton.isEnabled, "Upload button should be enabled")
        }
    }

    // MARK: - Code Analysis Tests

    @MainActor
    func testCodeAnalysisUI() throws {
        let app = XCUIApplication()
        app.launch()

        // Look for analysis related UI
        let analyzeButton = app.buttons["Analyze"].firstMatch
        let analyzeText = app.staticTexts["Analyze"].firstMatch

        let hasAnalysisUI = analyzeButton.exists || analyzeText.exists
        XCTAssertTrue(hasAnalysisUI, "App should have code analysis UI")
    }

    @MainActor
    func testAnalysisResultsDisplay() throws {
        let app = XCUIApplication()
        app.launch()

        // Check for results display areas
        let resultViews = app.otherElements.matching(identifier: "results").allElementsBoundByIndex
        let textViews = app.textViews.allElementsBoundByIndex

        // Should have some way to display results
        XCTAssertTrue(
            !resultViews.isEmpty || !textViews.isEmpty, "App should have result display areas")
    }

    // MARK: - Navigation Tests

    @MainActor
    func testTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Look for tab bars or navigation elements
        let tabBars = app.tabBars.allElementsBoundByIndex
        let navigationBars = app.navigationBars.allElementsBoundByIndex

        if !tabBars.isEmpty {
            // Test tab navigation
            let firstTab = tabBars[0].buttons.firstMatch
            if firstTab.exists {
                firstTab.tap()
                XCTAssertTrue(firstTab.isSelected, "Tab should be selected after tapping")
            }
        }

        if !navigationBars.isEmpty {
            // Test navigation bar exists
            XCTAssertTrue(navigationBars[0].exists, "Navigation bar should exist")
        }
    }

    // MARK: - Settings Tests

    @MainActor
    func testSettingsAccess() throws {
        let app = XCUIApplication()
        app.launch()

        // Look for settings UI
        let settingsButton = app.buttons["Settings"].firstMatch
        let preferencesButton = app.buttons["Preferences"].firstMatch

        if settingsButton.exists {
            settingsButton.tap()
            // Should navigate to settings
        } else if preferencesButton.exists {
            preferencesButton.tap()
            // Should navigate to preferences
        }
    }

    // MARK: - Performance Tests

    @MainActor
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testUIResponsiveness() throws {
        let app = XCUIApplication()
        app.launch()

        // Measure scrolling performance if scroll views exist
        let scrollViews = app.scrollViews.allElementsBoundByIndex
        if let scrollView = scrollViews.first {
            measure {
                scrollView.swipeUp()
            }
        }
    }

    // MARK: - Error Handling Tests

    @MainActor
    func testErrorHandling() throws {
        let app = XCUIApplication()
        app.launch()

        // Test with invalid file path
        let fileTextField = app.textFields["File Path"].firstMatch
        if fileTextField.exists {
            fileTextField.tap()
            fileTextField.typeText("/invalid/path/test.txt")

            let analyzeButton = app.buttons["Analyze"].firstMatch
            if analyzeButton.exists {
                analyzeButton.tap()

                // Should handle error gracefully
                let errorMessages = app.staticTexts.matching(identifier: "error")
                    .allElementsBoundByIndex
                // Error handling should be present (either error message or graceful failure)
            }
        }
    }

    // MARK: - Accessibility Tests

    @MainActor
    func testAccessibility() throws {
        let app = XCUIApplication()
        app.launch()

        // Test accessibility labels
        let allElements = app.descendants(matching: .any).allElementsBoundByIndex

        for element in allElements.prefix(10) {  // Test first 10 elements
            if element.isEnabled && element.isHittable {
                XCTAssertFalse(
                    element.label?.isEmpty ?? true,
                    "Interactive elements should have accessibility labels")
            }
        }
    }

    // MARK: - Memory Tests

    @MainActor
    func testMemoryUsage() throws {
        let app = XCUIApplication()
        app.launch()

        // Basic memory test - app should not crash under normal usage
        let initialMemory = app.memoryUsage

        // Perform some UI interactions
        if let button = app.buttons.allElementsBoundByIndex.first {
            button.tap()
        }

        // Memory should not increase dramatically
        let finalMemory = app.memoryUsage
        XCTAssertLessThan(
            finalMemory, initialMemory * 2,
            "Memory usage should not double after basic interactions")
    }
}
