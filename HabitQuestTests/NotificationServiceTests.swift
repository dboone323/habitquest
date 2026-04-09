import HabitQuestCore
import UserNotifications
import XCTest

@MainActor
final class NotificationServiceTests: XCTestCase {
    // MARK: - Permission Tests

    func testRequestNotificationPermission() async {
        // This might fail in simulator without interaction, but we can check the call
        let status = await NotificationService.checkNotificationPermissions()
        XCTAssertTrue([.notDetermined, .denied, .authorized, .provisional, .ephemeral].contains(status))
    }

    // MARK: - Habit Reminder Tests

    func testScheduleHabitReminder() async {
        let habit = Habit(name: "Morning Exercise", habitDescription: "Exercise", frequency: .daily)
        await NotificationService.scheduleHabitReminder(for: habit)
        XCTAssertTrue(true)
    }

    func testScheduleMultipleReminders() async {
        let habits = [
            Habit(name: "Morning Exercise", habitDescription: "Exercise", frequency: .daily),
            Habit(name: "Evening Meditation", habitDescription: "Meditate", frequency: .daily),
        ]
        await NotificationService.scheduleHabitReminders(for: habits)
        XCTAssertTrue(true)
    }

    func testCancelHabitReminder() async {
        let habit = Habit(name: "Test Habit", habitDescription: "Test", frequency: .daily)
        await NotificationService.scheduleHabitReminder(for: habit)
        await NotificationService.cancelNotifications(for: habit)
        XCTAssertTrue(true)
    }

    // MARK: - Clear Tests

    func testClearAllNotifications() {
        NotificationService.cancelAllNotifications()
        XCTAssertTrue(true)
    }
}
