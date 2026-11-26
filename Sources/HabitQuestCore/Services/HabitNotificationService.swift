//
// HabitNotificationService.swift
// HabitQuestCore
//

import Foundation
import UserNotifications
import OSLog

private let logger = Logger(subsystem: "com.habitquest.core", category: "HabitNotificationService")

/// Unified service for managing habit-related notifications and contextual reminders.
/// Consolidated from legacy SmartNotificationService, NotificationManager, and BehavioralAdaptationService.
@MainActor
public final class HabitNotificationService: NSObject, UNUserNotificationCenterDelegate, Sendable {
    public static let shared = HabitNotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        notificationCenter.delegate = self
    }

    // MARK: - Authorization

    /// Requests user permission to send notifications.
    public func requestAuthorization() async throws -> Bool {
        let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        if granted {
            logger.info("Notification permission granted.")
        } else {
            logger.warning("Notification permission denied.")
        }
        return granted
    }

    // MARK: - Basic Scheduling

    /// Schedules a simple one-off notification.
    public func scheduleNotification(title: String, body: String, after timeInterval: TimeInterval, identifier: String = UUID().uuidString) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.interruptionLevel = .active

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try await notificationCenter.add(request)
        logger.info("Scheduled notification: \(identifier)")
    }

    /// Cancels all pending notifications for a specific habit.
    public func cancelNotifications(for habitId: UUID) {
        var identifiers = [
            habitId.uuidString,
            "urgent_\(habitId.uuidString)",
            "milestone_\(habitId.uuidString)",
            "nudge_\(habitId.uuidString)",
        ]
        for weekday in 1...7 {
            identifiers.append("scheduled_\(habitId.uuidString)_\(weekday)")
        }
        identifiers.append("scheduled_\(habitId.uuidString)_daily")
        identifiers.append("scheduled_\(habitId.uuidString)_monthly")
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        logger.info("Cancelled notifications for habit: \(habitId.uuidString)")
    }

    /// Cancels existing pending notifications for a habit and reschedules calendar reminders if enabled.
    public func rescheduleReminders(for habit: Habit) async {
        cancelNotifications(for: habit.id)
        guard habit.reminderTime != nil else { return }
        await scheduleCalendarReminders(for: habit)
    }

    /// Computes calendar trigger date components for a habit's configured reminder time and scheduled days.
    public func notificationTriggerDateComponents(for habit: Habit, calendar: Calendar = .current) -> [DateComponents] {
        guard let reminderTime = habit.reminderTime else { return [] }
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        guard let hour = timeComponents.hour, let minute = timeComponents.minute else { return [] }

        if let scheduledDays = habit.scheduledDays?.sorted(), !scheduledDays.isEmpty {
            return scheduledDays.filter { (1...7).contains($0) }.map { weekday in
                var components = DateComponents()
                components.hour = hour
                components.minute = minute
                components.weekday = weekday
                return components
            }
        }

        var dailyComponents = DateComponents()
        dailyComponents.hour = hour
        dailyComponents.minute = minute
        return [dailyComponents]
    }

    /// Schedules repeating local calendar notifications matching the habit's reminder time and scheduled days.
    public func scheduleCalendarReminders(for habit: Habit) async {
        cancelNotifications(for: habit.id)
        let triggerComponents = notificationTriggerDateComponents(for: habit)
        guard !triggerComponents.isEmpty else { return }

        for components in triggerComponents {
            let content = UNMutableNotificationContent()
            content.title = "Quest Reminder"
            content.body = "Time for your habit: \(habit.name)"
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let suffix = components.weekday.map { "\($0)" } ?? "daily"
            let identifier = "scheduled_\(habit.id.uuidString)_\(suffix)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            try? await notificationCenter.add(request)
        }
    }

    // MARK: - Smart Contextual Reminders

    /// Analyzes habit context and schedules appropriate "Smart" reminders.
    public func scheduleSmartReminders(for habit: Habit) async {
        if habit.reminderTime != nil {
            await scheduleCalendarReminders(for: habit)
            return
        }

        let context = analyzeHabitContext(habit: habit)
        
        switch context {
        case .streakAtRisk:
            try? await scheduleUrgentReminder(for: habit)
        case .milestoneApproaching:
            try? await scheduleMilestonePrompt(for: habit)
        case .lowEngagement:
            try? await scheduleMotivationalNudge(for: habit)
        case .optimalTime, .normal:
            try? await scheduleStandardReminder(for: habit)
        }
    }

    private func analyzeHabitContext(habit: Habit) -> HabitContext {
        let recentLogs = habit.logs.suffix(7)
        let completionRate = recentLogs.isEmpty ? 1.0 : Double(recentLogs.filter(\.isCompleted).count) / Double(recentLogs.count)

        if habit.streak > 0 && completionRate < 0.3 {
            return .streakAtRisk
        }

        if habit.streak > 0 && (habit.streak % 10 == 9 || habit.streak == 6) {
            return .milestoneApproaching
        }

        if completionRate < 0.5 && habit.logs.count > 10 {
            return .lowEngagement
        }

        return .normal
    }

    private func scheduleUrgentReminder(for habit: Habit) async throws {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Keep the \(habit.streak)-day streak alive!"
        content.body = "Your streak for '\(habit.name)' is at risk! Complete it now to keep the fire burning!"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false) // 30 mins
        let request = UNNotificationRequest(identifier: "urgent_\(habit.id.uuidString)", content: content, trigger: trigger)
        try await notificationCenter.add(request)
    }

    private func scheduleMilestonePrompt(for habit: Habit) async throws {
        let content = UNMutableNotificationContent()
        content.title = "⭐️ Milestone Ahead!"
        content.body = "You're just one day away from a major milestone for '\(habit.name)'. You've got this!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "milestone_\(habit.id.uuidString)", content: content, trigger: trigger)
        try await notificationCenter.add(request)
    }

    private func scheduleMotivationalNudge(for habit: Habit) async throws {
        let content = UNMutableNotificationContent()
        content.title = "💪 Re-engage!"
        content.body = "Remember why you started '\(habit.name)'. Taking one small step today can restore your momentum."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: false)
        let request = UNNotificationRequest(identifier: "nudge_\(habit.id.uuidString)", content: content, trigger: trigger)
        try await notificationCenter.add(request)
    }

    private func scheduleStandardReminder(for habit: Habit) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Quest Reminder"
        content.body = "Time to work on your habit: \(habit.name)."
        content.sound = .default
        
        // Example: Schedule for tomorrow same time if not completed
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        try await notificationCenter.add(request)
    }

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}

