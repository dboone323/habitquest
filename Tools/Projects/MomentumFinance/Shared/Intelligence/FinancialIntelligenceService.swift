import CoreML
import Foundation
import OSLog
import SwiftData
import SwiftUI

// Momentum Finance - Financial Intelligence Services
// Copyright © 2025 Momentum Finance. All rights reserved.

/// Central service that provides financial intelligence and machine learning insights
<<<<<<< HEAD
=======
///
/// This main coordinator delegates to focused component implementations:
/// - TransactionPatternAnalyzer: Pattern detection and duplicate analysis
/// - FinancialMLModels: Machine learning models and predictions
/// - FinancialInsightModels: Insight data structures and enums
/// - FinancialIntelligenceService.Helpers: Analysis algorithms (existing)
>>>>>>> 1cf3938 (Create working state for recovery)
@MainActor
class FinancialIntelligenceService: ObservableObject {
    @MainActor static let shared = FinancialIntelligenceService()

    @Published var insights: [FinancialInsight] = []
    @Published var isAnalyzing: Bool = false
    @Published var lastAnalysisDate: Date?

<<<<<<< HEAD
    // Uses static Logger methods directly
    private var transactionCategorizationModel: TransactionCategorizationModel?
    private var anomalyDetectionModel: AnomalyDetectionModel?
    private var forecastingModel: ForecastingModel?

    private init() {
        loadModels()
    }

    // MARK: - Model Loading

