// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import Observation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class BudgetsViewModel {
    private var modelContext: ModelContext?

    /// <#Description#>
    /// - Returns: <#description#>
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// Get budgets for a specific month
    /// <#Description#>
    /// - Returns: <#description#>
    func budgetsForMonth(_ budgets: [Budget], month: Date) -> [Budget] {
        let calendar = Calendar.current
        return budgets.filter { budget in
            calendar.isDate(budget.month, equalTo: month, toGranularity: .month)
        }
    }

    /// Get total budgeted amount for a month
    /// <#Description#>
    /// - Returns: <#description#>
    func totalBudgetedAmount(_ budgets: [Budget], for month: Date) -> Double {
        self.budgetsForMonth(budgets, month: month).reduce(0) { $0 + $1.limitAmount }
    }

    /// Get total spent amount for budgets in a month
    /// <#Description#>
    /// - Returns: <#description#>
    func totalSpentAmount(_ budgets: [Budget], for month: Date) -> Double {
        self.budgetsForMonth(budgets, month: month).reduce(0) { $0 + $1.spentAmount }
    }

    /// Get remaining budget for a month
    /// <#Description#>
    /// - Returns: <#description#>
    func remainingBudget(_ budgets: [Budget], for month: Date) -> Double {
        let monthBudgets = self.budgetsForMonth(budgets, month: month)
        let totalBudgeted = monthBudgets.reduce(0) { $0 + $1.limitAmount }
        let totalSpent = monthBudgets.reduce(0) { $0 + $1.spentAmount }
        return totalBudgeted - totalSpent
    }

    /// Check if any budgets are over limit
    /// <#Description#>
    /// - Returns: <#description#>
    func hasOverBudgetCategories(_ budgets: [Budget], for month: Date) -> Bool {
        self.budgetsForMonth(budgets, month: month).contains { $0.isOverBudget }
    }

    /// Get categories that are over budget
    /// <#Description#>
    /// - Returns: <#description#>
    func overBudgetCategories(_ budgets: [Budget], for month: Date) -> [Budget] {
        self.budgetsForMonth(budgets, month: month).filter(\.isOverBudget)
    }

    /// Create a new budget
    /// <#Description#>
    /// - Returns: <#description#>
    func createBudget(category: ExpenseCategory, limitAmount: Double, month: Date) {
        guard let modelContext else { return }

        // Check if budget already exists for this category and month
        let existingBudgetDescriptor = FetchDescriptor<Budget>()
        let existingBudgets = (try? modelContext.fetch(existingBudgetDescriptor)) ?? []

        let calendar = Calendar.current
        let budgetExists = existingBudgets.contains { budget in
            budget.category?.name == category.name
                && calendar.isDate(budget.month, equalTo: month, toGranularity: .month)
        }

        if budgetExists {
            Logger.logBusiness("Budget already exists for \(category.name) in \(month)")
            return
        }

        let budget = Budget(name: "\(category.name) Budget", limitAmount: limitAmount, month: month)
        budget.category = category

        modelContext.insert(budget)

        do {
            try modelContext.save()
        } catch {
            Logger.logError(error, context: "Creating budget")
        }
    }

    /// Update budget limit
    /// <#Description#>
    /// - Returns: <#description#>
    func updateBudgetLimit(_ budget: Budget, newLimit: Double) {
        budget.limitAmount = newLimit

        do {
            try self.modelContext?.save()
        } catch {
            Logger.logError(error, context: "Updating budget")
        }
    }

    /// Delete budget
    /// <#Description#>
    /// - Returns: <#description#>
    func deleteBudget(_ budget: Budget) {
        guard let modelContext else { return }

        modelContext.delete(budget)

        do {
            try modelContext.save()
        } catch {
            Logger.logError(error, context: "Deleting budget")
        }
    }

    /// Get budget progress summary
    /// <#Description#>
    /// - Returns: <#description#>
    func budgetProgressSummary(_ budgets: [Budget], for month: Date) -> BudgetProgressSummary {
        let monthBudgets = self.budgetsForMonth(budgets, month: month)

        let totalBudgeted = monthBudgets.reduce(0) { $0 + $1.limitAmount }
        let totalSpent = monthBudgets.reduce(0) { $0 + $1.spentAmount }
        let onTrackCount = monthBudgets.count(where: { !$0.isOverBudget })
        let overBudgetCount = monthBudgets.filter(\.isOverBudget).count

        return BudgetProgressSummary(
            totalBudgeted: totalBudgeted,
            totalSpent: totalSpent,
            onTrackCount: onTrackCount,
            overBudgetCount: overBudgetCount,
            totalBudgets: monthBudgets.count,
        )
    }

    /// Get spending trend for categories
    /// <#Description#>
    /// - Returns: <#description#>
    func spendingTrend(for category: ExpenseCategory, months: Int = 6) -> [MonthlySpending] {
        guard self.modelContext != nil else { return [] }

        let calendar = Calendar.current
        let now = Date()
        var trend: [MonthlySpending] = []

        for i in 0 ..< months {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now) else {
                continue
            }

            let spent = category.totalSpent(for: monthDate)
            let monthSpending = MonthlySpending(
                month: monthDate,
                amount: spent,
                categoryName: category.name,
            )
            trend.insert(monthSpending, at: 0)
        }

        return trend
    }

    /// Update budget rollover settings
    /// <#Description#>
    /// - Returns: <#description#>
    func updateBudgetRolloverSettings(_ budget: Budget, enabled: Bool, maxPercentage: Double) {
        budget.rolloverEnabled = enabled
        budget.maxRolloverPercentage = maxPercentage

        do {
            try self.modelContext?.save()
            // Schedule rollover notifications after settings change
            // Temporarily disabled - NotificationManager not found in scope
            // NotificationManager.shared.scheduleRolloverNotifications(for: [budget])
        } catch {
            Logger.logError(error, context: "Updating budget rollover settings")
        }
    }

    /// Apply rollover to next period budget
    /// <#Description#>
    /// - Returns: <#description#>
    func applyRolloverToNextPeriod(for budget: Budget) {
        guard let modelContext else { return }

        let calendar = Calendar.current
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: budget.month) else {
            return
        }

        // Check if next period budget already exists
        let existingBudgetDescriptor = FetchDescriptor<Budget>()
        let existingBudgets = (try? modelContext.fetch(existingBudgetDescriptor)) ?? []

        let nextPeriodBudgetExists = existingBudgets.contains { existingBudget in
            existingBudget.category?.name == budget.category?.name
                && calendar.isDate(existingBudget.month, equalTo: nextMonth, toGranularity: .month)
        }

        if !nextPeriodBudgetExists {
            let nextBudget = budget.createNextPeriodBudget(for: nextMonth)
            modelContext.insert(nextBudget)

            do {
                try modelContext.save()
            } catch {
                Logger.logError(error, context: "Applying rollover to next period")
            }
        }
    }

    /// Get rollover summary for a budget
    /// <#Description#>
    /// - Returns: <#description#>
    func getRolloverSummary(for budget: Budget) -> BudgetRolloverSummary {
        let potentialRollover = budget.calculateRolloverAmount()
        let unusedAmount = budget.remainingAmount

        return BudgetRolloverSummary(
            budgetId: budget.id,
            unusedAmount: unusedAmount,
            potentialRollover: potentialRollover,
            rolloverEnabled: budget.rolloverEnabled,
            maxRolloverPercentage: budget.maxRolloverPercentage,
            currentRolloverAmount: budget.rolledOverAmount
        )
    }

    /// Schedule all budget-related notifications
    /// <#Description#>
    /// - Returns: <#description#>
    func scheduleBudgetNotifications(for _: [Budget]) {
        // Temporarily disabled due to compilation issues
        // NotificationManager.shared.schedulebudgetWarningNotifications(for: budgets)
        // NotificationManager.shared.scheduleRolloverNotifications(for: budgets)
        // NotificationManager.shared.scheduleSpendingPredictionNotifications(for: budgets)
    }
}

struct BudgetProgressSummary {
    let totalBudgeted: Double
    let totalSpent: Double
    let onTrackCount: Int
    let overBudgetCount: Int
    let totalBudgets: Int

    var remainingAmount: Double {
        self.totalBudgeted - self.totalSpent
    }

    var progressPercentage: Double {
        guard self.totalBudgeted > 0 else { return 0.0 }
        return self.totalSpent / self.totalBudgeted
    }
}

struct MonthlySpending {
    let month: Date
    let amount: Double
    let categoryName: String

    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self.month)
    }

    var formattedAmount: String {
        self.amount.formatted(.currency(code: "USD"))
    }
}

struct BudgetRolloverSummary {
    let budgetId: UUID
    let unusedAmount: Double
    let potentialRollover: Double
    let rolloverEnabled: Bool
    let maxRolloverPercentage: Double
    let currentRolloverAmount: Double

    var formattedUnusedAmount: String {
        self.unusedAmount.formatted(.currency(code: "USD"))
    }

    var formattedPotentialRollover: String {
        self.potentialRollover.formatted(.currency(code: "USD"))
    }

    var formattedCurrentRollover: String {
        self.currentRolloverAmount.formatted(.currency(code: "USD"))
    }
}
