import XCTest

final class HabitQuestUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testScreenshot() {
        let app = XCUIApplication()
        app.launch()
        dismissSystemPermissionAlertsIfPresent(in: app)

        // Take a screenshot
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)

        XCTAssertNotNil(screenshot)
    }

    @MainActor
    func testLiveCheckIssue68And66() {
        let app = XCUIApplication()
        app.launch()

        let todayTab = app.tabBars.buttons["Today"]
        if todayTab.waitForExistence(timeout: 3) {
            todayTab.tap()
        }

        // If no habit is present, add one
        let addQuestButton = app.buttons["Add Quest"]
        if addQuestButton.waitForExistence(timeout: 2) {
            addQuestButton.tap()

            let nameField = app.textFields.firstMatch
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("Daily Meditation")
            }

            let addButton = app.buttons["Add"]
            if addButton.waitForExistence(timeout: 2) {
                addButton.tap()
            }
        }

        // 1. Today tab with an uncompleted habit showing an empty circle
        let markCompleteButton = app.buttons["Mark complete"].firstMatch
        _ = markCompleteButton.waitForExistence(timeout: 5)
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        saveScreenshot(name: "01-today-uncompleted-circle.png")

        // 2. Same habit after completing — filled green checkmark
        if markCompleteButton.exists {
            markCompleteButton.tap()

            let awesomeButton = app.alerts.buttons.firstMatch
            if awesomeButton.waitForExistence(timeout: 3) {
                awesomeButton.tap()
            }
        }

        let markIncompleteButton = app.buttons["Mark incomplete"].firstMatch
        _ = markIncompleteButton.waitForExistence(timeout: 3)
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        saveScreenshot(name: "02-today-completed-checkmark.png")

        // 3. Tap again — back to empty circle, no duplicate log, XP reverted
        if markIncompleteButton.exists {
            markIncompleteButton.tap()
        }
        _ = app.buttons["Mark complete"].firstMatch.waitForExistence(timeout: 3)
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        saveScreenshot(name: "03-today-toggled-off-circle.png")

        // Complete again so Analytics has habit completion data
        if app.buttons["Mark complete"].firstMatch.exists {
            app.buttons["Mark complete"].firstMatch.tap()
            let alertButton = app.alerts.buttons.firstMatch
            if alertButton.waitForExistence(timeout: 3) {
                alertButton.tap()
            }
        }

        // 4. Analytics tab open with habits present — real streak data renders
        let analyticsTab = app.tabBars.buttons["Analytics"]
        if analyticsTab.waitForExistence(timeout: 3) {
            analyticsTab.tap()
        }

        // Wait for analytics data to render
        _ = app.staticTexts["Streak Distribution"].waitForExistence(timeout: 5)
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        saveScreenshot(name: "04-analytics-tab-with-data.png")

        // 5. Tap Refresh — data refreshes, no error
        let directRefresh = app.buttons["Refresh"]
        if directRefresh.exists {
            directRefresh.tap()
        } else {
            let menuButton = app.buttons["ellipsis.circle"]
            if menuButton.waitForExistence(timeout: 2) {
                menuButton.tap()
                let menuRefresh = app.buttons["Refresh"]
                if menuRefresh.waitForExistence(timeout: 2) {
                    menuRefresh.tap()
                }
            }
        }
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        saveScreenshot(name: "05-analytics-refreshed.png")
    }

    private func saveScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let targetDir = "/Users/danielstevens/Developer/HabitQuest/runs/issue68-66-live-check-2026-11-23"
        let fileURL = URL(fileURLWithPath: targetDir).appendingPathComponent(name)
        try? screenshot.pngRepresentation.write(to: fileURL)
    }
}

extension XCTestCase {
    @MainActor
    func dismissSystemPermissionAlertsIfPresent(
        in app: XCUIApplication,
        timeout: TimeInterval = 3
    ) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let preferredButtons = [
            "Allow",
            "Allow While Using App",
            "Allow While Using the App",
            "Allow Once",
            "Allow Notifications",
            "Always Allow",
            "OK",
            "Continue",
        ]

        let interruptionToken = addUIInterruptionMonitor(withDescription: "System Permission Alert") { alert in
            Self.tapPreferredButton(in: alert, preferredButtons: preferredButtons)
        }
        defer {
            removeUIInterruptionMonitor(interruptionToken)
        }

        let deadline = Date().addingTimeInterval(timeout)
        var consecutiveNoAlertChecks = 0
        while Date() < deadline {
            if Self.handleAlert(in: app.alerts.firstMatch, preferredButtons: preferredButtons) {
                consecutiveNoAlertChecks = 0
                continue
            }

            if Self.handleAlert(in: springboard.alerts.firstMatch, preferredButtons: preferredButtons) {
                consecutiveNoAlertChecks = 0
                continue
            }

            app.tap()
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))

            if Self.handleAlert(in: springboard.alerts.firstMatch, preferredButtons: preferredButtons) {
                consecutiveNoAlertChecks = 0
                continue
            }

            consecutiveNoAlertChecks += 1
            if consecutiveNoAlertChecks >= 3 {
                break
            }
        }
    }

    @MainActor
    private static func handleAlert(
        in alert: XCUIElement,
        preferredButtons: [String]
    ) -> Bool {
        guard alert.exists else {
            return false
        }

        if tapPreferredButton(in: alert, preferredButtons: preferredButtons) {
            return true
        }

        let buttons = alert.buttons.allElementsBoundByIndex
        if buttons.count > 1 {
            buttons[1].tap()
            return true
        }

        if let first = buttons.first, first.exists {
            first.tap()
            return true
        }

        return false
    }

    @MainActor
    private static func tapPreferredButton(
        in alert: XCUIElement,
        preferredButtons: [String]
    ) -> Bool {
        for title in preferredButtons {
            let button = alert.buttons[title]
            if button.exists {
                button.tap()
                return true
            }
        }

        let allowMatch = alert.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Allow'")).firstMatch
        if allowMatch.exists {
            allowMatch.tap()
            return true
        }

        let approveMatch = alert.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'OK' OR label CONTAINS[c] 'Continue'")
        ).firstMatch
        if approveMatch.exists {
            approveMatch.tap()
            return true
        }

        return false
    }
}
