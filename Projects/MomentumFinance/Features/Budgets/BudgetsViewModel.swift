// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
public final class BudgetsViewModel {
    private var modelContext: ModelContext?

    // MARK: - AI Insights Properties
    var budgetInsights: [BudgetInsight] = []
    var spendingPredictions: [SpendingPrediction] = []
    var isAnalyzingInsights = false

    // MARK: - Private Properties
    private let insightsService: FinancialInsightsService

    public init() {
        self.insightsService = ServiceLocator.shared.financialInsightsService
    }

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
        let unusedAmount = max(0, budget.limitAmount - budget.spentAmount)

        return BudgetRolloverSummary(
            budgetId: budget.id,
            unusedAmount: unusedAmount,
            potentialRollover: potentialRollover,
            rolloverEnabled: budget.rolloverEnabled,
            maxRolloverPercentage: budget.maxRolloverPercentage,
            currentRolloverAmount: budget.rolledOverAmount
        )
    }

    // MARK: - AI Insights Methods

    /// Load AI-powered insights for budget performance and recommendations
    func loadAIInsights() async {
        guard let modelContext else { return }

        isAnalyzingInsights = true
        defer { isAnalyzingInsights = false }

        do {
            // For budget view, we'll use a generic user ID since we're analyzing all budgets
            let userId = "all_users" // In a real app, this would be the current user

            // Fetch all budgets for analysis
            let budgetDescriptor = FetchDescriptor<Budget>()
            let allBudgets = try modelContext.fetch(budgetDescriptor)

            // Generate budget insights for each budget
            var insights: [BudgetInsight] = []
            var predictions: [SpendingPrediction] = []

            for budget in allBudgets {
                // Get budget insights from AI service
                let budgetInsights = try await insightsService.getBudgetInsights(
                    for: budget.id,
                    timeRange: DateInterval(start: budget.month, end: Date())
                )

                // Convert to BudgetInsight model
                let insight = BudgetInsight(
                    budgetId: budget.id,
                    budgetName: budget.name,
                    utilizationRate: budgetInsights.utilizationRate,
                    recommendations: budgetInsights.recommendations,
                    alerts: budgetInsights.alerts,
                    trendDirection: budgetInsights.trendAnalysis
                )
                insights.append(insight)

                // Generate spending predictions for this budget's category
                if let category = budget.category {
                    let categoryPredictions = try await generateSpendingPredictions(for: category, budget: budget)
                    predictions.append(contentsOf: categoryPredictions)
                }
            }

            self.budgetInsights = insights
            self.spendingPredictions = predictions

        } catch {
            Logger.logError(error, context: "Loading AI budget insights")
            // Don't set error state here as it's not critical for basic functionality
        }
    }

    /// Generate spending predictions for a budget category
    private func generateSpendingPredictions(for category: ExpenseCategory, budget: Budget) async throws -> [SpendingPrediction] {
        // Use AI service to predict future spending for this category
        let userId = "all_users" // In a real app, this would be the current user
        let predictions = try await insightsService.predictFutureExpenses(for: userId, months: 3)

        // Convert to SpendingPrediction model
        return predictions.predictions.enumerated().map { index, amount in
            let predictionDate = Calendar.current.date(byAdding: .month, value: index + 1, to: Date()) ?? Date()
            return SpendingPrediction(
                categoryName: category.name,
                predictedAmount: amount,
                predictionDate: predictionDate,
                confidence: predictions.modelAccuracy,
                budgetLimit: budget.limitAmount
            )
        }
    }

    // MARK: - AI Insights Computed Properties

    /// Get budget insights summary
    var budgetInsightsSummary: String {
        guard !budgetInsights.isEmpty else {
            return isAnalyzingInsights ? "Analyzing budget insights..." : "No budget insights available"
        }

        let overBudgetCount = budgetInsights.filter { $0.utilizationRate > 1.0 }.count
        let atRiskCount = budgetInsights.filter { $0.utilizationRate > 0.8 && $0.utilizationRate <= 1.0 }.count
        let healthyCount = budgetInsights.filter { $0.utilizationRate <= 0.8 }.count

        return "Budget Health: \(healthyCount) healthy, \(atRiskCount) at risk, \(overBudgetCount) over budget"
    }

    /// Get optimization recommendations
    var optimizationRecommendations: [String] {
        budgetInsights.flatMap { $0.recommendations }
    }

    /// Get risk alerts
    var riskAlerts: [BudgetAlert] {
        budgetInsights.flatMap { $0.alerts }
    }

    /// Get budgets at risk (over 80% utilization)
    var atRiskBudgets: [BudgetInsight] {
        budgetInsights.filter { $0.utilizationRate > 0.8 }
    }

    /// Get over-budget insights
    var overBudgetInsights: [BudgetInsight] {
        budgetInsights.filter { $0.utilizationRate > 1.0 }
    }

    /// Get spending predictions for next month
    var nextMonthPredictions: [SpendingPrediction] {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        return spendingPredictions.filter { prediction in
            Calendar.current.isDate(prediction.predictionDate, equalTo: nextMonth, toGranularity: .month)
        }
    }

    /// Refresh budgets and AI insights
    func refresh() async {
        await loadAIInsights()
    }

    /// Schedule all budget-related notifications
    /// <#Description#>
    /// - Returns: <#description#>
    public func scheduleBudgetNotifications(for _: [Budget]) {
        // Temporarily disabled due to compilation issues
        // NotificationManager.shared.schedulebudgetWarningNotifications(for: budgets)
        // NotificationManager.shared.scheduleRolloverNotifications(for: budgets)
        // NotificationManager.shared.scheduleSpendingPredictionNotifications(for: budgets)
    }
}

// MARK: - AI Insights Models

/// Budget insight model for AI analysis
struct BudgetInsight {
    let budgetId: UUID
    let budgetName: String
    let utilizationRate: Double
    let recommendations: [String]
    let alerts: [BudgetAlert]
    let trendDirection: TrendDirection

    var utilizationPercentage: Int {
        Int(utilizationRate * 100)
    }

    var isOverBudget: Bool {
        utilizationRate > 1.0
    }

    var isAtRisk: Bool {
        utilizationRate > 0.8 && utilizationRate <= 1.0
    }

    var statusColor: String {
        if isOverBudget {
            return "red"
        } else if isAtRisk {
            return "orange"
        } else {
            return "green"
        }
    }
}

/// Spending prediction model
struct SpendingPrediction {
    let categoryName: String
    let predictedAmount: Double
    let predictionDate: Date
    let confidence: Double
    let budgetLimit: Double

    var confidencePercentage: Int {
        Int(confidence * 100)
    }

    var isOverBudget: Bool {
        predictedAmount > budgetLimit
    }

    var formattedPredictedAmount: String {
        predictedAmount.formatted(.currency(code: "USD"))
    }

    var formattedPredictionDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: predictionDate)
    }
}

/// Budget alert model
struct BudgetAlert {
    let type: AlertType
    let severity: AlertSeverity
    let message: String
    let threshold: Double
    let currentValue: Double

    enum AlertType {
        case budgetExceeded
        case budgetWarning
        case spendingSpike
        case trendWarning
    }

    enum AlertSeverity {
        case info
        case warning
        case error
    }
}

/// Trend direction for budget analysis
enum TrendDirection {
    case increasing
    case decreasing
    case stable
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
