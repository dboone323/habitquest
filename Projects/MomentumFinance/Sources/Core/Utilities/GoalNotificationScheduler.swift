// Momentum Finance - Goal Notification Scheduler
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import OSLog
import UserNotifications

/// Schedules goal milestone and reminder notifications
public struct GoalNotificationScheduler {
    private let center = UNUserNotificationCenter.current()
    private let logger: OSLog

    public init(logger: OSLog) {
        self.logger = logger
    }

    /// Schedules progress reminders for savings goals
    public func scheduleProgressReminders(for goals: [SavingsGoal]) {
        for goal in goals {
            self.scheduleProgressReminder(for: goal)
        }
    }

    /// Alias for scheduleProgressReminders to match NotificationManager interface
    public func checkMilestones(for goals: [SavingsGoal]) {
        self.scheduleProgressReminders(for: goals)
    }

    private func scheduleProgressReminder(for goal: SavingsGoal) {
        let identifier = "goal_progress_\(goal.persistentModelID)"

        // Remove existing notifications for this goal
        self.center.removePendingNotificationRequests(withIdentifiers: [identifier])

        // Calculate progress percentage
        let progressPercentage = goal.currentAmount / goal.targetAmount
        let progressPercent = Int(progressPercentage * 100)

        // Only schedule if goal is active and has meaningful progress
        guard !goal.isCompleted, progressPercentage > 0.1 else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Goal Progress Update"
        content.body =
            "You're \(progressPercent)% of the way to your \(goal.title) goal! Keep going!"
        content.sound = .default
        content.categoryIdentifier = "GOAL_PROGRESS"
        content.userInfo = [
            "type": "goal_progress",
            "goalId": "\(goal.persistentModelID)",
            "progress": progressPercentage,
        ]

        // Schedule for next week
        let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        let triggerComponents = Calendar.current.dateComponents([.weekday, .hour], from: nextWeek)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger
        )

        // Extract goal title before the closure
        let goalTitle = goal.title

        self.center.add(request) { [logger] error in
            if let error {
                os_log(
                    "Failed to schedule goal progress reminder: %@", log: logger, type: .error,
                    error.localizedDescription
                )
            } else {
                os_log(
                    "Scheduled goal progress reminder for %@", log: logger, type: .info, goalTitle
                )
            }
        }
    }
}
