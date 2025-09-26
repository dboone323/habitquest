// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Observation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class GoalsAndReportsViewModel {
    private var modelContext: ModelContext?

    /// <#Description#>
    /// - Returns: <#description#>
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// Get completed savings goals
    /// <#Description#>
    /// - Returns: <#description#>
    func completedGoals(_ goals: [SavingsGoal]) -> [SavingsGoal] {
        goals.filter(\.isCompleted)
    }

    /// Get active savings goals
    /// <#Description#>
    /// - Returns: <#description#>
    func activeGoals(_ goals: [SavingsGoal]) -> [SavingsGoal] {
        goals.filter { !$0.isCompleted }
    }

    /// Get goals sorted by progress
    /// <#Description#>
    /// - Returns: <#description#>
    func goalsByProgress(_ goals: [SavingsGoal]) -> [SavingsGoal] {
        goals.sorted { $0.progressPercentage > $1.progressPercentage }
    }

    /// Calculate total savings across all goals
    /// <#Description#>
    /// - Returns: <#description#>
    func totalSavings(_ goals: [SavingsGoal]) -> Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }

    /// Calculate total target amount across all goals
    /// <#Description#>
    /// - Returns: <#description#>
    func totalTargetAmount(_ goals: [SavingsGoal]) -> Double {
        goals.reduce(0) { $0 + $1.targetAmount }
    }

    /// Get overall savings progress
    /// <#Description#>
    /// - Returns: <#description#>
    func overallSavingsProgress(_ goals: [SavingsGoal]) -> Double {
        let totalTarget = self.totalTargetAmount(goals)
        guard totalTarget > 0 else { return 0.0 }
        return self.totalSavings(goals) / totalTarget
    }

    /// Create a new savings goal
    func createSavingsGoal(
        name: String,
        targetAmount: Double,
        targetDate: Date? = nil,
        notes: String? = nil,
    ) {
        guard let modelContext else { return }

        let goal = SavingsGoal(
            name: name,
            targetAmount: targetAmount,
            targetDate: targetDate,
            notes: notes,
        )

        modelContext.insert(goal)

        do {
            try modelContext.save()
        } catch {
            Logger.logError(error, context: "Error creating savings goal")
        }
    }

    /// Add funds to a savings goal
    /// <#Description#>
    /// - Returns: <#description#>
    func addFundsToGoal(_ goal: SavingsGoal, amount: Double) {
        goal.addFunds(amount)

        do {
            try self.modelContext?.save()
        } catch {
            Logger.logError(error, context: "Adding funds to goal")
        }
    }

    /// Remove funds from a savings goal
    /// <#Description#>
    /// - Returns: <#description#>
    func removeFundsFromGoal(_ goal: SavingsGoal, amount: Double) {
        goal.removeFunds(amount)

        do {
            try self.modelContext?.save()
        } catch {
            Logger.logError(error, context: "Removing funds from goal")
        }
    }

    /// Delete a savings goal
    /// <#Description#>
    /// - Returns: <#description#>
    func deleteSavingsGoal(_ goal: SavingsGoal) {
        guard let modelContext else { return }

        modelContext.delete(goal)

        do {
            try modelContext.save()
        } catch {
            Logger.logError(error, context: "Deleting savings goal")
        }
    }

    /// Get spending report for a time period
    func spendingReport(
        _ transactions: [FinancialTransaction],
        for period: DateInterval,
    ) -> SpendingReport {
        let periodTransactions = transactions.filter { period.contains($0.date) }

        // Calculate totals in a single pass
        var income = 0.0
        var expenses = 0.0
        var categorySpending: [String: Double] = [:]

        for transaction in periodTransactions {
            switch transaction.transactionType {
            case .income:
                income += transaction.amount
            case .expense:
                expenses += transaction.amount
                let categoryName = transaction.category?.name ?? "Uncategorized"
                categorySpending[categoryName, default: 0] += transaction.amount
            case .transfer:
                continue
            }
        }

        return SpendingReport(
            period: period,
            totalIncome: income,
            totalExpenses: expenses,
            netIncome: income - expenses,
            categorySpending: categorySpending,
            transactionCount: periodTransactions.count,
        )
    }

    /// Get monthly spending trend
    func monthlySpendingTrend(
        _ transactions: [FinancialTransaction],
        months: Int = 6,
    ) -> [MonthlySpendingData] {
        let calendar = Calendar.current
        let now = Date()

        // Pre-group transactions by month for better performance
        let monthlyGroups = Dictionary(grouping: transactions) { transaction in
            calendar.date(from: calendar.dateComponents([.year, .month], from: transaction.date))
        }

        return (0 ..< months).compactMap { i in
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now),
                  let monthKey = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))
            else {
                return nil
            }

            let monthTransactions = monthlyGroups[monthKey] ?? []

            let income = monthTransactions
                .filter { $0.transactionType == .income }
                .reduce(0.0) { $0 + $1.amount }

            let expenses = monthTransactions
                .filter { $0.transactionType == .expense }
                .reduce(0.0) { $0 + $1.amount }

            return MonthlySpendingData(
                month: monthDate,
                income: income,
                expenses: expenses,
                netIncome: income - expenses,
            )
        }.reversed()
    }

    /// Get category spending comparison
    func categorySpendingComparison(
        _ transactions: [FinancialTransaction],
        currentPeriod: DateInterval,
        previousPeriod: DateInterval,
    ) -> [CategorySpendingComparison] {
        let currentSpending = self.getCategorySpending(transactions, for: currentPeriod)
        let previousSpending = self.getCategorySpending(transactions, for: previousPeriod)

        let allCategories = Set(currentSpending.keys).union(Set(previousSpending.keys))

        return allCategories.map { category in
            let current = currentSpending[category] ?? 0
            let previous = previousSpending[category] ?? 0
            let change = current - previous
            let percentageChange = previous > 0 ? (change / previous) * 100 : 0

            return CategorySpendingComparison(
                categoryName: category,
                currentAmount: current,
                previousAmount: previous,
                change: change,
                percentageChange: percentageChange,
            )
        }
        .sorted { $0.currentAmount > $1.currentAmount }
    }

    private func getCategorySpending(
        _ transactions: [FinancialTransaction],
        for period: DateInterval,
    ) -> [String: Double] {
        let filteredTransactions = transactions.filter {
            $0.transactionType == .expense && period.contains($0.date)
        }

        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            transaction.category?.name ?? "Uncategorized"
        }

        return grouped.mapValues { transactions in
            transactions.reduce(0.0) { $0 + $1.amount }
        }
    }

    /// Get budget vs actual spending report
    /// <#Description#>
    /// - Returns: <#description#>
    func budgetVsActualReport(_ budgets: [Budget]) -> [BudgetVsActual] {
        budgets.map { budget in
            BudgetVsActual(
                categoryName: budget.category?.name ?? "Unknown",
                budgetedAmount: budget.limitAmount,
                actualAmount: budget.spentAmount,
                difference: budget.remainingAmount,
                isOverBudget: budget.isOverBudget,
            )
        }
        .sorted { $0.actualAmount > $1.actualAmount }
    }
}

