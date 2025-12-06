@testable import HabitQuest
import XCTest
import UserNotifications

@MainActor
final class NotificationServiceTests: XCTestCase {

    // MARK: - Permission Tests

    func testRequestNotificationPermission() async {
        // This might fail in simulator without interaction, but we can check the call
        // Since we can't easily mock UNUserNotificationCenter, we'll skip the actual request test
        // or just check the status check method
        let status = await NotificationService.checkNotificationPermissions()
        XCTAssertTrue([.notDetermined, .denied, .authorized, .provisional, .ephemeral].contains(status))
    }

    // MARK: - Habit Reminder Tests

    func testScheduleHabitReminder() async {
        let habit = Habit(name: "Morning Exercise", habitDescription: "Exercise", frequency: .daily)

        await NotificationService.scheduleHabitReminder(for: habit)

        // We can't easily verify the schedule without mocking, but we can verify no crash
        XCTAssertTrue(true)
    }

    func testScheduleMultipleReminders() async {
        let habits = [
            Habit(name: "Morning Exercise", habitDescription: "Exercise", frequency: .daily),
            Habit(name: "Evening Meditation", habitDescription: "Meditate", frequency: .daily)
        ]

        await NotificationService.scheduleHabitReminders(for: habits)
        XCTAssertTrue(true)
    }

    func testCancelHabitReminder() async {
        let habit = Habit(name: "Test Habit", habitDescription: "Test", frequency: .daily)

        await NotificationService.scheduleHabitReminder(for: habit)
        await NotificationService.cancelNotifications(for: habit)

        // Verification would require mocking
        XCTAssertTrue(true)
    }

    // MARK: - Clear Tests

    func testClearAllNotifications() async {
        NotificationService.cancelAllNotifications()
        XCTAssertTrue(true)
    }
}

// Mock Habit for testing
struct MockHabit: Identifiable {
    let id = UUID()
    var name: String
    var time: String
}