    private func loadModels() {
        // Load or create the transaction categorization model
        transactionCategorizationModel = TransactionCategorizationModel()

        // Load or create the anomaly detection model
        anomalyDetectionModel = AnomalyDetectionModel()

        // Load or create the forecasting model
        forecastingModel = ForecastingModel()
=======
    private let logger = Logger()
    private let mlModels = FinancialMLModels()
    private let patternAnalyzer = TransactionPatternAnalyzer()

    private init() {
        // Initialization handled by component models
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    // MARK: - Analysis Methods

    /// Performs a comprehensive analysis of financial data
<<<<<<< HEAD
    /// <#Description#>
    /// - Returns: <#description#>
=======
>>>>>>> 1cf3938 (Create working state for recovery)
    func analyzeFinancialData(modelContext: ModelContext) async {
        DispatchQueue.main.async {
            self.isAnalyzing = true
            self.insights = []
        }

        do {
<<<<<<< HEAD
            // Fetch all transactions
            let transactionsDescriptor = FetchDescriptor<FinancialTransaction>()
            let transactions = try modelContext.fetch(transactionsDescriptor)

            // Fetch all categories
            let categoriesDescriptor = FetchDescriptor<ExpenseCategory>()
            let categories = try modelContext.fetch(categoriesDescriptor)

            // Fetch all accounts
            let accountsDescriptor = FetchDescriptor<FinancialAccount>()
            let accounts = try modelContext.fetch(accountsDescriptor)

            // Fetch all budgets
            let budgetsDescriptor = FetchDescriptor<Budget>()
            let budgets = try modelContext.fetch(budgetsDescriptor)

            // Perform various analyses
            let spendingPatternInsights = analyzeSpendingPatterns(transactions: transactions, categories: categories)
            let anomalyInsights = detectAnomalies(transactions: transactions)
            let budgetInsights = analyzeBudgets(transactions: transactions, budgets: budgets)
            let forecastInsights = generateForecasts(transactions: transactions, accounts: accounts)
            let optimizationInsights = suggestOptimizations(transactions: transactions,
                                                            accounts: accounts)

            // Combine all insights and sort by priority
            var allInsights = spendingPatternInsights + anomalyInsights + budgetInsights +
                forecastInsights + optimizationInsights
=======
            // Fetch all data
            let transactionsDescriptor = FetchDescriptor<FinancialTransaction>()
            let transactions = try modelContext.fetch(transactionsDescriptor)

            let categoriesDescriptor = FetchDescriptor<ExpenseCategory>()
            let categories = try modelContext.fetch(categoriesDescriptor)

            let accountsDescriptor = FetchDescriptor<FinancialAccount>()
            let accounts = try modelContext.fetch(accountsDescriptor)

            let budgetsDescriptor = FetchDescriptor<Budget>()
            let budgets = try modelContext.fetch(budgetsDescriptor)

            // Delegate to specialized analysis methods in Helpers
            let spendingPatternInsights = analyzeSpendingPatterns(
                transactions: transactions, categories: categories)
            let anomalyInsights = detectAnomalies(transactions: transactions)
            let budgetInsights = analyzeBudgets(transactions: transactions, budgets: budgets)
            let forecastInsights = fi_generateForecasts(
                transactions: transactions, accounts: accounts)
            let optimizationInsights = suggestOptimizations(
                transactions: transactions,
                accounts: accounts)

            // Combine all insights and sort by priority
            var allInsights =
                spendingPatternInsights + anomalyInsights + budgetInsights + forecastInsights
                + optimizationInsights
>>>>>>> 1cf3938 (Create working state for recovery)
            allInsights.sort { $0.priority > $1.priority }

            // Update the UI
            DispatchQueue.main.async {
                self.insights = allInsights
                self.isAnalyzing = false
                self.lastAnalysisDate = Date()
            }
        } catch {
            print("Error analyzing financial data: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isAnalyzing = false
            }
        }
    }

    /// Categorizes a new transaction based on historical data
<<<<<<< HEAD
    /// <#Description#>
    /// - Returns: <#description#>
    func suggestCategoryForTransaction(_ transaction: FinancialTransaction) -> ExpenseCategory? {
        // Use the transaction categorization model to suggest a category
        guard let model = transactionCategorizationModel else { return nil }

        // Extract features from the transaction
        let features = extractTransactionFeatures(transaction)

        // Predict the category
        return model.predictCategory(features: features)
    }

    // MARK: - Specific Analysis Methods

    private func analyzeSpendingPatterns(transactions: [FinancialTransaction], categories: [ExpenseCategory]) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        // Group transactions by month and category
        let calendar = Calendar.current
        var monthlySpendingByCategory: [String: [Date: Double]] = [:]

        for transaction in transactions where transaction.amount < 0 {
            guard let category = transaction.category else { continue }
            let categoryId = category.id.hashValue.description

            let month = calendar.startOfMonth(for: transaction.date)

            if monthlySpendingByCategory[categoryId] == nil {
                monthlySpendingByCategory[categoryId] = [:]
            }

            let currentAmount = monthlySpendingByCategory[categoryId]?[month] ?? 0
            monthlySpendingByCategory[categoryId]?[month] = currentAmount + abs(transaction.amount)
        }

        // Analyze spending trends for each category
        for (categoryId, monthlySpending) in monthlySpendingByCategory {
            guard let category = categories.first(where: { $0.id.hashValue.description == categoryId }) else { continue }

            // Sort monthly spending by date
            let sortedSpending = monthlySpending.sorted { $0.key < $1.key }
            guard sortedSpending.count >= 2 else { continue }

            // Calculate average and last month spending
            let values = sortedSpending.map(\.value)
            let average = values.reduce(0, +) / Double(values.count)

            let lastMonthSpending = sortedSpending.last?.value ?? 0
            let previousMonthSpending = sortedSpending.count > 1 ? sortedSpending[sortedSpending.count - 2].value : 0

            // Check for significant increase
            if lastMonthSpending > average * 1.2 && lastMonthSpending > previousMonthSpending * 1.1 {
                let percentIncrease = ((lastMonthSpending - previousMonthSpending) / previousMonthSpending) * 100
                let insight = FinancialInsight(
                    title: "Increased Spending in \(category.name)",
                    description: "Your spending in \(category.name) increased by \(Int(percentIncrease))% last month.",
                    priority: .medium,
                    type: .spendingPattern,
                    relatedCategoryId: categoryId,
                    visualizationType: .lineChart,
                    data: sortedSpending.map { ($0.key.formatted(.dateTime.month(.abbreviated)), $0.value) },
                    )
                insights.append(insight)
            }

            // Check for spending trend reduction
            if lastMonthSpending < average * 0.8 && lastMonthSpending < previousMonthSpending * 0.9 {
                let percentDecrease = ((previousMonthSpending - lastMonthSpending) / previousMonthSpending) * 100
                let insight = FinancialInsight(
                    title: "Reduced Spending in \(category.name)",
                    description: "Your spending in \(category.name) decreased by \(Int(percentDecrease))% last month.",
                    priority: .low,
                    type: .positiveSpendingTrend,
                    relatedCategoryId: categoryId,
                    visualizationType: .lineChart,
                    data: sortedSpending.map { ($0.key.formatted(.dateTime.month(.abbreviated)), $0.value) },
                    )
                insights.append(insight)
            }
        }

        // Analyze top spending categories
        let totalSpendingByCategory = monthlySpendingByCategory.mapValues { monthlySpendings in
            monthlySpendings.values.reduce(0, +)
        }

        let sortedCategories = totalSpendingByCategory.sorted { $0.value > $1.value }
        if !sortedCategories.isEmpty {
            let topCategories = sortedCategories.prefix(3)
            let topCategoryData = topCategories.compactMap { categoryId, total -> (String, Double)? in
                guard let category = categories.first(where: { $0.id.hashValue.description == categoryId }) else { return nil }
                return (category.name, total)
            }

            let insight = FinancialInsight(
                title: "Top Spending Categories",
                description: "Your highest spending categories are \(topCategoryData.map(\.0).joined(separator: ", ")).",
                priority: .medium,
                type: .spendingPattern,
                visualizationType: .pieChart,
                data: topCategoryData,
                )
            insights.append(insight)
        }

        // Find recurring transactions (potential subscriptions)
        let recurringTransactions = findRecurringTransactions(transactions)
        if !recurringTransactions.isEmpty {
            let insight = FinancialInsight(
                title: "Potential Recurring Expenses",
                description: "You may have \(recurringTransactions.count) recurring payments that are not tracked as subscriptions.",
                priority: .medium,
                type: .subscriptionDetection,
                data: recurringTransactions.prefix(5).map { ($0.title, abs($0.amount)) },
                )
            insights.append(insight)
        }

        return insights
    }

    private func detectAnomalies(transactions: [FinancialTransaction]) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        // Group transactions by month and category
        let calendar = Calendar.current
        var transactionsByCategory: [String: [FinancialTransaction]] = [:]

        for transaction in transactions where transaction.amount < 0 {
            guard let category = transaction.category else { continue }
            let categoryId = category.id.hashValue.description

            if transactionsByCategory[categoryId] == nil {
                transactionsByCategory[categoryId] = []
            }

            transactionsByCategory[categoryId]?.append(transaction)
        }

        // Detect outliers within each category
        for (_, categoryTransactions) in transactionsByCategory {
            guard categoryTransactions.count >= 5 else { continue }

            let amounts = categoryTransactions.map { abs($0.amount) }
            let mean = amounts.reduce(0, +) / Double(amounts.count)
            let variance = amounts.map { pow($0 - mean, 2) }.reduce(0, +) / Double(amounts.count)
            let stdDev = sqrt(variance)

            // Find transactions that are more than 2 standard deviations away from the mean
            let outlierThreshold = mean + (2 * stdDev)
            let outliers = categoryTransactions.filter { abs($0.amount) > outlierThreshold }
                .sorted { abs($0.amount) > abs($1.amount) }

            if let topOutlier = outliers.first, let category = topOutlier.category {
                let transactionAmount = abs(topOutlier.amount)
                let percentageHigher = Int((transactionAmount / mean - 1) * 100)
                let formattedAmount = transactionAmount.formatted(.currency(code: "USD"))
                let formattedDate = topOutlier.date.formatted(date: .abbreviated, time: .omitted)

                let categoryName = category.name
                let descriptionText = "\(topOutlier.title) (\(formattedAmount)) on \(formattedDate) is \(percentageHigher)% higher than your average \(categoryName) transaction."

                let insight = FinancialInsight(
                    title: "Unusual Spending in \(categoryName)",
                    description: descriptionText,
                    priority: .high,
                    type: .anomaly,
                    relatedTransactionId: topOutlier.id.hashValue.description,
                    visualizationType: .boxPlot,
                    data: [
                        ("Average", mean),
                        ("This Transaction", transactionAmount),
                        ("Typical Range", mean + stdDev)
                    ],
                    )
                insights.append(insight)
            }
        }

        // Detect unusual transaction frequency
        let recentTransactions = transactions.filter {
            calendar.dateComponents([.day], from: $0.date, to: Date()).day ?? 0 < 30
        }

        let transactionsByDay = Dictionary(grouping: recentTransactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }

        let sortedDays = transactionsByDay.sorted { $0.key > $1.key }
        if sortedDays.count >= 7 {
            let last7Days = sortedDays.prefix(7)
            let transactionCounts = last7Days.map(\.value.count)
            let averageCount = Double(transactionCounts.reduce(0, +)) / Double(transactionCounts.count)

            if let highestDay = last7Days.max(by: { $0.value.count < $1.value.count }),
               Double(highestDay.value.count) > averageCount * 2 {
                let transactionCount = highestDay.value.count
                let percentageMore = Int((Double(transactionCount) / averageCount - 1) * 100)
                let formattedDate = highestDay.key.formatted(date: .abbreviated, time: .omitted)

                let chartData = last7Days.map { dayData in
                    (dayData.key.formatted(date: .abbreviated, time: .omitted), Double(dayData.value.count))
                }

                let insight = FinancialInsight(
                    title: "Unusual Transaction Activity",
                    description: "You had \(transactionCount) transactions on \(formattedDate), which is \(percentageMore)% more than your daily average.",
                    priority: .medium,
                    type: .anomaly,
                    visualizationType: .barChart,
                    data: chartData,
                    )
                insights.append(insight)
            }
        }

        return insights
    }

