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
                os_log("Notification permission granted", log: logger, type: .info)
            } else {
                os_log("Notification permission denied", log: logger, type: .error)
            }

            return granted
        } catch {
            os_log("Error requesting notification permission: %@", log: logger, type: .error, error.localizedDescription)
            return false
        }
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
            let spentPercentage = budget.spentAmount / budget.limitAmount

            // 75% spending warning
            if spentPercentage >= 0.75 && spentPercentage < 0.90 {
                scheduleBudgetWarning(
                    budget: budget,
                    percentage: 75,
                    urgency: .medium
                )
            }

            // 90% spending warning
            if spentPercentage >= 0.90 && spentPercentage < 1.0 {
                scheduleBudgetWarning(
                    budget: budget,
                    percentage: 90,
                    urgency: .high
                )
            }

            // Over budget alert
            if spentPercentage >= 1.0 {
                scheduleBudgetWarning(
                    budget: budget,
                    percentage: 100,
                    urgency: .critical
                )
            }
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
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = urgency.title
        content.body = createBudgetWarningMessage(budget: budget, percentage: percentage)
        content.sound = urgency.sound
        content.categoryIdentifier = "BUDGET_WARNING"
        content.userInfo = [
            "type": "budget_warning",
            "budgetId": "\(budget.persistentModelID)",
            "percentage": percentage,
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

    /// Creates a contextual warning message based on budget status
    private func createBudgetWarningMessage(budget: Budget, percentage: Int) -> String {
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
            scheduleDueDateReminder(for: subscription)
        }
    }

    private func scheduleDueDateReminder(for subscription: Subscription) {
        let identifier = "subscription_reminder_\(subscription.persistentModelID)"

        // Remove existing notifications for this subscription
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        // Calculate next due date
        guard let nextDueDate = subscription.nextBillingDate else {
            os_log("No next billing date for subscription %@", log: logger, type: .info, subscription.name)
            return
        }

        // Schedule notification 1 day before due date
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: nextDueDate)

        guard let reminderDate, reminderDate > Date() else {
            os_log("Reminder date is in the past for subscription %@", log: logger, type: .info, subscription.name)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Subscription Due Tomorrow"
        content.body = "\(subscription.name) (\(subscription.amount.formatted(.currency(code: "USD")))) is due tomorrow"
        content.sound = .default
        content.categoryIdentifier = "SUBSCRIPTION_REMINDER"
        content.userInfo = [
            "type": "subscription_reminder",
            "subscriptionId": "\(subscription.persistentModelID)",
        ]

        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                os_log("Failed to schedule subscription reminder: %@", log: self.logger, type: .error, error.localizedDescription)
            } else {
                os_log("Scheduled subscription reminder for %@", log: self.logger, type: .info, subscription.name)
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
            scheduleProgressReminder(for: goal)
        }
    }

    private func scheduleProgressReminder(for goal: SavingsGoal) {
        let identifier = "goal_progress_\(goal.persistentModelID)"

        // Remove existing notifications for this goal
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        // Calculate progress percentage
        let progressPercentage = goal.currentAmount / goal.targetAmount
        let progressPercent = Int(progressPercentage * 100)

        // Only schedule if goal is active and has meaningful progress
        guard !goal.isCompleted && progressPercentage > 0.1 else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Goal Progress Update"
        content.body = "You're \(progressPercent)% of the way to your \(goal.title) goal! Keep going!"
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
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                os_log("Failed to schedule goal progress reminder: %@", log: self.logger, type: .error, error.localizedDescription)
            } else {
                os_log("Scheduled goal progress reminder for %@", log: self.logger, type: .info, goal.title)
            }
        }
    }
}