// MARK: - Report Data Models

struct SpendingReport {
    let period: DateInterval
    let totalIncome: Double
    let totalExpenses: Double
    let netIncome: Double
    let categorySpending: [String: Double]
    let transactionCount: Int

    var formattedPeriod: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return
            "\(formatter.string(from: self.period.start)) - \(formatter.string(from: self.period.end))"
    }

    var formattedTotalIncome: String {
        self.totalIncome.formatted(.currency(code: "USD"))
    }

    var formattedTotalExpenses: String {
        self.totalExpenses.formatted(.currency(code: "USD"))
    }

    var formattedNetIncome: String {
        self.netIncome.formatted(.currency(code: "USD"))
    }

    var topSpendingCategories: [(String, Double)] {
        self.categorySpending.sorted { $0.value > $1.value }
    }
}

struct MonthlySpendingData {
    let month: Date
    let income: Double
    let expenses: Double
    let netIncome: Double

    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self.month)
    }

    var formattedIncome: String {
        self.income.formatted(.currency(code: "USD"))
    }

    var formattedExpenses: String {
        self.expenses.formatted(.currency(code: "USD"))
    }

    var formattedNetIncome: String {
        self.netIncome.formatted(.currency(code: "USD"))
    }
}

struct CategorySpendingComparison {
    let categoryName: String
    let currentAmount: Double
    let previousAmount: Double
    let change: Double
    let percentageChange: Double

    var formattedCurrentAmount: String {
        self.currentAmount.formatted(.currency(code: "USD"))
    }

    var formattedPreviousAmount: String {
        self.previousAmount.formatted(.currency(code: "USD"))
    }

    var formattedChange: String {
        let sign = self.change >= 0 ? "+" : ""
        return "\(sign)\(self.change.formatted(.currency(code: "USD")))"
    }

    var formattedPercentageChange: String {
        let sign = self.percentageChange >= 0 ? "+" : ""
        return "\(sign)\(self.percentageChange.formatted(.number.precision(.fractionLength(1))))%"
    }

    var isIncreased: Bool {
        self.change > 0
    }
}

struct BudgetVsActual {
    let categoryName: String
    let budgetedAmount: Double
    let actualAmount: Double
    let difference: Double
    let isOverBudget: Bool

    var formattedBudgetedAmount: String {
        self.budgetedAmount.formatted(.currency(code: "USD"))
    }

    var formattedActualAmount: String {
        self.actualAmount.formatted(.currency(code: "USD"))
    }

    var formattedDifference: String {
        let sign = self.difference >= 0 ? "+" : ""
        return "\(sign)\(self.difference.formatted(.currency(code: "USD")))"
    }

    var performanceDescription: String {
        if self.isOverBudget {
            "Over by \(abs(self.difference).formatted(.currency(code: "USD")))"
        } else {
            "Under by \(self.difference.formatted(.currency(code: "USD")))"
        }
    }
}
