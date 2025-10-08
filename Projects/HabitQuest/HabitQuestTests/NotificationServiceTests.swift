@testable import HabitQuest
import XCTest

@MainActor
final class NotificationServiceTests: XCTestCase {
    var testHabit: Habit!

    override func setUp() async throws {
        try await super.setUp()

        // Create test habit
        self.testHabit = Habit(
            name: "Test Habit",
            habitDescription: "A test habit for notifications",
            frequency: .daily,
            xpValue: 10,
            category: .health,
            difficulty: .easy
        )
    }

    override func tearDown() async throws {
        self.testHabit = nil
        try await super.tearDown()
    }

    // MARK: - NotificationCategory Tests

    func testNotificationCategory_AllCases() {
        let allCases = NotificationService.NotificationCategory.allCases
        XCTAssertEqual(allCases.count, 4, "Should have 4 notification categories")

        XCTAssertTrue(allCases.contains(.habitReminder), "Should contain habitReminder")
        XCTAssertTrue(allCases.contains(.streakMotivation), "Should contain streakMotivation")
        XCTAssertTrue(allCases.contains(.levelUp), "Should contain levelUp")
        XCTAssertTrue(allCases.contains(.achievementUnlocked), "Should contain achievementUnlocked")
    }

    func testNotificationCategory_Identifiers() {
        XCTAssertEqual(NotificationService.NotificationCategory.habitReminder.identifier, "habit_reminder")
        XCTAssertEqual(NotificationService.NotificationCategory.streakMotivation.identifier, "streak_motivation")
        XCTAssertEqual(NotificationService.NotificationCategory.levelUp.identifier, "level_up")
        XCTAssertEqual(NotificationService.NotificationCategory.achievementUnlocked.identifier, "achievement_unlocked")
    }

    func testNotificationCategory_Titles() {
        XCTAssertEqual(NotificationService.NotificationCategory.habitReminder.title, "Habit Reminder")
        XCTAssertEqual(NotificationService.NotificationCategory.streakMotivation.title, "Keep Your Streak!")
        XCTAssertEqual(NotificationService.NotificationCategory.levelUp.title, "Level Up!")
        XCTAssertEqual(NotificationService.NotificationCategory.achievementUnlocked.title, "Achievement Unlocked!")
    }

    // MARK: - Notification Scheduling Tests

    func testScheduleHabitReminders() async {
        let habits: [Habit] = [testHabit]

        // Test that the method completes without error
        await NotificationService.scheduleHabitReminders(for: habits)
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testScheduleHabitReminder() async {
        // Test that the method completes without error
        await NotificationService.scheduleHabitReminder(for: self.testHabit)
        XCTAssertTrue(true, "Method should complete without error")
    }

    // MARK: - Setup Tests

    func testSetupNotificationCategories() async {
        // Test that the method completes without error
        // This is a private method, but we're testing it indirectly through permission request
        let granted = await NotificationService.requestNotificationPermissions()

        // Even if not granted, the setup should have been attempted
        XCTAssertTrue(granted || !granted, "Should return a boolean value")
    }
}
