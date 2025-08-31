//
//  SubscriptionNotificationScheduler.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation
import OSLog
import UserNotifications

/// Schedules subscription-related notifications
public struct SubscriptionNotificationScheduler {

    private let center = UNUserNotificationCenter.current()
    private let logger: OSLog

    init(logger: OSLog) {
        self.logger = logger
    }

    /// Schedules notifications for multiple subscriptions
    /// - Parameter subscriptions: Array of subscriptions to schedule notifications for
    func scheduleNotifications(for subscriptions: [Subscription]) {
        for subscription in subscriptions {
            scheduleUpcomingPaymentNotification(subscription: subscription)
            schedulePaymentDueNotification(subscription: subscription)
        }
    }

    /// Schedules an upcoming payment notification (1 day before due date)
    /// - Parameter subscription: The subscription to schedule for
    private func scheduleUpcomingPaymentNotification(subscription: Subscription) {
        let nextDueDate = subscription.nextDueDate
        let identifier = "subscription_upcoming_\(subscription.persistentModelID)"

        // Remove existing notification
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Payment"
        content.body = "\(subscription.name) payment of \(subscription.amount.formatted(.currency(code: "USD"))) is due tomorrow"
        content.sound = .default
        content.categoryIdentifier = "SUBSCRIPTION_UPCOMING"
        content.userInfo = [
            "type": "subscription_upcoming",
            "subscriptionId": "\(subscription.persistentModelID)",
        ]

        // Schedule for 1 day before due date at 9 AM
        let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: nextDueDate)!
        var components = Calendar.current.dateComponents([.year, .month, .day], from: oneDayBefore)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                os_log("Failed to schedule upcoming subscription notification: %@", log: self.logger, type: .error, error.localizedDescription)
            }
        }
    }

    /// Schedules a payment due notification (on the due date)
    /// - Parameter subscription: The subscription to schedule for
    private func schedulePaymentDueNotification(subscription: Subscription) {
        let nextDueDate = subscription.nextDueDate
        let identifier = "subscription_due_\(subscription.persistentModelID)"

        // Remove existing notification
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Payment Due Today"
        content.body = "\(subscription.name) payment of \(subscription.amount.formatted(.currency(code: "USD"))) is due today"
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = "SUBSCRIPTION_DUE"
        content.userInfo = [
            "type": "subscription_due",
            "subscriptionId": "\(subscription.persistentModelID)",
        ]

        // Schedule for due date at 8 AM
        var components = Calendar.current.dateComponents([.year, .month, .day], from: nextDueDate)
        components.hour = 8
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                os_log("Failed to schedule due subscription notification: %@", log: self.logger, type: .error, error.localizedDescription)
            }
        }
    }
}
