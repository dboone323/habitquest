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
<<<<<<< HEAD
=======
/// 
/// This main coordinator delegates to focused component implementations:
/// - NotificationPermissionManager: Permission handling and authorization
/// - BudgetNotificationScheduler: Budget warning and alert scheduling
/// - SubscriptionNotificationScheduler: Payment reminder scheduling
/// - GoalNotificationScheduler: Milestone and achievement notifications
/// - NotificationTypes: Supporting enums and data models
>>>>>>> 1cf3938 (Create working state for recovery)
@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isNotificationPermissionGranted = false
    @Published var pendingNotifications: [ScheduledNotification] = []

    private let center = UNUserNotificationCenter.current()
    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance", category: "Notifications")
<<<<<<< HEAD

    private init() {
        checkNotificationPermission()
    }

    // MARK: - Permission Management

    /// <#Description#>
    /// - Returns: <#description#>
    func requestNotificationPermission() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isNotificationPermissionGranted = granted

            if granted {
                os_log("Notification permission granted", log: self.logger, type: .info)
            } else {
                os_log("Notification permission denied", log: self.logger, type: .info)
            }
        } catch {
            os_log("Failed to request notification permission: %@", log: self.logger, type: .error, error.localizedDescription)
        }
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func checkNotificationPermission() {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Smart Budget Notifications

    /// <#Description#>
    /// - Returns: <#description#>
    func schedulebudgetWarningNotifications(for budgets: [Budget]) {
        guard isNotificationPermissionGranted else { return }

        for budget in budgets {
            let spentPercentage = budget.spentAmount / budget.limitAmount

            // 75% spending warning
            if spentPercentage >= 0.75 && spentPercentage < 0.90 {
                scheduleBudgetWarning(
                    budget: budget,
                    percentage: 75,
                    urgency: .medium,
                    )
            }

            // 90% spending warning
            if spentPercentage >= 0.90 && spentPercentage < 1.0 {
                scheduleBudgetWarning(
                    budget: budget,
                    percentage: 90,
                    urgency: .high,
                    )
            }

            // Over budget alert
            if spentPercentage >= 1.0 {
                scheduleBudgetWarning(
                    budget: budget,
                    percentage: 100,
                    urgency: .critical,
                    )
            }
        }
    }

    private func scheduleBudgetWarning(
        budget: Budget,
        percentage: Int,
        urgency: NotificationUrgency,
        ) {
        let identifier = "budget_warning_\(budget.persistentModelID)_\(percentage)"

        // Remove existing notification for this budget/percentage
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = urgency.title
        content.body = budgetWarningMessage(budget: budget, percentage: percentage)
        content.sound = urgency.sound
        content.categoryIdentifier = "BUDGET_WARNING"
        content.userInfo = [
            "type": "budget_warning",
            "budgetId": "\(budget.persistentModelID)",
            "percentage": percentage
        ]

        // Schedule immediately for current warnings
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Extract category name before the closure to avoid capturing budget
        let categoryName = budget.category?.name ?? "Unknown"

        center.add(request) { error in
            if let error {
                os_log("Failed to schedule budget notification: %@", log: self.logger, type: .error, error.localizedDescription)
            } else {
                os_log("Scheduled budget warning for %@", log: self.logger, type: .info, categoryName)
            }
        }
    }

    private func budgetWarningMessage(budget: Budget, percentage: Int) -> String {
        let categoryName = budget.category?.name ?? "Unknown Category"
        let spent = budget.spentAmount
        let limit = budget.limitAmount
        let remaining = max(0, limit - spent)

        switch percentage {
        case 75:
            let spentFormatted = spent.formatted(.currency(code: "USD"))
            let limitFormatted = limit.formatted(.currency(code: "USD"))
            let remainingFormatted = remaining.formatted(.currency(code: "USD"))
            return "You've spent \(spentFormatted) of your \(limitFormatted) \(categoryName) budget. \(remainingFormatted) remaining."
        case 90:
            let spentFormatted = spent.formatted(.currency(code: "USD"))
            let limitFormatted = limit.formatted(.currency(code: "USD"))
            let remainingFormatted = remaining.formatted(.currency(code: "USD"))
            return "Almost over budget! You've spent \(spentFormatted) of \(limitFormatted) for \(categoryName). Only \(remainingFormatted) left."
        case 100:
            let overspent = spent - limit
            let overspentFormatted = overspent.formatted(.currency(code: "USD"))
            let limitFormatted = limit.formatted(.currency(code: "USD"))
            return "Budget exceeded! You've spent \(overspentFormatted) over your \(limitFormatted) \(categoryName) budget."
        default:
            let spentFormatted = spent.formatted(.currency(code: "USD"))
            let limitFormatted = limit.formatted(.currency(code: "USD"))
            return "Budget update for \(categoryName): \(spentFormatted) of \(limitFormatted) spent."
        }
    }

    // MARK: - Subscription Due Date Notifications

    /// <#Description#>
    /// - Returns: <#description#>
    func scheduleSubscriptionNotifications(for subscriptions: [Subscription]) {
        guard isNotificationPermissionGranted else { return }

        for subscription in subscriptions {
            scheduleUpcomingPaymentNotification(subscription: subscription)
            schedulePaymentDueNotification(subscription: subscription)
        }
    }

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
            "subscriptionId": "\(subscription.persistentModelID)"
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
            "subscriptionId": "\(subscription.persistentModelID)"
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

    // MARK: - Goal Milestone Notifications

    /// <#Description#>
    /// - Returns: <#description#>
    func checkGoalMilestones(for goals: [SavingsGoal]) {
        guard isNotificationPermissionGranted else { return }

        for goal in goals {
            let progressPercentage = goal.currentAmount / goal.targetAmount

            // 25%, 50%, 75%, 90% milestones
            let milestones = [0.25, 0.50, 0.75, 0.90]

            for milestone in milestones {
                if progressPercentage >= milestone {
                    scheduleGoalMilestoneNotification(goal: goal, milestone: milestone)
                }
            }

            // Goal achieved
            if progressPercentage >= 1.0 {
                scheduleGoalAchievedNotification(goal: goal)
            }
        }
    }

    private func scheduleGoalMilestoneNotification(goal: SavingsGoal, milestone: Double) {
        let identifier = "goal_milestone_\(goal.persistentModelID)_\(Int(milestone * 100))"

        let content = UNMutableNotificationContent()
        content.title = "Goal Milestone Reached! 🎉"

        let percentageInt = Int(milestone * 100)
        let currentFormatted = goal.currentAmount.formatted(.currency(code: "USD"))
        let targetFormatted = goal.targetAmount.formatted(.currency(code: "USD"))
        content.body = "You've saved \(percentageInt)% toward your \(goal.name) goal! \(currentFormatted) of \(targetFormatted)"

        content.sound = .default
        content.categoryIdentifier = "GOAL_MILESTONE"
        content.userInfo = [
            "type": "goal_milestone",
            "goalId": "\(goal.persistentModelID)",
            "milestone": milestone
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                os_log("Failed to schedule goal milestone notification: %@", log: self.logger, type: .error, error.localizedDescription)
            }
        }
    }

    private func scheduleGoalAchievedNotification(goal: SavingsGoal) {
        let identifier = "goal_achieved_\(goal.persistentModelID)"

        let content = UNMutableNotificationContent()
        content.title = "Goal Achieved! 🏆"
        content.body = "Congratulations! You've reached your \(goal.name) savings goal of \(goal.targetAmount.formatted(.currency(code: "USD")))!"
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = "GOAL_ACHIEVED"
        content.userInfo = [
            "type": "goal_achieved",
            "goalId": "\(goal.persistentModelID)"
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                os_log("Failed to schedule goal achieved notification: %@", log: self.logger, type: .error, error.localizedDescription)
            }
        }
