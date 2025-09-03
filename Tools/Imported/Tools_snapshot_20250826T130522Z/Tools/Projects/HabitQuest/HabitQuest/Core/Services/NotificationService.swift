import Foundation
import SwiftData
@preconcurrency import UserNotifications

/// Service for managing push notifications and habit reminders
/// Handles notification scheduling, permission requests, and reminder management
struct NotificationService {
    private static let logger = Logger(category: .general)

    /// Notification categories for different types of reminders
    enum NotificationCategory: String, CaseIterable {
        case habitReminder = "habit_reminder"
        case streakMotivation = "streak_motivation"
        case levelUp = "level_up"
        case achievementUnlocked = "achievement_unlocked"

        var identifier: String { rawValue }

        var title: String {
            switch self {
            case .habitReminder: return "Habit Reminder"
            case .streakMotivation: return "Keep Your Streak!"
            case .levelUp: return "Level Up!"
            case .achievementUnlocked: return "Achievement Unlocked!"
            }
        }
    }

    /// Request notification permissions from the user
    static func requestNotificationPermissions() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])

            if granted {
                await setupNotificationCategories()
                logger.info("Notification permissions granted")
            } else {
                logger.warning("Notification permissions denied")
            }

            return granted
        } catch {
            logger.error("Failed to request notification permissions: \(error)")
            return false
        }
    }

    /// Check current notification permission status
    static func checkNotificationPermissions() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    /// Schedule daily reminders for all active habits
    static func scheduleHabitReminders(for habits: [Habit]) async {
        let center = UNUserNotificationCenter.current()

        // Remove existing habit reminders
        let existingIdentifiers = await center.pendingNotificationRequests()
            .filter { $0.content.categoryIdentifier == NotificationCategory.habitReminder.identifier }
            .map { $0.identifier }

        center.removePendingNotificationRequests(withIdentifiers: existingIdentifiers)

        // Schedule new reminders
        for habit in habits {
            await scheduleHabitReminder(for: habit)
        }

        logger.info(
            "Scheduled reminders for \(habits.count) habits"
        )
    }

    /// Schedule a reminder for a specific habit
    static func scheduleHabitReminder(for habit: Habit) async {
        let center = UNUserNotificationCenter.current()

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for your quest!"
        content.body = "Don't forget to complete: \(habit.name)"
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.habitReminder.identifier
        content.userInfo = [
            "habitId": habit.id.uuidString,
            "habitName": habit.name
        ]

        // Schedule based on habit frequency
        let triggers = createNotificationTriggers(for: habit)

        for (index, trigger) in triggers.enumerated() {
            let identifier = "habit_\(habit.id.uuidString)_\(index)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            do {
                try await center.add(request)
                logger.debug("Scheduled reminder for habit: \(habit.name)")
            } catch {
                logger.error("Failed to schedule reminder for \(habit.name): \(error)")
            }
        }
    }

    /// Create appropriate notification triggers based on habit frequency
    private static func createNotificationTriggers(for habit: Habit) -> [UNNotificationTrigger] {
        var triggers: [UNNotificationTrigger] = []

        switch habit.frequency {
        case .daily:
            // Schedule for 9 AM every day
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            triggers.append(trigger)

            // Optional evening reminder at 6 PM
            var eveningComponents = DateComponents()
            eveningComponents.hour = 18
            eveningComponents.minute = 0

            let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: eveningComponents, repeats: true)
            triggers.append(eveningTrigger)

        case .weekly:
            // Schedule for Monday at 9 AM
            var dateComponents = DateComponents()
            dateComponents.weekday = 2 // Monday
            dateComponents.hour = 9
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            triggers.append(trigger)

        case .custom:
            // For custom frequency, schedule daily at 9 AM by default
            // This could be enhanced to support custom scheduling patterns
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            triggers.append(trigger)
        }

        return triggers
    }

    /// Send immediate notification for achievements and level ups
    static func sendImmediateNotification(
        category: NotificationCategory,
        title: String,
        body: String,
        userInfo: [String: Any] = [:]
    ) async {
        guard await checkNotificationPermissions() == .authorized else {
            logger.warning("Cannot send immediate notification - permissions not granted")
            return
        }

        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category.identifier
        content.userInfo = userInfo

        // Send immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "\(category.rawValue)_\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
            logger.info("Sent immediate notification: \(title)")
        } catch {
            logger.error("Failed to send immediate notification: \(error)")
        }
    }

    /// Schedule streak motivation reminders
    static func scheduleStreakMotivation(for habit: Habit) async {
        guard habit.streak >= 3 else { return } // Only for habits with 3+ day streaks

        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "🔥 Keep your streak alive!"
        content.body = "You're on a \(habit.streak)-day streak with \(habit.name). Don't break it now!"
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.streakMotivation.identifier
        content.userInfo = [
            "habitId": habit.id.uuidString,
            "streak": habit.streak
        ]

        // Schedule for evening if not completed today
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = "streak_\(habit.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
            logger.debug("Scheduled streak motivation for: \(habit.name)")
        } catch {
            logger.error("Failed to schedule streak motivation: \(error)")
        }
    }

    /// Cancel all scheduled notifications
    static func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        logger.info("Cancelled all scheduled notifications")
    }

    /// Cancel notifications for a specific habit
    static func cancelNotifications(for habit: Habit) async {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()

        let identifiersToRemove = pendingRequests
            .filter { request in
                if let habitId = request.content.userInfo["habitId"] as? String {
                    return habitId == habit.id.uuidString
                }
                return false
            }
            .map { $0.identifier }

        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        logger.info("Cancelled notifications for habit: \(habit.name)")
    }

    /// Setup notification categories and actions
    private static func setupNotificationCategories() async {
        let center = UNUserNotificationCenter.current()

        // Create actions for habit reminders
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_HABIT",
            title: "Mark Complete",
            options: [.foreground]
        )

        let postponeAction = UNNotificationAction(
            identifier: "POSTPONE_REMINDER",
            title: "Remind Later",
            options: []
        )

        // Create categories
        let habitReminderCategory = UNNotificationCategory(
            identifier: NotificationCategory.habitReminder.identifier,
            actions: [completeAction, postponeAction],
            intentIdentifiers: [],
            options: []
        )

        let streakCategory = UNNotificationCategory(
            identifier: NotificationCategory.streakMotivation.identifier,
            actions: [completeAction],
            intentIdentifiers: [],
            options: []
        )

        let levelUpCategory = UNNotificationCategory(
            identifier: NotificationCategory.levelUp.identifier,
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        let achievementCategory = UNNotificationCategory(
            identifier: NotificationCategory.achievementUnlocked.identifier,
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([
            habitReminderCategory,
            streakCategory,
            levelUpCategory,
            achievementCategory
        ])

        logger.info("Setup notification categories")
    }

    /// Get the count of pending notifications
    static func getPendingNotificationCount() async -> Int {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }
}
