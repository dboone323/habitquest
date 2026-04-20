import Foundation
import UserNotifications
import HabitQuestCore

/// Legacy bridge for NotificationService.
/// Delegates to HabitNotificationService in HabitQuestCore.
class NotificationService {
    static let shared = NotificationService()
    private let coreService = HabitNotificationService.shared
    
    func requestAuthorization() async throws -> Bool {
        return try await coreService.requestAuthorization()
    }
    
    func scheduleNotification(for habit: HabitQuestCore.Habit) async {
        await coreService.scheduleSmartReminders(for: habit)
    }
    
    static func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}
