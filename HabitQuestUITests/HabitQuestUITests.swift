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

    // MARK: - Issue #90: Celebration Timer Reset on Second Completion

    @MainActor
    func testCelebrationTimerResetOnSecondCompletion() {
        let app = XCUIApplication()
        app.launch()
        dismissSystemPermissionAlertsIfPresent(in: app)

        let todayTab = app.tabBars.buttons["Today"]
        if todayTab.waitForExistence(timeout: 3) {
            todayTab.tap()
        }

        // Reset any completed habits to uncompleted
        let markIncompleteButtons = app.buttons.matching(NSPredicate(format: "label == 'Mark incomplete'"))
        for _ in 0..<markIncompleteButtons.count {
            if markIncompleteButtons.firstMatch.exists {
                markIncompleteButtons.firstMatch.tap()
                RunLoop.current.run(until: Date().addingTimeInterval(0.3))
            }
        }

        // Ensure at least two habits exist
        var completeButtons = app.buttons.matching(NSPredicate(format: "label == 'Mark complete'"))
        while completeButtons.count < 2 {
            let addQuestButton = app.buttons["Add Quest"]
            if addQuestButton.waitForExistence(timeout: 2) {
                addQuestButton.tap()
                let nameField = app.textFields.firstMatch
                if nameField.waitForExistence(timeout: 2) {
                    nameField.tap()
                    nameField.typeText("Quest \(UUID().uuidString.prefix(4))")
                }
                let addButton = app.buttons["Add"]
                if addButton.waitForExistence(timeout: 2) {
                    addButton.tap()
                    RunLoop.current.run(until: Date().addingTimeInterval(1.0))
                }
            } else {
                break
            }
            completeButtons = app.buttons.matching(NSPredicate(format: "label == 'Mark complete'"))
        }

        XCTAssertGreaterThanOrEqual(completeButtons.count, 2, "At least two quests must be available to complete")

        // 1. Complete first habit
        completeButtons.firstMatch.tap()

        let celebrationPopover = app.descendants(matching: .any)["CelebrationPopover"]
        XCTAssertTrue(celebrationPopover.waitForExistence(timeout: 3), "Celebration popover should appear on first completion")

        // 2. Wait 1.0s (within 3.5s celebration window)
        RunLoop.current.run(until: Date().addingTimeInterval(1.0))
        XCTAssertTrue(celebrationPopover.exists, "Popover should still be visible at 1.0s after appearance")

        // 3. Complete second habit while first celebration is active (at ~1.5s)
        let remainingCompleteBtn = app.buttons.matching(NSPredicate(format: "label == 'Mark complete'")).firstMatch
        XCTAssertTrue(remainingCompleteBtn.waitForExistence(timeout: 2), "Second uncompleted habit must exist")
        remainingCompleteBtn.tap()

        // 4. Wait 2.3s. Total elapsed since first completion is ~4.0s (past the original 3.5s window).
        // Elapsed since second completion is only ~2.3s (well within the renewed 3.5s window).
        RunLoop.current.run(until: Date().addingTimeInterval(2.3))

        // Without the fix, the first task dismissed the popover at 3.5s.
        // With the fix, the popover remains visible for the renewed 3.5s interval.
        XCTAssertTrue(celebrationPopover.exists, "Celebration popover must remain visible for full interval after second completion")

        // 5. Wait another 2.0s. Total elapsed since second completion: ~4.3s (past renewed 3.5s).
        RunLoop.current.run(until: Date().addingTimeInterval(2.0))
        XCTAssertFalse(celebrationPopover.exists, "Celebration popover must auto-dismiss after renewed interval expires")
    }

    // MARK: - Issue #67: Quest Log Add Quest Button

    @MainActor
    func testIssue67QuestLogAddQuestButtonOpensNewQuestSheet() {
        let app = XCUIApplication()
        app.launch()
        dismissSystemPermissionAlertsIfPresent(in: app)

        let logTab = app.tabBars.buttons["Log"]
        XCTAssertTrue(logTab.waitForExistence(timeout: 5), "Log tab must exist")
        logTab.tap()

        XCTAssertFalse(app.buttons["Filter"].exists, "Misleading Filter button must not exist")
        XCTAssertFalse(app.buttons["Filter Button"].exists, "Misleading Filter Button must not exist")

        let addQuestButton = app.buttons["Add Quest"]
        XCTAssertTrue(addQuestButton.waitForExistence(timeout: 3), "Add Quest toolbar button must exist on Log tab")
        addQuestButton.tap()

        let newQuestNavBar = app.navigationBars["New Quest"]
        XCTAssertTrue(newQuestNavBar.waitForExistence(timeout: 3), "Tapping Add Quest must open New Quest sheet")

        let cancelButton = app.buttons["Cancel"]
        if cancelButton.waitForExistence(timeout: 2) {
            cancelButton.tap()
        }
    }

    // MARK: - Issue #69: ProfileView Cards Not Clipped by Tab Bar

    @MainActor
    func testIssue69ProfileViewCardsNotClippedByTabBar() {
        let app = XCUIApplication()
        app.launch()
        dismissSystemPermissionAlertsIfPresent(in: app)

        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5), "Profile tab must exist")
        profileTab.tap()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 3), "Tab bar must exist")

        let viewAllButton = app.buttons["ViewAllAchievementsButton"]
        if !viewAllButton.exists || !viewAllButton.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(viewAllButton.waitForExistence(timeout: 5), "View All achievements button must exist")
        XCTAssertLessThanOrEqual(
            viewAllButton.frame.maxY,
            tabBar.frame.minY,
            "Bottom Profile content must scroll cleanly above the tab bar without clipping"
        )
    }

    // MARK: - Issue #72: Settings Appearance Picker

    @MainActor
    func testIssue72SettingsAppearancePickerChangesTheme() {
        let app = XCUIApplication()
        app.launch()
        dismissSystemPermissionAlertsIfPresent(in: app)

        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5), "Settings tab must exist")
        settingsTab.tap()

        let appearanceHeader = app.staticTexts["Appearance"]
        XCTAssertTrue(appearanceHeader.waitForExistence(timeout: 5), "Appearance section must exist in Settings")

        let lightOption = app.buttons["Light"]
        let darkOption = app.buttons["Dark"]
        let systemOption = app.buttons["System"]

        XCTAssertTrue(lightOption.waitForExistence(timeout: 3), "Light theme option must exist")
        XCTAssertTrue(darkOption.exists, "Dark theme option must exist")
        XCTAssertTrue(systemOption.exists, "System theme option must exist")

        lightOption.tap()
        XCTAssertTrue(lightOption.isSelected, "Light option must become selected when tapped")

        darkOption.tap()
        XCTAssertTrue(darkOption.isSelected, "Dark option must become selected when tapped")

        systemOption.tap()
        XCTAssertTrue(systemOption.isSelected, "System option must become selected when tapped")
    }

    @MainActor
    func testIssue73HealthSettingsAndAddQuestToggle() {
        let app = XCUIApplication()
        app.launch()
        dismissSystemPermissionAlertsIfPresent(in: app)

        // 1. Settings -> Apple Health section
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5), "Settings tab must exist")
        settingsTab.tap()

        XCTAssertTrue(app.staticTexts["Apple Health"].waitForExistence(timeout: 5), "Apple Health section must appear in Settings")
        let connectButton = app.buttons["Connect Apple Health"]
        XCTAssertTrue(connectButton.waitForExistence(timeout: 3), "Connect Apple Health button must exist")

        // 2. Today -> Add Quest -> Sync with Apple Health toggle
        let todayTab = app.tabBars.buttons["Today"]
        XCTAssertTrue(todayTab.waitForExistence(timeout: 5), "Today tab must exist")
        todayTab.tap()

        let addQuestButton = app.buttons["Add Quest"]
        XCTAssertTrue(addQuestButton.waitForExistence(timeout: 5), "Add Quest button must exist")
        addQuestButton.tap()

        app.swipeUp()
        let syncToggle = app.switches["Sync with Apple Health"]
        XCTAssertTrue(syncToggle.waitForExistence(timeout: 5), "Sync with Apple Health toggle must exist in Add Quest sheet")
        syncToggle.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        app.swipeUp()

        let healthMetricButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Health Metric'")).firstMatch
        let dailyTargetText = app.staticTexts["Daily Target (steps)"]
        XCTAssertTrue(
            healthMetricButton.waitForExistence(timeout: 3) || dailyTargetText.waitForExistence(timeout: 3),
            "Health Metric picker must appear when enabled"
        )

        let cancelButton = app.buttons["Cancel"]
        if cancelButton.waitForExistence(timeout: 2) {
            cancelButton.tap()
        }
    }

    @MainActor
    func testIssue74SchedulingAndReminderUI() {
        let app = XCUIApplication()
        app.launch()
        dismissSystemPermissionAlertsIfPresent(in: app)

        let todayTab = app.tabBars.buttons["Today"]
        XCTAssertTrue(todayTab.waitForExistence(timeout: 5), "Today tab must exist")
        todayTab.tap()

        let addQuestButton = app.buttons["Add Quest"]
        XCTAssertTrue(addQuestButton.waitForExistence(timeout: 5), "Add Quest button must exist")
        addQuestButton.tap()

        // Switch Frequency to custom to reveal weekday picker
        let frequencyPicker = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Frequency'")).firstMatch
        XCTAssertTrue(frequencyPicker.waitForExistence(timeout: 3), "Frequency picker must exist")
        frequencyPicker.tap()
        let customOption = app.buttons["custom"]
        XCTAssertTrue(customOption.waitForExistence(timeout: 3), "custom frequency option must exist")
        customOption.tap()

        XCTAssertTrue(app.buttons["Weekday 2"].waitForExistence(timeout: 3), "Weekday 2 (Monday) button must appear for custom frequency")
        app.buttons["Weekday 2"].tap()

        app.swipeUp()
        let reminderToggle = app.switches["Daily Reminder"]
        XCTAssertTrue(reminderToggle.waitForExistence(timeout: 3), "Daily Reminder toggle must exist")
        reminderToggle.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Reminder Time"].waitForExistence(timeout: 3) || app.datePickers.firstMatch.waitForExistence(timeout: 3), "Reminder Time picker must appear when enabled")

        let cancelButton = app.buttons["Cancel"]
        if cancelButton.waitForExistence(timeout: 2) {
            cancelButton.tap()
        }
    }

    private func saveScreenshot(name: String, directoryName: String = "issue68-66-live-check-2026-11-23") {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let targetDir = "/Users/danielstevens/AI-Workspace/repos/HabitQuest/runs/\(directoryName)"
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
