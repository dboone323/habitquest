//
//  NotificationTypes.swift
//  MomentumFinance - Consolidated notification types
//
//  Moved from NotificationComponents for build compatibility
//

import Foundation
import OSLog
import UserNotifications

// MARK: - Notification Types

/// Notification urgency levels
public enum NotificationUrgency {
    case low, medium, high, critical

    public var title: String {
        switch self {
        case .low: "Budget Update"
        case .medium: "Budget Warning"
        case .high: "Budget Alert"
        case .critical: "Budget Exceeded!"
        }
    }

    public var sound: UNNotificationSound {
        switch self {
        case .low: .default
        case .medium: .default
        case .high: .defaultCritical
        case .critical: .defaultCritical
        }
    }
}

/// Represents a scheduled notification with its metadata
public struct ScheduledNotification: Identifiable {
    public let id: String
    public let title: String
    public let body: String
    public let type: String
    public let scheduledDate: Date?

    public init(id: String, title: String, body: String, type: String, scheduledDate: Date?) {
        self.id = id
        self.title = title
        self.body = body
        self.type = type
        self.scheduledDate = scheduledDate
    }
}

// MARK: - Notification Managers

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

/// Schedules and manages budget-related notifications
public struct BudgetNotificationScheduler {
    private let center = UNUserNotificationCenter.current()
    private let logger: OSLog

    public init(logger: OSLog) {
        self.logger = logger
    }

    /// Schedules budget warning notifications for multiple budgets
    /// - Parameter budgets: Array of budgets to check for warnings
    public func scheduleWarningNotifications(for budgets: [Budget]) {
        for budget in budgets {
            let spentPercentage = budget.spentAmount / budget.effectiveLimit

            // 75% spending warning
            if spentPercentage >= 0.75, spentPercentage < 0.90 {
                self.scheduleBudgetWarning(
                    budget: budget,
                    percentage: 75,
                    urgency: .medium
                )
            }

            // 90% spending warning
            if spentPercentage >= 0.90, spentPercentage < 1.0 {
                self.scheduleBudgetWarning(
                    budget: budget,
                    percentage: 90,
                    urgency: .high
                )
            }

            // Over budget alert
            if spentPercentage >= 1.0 {
                self.scheduleBudgetWarning(
                    budget: budget,
                    percentage: 100,
                    urgency: .critical
                )
            }

            // Rollover opportunity notification
            if budget.rolloverEnabled, budget.calculateRolloverAmount() > 0 {
                self.scheduleRolloverOpportunityNotification(budget: budget)
            }

            // Spending prediction alerts
            self.scheduleSpendingPredictionAlerts(budget: budget)
        }
    }

    /// Schedules a specific budget warning notification
    private func scheduleBudgetWarning(
        budget: Budget,
        percentage: Int,
        urgency: NotificationUrgency
    ) {
        let identifier = "budget_warning_\(budget.persistentModelID)_\(percentage)"

        // Remove existing notification for this budget/percentage
        self.center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = urgency.title
        content.body = self.createBudgetWarningMessage(budget: budget, percentage: percentage)
        content.sound = urgency.sound
        content.categoryIdentifier = "BUDGET_WARNING"
        content.userInfo = [
            "type": "budget_warning",
            "budgetId": "\(budget.persistentModelID)",
            "percentage": percentage,
        ]

        // Schedule immediately for current warnings
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger
        )

        // Extract category name before the closure to avoid capturing budget
        let categoryName = budget.category?.name ?? "Unknown"