    private func analyzeBudgets(transactions: [FinancialTransaction], budgets: [Budget]) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        // Get current month transactions
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())

        let currentMonthTransactions = transactions.filter { transaction in
            let month = calendar.component(.month, from: transaction.date)
            let year = calendar.component(.year, from: transaction.date)
            return month == currentMonth && year == currentYear
        }

        // Check budget progress
        for budget in budgets {
            guard let category = budget.category else { continue }
            let categoryId = category.id.hashValue.description

            // Calculate current spending for the category
            let categoryTransactions = currentMonthTransactions.filter {
                $0.category?.id.hashValue.description == categoryId && $0.amount < 0
            }
            let totalSpent = categoryTransactions.reduce(0) { $0 + abs($1.amount) }

            // Calculate percentage of budget used
            let percentUsed = totalSpent / budget.limitAmount

            // Calculate days remaining in month
            let today = Date()
            let daysInMonth = calendar.range(of: .day, in: .month, for: Date())?.count ?? 30
            let day = calendar.component(.day, from: today)
            let daysRemaining = daysInMonth - day + 1

            // Calculate ideal percentage (based on days passed)
            let idealPercentage = Double(day - 1) / Double(daysInMonth)

            // Check if over budget
            if totalSpent >= budget.limitAmount {
                let insight = FinancialInsight(
                    title: "Budget Exceeded",
                    description: "You've exceeded your \(budget.name) budget by \((totalSpent - budget.limitAmount).formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))).",
                    priority: .critical,
                    type: .budgetAlert,
                    relatedBudgetId: budget.id.hashValue.description,
                    visualizationType: .progressBar,
                    data: [
                        ("Budget", budget.limitAmount),
                        ("Spent", totalSpent),
                        ("Overspent", totalSpent - budget.limitAmount)
                    ],
                    )
                insights.append(insight)
            }
            // Check if at risk of exceeding budget
            else if percentUsed > idealPercentage * 1.1 && percentUsed > 0.7 {
                // Calculate projected final spending
                let projectedTotal = totalSpent * Double(daysInMonth) / Double(day - 1)

                if projectedTotal > budget.limitAmount {
                    let projectedOverage = projectedTotal - budget.limitAmount
                    let remainingBudget = budget.limitAmount - totalSpent
                    let projectedOverageFormatted = projectedOverage.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
                    let remainingBudgetFormatted = remainingBudget.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))

                    let insight = FinancialInsight(
                        title: "Budget at Risk",
                        description: "At your current rate, you'll exceed your \(budget.name) budget by \(projectedOverageFormatted). You have \(remainingBudgetFormatted) left for \(daysRemaining) days.",
                        priority: .high,
                        type: .budgetAlert,
                        relatedBudgetId: budget.id.hashValue.description,
                        visualizationType: .progressBar,
                        data: [
                            ("Budget", budget.limitAmount),
                            ("Spent", totalSpent),
                            ("Projected", projectedTotal)
                        ],
                        )
                    insights.append(insight)
                }
            }
            // Check if significantly under budget
            else if percentUsed < idealPercentage * 0.5 && idealPercentage > 0.5 {
                let insight = FinancialInsight(
                    title: "Budget Underutilized",
                    description: "You've only used \(Int(percentUsed * 100))% of your \(budget.name) budget with \(daysRemaining) days remaining. Consider reallocating funds.",
                    priority: .low,
                    type: .budgetInsight,
                    relatedBudgetId: budget.id.hashValue.description,
                    visualizationType: .progressBar,
                    data: [
                        ("Budget", budget.limitAmount),
                        ("Spent", totalSpent),
                        ("Remaining", budget.limitAmount - totalSpent)
                    ],
                    )
                insights.append(insight)
            }
        }

        // Identify categories without budgets that have significant spending
        let categoriesWithBudgets = Set(budgets.compactMap { $0.category?.id.hashValue.description })
        var spendingByCategory: [String: Double] = [:]

        for transaction in currentMonthTransactions where transaction.amount < 0 {
            guard let category = transaction.category else { continue }
            let categoryId = category.id.hashValue.description
            guard !categoriesWithBudgets.contains(categoryId) else { continue }

            spendingByCategory[categoryId] = (spendingByCategory[categoryId] ?? 0) + abs(transaction.amount)
        }

        let significantSpending = spendingByCategory.filter { $0.value > 100 }
            .sorted { $0.value > $1.value }

        for (categoryId, amount) in significantSpending.prefix(3) {
            if let category = transactions.first(where: { $0.category?.id.hashValue.description == categoryId })?.category {
                let insight = FinancialInsight(
                    title: "Budget Recommendation",
                    description: "You've spent \(amount.formatted(.currency(code: "USD"))) on \(category.name) without a budget. Consider creating one.",
                    priority: .medium,
                    type: .budgetRecommendation,
                    relatedCategoryId: categoryId,
                    data: [("Amount", amount)],
                    )
                insights.append(insight)
            }
        }

        return insights
    }

    private func generateForecasts(transactions: [FinancialTransaction], accounts: [FinancialAccount]) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        // Analyze cash flow trend
        let calendar = Calendar.current
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: Date()) ?? Date()

        // Group transactions by month
        var monthlyNetCashFlow: [Date: Double] = [:]

        for transaction in transactions where transaction.date >= sixMonthsAgo {
            let month = calendar.startOfMonth(for: transaction.date)
            let currentAmount = monthlyNetCashFlow[month] ?? 0
            monthlyNetCashFlow[month] = currentAmount + transaction.amount
        }

        // Sort by date and get the trend
        let sortedMonths = monthlyNetCashFlow.sorted { $0.key < $1.key }

        if sortedMonths.count >= 3 {
            // Calculate trend
            let values = sortedMonths.map(\.value)
            var trendDirection = "stable"
            var trendPercentage = 0.0

            if values.count >= 2 {
                let latestValue = values.last ?? 0
                let previousValue = values[values.count - 2]

                if latestValue != 0 && previousValue != 0 {
                    trendPercentage = ((latestValue - previousValue) / abs(previousValue)) * 100

                    if trendPercentage > 10 {
                        trendDirection = "improving"
                    } else if trendPercentage < -10 {
                        trendDirection = "declining"
                    }
                }
            }

            // Forecast next month
            let model = SimpleRegressionModel()
            let xValues = Array(0 ..< values.count).map { Double($0) }
            let forecast = model.forecast(xValues: xValues, yValues: values, steps: 1)

            if let nextMonthForecast = forecast.first {
                let title: String
                let priority: InsightPriority

                if nextMonthForecast < 0 && trendDirection == "declining" {
                    title = "Negative Cash Flow Forecast"
                    priority = .critical
                } else if nextMonthForecast < 0 {
                    title = "Potential Negative Cash Flow"
                    priority = .high
                } else if trendDirection == "improving" {
                    title = "Improving Cash Flow"
                    priority = .low
                } else {
                    title = "Cash Flow Forecast"
                    priority = .medium
                }

                let lastMonths = sortedMonths.suffix(3).map { $0.key.formatted(.dateTime.month(.abbreviated)) }
                var forecastLabels = lastMonths

                // Add next month label
                if let lastDate = sortedMonths.last?.key,
                   let nextMonth = calendar.date(byAdding: .month, value: 1, to: lastDate) {
                    forecastLabels.append(nextMonth.formatted(.dateTime.month(.abbreviated)))
                }

                let lastValues = values.suffix(3)
                var chartData: [(String, Double)] = Array(zip(lastMonths, lastValues))
                chartData.append((forecastLabels.last ?? "Next", nextMonthForecast))

                let insight = FinancialInsight(
                    title: title,
                    description: "Your cash flow is \(trendDirection). Next month's estimated net flow is \(nextMonthForecast.formatted(.currency(code: "USD"))).",
                    priority: priority,
                    type: .forecast,
                    visualizationType: .lineChart,
                    data: chartData,
                    )
                insights.append(insight)
            }
        }

        // Generate balance forecast for each account
        for account in accounts {
            let accountTransactions = transactions.filter { $0.account?.id == account.id }
            let monthlyTransactions = Dictionary(grouping: accountTransactions) { transaction in
                calendar.startOfMonth(for: transaction.date)
            }

            // We need at least 3 months of data for a meaningful forecast
            guard monthlyTransactions.count >= 3 else { continue }

            let sortedMonths = monthlyTransactions.sorted { $0.key < $1.key }
            let monthlyNetFlow = sortedMonths.map { month, transactions in
                (month, transactions.reduce(0) { $0 + $1.amount })
            }

            // Calculate average monthly change
            let monthlyChanges = monthlyNetFlow.map(\.1)
            let averageMonthlyChange = monthlyChanges.reduce(0, +) / Double(monthlyChanges.count)

            // Forecast next 3 months
            var projectedBalance = account.balance
            var forecastData: [(String, Double)] = []

            let currentMonth = calendar.startOfMonth(for: Date())
            for i in 0 ..< 3 {
                guard let futureMonth = calendar.date(byAdding: .month, value: i + 1, to: currentMonth) else { continue }
                projectedBalance += averageMonthlyChange
                forecastData.append((futureMonth.formatted(.dateTime.month(.abbreviated)), projectedBalance))
            }

            let threeMonthPrediction = account.balance + (averageMonthlyChange * 3)

            let title: String
            let priority: InsightPriority
            let description: String

            if averageMonthlyChange < 0 && threeMonthPrediction < account.balance * 0.5 {
                title = "Critical Balance Reduction"
                priority = .critical
                description = "Your \(account.name) balance is projected to drop by \(abs(averageMonthlyChange * 3).formatted(.currency(code: account.currencyCode))) in the next 3 months."
            } else if averageMonthlyChange < 0 {
                title = "Declining Account Balance"
                priority = .high
                description = "Your \(account.name) balance is declining by approximately \(abs(averageMonthlyChange).formatted(.currency(code: account.currencyCode))) per month."
            } else if averageMonthlyChange > 0 {
                title = "Growing Account Balance"
                priority = .medium
                description = "Your \(account.name) balance is growing by approximately \(averageMonthlyChange.formatted(.currency(code: account.currencyCode))) per month."
            } else {
                title = "Stable Account Balance"
                priority = .low
                description = "Your \(account.name) balance is stable."
            }

            let insight = FinancialInsight(
                title: title,
                description: description,
                priority: priority,
                type: .forecast,
                relatedAccountId: String(account.id.hashValue),
                visualizationType: .lineChart,
                data: forecastData,
                )
            insights.append(insight)
        }

        return insights
    }

    private func suggestOptimizations(transactions: [FinancialTransaction], accounts: [FinancialAccount]) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        // Calculate idle cash in checking accounts
        let checkingAccounts = accounts.filter { $0.accountType == .checking }
        for account in checkingAccounts {
            guard account.balance > 5_000 else { continue }

            // Calculate average monthly expenses from this account
            let accountTransactions = transactions.filter { $0.account?.id == account.id && $0.amount < 0 }

            let calendar = Calendar.current
            let monthlyTransactions = Dictionary(grouping: accountTransactions) { transaction in
                calendar.startOfMonth(for: transaction.date)
            }

            // Calculate average monthly expenses
            let monthlyExpenses = monthlyTransactions.map { $0.value.reduce(0) { $0 + abs($1.amount) } }
            let averageMonthlyExpense = monthlyExpenses.isEmpty ? 0 : monthlyExpenses.reduce(0, +) / Double(monthlyExpenses.count)

            // Buffer is 2x average monthly expense
            let recommendedBuffer = averageMonthlyExpense * 2

            // If there's more than the buffer, suggest moving some to savings
            if account.balance > recommendedBuffer {
                let excessCash = account.balance - recommendedBuffer

                let insight = FinancialInsight(
                    title: "Idle Cash Detected",
                    description: "You have \(excessCash.formatted(.currency(code: account.currencyCode))) more than needed in your \(account.name). Consider moving \(excessCash.formatted(.currency(code: account.currencyCode))) to a higher-yielding savings or investment account.",
                    priority: .medium,
                    type: .optimization,
                    relatedAccountId: String(account.id.hashValue),
                    data: [
                        ("Current Balance", account.balance),
                        ("Recommended Buffer", recommendedBuffer),
                        ("Excess Cash", excessCash)
                    ],
                    )
                insights.append(insight)
            }
        }

        // Analyze credit utilization
        let creditAccounts = accounts.filter { $0.accountType == .credit }
        for account in creditAccounts {
            guard let creditLimit = account.creditLimit, creditLimit > 0 else { continue }

            let balance = abs(account.balance) // Credit balance is typically negative
            let utilization = balance / creditLimit

            if utilization > 0.3 {
                let insight = FinancialInsight(
                    title: "High Credit Utilization",
                    description: "Your credit utilization on \(account.name) is \(Int(utilization * 100))%. It's recommended to keep this under 30% to maintain a good credit score.",
                    priority: utilization > 0.7 ? .critical : .high,
                    type: .optimization,
                    relatedAccountId: String(account.id.hashValue),
                    visualizationType: .progressBar,
                    data: [
                        ("Balance", balance),
                        ("Credit Limit", creditLimit),
                        ("Utilization", utilization)
                    ],
                    )
                insights.append(insight)
            }
        }

        // Detect potential double payments
        let recentTransactions = transactions.filter { transaction in
            let calendar = Calendar.current
            return calendar.dateComponents([.day], from: transaction.date, to: Date()).day ?? 0 < 14
        }

        let duplicateSuspects = findPotentialDuplicates(recentTransactions)
        for duplicate in duplicateSuspects {
            let insight = FinancialInsight(
                title: "Potential Duplicate Payment",
                description: "You may have duplicate payments: \(duplicate.first?.title ?? "") for \((duplicate.first?.amount ?? 0).formatted(.currency(code: "USD"))) on multiple dates.",
                priority: .high,
                type: .anomaly,
                relatedTransactionId: duplicate.first?.id.hashValue.description,
                data: duplicate.map { (DateFormatter.localizedString(from: $0.date, dateStyle: .short, timeStyle: .none), abs($0.amount)) },
                )
            insights.append(insight)
        }

        return insights
    }

    // MARK: - Helper Methods

    private func findRecurringTransactions(_ transactions: [FinancialTransaction]) -> [FinancialTransaction] {
        // Group transactions by name similarity and similar amount
        var transactionsByNameAndAmount: [String: [FinancialTransaction]] = [:]

        for transaction in transactions where transaction.amount < 0 {
            // Generate a key that combines a simplified name and amount range
            let simplifiedName = transaction.title.lowercased()
                .replacingOccurrences(of: "[^a-z0-9]", with: "", options: String.CompareOptions.regularExpression)

            // Round amount to nearest dollar for grouping
            let roundedAmount = round(abs(transaction.amount) * 100) / 100

            let key = "\(simplifiedName)_\(roundedAmount)"

            if transactionsByNameAndAmount[key] == nil {
                transactionsByNameAndAmount[key] = []
            }

            transactionsByNameAndAmount[key]?.append(transaction)
        }

        // Filter for potential recurring transactions (3 or more instances with regular timing)
        var recurringTransactions: [FinancialTransaction] = []

        for (_, similarTransactions) in transactionsByNameAndAmount where similarTransactions.count >= 3 {
            // Sort by date
            let sortedTransactions = similarTransactions.sorted { $0.date < $1.date }

            // Check if the intervals between transactions are regular
            var isRegular = true
            var intervals: [TimeInterval] = []

            for i in 1 ..< sortedTransactions.count {
                let interval = sortedTransactions[i].date.timeIntervalSince(sortedTransactions[i - 1].date)
                intervals.append(interval)
            }

            // Check if the intervals are similar
            if !intervals.isEmpty {
                let averageInterval = intervals.reduce(0, +) / Double(intervals.count)

                // Check if the intervals are within 20% of the average
                for interval in intervals where abs(interval - averageInterval) > averageInterval * 0.2 {
                    isRegular = false
                    break
                }

                // Check if the interval is roughly a month
                let isMonthly = averageInterval >= 28 * 24 * 60 * 60 && averageInterval <= 31 * 24 * 60 * 60
                let isWeekly = averageInterval >= 6.5 * 24 * 60 * 60 && averageInterval <= 7.5 * 24 * 60 * 60
                let isYearly = averageInterval >= 360 * 24 * 60 * 60 && averageInterval <= 370 * 24 * 60 * 60

                if isRegular && (isMonthly || isWeekly || isYearly) {
                    recurringTransactions.append(sortedTransactions.last!)
                }
            }
        }

        return recurringTransactions
    }

    private func findPotentialDuplicates(_ transactions: [FinancialTransaction]) -> [[FinancialTransaction]] {
        // Group transactions by similar name and amount
        var transactionsByNameAndAmount: [String: [FinancialTransaction]] = [:]

        for transaction in transactions where transaction.amount < 0 {
            // Generate a key that combines a simplified name and exact amount
            let simplifiedName = transaction.title.lowercased()
                .replacingOccurrences(of: "[^a-z0-9]", with: "", options: String.CompareOptions.regularExpression)

            let exactAmount = abs(transaction.amount)
            let key = "\(simplifiedName)_\(exactAmount)"

            if transactionsByNameAndAmount[key] == nil {
                transactionsByNameAndAmount[key] = []
            }

            transactionsByNameAndAmount[key]?.append(transaction)
        }

        // Find transactions with the same name and amount that occurred close together
        var duplicateSuspects: [[FinancialTransaction]] = []

        for (_, similarTransactions) in transactionsByNameAndAmount where similarTransactions.count >= 2 {
            // Sort by date
            let sortedTransactions = similarTransactions.sorted { $0.date < $1.date }

            // Check for transactions that are less than 48 hours apart
            for i in 1 ..< sortedTransactions.count {
                let interval = sortedTransactions[i].date.timeIntervalSince(sortedTransactions[i - 1].date)
                if interval < 48 * 60 * 60 {
                    duplicateSuspects.append([sortedTransactions[i - 1], sortedTransactions[i]])
                    break
                }
            }
        }

        return duplicateSuspects
    }

    private func extractTransactionFeatures(_ transaction: FinancialTransaction) -> [String: Any] {
        var features: [String: Any] = [:]

        // Extract name features
        features["name"] = transaction.title.lowercased()

        // Extract amount features
        features["amount"] = abs(transaction.amount)
        features["is_expense"] = transaction.amount < 0

        // Extract date features
        let calendar = Calendar.current
        features["day_of_week"] = calendar.component(.weekday, from: transaction.date)
        features["month"] = calendar.component(.month, from: transaction.date)

        return features
    }
}

