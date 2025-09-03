// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

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
        budgetsForMonth(budgets, month: month).reduce(0) { $0 + $1.limitAmount }
    }

    /// Get total spent amount for budgets in a month
    /// <#Description#>
    /// - Returns: <#description#>
    func totalSpentAmount(_ budgets: [Budget], for month: Date) -> Double {
        budgetsForMonth(budgets, month: month).reduce(0) { $0 + $1.spentAmount }
    }

    /// Get remaining budget for a month
    /// <#Description#>
    /// - Returns: <#description#>
    func remainingBudget(_ budgets: [Budget], for month: Date) -> Double {
        let monthBudgets = budgetsForMonth(budgets, month: month)
        let totalBudgeted = monthBudgets.reduce(0) { $0 + $1.limitAmount }
        let totalSpent = monthBudgets.reduce(0) { $0 + $1.spentAmount }
        return totalBudgeted - totalSpent
    }

    /// Check if any budgets are over limit
    /// <#Description#>
    /// - Returns: <#description#>
    func hasOverBudgetCategories(_ budgets: [Budget], for month: Date) -> Bool {
        budgetsForMonth(budgets, month: month).contains { $0.isOverBudget }
    }

    /// Get categories that are over budget
    /// <#Description#>
    /// - Returns: <#description#>
    func overBudgetCategories(_ budgets: [Budget], for month: Date) -> [Budget] {
        budgetsForMonth(budgets, month: month).filter(\.isOverBudget)
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
            budget.category?.name == category.name &&
                calendar.isDate(budget.month, equalTo: month, toGranularity: .month)
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
            try modelContext?.save()
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
        let monthBudgets = budgetsForMonth(budgets, month: month)

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
<<<<<<< HEAD
            )
=======
        )
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    /// Get spending trend for categories
    /// <#Description#>
    /// - Returns: <#description#>
    func spendingTrend(for category: ExpenseCategory, months: Int = 6) -> [MonthlySpending] {
        guard modelContext != nil else { return [] }

        let calendar = Calendar.current
        let now = Date()
        var trend: [MonthlySpending] = []

        for i in 0 ..< months {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }

            let spent = category.totalSpent(for: monthDate)
            let monthSpending = MonthlySpending(
                month: monthDate,
                amount: spent,
                categoryName: category.name,
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
            trend.insert(monthSpending, at: 0)
        }

        return trend
    }
}

struct BudgetProgressSummary {
    let totalBudgeted: Double
    let totalSpent: Double
    let onTrackCount: Int
    let overBudgetCount: Int
    let totalBudgets: Int

    var remainingAmount: Double {
        totalBudgeted - totalSpent
    }

    var progressPercentage: Double {
        guard totalBudgeted > 0 else { return 0.0 }
        return totalSpent / totalBudgeted
    }
}

struct MonthlySpending {
    let month: Date
    let amount: Double
    let categoryName: String

    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: month)
    }

    var formattedAmount: String {
        amount.formatted(.currency(code: "USD"))
    }
}
