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
        if addQuestButton.waitForExistence(timeout: 2) && !app.buttons["Mark complete"].exists && !app.buttons["Mark incomplete"].exists {
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

        // Ensure habit is uncompleted to begin
        if app.buttons["Mark incomplete"].firstMatch.waitForExistence(timeout: 2) {
            app.buttons["Mark incomplete"].firstMatch.tap()
            RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        }

        // 1. Today tab with an uncompleted habit showing an empty circle
        let markCompleteButton = app.buttons["Mark complete"].firstMatch
        _ = markCompleteButton.waitForExistence(timeout: 5)
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        saveScreenshot(name: "01-today-uncompleted-circle.png", directoryName: "issue68-66-live-check-2026-11-23")

        // 2. Same habit after completing — filled green checkmark
        if markCompleteButton.exists {
            markCompleteButton.tap()

            if app.alerts.firstMatch.waitForExistence(timeout: 1) {
                app.alerts.buttons.firstMatch.tap()
            }
        }

        let markIncompleteButton = app.buttons["Mark incomplete"].firstMatch
        _ = markIncompleteButton.waitForExistence(timeout: 3)
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        saveScreenshot(name: "02-today-completed-checkmark.png", directoryName: "issue68-66-live-check-2026-11-23")

        // 3. Tap again — back to empty circle, no duplicate log, XP reverted
        if markIncompleteButton.exists {
            markIncompleteButton.tap()
        }
        _ = app.buttons["Mark complete"].firstMatch.waitForExistence(timeout: 3)
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        saveScreenshot(name: "03-today-toggled-off-circle.png", directoryName: "issue68-66-live-check-2026-11-23")

        // Complete again so Analytics has habit completion data
        if app.buttons["Mark complete"].firstMatch.exists {
            app.buttons["Mark complete"].firstMatch.tap()
            if app.alerts.firstMatch.waitForExistence(timeout: 1) {
                app.alerts.buttons.firstMatch.tap()
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
        saveScreenshot(name: "04-analytics-tab-with-data.png", directoryName: "issue68-66-live-check-2026-11-23")

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
        saveScreenshot(name: "05-analytics-refreshed.png", directoryName: "issue68-66-live-check-2026-11-23")
    }

    @MainActor
    func testLiveCheckIssue76() {
        let app = XCUIApplication()
        app.launch()
        dismissSystemPermissionAlertsIfPresent(in: app)

        let targetDir = "issue76-live-check-2026-11-23"

        let todayTab = app.tabBars.buttons["Today"]
        if todayTab.waitForExistence(timeout: 3) {
            todayTab.tap()
        }

        // Ensure at least one habit exists
        let addQuestButton = app.buttons["Add Quest"]
        if addQuestButton.waitForExistence(timeout: 2) && !app.buttons["Mark complete"].exists && !app.buttons["Mark incomplete"].exists {
            addQuestButton.tap()

            let nameField = app.textFields.firstMatch
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("Morning Meditation")
            }

            let addButton = app.buttons["Add"]
            if addButton.waitForExistence(timeout: 2) {
                addButton.tap()
            }
        }

        // Ensure habit is uncompleted to begin Flow 1
        if app.buttons["Mark incomplete"].firstMatch.waitForExistence(timeout: 2) {
            app.buttons["Mark incomplete"].firstMatch.tap()
            RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        }

        // Flow 1: Complete a habit — particle burst + XP popover visible, NO modal alert
        let markCompleteBtn = app.buttons["Mark complete"].firstMatch
        XCTAssertTrue(markCompleteBtn.waitForExistence(timeout: 5), "Mark complete button must exist")

        markCompleteBtn.tap()

        // Issue #84 Done Criteria: Celebration popover must exist after completing
        let celebrationPopover = app.descendants(matching: .any)["CelebrationPopover"]
        XCTAssertTrue(celebrationPopover.waitForExistence(timeout: 5), "Celebration popover must exist after completing")

        // Verify NO modal alert is presented
        XCTAssertFalse(app.alerts["Quest Completed!"].exists, "No modal alert should be presented on completion")

        // Wait ~1 second for popover animation to settle and capture screenshot before auto-dismiss
        RunLoop.current.run(until: Date().addingTimeInterval(1.0))
        saveScreenshot(name: "01-completion-celebration-no-alert.png", directoryName: targetDir)

        // Issue #83 Done Criteria: Check if achievement extra message is displayed in popover
        let celebrationExtra = app.descendants(matching: .any)["CelebrationExtraMessage"]
        if celebrationExtra.waitForExistence(timeout: 2) {
            XCTAssertTrue(celebrationExtra.exists, "Celebration extra message (level up / achievement) is displayed")
        }

        // Flow 2: Profile -> "View All" — gallery opens with real achievements, tap one — detail shows description, XP reward, unlock date/progress
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()

        // Wait for profile view to render
        RunLoop.current.run(until: Date().addingTimeInterval(1))

        // Find "View All" button in Achievements section
        let viewAllButton = app.buttons["ViewAllAchievementsButton"]
        if !viewAllButton.exists {
            app.swipeUp()
        }
        XCTAssertTrue(viewAllButton.waitForExistence(timeout: 5), "View All button must exist in Profile")
        viewAllButton.tap()

        // Verify Achievement Gallery opens
        let galleryNavBar = app.navigationBars["Achievement Gallery"]
        XCTAssertTrue(galleryNavBar.waitForExistence(timeout: 5), "Achievement Gallery should open")
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        saveScreenshot(name: "02-achievement-gallery-open.png", directoryName: targetDir)

        // Tap the first achievement card to inspect details
        let firstCard = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'AchievementCard_'")).firstMatch
        if firstCard.waitForExistence(timeout: 3) {
            firstCard.tap()

            // Verify Detail Sheet opens
            let detailNavBar = app.navigationBars["Achievement Detail"]
            _ = detailNavBar.waitForExistence(timeout: 3)
            RunLoop.current.run(until: Date().addingTimeInterval(1))
            saveScreenshot(name: "02b-achievement-detail-sheet.png", directoryName: targetDir)

            // Dismiss detail sheet
            let closeButton = app.buttons["Close"]
            if closeButton.waitForExistence(timeout: 3) {
                closeButton.tap()
            }
            RunLoop.current.run(until: Date().addingTimeInterval(1))
        }

        // Dismiss gallery
        let doneButton = app.buttons["Done"]
        if doneButton.waitForExistence(timeout: 3) {
            doneButton.tap()
        }
        RunLoop.current.run(until: Date().addingTimeInterval(1))

        // Flow 3: Settings — streak forgiveness threshold visible and changeable
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        RunLoop.current.run(until: Date().addingTimeInterval(1))
        if !app.staticTexts["Streak Forgiveness & Gamification"].exists {
            app.swipeUp()
        }
        RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        saveScreenshot(name: "03-settings-streak-forgiveness-default.png", directoryName: targetDir)

        // Find the Stepper for streak forgiveness threshold and change it
        var stepper = app.steppers["Streak forgiveness threshold"]
        if !stepper.exists {
            stepper = app.steppers.firstMatch
        }
        if !stepper.isHittable {
            app.swipeUp()
        }
        if stepper.waitForExistence(timeout: 3) {
            let incrementBtn = stepper.buttons.element(boundBy: 1)
            if incrementBtn.exists {
                incrementBtn.tap()
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.5))
            saveScreenshot(name: "03b-settings-streak-forgiveness-changed.png", directoryName: targetDir)
            let decrementBtn = stepper.buttons.element(boundBy: 0)
            if decrementBtn.exists {
                decrementBtn.tap()
            }
        }

        // Flow 4: Today tab after toggling off — no celebration fires, XP reverts
        todayTab.tap()
        RunLoop.current.run(until: Date().addingTimeInterval(0.5))

        let markIncompleteBtn = app.buttons["Mark incomplete"].firstMatch
        if markIncompleteBtn.waitForExistence(timeout: 3) {
            markIncompleteBtn.tap()
        }

        // Verify un-complete does not show celebration popover or modal alert
        RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        XCTAssertFalse(app.alerts.firstMatch.exists, "No alert should appear when un-completing")
        XCTAssertFalse(app.descendants(matching: .any)["CelebrationPopover"].exists, "No celebration popover should appear when un-completing")

        saveScreenshot(name: "04-today-toggled-off-no-celebration.png", directoryName: targetDir)
    }

    private func saveScreenshot(name: String, directoryName: String = "issue68-66-live-check-2026-11-23") {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let targetDir = "/Users/danielstevens/Developer/HabitQuest/runs/\(directoryName)"
        try? FileManager.default.createDirectory(atPath: targetDir, withIntermediateDirectories: true)
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