// MARK: - Calendar Extension

extension Calendar {
    /// <#Description#>
    /// - Returns: <#description#>
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

// MARK: - Machine Learning Models

class TransactionCategorizationModel {
    // In a real implementation, this would use CoreML or a custom model
    // For this prototype, we'll use a simplified approach

    /// <#Description#>
    /// - Returns: <#description#>
    func predictCategory(features: [String: Any]) -> ExpenseCategory? {
        // This would typically use the model to make a prediction
        // For demonstration purposes, we'll return nil
        nil
    }
}

class AnomalyDetectionModel {
    // This would use statistical methods or machine learning to detect anomalies
    // For this prototype, we'll use the SimpleRegressionModel for demonstrations
}

class ForecastingModel {
    // This would implement time series forecasting models
    // For this prototype, we'll use the SimpleRegressionModel for demonstrations
}

// MARK: - Simple Regression Model for Forecasting

class SimpleRegressionModel {
    /// <#Description#>
    /// - Returns: <#description#>
    func forecast(xValues: [Double], yValues: [Double], steps: Int) -> [Double] {
        guard xValues.count == yValues.count, xValues.count >= 2 else { return [] }

        // Simple linear regression
        let n = Double(xValues.count)

        let sumX = xValues.reduce(0, +)
        let sumY = yValues.reduce(0, +)
        let sumXY = zip(xValues, yValues).map { $0 * $1 }.reduce(0, +)
        let sumX2 = xValues.map { $0 * $0 }.reduce(0, +)

        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n

        // Generate forecasts
        var forecasts: [Double] = []
        let lastX = xValues.last ?? 0

        for step in 1 ... steps {
            let forecastX = lastX + Double(step)
            let forecastY = slope * forecastX + intercept
            forecasts.append(forecastY)
        }

        return forecasts
    }
}

// MARK: - Insights Model

/// Represents a specific financial insight generated by the analysis
struct FinancialInsight: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let priority: InsightPriority
    let type: InsightType
    let relatedAccountId: String?
    let relatedTransactionId: String?
    let relatedCategoryId: String?
    let relatedBudgetId: String?
    let visualizationType: VisualizationType?
    let data: [(String, Double)]