=======
    
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
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    // MARK: - Notification Management

<<<<<<< HEAD
    /// <#Description#>
    /// - Returns: <#description#>
=======
>>>>>>> 1cf3938 (Create working state for recovery)
    func clearAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        pendingNotifications.removeAll()
    }

<<<<<<< HEAD
    /// <#Description#>
    /// - Returns: <#description#>
=======
>>>>>>> 1cf3938 (Create working state for recovery)
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
<<<<<<< HEAD
                scheduledDate: (request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate(),
                )
        }
    }
}

// MARK: - Supporting Types

enum NotificationUrgency {
    case low, medium, high, critical

    var title: String {
        switch self {
        case .low: "Budget Update"
        case .medium: "Budget Warning"
        case .high: "Budget Alert"
        case .critical: "Budget Exceeded!"
        }
    }

    var sound: UNNotificationSound {
        switch self {
        case .low, .medium: .default
        case .high: UNNotificationSound(named: UNNotificationSoundName("alert.caf"))
        case .critical: .defaultCritical
        }
    }
}

struct ScheduledNotification: Identifiable {
    let id: String
    let title: String
    let body: String
    let type: String
    let scheduledDate: Date?
}

// MARK: - Notification Categories Setup

extension NotificationManager {
    /// <#Description#>
    /// - Returns: <#description#>
    func setupNotificationCategories() {
        let budgetWarningCategory = UNNotificationCategory(
            identifier: "BUDGET_WARNING",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_BUDGET",
                    title: "View Budget",
                    options: [.foreground],
                    ),
                UNNotificationAction(
                    identifier: "DISMISS",
                    title: "Dismiss",
                    options: [],
                    )
            ],
            intentIdentifiers: [],
            options: [],
            )

        let subscriptionCategory = UNNotificationCategory(
            identifier: "SUBSCRIPTION_UPCOMING",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_SUBSCRIPTION",
                    title: "View Details",
                    options: [.foreground],
                    ),
                UNNotificationAction(
                    identifier: "MARK_PAID",
                    title: "Mark as Paid",
                    options: [],
                    )
            ],
            intentIdentifiers: [],
            options: [],
            )

        let goalCategory = UNNotificationCategory(
            identifier: "GOAL_MILESTONE",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_GOAL",
                    title: "View Goal",
                    options: [.foreground],
                    ),
                UNNotificationAction(
                    identifier: "ADD_MORE",
                    title: "Add More",
                    options: [.foreground],
                    )
            ],
            intentIdentifiers: [],
            options: [],
            )

        center.setNotificationCategories([
            budgetWarningCategory,
            subscriptionCategory,
            goalCategory
        ])
=======
                scheduledDate: (request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
            )
        }
    }

    // MARK: - Notification Categories Setup (Delegate to PermissionManager)

    func setupNotificationCategories() {
        permissionManager.setupNotificationCategories()
>>>>>>> 1cf3938 (Create working state for recovery)
    }
}
