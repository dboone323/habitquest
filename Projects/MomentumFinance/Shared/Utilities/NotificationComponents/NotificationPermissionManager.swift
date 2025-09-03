//
//  NotificationPermissionManager.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation
import OSLog
import UserNotifications

/// Manages notification permissions and authorization status
public struct NotificationPermissionManager {

    private let center = UNUserNotificationCenter.current()
    private let logger: OSLog

    init(logger: OSLog) {
        self.logger = logger
    }

    /// Requests notification permission from the user
    /// - Returns: Boolean indicating if permission was granted
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])

            if granted {
                os_log("Notification permission granted", log: logger, type: .info)
            } else {
                os_log("Notification permission denied", log: logger, type: .info)
            }

            return granted
        } catch {
            os_log("Failed to request notification permission: %@", log: logger, type: .error, error.localizedDescription)
            return false
        }
    }

    /// Checks the current notification permission status
    /// - Parameter completion: Callback with the authorization status
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { settings in
            let isAuthorized = settings.authorizationStatus == .authorized
            DispatchQueue.main.async {
                completion(isAuthorized)
            }
        }
    }

    /// Sets up notification categories with actions
    func setupNotificationCategories() {
        let budgetWarningCategory = UNNotificationCategory(
            identifier: "BUDGET_WARNING",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_BUDGET",
                    title: "View Budget",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "DISMISS",
                    title: "Dismiss",
                    options: []
                ),
            ],
            intentIdentifiers: [],
            options: []
        )

        let subscriptionCategory = UNNotificationCategory(
            identifier: "SUBSCRIPTION_UPCOMING",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_SUBSCRIPTION",
                    title: "View Details",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "MARK_PAID",
                    title: "Mark as Paid",
                    options: []
                ),
            ],
            intentIdentifiers: [],
            options: []
        )

        let goalCategory = UNNotificationCategory(
            identifier: "GOAL_MILESTONE",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_GOAL",
                    title: "View Goal",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "ADD_MORE",
                    title: "Add More",
                    options: [.foreground]
                ),
            ],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([
            budgetWarningCategory,
            subscriptionCategory,
            goalCategory,
        ])
    }
}