    init(
        title: String,
        description: String,
        priority: InsightPriority,
        type: InsightType,
        relatedAccountId: String? = nil,
        relatedTransactionId: String? = nil,
        relatedCategoryId: String? = nil,
        relatedBudgetId: String? = nil,
        visualizationType: VisualizationType? = nil,
        data: [(String, Double)] = [],
        ) {
        self.title = title
        self.description = description
        self.priority = priority
        self.type = type
        self.relatedAccountId = relatedAccountId
        self.relatedTransactionId = relatedTransactionId
        self.relatedCategoryId = relatedCategoryId
        self.relatedBudgetId = relatedBudgetId
        self.visualizationType = visualizationType
        self.data = data
    }

    // Hashable conformance
    /// <#Description#>
    /// - Returns: <#description#>
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FinancialInsight, rhs: FinancialInsight) -> Bool {
        lhs.id == rhs.id
    }
}

enum InsightPriority: String, CaseIterable, Comparable {
    case critical
    case high
    case medium
    case low

    var color: Color {
        switch self {
        case .critical:
            .red
        case .high:
            .orange
        case .medium:
            .blue
        case .low:
            .green
        }
    }

    var icon: String {
        switch self {
        case .critical:
            "exclamationmark.triangle.fill"
        case .high:
            "exclamationmark.circle.fill"
        case .medium:
            "info.circle.fill"
        case .low:
            "checkmark.circle.fill"
        }
    }

