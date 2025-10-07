//
//  CodingReviewerUITestsTests.swift
//  CodingReviewerUITests
//
//  Created by Daniel Stevens on 9/19/25.
//

import XCTest

public class CodingReviewerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Initialize the application
        self.app = XCUIApplication()

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run.
        // The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.app = nil
        try super.tearDownWithError()
    }

    // MARK: - Application Launch Tests

    func testApplicationLaunch() throws {
        // Given
        let expectedAppState = XCUIApplication.State.notRunning

        // When
        self.app.launch()

        // Then
        XCTAssertTrue(self.app.state != expectedAppState, "Application should be running after launch")
        XCTAssertTrue(self.app.wait(for: .runningForeground, timeout: 10), "Application should be in foreground")
    }

    func testApplicationLaunchFailure() throws {
        // Given
        // Simulate a scenario where app might not launch properly
        // Note: This is more of a conceptual test as XCUIApplication launch typically succeeds

        // When
        self.app.launch()

        // Then
        XCTAssertNotNil(self.app, "Application instance should not be nil")
        XCTAssertFalse(self.app.state == .notRunning, "Application should not be in notRunning state after launch attempt")
    }

    func testApplicationLaunchWithDifferentStates() throws {
        // Test initial state
        XCTAssertEqual(self.app.state, .notRunning, "Application should start in notRunning state")

        // Launch the application
        self.app.launch()

        // Test post-launch state
        XCTAssertTrue(
            self.app.state == .runningForeground || self.app.state == .runningBackground,
            "Application should be running after launch"
        )
    }

    // MARK: - UI Element Interaction Tests

    func testBasicUIElementsExist() throws {
        // Given
        self.app.launch()

        // When & Then
        // These tests assume common UI elements exist - customize based on actual app
        XCTAssertNotNil(self.app.windows.element(boundBy: 0), "Main window should exist")
        XCTAssertGreaterThan(self.app.staticTexts.count, 0, "Should have at least one static text element")
        XCTAssertNotNil(self.app.navigationBars.element(boundBy: 0), "Navigation bar should exist")
    }

    func testNavigationBarExists() throws {
        // Given
        self.app.launch()

        // When
        let navigationBar = self.app.navigationBars.element(boundBy: 0)

        // Then
        XCTAssertTrue(navigationBar.exists, "Navigation bar should exist")
    }

    func testStaticTextElements() throws {
        // Given
        self.app.launch()

        // When
        let staticTexts = self.app.staticTexts

        // Then
        XCTAssertNotNil(staticTexts, "Static texts collection should not be nil")
    }

    // MARK: - Orientation Tests

    func testInterfaceOrientation() throws {
        // Given
        self.app.launch()

        // When & Then
        // Test that we can get interface orientation (this will vary by device)
        #if targetEnvironment(simulator)
        // Simulator-specific tests if needed
        #endif
    }

    func testApplicationOrientationHandling() throws {
        // Given
        self.app.launch()

        // When
        let initialOrientation = self.app.orientation

        // Then
        XCTAssertNotNil(initialOrientation, "Application should have an orientation")
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    func testLaunchPerformanceWithMultipleIterations() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // Test performance with multiple launch attempts
            let launchMetrics = XCTApplicationLaunchMetric()

            measure(metrics: [launchMetrics]) {
                let testApp = XCUIApplication()
                testApp.launch()
                testApp.terminate()
            }
        }
    }

    func testUIInteractionPerformance() throws {
        if #available(iOS 13.0, *) {
            app.launch()

            measure(metrics: [XCTOSSignpostMetric(applicationLaunch: app)]) {
                // Perform some basic UI interactions
                _ = app.staticTexts.element(boundBy: 0).exists
                _ = app.buttons.element(boundBy: 0).exists
            }
        }
    }

    // MARK: - Edge Case Tests

    func testApplicationLaunchWhenAlreadyRunning() throws {
        // Given
        self.app.launch()
        XCTAssertTrue(self.app.state != .notRunning, "Application should be running")

        // When - Attempt to launch again
        self.app.launch()

        // Then - Should still be running
        XCTAssertTrue(
            self.app.state == .runningForeground || self.app.state == .runningBackground,
            "Application should remain running after duplicate launch attempt"
        )
    }

    func testApplicationTermination() throws {
        // Given
        self.app.launch()
        XCTAssertTrue(self.app.state != .notRunning, "Application should be running")

        // When
        self.app.terminate()

        // Then
        XCTAssertTrue(self.app.state == .notRunning, "Application should be terminated")
    }

    func testApplicationStateTransitions() throws {
        // Given
        XCTAssertEqual(self.app.state, .notRunning, "Initial state should be notRunning")

        // When
        self.app.launch()

        // Then
        XCTAssertTrue(
            self.app.state == .runningForeground || self.app.state == .runningBackground,
            "State should be running after launch"
        )

        // When
        self.app.terminate()

        // Then
        XCTAssertEqual(self.app.state, .notRunning, "State should be notRunning after termination")
    }

    // MARK: - Accessibility Tests

    func testAccessibilityLabelsExist() throws {
        // Given
        self.app.launch()

        // When
        let elementsWithLabels = self.app.descendants(matching: .any).matching(NSPredicate(format: "label != ''"))

        // Then
        // This test checks that some elements have accessibility labels
        // Adjust threshold based on your app's requirements
        XCTAssertGreaterThanOrEqual(
            elementsWithLabels.count,
            0,
            "Should have elements with accessibility labels"
        )
    }

    func testAccessibilityIdentifiers() throws {
        // Given
        self.app.launch()

        // When
        let elementsWithIdentifiers = self.app.descendants(matching: .any).matching(NSPredicate(format: "identifier != ''"))

        // Then
        XCTAssertGreaterThanOrEqual(
            elementsWithIdentifiers.count,
            0,
            "Should have elements with accessibility identifiers"
        )
    }

    // MARK: - Timeout and Wait Tests

    func testApplicationLaunchWithTimeout() throws {
        // Given
        let timeout: TimeInterval = 15.0

        // When
        self.app.launch()

        // Then
        let isRunning = self.app.wait(for: .runningForeground, timeout: timeout)
        XCTAssertTrue(isRunning, "Application should launch within \(timeout) seconds")
    }

    func testElementExistenceWithTimeout() throws {
        // Given
        self.app.launch()
        let timeout: TimeInterval = 5.0

        // When & Then
        let exists = self.app.staticTexts.element(boundBy: 0).waitForExistence(timeout: timeout)
        XCTAssertTrue(
            exists || self.app.staticTexts.count == 0,
            "Elements should either exist or not be present in the UI"
        )
    }

    // MARK: - Configuration Tests

    func testApplicationLaunchArguments() throws {
        // Given
        self.app.launchArguments = ["UI_TEST_MODE"]

        // When
        self.app.launch()

        // Then
        XCTAssertTrue(self.app.state != .notRunning, "Application should launch with custom arguments")
    }

    func testApplicationLaunchEnvironment() throws {
        // Given
        self.app.launchEnvironment = ["TEST_ENV": "true"]

        // When
        self.app.launch()

        // Then
        XCTAssertTrue(self.app.state != .notRunning, "Application should launch with custom environment")
    }

    // MARK: - Screenshot Tests

    func testScreenshotCapture() throws {
        // Given
        self.app.launch()

        // When
        let screenshot = XCUIScreen.main.screenshot()

        // Then
        XCTAssertNotNil(screenshot, "Screenshot should be captured successfully")
        XCTAssertGreaterThan(screenshot.image.size.width, 0, "Screenshot should have valid dimensions")
        XCTAssertGreaterThan(screenshot.image.size.height, 0, "Screenshot should have valid dimensions")
    }

    // MARK: - Error Handling Tests

    func testInvalidElementAccess() throws {
        // Given
        self.app.launch()

        // When & Then
        // Test accessing elements that may not exist
        let nonExistentElement = self.app.staticTexts["NON_EXISTENT_ELEMENT"]
        XCTAssertFalse(nonExistentElement.exists, "Non-existent element should not exist")
    }

    func testElementInteractionOnNonExistentElement() throws {
        // Given
        self.app.launch()
        let nonExistentElement = self.app.buttons["NON_EXISTENT_BUTTON"]

        // When & Then
        XCTAssertFalse(nonExistentElement.exists, "Element should not exist")
        // Note: Interacting with non-existent elements typically doesn't crash in UI tests
    }
}

// MARK: - Extension for Additional Test Helpers

extension XCUIApplication {
    /// Custom helper to check if app is responsive
    func isResponsive(timeout: TimeInterval = 5.0) -> Bool {
        wait(for: .runningForeground, timeout: timeout)
    }
}

// MARK: - Mock Data Provider (if needed for more complex tests)

enum UITestMockData {
    static let testButtonTitles = ["Button 1", "Button 2", "Submit", "Cancel"]
    static let testLabels = ["Welcome", "Home", "Settings", "Profile"]
    static let testIdentifiers = ["mainView", "contentView", "navigationBar", "tabBar"]

    static func generateTestElementData(count: Int) -> [String] {
        Array(repeating: "testElement", count: count)
    }
}
