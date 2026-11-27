import Foundation
import HabitQuestCore
import UserNotifications

/// Legacy bridge for NotificationService.
/// Delegates to HabitNotificationService in HabitQuestCore.
class NotificationService {
    static let shared = NotificationService()
    private let coreService = HabitNotificationService.shared

    func requestAuthorization() async throws -> Bool {
        try await coreService.requestAuthorization()
    }

    func scheduleNotification(for habit: HabitQuestCore.Habit) async {
        await coreService.scheduleSmartReminders(for: habit)
    }

    func scheduleLocationReminder(
        for habit: HabitQuestCore.Habit,
        locationName: String,
        latitude: Double,
        longitude: Double
    ) {
        LocationReminderManager.shared.requestAuthorization()
        let reminder = LocationReminder(
            habitId: habit.id,
            habitName: habit.name,
            latitude: latitude,
            longitude: longitude,
            locationName: locationName
        )
        LocationReminderManager.shared.addReminder(reminder)
    }

    static func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}