        self.center.add(request) { [logger] error in
            if let error {
                os_log(
                    "Failed to schedule budget notification: %@", log: logger, type: .error,
                    error.localizedDescription
                )
            } else {
                os_log("Scheduled budget warning for %@", log: logger, type: .info, categoryName)
            }
        }
    }

    /// Creates a contextual warning message based on budget status
    private func createBudgetWarningMessage(budget: Budget, percentage: Int) -> String {
        let categoryName = budget.category?.name ?? "Unknown Category"
        let spent = budget.spentAmount
        let limit = budget.effectiveLimit
        let remaining = max(0, limit - spent)

        switch percentage {
        case 75:
            let spentFormatted = spent.formatted(.currency(code: "USD"))
            let limitFormatted = limit.formatted(.currency(code: "USD"))
            let remainingFormatted = remaining.formatted(.currency(code: "USD"))
            return
                "You've spent \(spentFormatted) of your \(limitFormatted) \(categoryName) budget. \(remainingFormatted) remaining."
        case 90:
            let spentFormatted = spent.formatted(.currency(code: "USD"))
            let limitFormatted = limit.formatted(.currency(code: "USD"))
            let remainingFormatted = remaining.formatted(.currency(code: "USD"))
            return
                "Almost over budget! You've spent \(spentFormatted) of \(limitFormatted) for \(categoryName). Only \(remainingFormatted) left."
        case 100:
            let overspent = spent - limit
            let overspentFormatted = overspent.formatted(.currency(code: "USD"))
            let limitFormatted = limit.formatted(.currency(code: "USD"))
            return
                "Budget exceeded! You've spent \(overspentFormatted) over your \(limitFormatted) \(categoryName) budget."
        default:
            let spentFormatted = spent.formatted(.currency(code: "USD"))
            let limitFormatted = limit.formatted(.currency(code: "USD"))
            return
                "Budget update for \(categoryName): \(spentFormatted) of \(limitFormatted) spent."
        }
    }

    /// Schedules a rollover opportunity notification
    private func scheduleRolloverOpportunityNotification(budget: Budget) {
        let rolloverAmount = budget.calculateRolloverAmount()
        guard rolloverAmount > 0 else { return }

        let identifier = "rollover_opportunity_\(budget.persistentModelID)"

        // Remove existing notification for this budget
        self.center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Budget Rollover Available"
        content.body = self.createRolloverMessage(budget: budget, rolloverAmount: rolloverAmount)
        content.sound = .default
        content.categoryIdentifier = "BUDGET_WARNING"
        content.userInfo = [
            "type": "rollover_opportunity",
            "budgetId": "\(budget.persistentModelID)",
            "rolloverAmount": rolloverAmount,
        ]

        // Schedule immediately for current opportunities
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger
        )

        // Extract category name before the closure
        let categoryName = budget.category?.name ?? "Unknown"

        self.center.add(request) { [logger] error in
            if let error {
                os_log(
                    "Failed to schedule rollover notification: %@", log: logger, type: .error,
                    error.localizedDescription
                )
            } else {
                os_log("Scheduled rollover opportunity for %@", log: logger, type: .info, categoryName)
            }
        }
    }

    /// Schedules spending prediction alerts based on current spending patterns
    private func scheduleSpendingPredictionAlerts(budget: Budget) {
        let spentPercentage = budget.spentAmount / budget.effectiveLimit
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: budget.month)?.count ?? 30
        let currentDay = Calendar.current.component(.day, from: Date())
        let daysRemaining = max(1, daysInMonth - currentDay)
        let dailySpendingRate = budget.spentAmount / Double(currentDay)

        // Predict end-of-month spending
        let predictedSpending = dailySpendingRate * Double(daysInMonth)
        let predictedPercentage = predictedSpending / budget.effectiveLimit

        // Alert if predicted spending exceeds budget
        if predictedPercentage > 1.0, spentPercentage < 0.9 {
            self.scheduleSpendingPredictionNotification(
                budget: budget,
                predictedAmount: predictedSpending,
                daysRemaining: daysRemaining
            )
        }

        // Alert for unusual spending spikes
        if self.detectSpendingSpike(budget: budget) {
            self.scheduleSpendingSpikeAlert(budget: budget)
        }
    }

    /// Schedules a spending prediction notification
    private func scheduleSpendingPredictionNotification(
        budget: Budget,
        predictedAmount: Double,
        daysRemaining: Int
    ) {
        let identifier = "spending_prediction_\(budget.persistentModelID)"

        // Remove existing notification for this budget
        self.center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Spending Prediction Alert"
        content.body = self.createSpendingPredictionMessage(
            budget: budget,
            predictedAmount: predictedAmount,
            daysRemaining: daysRemaining
        )
        content.sound = .defaultCritical
        content.categoryIdentifier = "BUDGET_WARNING"
        content.userInfo = [
            "type": "spending_prediction",
            "budgetId": "\(budget.persistentModelID)",
            "predictedAmount": predictedAmount,
        ]

        // Schedule immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger
        )

        // Extract category name before the closure
        let categoryName = budget.category?.name ?? "Unknown"

        self.center.add(request) { [logger] error in
            if let error {
                os_log(
                    "Failed to schedule spending prediction: %@", log: logger, type: .error,
                    error.localizedDescription
                )
            } else {
                os_log("Scheduled spending prediction for %@", log: logger, type: .info, categoryName)
            }
        }
    }

    /// Schedules an alert for unusual spending spikes
    private func scheduleSpendingSpikeAlert(budget: Budget) {
        let identifier = "spending_spike_\(budget.persistentModelID)"

        // Remove existing notification for this budget
        self.center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Unusual Spending Detected"
        content.body = self.createSpendingSpikeMessage(budget: budget)
        content.sound = .defaultCritical
        content.categoryIdentifier = "BUDGET_WARNING"
        content.userInfo = [
            "type": "spending_spike",
            "budgetId": "\(budget.persistentModelID)",
        ]

        // Schedule immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger
        )

        // Extract category name before the closure
        let categoryName = budget.category?.name ?? "Unknown"

        self.center.add(request) { [logger] error in
            if let error {
                os_log(
                    "Failed to schedule spending spike alert: %@", log: logger, type: .error,
                    error.localizedDescription
                )
            } else {
                os_log("Scheduled spending spike alert for %@", log: logger, type: .info, categoryName)
            }
        }
    }

    /// Creates a rollover opportunity message
    private func createRolloverMessage(budget: Budget, rolloverAmount: Double) -> String {
        let categoryName = budget.category?.name ?? "Unknown Category"
        let rolloverFormatted = rolloverAmount.formatted(.currency(code: "USD"))
        let percentage = Int((rolloverAmount / budget.limitAmount) * 100)

        return
            "Great job staying under budget! You can roll over \(rolloverFormatted) (\(percentage)%) from your \(categoryName) budget to next month."
    }

    /// Creates a spending prediction message
    private func createSpendingPredictionMessage(
        budget: Budget,
        predictedAmount: Double,
        daysRemaining: Int
    ) -> String {
        let categoryName = budget.category?.name ?? "Unknown Category"
        let predictedFormatted = predictedAmount.formatted(.currency(code: "USD"))
        let limitFormatted = budget.effectiveLimit.formatted(.currency(code: "USD"))
        let overspend = predictedAmount - budget.effectiveLimit
        let overspendFormatted = overspend.formatted(.currency(code: "USD"))

        return
            "Based on your current spending, you may overspend your \(categoryName) budget by \(overspendFormatted) in \(daysRemaining) days. Predicted total: \(predictedFormatted) of \(limitFormatted)."
    }

    /// Creates a spending spike alert message
    private func createSpendingSpikeMessage(budget: Budget) -> String {
        let categoryName = budget.category?.name ?? "Unknown Category"
        return
            "Unusual spending detected in your \(categoryName) category. Check recent transactions to ensure they're correct."
    }

    /// Detects if there's been an unusual spending spike
    private func detectSpendingSpike(budget: Budget) -> Bool {
        // Simple spike detection - in a real app, this would use more sophisticated analysis
        // For now, just check if spending is significantly above average daily spending
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: budget.month)?.count ?? 30
        let currentDay = Calendar.current.component(.day, from: Date())
        let averageDailySpending = budget.spentAmount / Double(max(1, currentDay))

        // Check recent transactions for spikes (simplified logic)
        // This would need access to transaction data to implement properly
        return false // Placeholder - would need transaction analysis
    }

    /// Schedules rollover opportunity notifications for multiple budgets
    /// - Parameter budgets: Array of budgets to check for rollover opportunities
    public func scheduleRolloverNotifications(for budgets: [Budget]) {
        for budget in budgets where budget.rolloverEnabled {
            let rolloverAmount = budget.calculateRolloverAmount()
            if rolloverAmount > 0 {
                self.scheduleRolloverOpportunityNotification(budget: budget)
            }
        }
    }

    /// Schedules spending prediction notifications for multiple budgets
    /// - Parameter budgets: Array of budgets to analyze for spending predictions
    public func scheduleSpendingPredictionNotifications(for budgets: [Budget]) {
        for budget in budgets {
            self.scheduleSpendingPredictionAlerts(budget: budget)
        }
    }
}

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
