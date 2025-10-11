// Momentum Finance - Subscription Notification Scheduler
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import OSLog
import UserNotifications

/// Schedules subscription-related notifications
public struct SubscriptionNotificationScheduler {
    private let center = UNUserNotificationCenter.current()
    private let logger: OSLog

    public init(logger: OSLog) {
        self.logger = logger
    }

    /// Schedules due date reminders for subscriptions
    public func scheduleDueDateReminders(for subscriptions: [Subscription]) {
        for subscription in subscriptions {
            self.scheduleDueDateReminder(for: subscription)
        }
    }

    /// Alias for scheduleDueDateReminders to match NotificationManager interface
    public func scheduleNotifications(for subscriptions: [Subscription]) {
        self.scheduleDueDateReminders(for: subscriptions)
    }

    private func scheduleDueDateReminder(for subscription: Subscription) {
        let identifier = "subscription_reminder_\(subscription.persistentModelID)"

        // Remove existing notifications for this subscription
        self.center.removePendingNotificationRequests(withIdentifiers: [identifier])

        // Calculate next due date
        guard let nextDueDate = subscription.nextBillingDate else {
            os_log(
                "No next billing date for subscription %@", log: self.logger, type: .info,
                subscription.name
            )
            return
        }

        // Schedule notification 1 day before due date
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: nextDueDate)

        guard let reminderDate, reminderDate > Date() else {
            os_log(
                "Reminder date is in the past for subscription %@", log: self.logger, type: .info,
                subscription.name
            )
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Subscription Due Tomorrow"
        content.body =
            "\(subscription.name) (\(subscription.amount.formatted(.currency(code: "USD")))) is due tomorrow"
        content.sound = .default
        content.categoryIdentifier = "SUBSCRIPTION_REMINDER"
        content.userInfo = [
            "type": "subscription_reminder",
            "subscriptionId": "\(subscription.persistentModelID)",
        ]

        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger
        )

        // Extract subscription name before the closure
        let subscriptionName = subscription.name

        self.center.add(request) { [logger] error in
            if let error {
                os_log(
                    "Failed to schedule subscription reminder: %@", log: logger, type: .error,
                    error.localizedDescription
                )
            } else {
                os_log(
                    "Scheduled subscription reminder for %@", log: logger, type: .info,
                    subscriptionName
                )
            }
        }
    }
}
