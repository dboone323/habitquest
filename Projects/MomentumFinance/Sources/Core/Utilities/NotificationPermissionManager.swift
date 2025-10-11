// Momentum Finance - Notification Permission Manager
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import OSLog
import UserNotifications

/// Manages notification permissions and authorization status
public struct NotificationPermissionManager {
    private let center = UNUserNotificationCenter.current()
    private let logger: OSLog

    public init(logger: OSLog) {
        self.logger = logger
    }

    /// Requests notification permission from the user
    /// - Returns: Boolean indicating if permission was granted
    public func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])

            if granted {
                os_log("Notification permission granted", log: self.logger, type: .info)
            } else {
                os_log("Notification permission denied", log: self.logger, type: .error)
            }

            return granted
        } catch {
            os_log(
                "Error requesting notification permission: %@", log: self.logger, type: .error,
                error.localizedDescription
            )
            return false
        }
    }

    /// Checks current notification permission status asynchronously
    /// - Returns: Boolean indicating if permission is granted
    public func checkNotificationPermissionAsync() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    /// Sets up notification categories for the app
    public func setupNotificationCategories() {
        let budgetCategory = UNNotificationCategory(
            identifier: "BUDGET_WARNING",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let subscriptionCategory = UNNotificationCategory(
            identifier: "SUBSCRIPTION_REMINDER",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let goalCategory = UNNotificationCategory(
            identifier: "GOAL_PROGRESS",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        self.center.setNotificationCategories([budgetCategory, subscriptionCategory, goalCategory])
    }
}
