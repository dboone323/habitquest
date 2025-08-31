//
//  BudgetNotificationScheduler.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation
import OSLog
import UserNotifications

/// Schedules and manages budget-related notifications
public struct BudgetNotificationScheduler {

    private let center = UNUserNotificationCenter.current()
    private let logger: OSLog

    init(logger: OSLog) {
        self.logger = logger
    }

    /// Schedules budget warning notifications for multiple budgets
    /// - Parameter budgets: Array of budgets to check for warnings
    func scheduleWarningNotifications(for budgets: [Budget]) {
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
    /// - Parameters:
    ///   - budget: The budget to warn about
    ///   - percentage: The spending percentage threshold
    ///   - urgency: The urgency level for the notification
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
    /// - Parameters:
    ///   - budget: The budget to create a message for
    ///   - percentage: The spending percentage
    /// - Returns: Formatted warning message string
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