    // Comparable implementation (critical > high > medium > low)
    static func < (lhs: InsightPriority, rhs: InsightPriority) -> Bool {
        let order: [InsightPriority] = [.low, .medium, .high, .critical]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs)
        else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

enum InsightType: String, CaseIterable {
    case spendingPattern
    case positiveSpendingTrend
    case anomaly
    case budgetAlert
    case budgetInsight
    case budgetRecommendation
    case subscriptionDetection
    case forecast
    case optimization

    var icon: String {
        switch self {
        case .spendingPattern:
            "chart.line.uptrend.xyaxis"
        case .positiveSpendingTrend:
            "arrow.down.circle"
        case .anomaly:
            "exclamationmark.triangle"
        case .budgetAlert:
            "chart.pie.fill"
        case .budgetInsight:
            "chart.bar.fill"
        case .budgetRecommendation:
            "plus.circle"
        case .subscriptionDetection:
            "calendar.badge.clock"
        case .forecast:
            "chart.xyaxis.line"
        case .optimization:
            "bolt.circle"
        }
    }
}

enum VisualizationType {
    case barChart
    case lineChart
    case pieChart
    case progressBar
    case boxPlot
=======
    func suggestCategoryForTransaction(_ transaction: FinancialTransaction) -> ExpenseCategory? {
        return mlModels.suggestCategoryForTransaction(transaction)
    }

