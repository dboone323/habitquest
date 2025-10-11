import Foundation
import "./NotificationTypes.swift"
import OSLog
import UserNotifications

// Momentum Finance - Budget Notification Scheduler
// Copyright © 2025 Momentum Finance. All rights reserved.

// Import shared types
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
