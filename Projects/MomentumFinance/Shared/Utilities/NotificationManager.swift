import Foundation
import os
import OSLog
import SwiftData

//
//  NotificationManager.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

@preconcurrency import UserNotifications

/// Manages smart notifications for budget limits and subscription due dates
///
/// This main coordinator delegates to focused component implementations:
/// - NotificationPermissionManager: Permission handling and authorization
/// - BudgetNotificationScheduler: Budget warning and alert scheduling
/// - SubscriptionNotificationScheduler: Payment reminder scheduling
/// - GoalNotificationScheduler: Milestone and achievement notifications
/// - NotificationTypes: Supporting enums and data models
@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isNotificationPermissionGranted = false
    @Published var pendingNotifications: [ScheduledNotification] = []

    private let center = UNUserNotificationCenter.current()
    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance", category: "Notifications")

    // Component delegates
    private let permissionManager: NotificationPermissionManager
    private let budgetScheduler: BudgetNotificationScheduler
    private let subscriptionScheduler: SubscriptionNotificationScheduler
    private let goalScheduler: GoalNotificationScheduler

    private init() {
        // Initialize component delegates
        permissionManager = NotificationPermissionManager(logger: logger)
        budgetScheduler = BudgetNotificationScheduler(logger: logger)
        subscriptionScheduler = SubscriptionNotificationScheduler(logger: logger)
        goalScheduler = GoalNotificationScheduler(logger: logger)

        checkNotificationPermission()
        setupNotificationCategories()
    }

    // MARK: - Permission Management (Delegate to PermissionManager)

    func requestNotificationPermission() async {
        let granted = await permissionManager.requestNotificationPermission()
        isNotificationPermissionGranted = granted
    }

    func checkNotificationPermission() {
        permissionManager.checkNotificationPermission { granted in
            self.isNotificationPermissionGranted = granted
        }
    }

    // MARK: - Smart Budget Notifications (Delegate to BudgetScheduler)

    func schedulebudgetWarningNotifications(for budgets: [Budget]) {
        guard isNotificationPermissionGranted else { return }
        budgetScheduler.scheduleWarningNotifications(for: budgets)
    }

    // MARK: - Subscription Due Date Notifications (Delegate to SubscriptionScheduler)

    func scheduleSubscriptionNotifications(for subscriptions: [Subscription]) {
        guard isNotificationPermissionGranted else { return }
        subscriptionScheduler.scheduleNotifications(for: subscriptions)
    }

    // MARK: - Goal Milestone Notifications (Delegate to GoalScheduler)

    func checkGoalMilestones(for goals: [SavingsGoal]) {
        guard isNotificationPermissionGranted else { return }
        goalScheduler.checkMilestones(for: goals)
    }

    // MARK: - Notification Management

    func clearAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        pendingNotifications.removeAll()
    }

    func clearNotifications(ofType type: String) {
        Task { @MainActor in
            let requests = await center.pendingNotificationRequests()
            let identifiersToRemove = requests
                .filter { request in
                    (request.content.userInfo["type"] as? String) == type
                }
                .map(\.identifier)

            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }

    nonisolated func getPendingNotifications() async -> [ScheduledNotification] {
        let requests = await center.pendingNotificationRequests()

        return requests.compactMap { request in
            ScheduledNotification(
                id: request.identifier,
                title: request.content.title,
                body: request.content.body,
                type: request.content.userInfo["type"] as? String ?? "unknown",
                scheduledDate: (request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
            )
        }
    }

    // MARK: - Notification Categories Setup (Delegate to PermissionManager)

    func setupNotificationCategories() {
        // Set up notification categories
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

        UNUserNotificationCenter.current().setNotificationCategories([
            budgetCategory,
            subscriptionCategory,
        ])
    }
}