    // MARK: - Specific Analysis Methods (Delegate to Helpers)

    private func analyzeSpendingPatterns(
        transactions: [FinancialTransaction], categories: [ExpenseCategory]
    ) -> [FinancialInsight] {
        return fi_analyzeSpendingPatterns(transactions: transactions, categories: categories)
    }

    private func detectAnomalies(transactions: [FinancialTransaction]) -> [FinancialInsight] {
        return fi_detectAnomalies(transactions: transactions)
    }

    private func analyzeBudgets(transactions: [FinancialTransaction], budgets: [Budget])
        -> [FinancialInsight]
    {
        return fi_analyzeBudgets(transactions: transactions, budgets: budgets)
    }

    // Forecasting is implemented canonically in
    // FinancialIntelligenceService.Forecasting.swift — use fi_generateForecasts to call it.

    private func suggestOptimizations(
        transactions: [FinancialTransaction], accounts: [FinancialAccount]
    ) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        insights.append(
            contentsOf: fi_suggestIdleCashInsights(transactions: transactions, accounts: accounts))
        insights.append(contentsOf: fi_suggestCreditUtilizationInsights(accounts: accounts))
        insights.append(contentsOf: fi_suggestDuplicatePaymentInsights(transactions: transactions))

        return insights
    }
>>>>>>> 1cf3938 (Create working state for recovery)
}
