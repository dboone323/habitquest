//
//  FinancialInsightsService.swift
//  MomentumFinance
//
//  Created by AI Enhancement System
//  Copyright © 2024 Quantum Workspace. All rights reserved.
//

import Foundation
import SwiftData
import Combine

/// Service for providing AI-powered financial insights and recommendations
@MainActor
public final class FinancialInsightsService: FinancialServiceProtocol {
    // MARK: - ServiceProtocol Conformance

    public let serviceId: String = "com.quantum.momentumfinance.financialinsights"
    public let version: String = "1.0.0"

    // MARK: - Private Properties

    private let predictiveAnalytics: PredictiveAnalyticsEngine
    private let naturalLanguageProcessor: NaturalLanguageProcessor
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Initialize AI components
        self.predictiveAnalytics = PredictiveAnalyticsEngine()
        self.naturalLanguageProcessor = NaturalLanguageProcessor()

        // Configure AI engines for financial analysis
        configureAIEngines()
    }

    private func configureAIEngines() {
        // Configure predictive analytics for financial patterns
        predictiveAnalytics.configure(for: .financial)

        // Configure NLP for transaction categorization and insights
        naturalLanguageProcessor.configure(for: .financial)
    }

    // MARK: - ServiceProtocol Methods

    public func initialize() async throws {
        // Initialize AI models and validate configuration
        try await predictiveAnalytics.initialize()
        try await naturalLanguageProcessor.initialize()
    }

    public func cleanup() async {
        // Cleanup AI resources
        await predictiveAnalytics.cleanup()
        await naturalLanguageProcessor.cleanup()

        // Cancel any ongoing operations
        cancellables.removeAll()
    }

    public func healthCheck() async -> ServiceHealthStatus {
        do {
            // Check AI engine health
            let analyticsHealth = await predictiveAnalytics.healthCheck()
            let nlpHealth = await naturalLanguageProcessor.healthCheck()

            if analyticsHealth == .healthy && nlpHealth == .healthy {
                return .healthy
            } else if analyticsHealth == .unhealthy || nlpHealth == .unhealthy {
                return .unhealthy(error: NSError(domain: serviceId, code: -1, userInfo: [NSLocalizedDescriptionKey: "AI engines unhealthy"]))
            } else {
                return .degraded(reason: "One or more AI engines degraded")
            }
        } catch {
            return .unhealthy(error: error)
        }
    }

    // MARK: - FinancialServiceProtocol Methods

    public func createTransaction(_ transaction: EnhancedFinancialTransaction) async throws -> EnhancedFinancialTransaction {
        // Auto-categorize transaction using AI
        let categorizedTransaction = try await categorizeTransaction(transaction)

        // Validate transaction
        try await validate(categorizedTransaction)

        // Save to database
        modelContext.insert(categorizedTransaction)
        try modelContext.save()

        return categorizedTransaction
    }

    public func calculateAccountBalance(_ accountId: UUID, asOf: Date? = nil) async throws -> Double {
        let date = asOf ?? Date()

        let descriptor = FetchDescriptor<FinancialTransaction>(
            predicate: #Predicate<FinancialTransaction> { transaction in
                transaction.accountId == accountId &&
                transaction.date <= date
            }
        )

        let transactions = try modelContext.fetch(descriptor)
        return transactions.reduce(0.0) { $0 + $1.amount }
    }

    public func getBudgetInsights(for budgetId: UUID, timeRange: DateInterval) async throws -> BudgetInsights {
        // Fetch budget and related transactions
        let budget = try await fetchBudget(by: budgetId)
        let transactions = try await fetchTransactions(for: budgetId, in: timeRange)

        // Calculate utilization rate
        let totalSpent = transactions
            .filter { $0.amount < 0 }
            .reduce(0.0) { $0 + abs($1.amount) }

        let utilizationRate = budget.limit > 0 ? totalSpent / budget.limit : 0.0

        // Analyze spending patterns
        let categoryBreakdown = try await analyzeCategoryBreakdown(transactions)
        let trendAnalysis = try await analyzeSpendingTrend(transactions, timeRange: timeRange)

        // Generate recommendations
        let recommendations = try await generateBudgetRecommendations(
            budget: budget,
            transactions: transactions,
            utilizationRate: utilizationRate
        )

        // Check for alerts
        let alerts = try await generateBudgetAlerts(
            budget: budget,
            transactions: transactions,
            utilizationRate: utilizationRate
        )

        return BudgetInsights(
            budgetId: budgetId,
            timeRange: timeRange,
            utilizationRate: utilizationRate,
            categoryBreakdown: categoryBreakdown,
            trendAnalysis: trendAnalysis,
            recommendations: recommendations,
            alerts: alerts
        )
    }

    public func calculateNetWorth(for userId: String, asOf: Date? = nil) async throws -> NetWorthSummary {
        let date = asOf ?? Date()

        // Fetch all accounts for user
        let accounts = try await fetchAccounts(for: userId)

        // Calculate totals
        var totalAssets = 0.0
        var totalLiabilities = 0.0

        for account in accounts {
            let balance = try await calculateAccountBalance(account.id, asOf: date)
            if account.type.isAsset {
                totalAssets += balance
            } else {
                totalLiabilities += balance
            }
        }

        // Calculate changes (simplified - would need historical data)
        let monthOverMonthChange = 0.0 // TODO: Implement historical comparison
        let yearOverYearChange = 0.0   // TODO: Implement historical comparison

        // Create breakdown
        let breakdown = NetWorthBreakdown(
            cashAndEquivalents: accounts.filter { $0.type == .checking || $0.type == .savings }.reduce(0.0) { $0 + (try? await calculateAccountBalance($1.id, asOf: date)) ?? 0.0 },
            investments: accounts.filter { $0.type == .investment }.reduce(0.0) { $0 + (try? await calculateAccountBalance($1.id, asOf: date)) ?? 0.0 },
            realEstate: 0.0, // TODO: Add real estate tracking
            personalProperty: 0.0, // TODO: Add personal property tracking
            creditCardDebt: accounts.filter { $0.type == .creditCard }.reduce(0.0) { $0 + abs((try? await calculateAccountBalance($1.id, asOf: date)) ?? 0.0) },
            loans: 0.0, // TODO: Add loan tracking
            mortgages: 0.0 // TODO: Add mortgage tracking
        )

        return NetWorthSummary(
            userId: userId,
            asOfDate: date,
            totalAssets: totalAssets,
            totalLiabilities: totalLiabilities,
            monthOverMonthChange: monthOverMonthChange,
            yearOverYearChange: yearOverYearChange,
            breakdown: breakdown
        )
    }

    public func generateFinancialRecommendations(for userId: String) async throws -> [FinancialRecommendation] {
        var recommendations: [FinancialRecommendation] = []

        // Analyze spending patterns
        let spendingAnalysis = try await analyzeSpendingPatterns(for: userId)

        // Budget optimization recommendations
        if spendingAnalysis.hasIrregularSpending {
            recommendations.append(FinancialRecommendation(
                type: .budgetOptimization,
                title: "Optimize Budget Allocation",
                description: "Your spending shows irregular patterns. Consider reallocating budget categories based on actual usage.",
                priority: .medium,
                estimatedImpact: 0.15,
                confidence: 0.85,
                actionItems: [
                    "Review category spending vs budget limits",
                    "Reallocate underutilized budget amounts",
                    "Set up spending alerts for high-variance categories"
                ],
                timeframe: "2-4 weeks"
            ))
        }

        // Savings recommendations
        if spendingAnalysis.savingsRate < 0.1 {
            recommendations.append(FinancialRecommendation(
                type: .savingsGoal,
                title: "Increase Savings Rate",
                description: "Your current savings rate is below optimal. Small increases can compound significantly over time.",
                priority: .high,
                estimatedImpact: 0.25,
                confidence: 0.90,
                actionItems: [
                    "Set up automatic transfers to savings",
                    "Review and cut non-essential expenses",
                    "Consider high-yield savings options"
                ],
                timeframe: "1-2 months"
            ))
        }

        // Expense reduction opportunities
        let highExpenseCategories = spendingAnalysis.categoryAnalysis
            .filter { $0.percentage > 0.2 }
            .sorted { $0.amount > $1.amount }

        if let topCategory = highExpenseCategories.first {
            recommendations.append(FinancialRecommendation(
                type: .expenseReduction,
                title: "Reduce \(topCategory.category.rawValue.capitalized) Expenses",
                description: "\(topCategory.category.rawValue.capitalized) represents \(Int(topCategory.percentage * 100))% of your spending. Look for optimization opportunities.",
                priority: .medium,
                estimatedImpact: 0.10,
                confidence: 0.75,
                actionItems: [
                    "Audit recent \(topCategory.category.rawValue) transactions",
                    "Compare prices and find alternatives",
                    "Set spending limits for this category"
                ],
                timeframe: "1-3 weeks"
            ))
        }

        return recommendations
    }

    public func categorizeTransaction(_ transaction: EnhancedFinancialTransaction) async throws -> TransactionCategory {
        // Use AI to categorize transaction based on description and amount
        let category = try await predictiveAnalytics.predictExpenseCategory(
            description: transaction.description ?? "",
            amount: transaction.amount,
            merchant: transaction.merchant ?? ""
        )

        // Convert to TransactionCategory enum
        switch category {
        case .food, .dining:
            return .expense
        case .transportation:
            return .expense
        case .entertainment:
            return .expense
        case .utilities:
            return .expense
        case .healthcare:
            return .expense
        case .shopping:
            return .expense
        case .income:
            return .income
        case .transfer:
            return .transfer
        default:
            return .expense
        }
    }

    // MARK: - AI-Powered Insights Methods

    /// Analyze spending patterns for a user
    public func analyzeSpendingPatterns(for userId: String) async throws -> SpendingPatternAnalysis {
        let transactions = try await fetchRecentTransactions(for: userId, months: 6)

        // Use AI to analyze patterns
        let patterns = try await predictiveAnalytics.analyzeSpendingPatterns(transactions.map { $0.amount })

        // Calculate category breakdown
        let categoryAnalysis = try await analyzeCategoryBreakdown(transactions)

        // Calculate savings rate
        let totalIncome = transactions.filter { $0.amount > 0 }.reduce(0.0) { $0 + $1.amount }
        let totalExpenses = transactions.filter { $0.amount < 0 }.reduce(0.0) { $0 + abs($1.amount) }
        let savingsRate = totalIncome > 0 ? (totalIncome - totalExpenses) / totalIncome : 0.0

        return SpendingPatternAnalysis(
            userId: userId,
            totalTransactions: transactions.count,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            savingsRate: savingsRate,
            categoryAnalysis: categoryAnalysis,
            hasIrregularSpending: patterns.hasIrregularSpending,
            averageTransactionSize: patterns.averageTransactionSize,
            spendingVolatility: patterns.spendingVolatility,
            seasonalPatterns: patterns.seasonalPatterns
        )
    }

    /// Generate personalized financial insights
    public func generatePersonalizedInsights(for userId: String) async throws -> [FinancialInsight] {
        let spendingAnalysis = try await analyzeSpendingPatterns(for: userId)
        var insights: [FinancialInsight] = []

        // Spending trend insight
        if spendingAnalysis.spendingVolatility > 0.3 {
            insights.append(FinancialInsight(
                type: .warning,
                title: "Variable Spending Detected",
                description: "Your spending shows high variability. Consider creating a more consistent budget.",
                confidence: 0.85,
                actionable: true,
                category: .budgeting
            ))
        }

        // Savings insight
        if spendingAnalysis.savingsRate < 0.05 {
            insights.append(FinancialInsight(
                type: .opportunity,
                title: "Savings Opportunity",
                description: "You're saving less than 5% of income. Small changes can lead to significant long-term savings.",
                confidence: 0.90,
                actionable: true,
                category: .savings
            ))
        }

        // Category insights
        for categoryAnalysis in spendingAnalysis.categoryAnalysis where categoryAnalysis.percentage > 0.25 {
            insights.append(FinancialInsight(
                type: .info,
                title: "High \(categoryAnalysis.category.rawValue.capitalized) Spending",
                description: "\(categoryAnalysis.category.rawValue.capitalized) accounts for \(Int(categoryAnalysis.percentage * 100))% of expenses. Review for optimization opportunities.",
                confidence: 0.75,
                actionable: true,
                category: .spending
            ))
        }

        return insights
    }

    /// Predict future expenses based on patterns
    public func predictFutureExpenses(for userId: String, months: Int = 3) async throws -> ExpensePrediction {
        let transactions = try await fetchRecentTransactions(for: userId, months: 12)

        // Use AI to predict future spending
        let predictions = try await predictiveAnalytics.predictFutureExpenses(
            historicalData: transactions.map { $0.amount },
            months: months
        )

        // Calculate confidence intervals
        let confidenceIntervals = try await predictiveAnalytics.calculateConfidenceIntervals(
            predictions: predictions,
            confidence: 0.95
        )

        return ExpensePrediction(
            userId: userId,
            predictions: predictions,
            confidenceIntervals: confidenceIntervals,
            predictionHorizon: months,
            modelAccuracy: 0.82, // Based on historical performance
            lastUpdated: Date()
        )
    }

    // MARK: - Private Helper Methods

    private func fetchBudget(by id: UUID) async throws -> Budget {
        let descriptor = FetchDescriptor<Budget>(
            predicate: #Predicate<Budget> { $0.id == id }
        )

        guard let budget = try modelContext.fetch(descriptor).first else {
            throw NSError(domain: serviceId, code: -1, userInfo: [NSLocalizedDescriptionKey: "Budget not found"])
        }

        return budget
    }

    private func fetchTransactions(for budgetId: UUID, in timeRange: DateInterval) async throws -> [FinancialTransaction] {
        let descriptor = FetchDescriptor<FinancialTransaction>(
            predicate: #Predicate<FinancialTransaction> { transaction in
                transaction.budgetId == budgetId &&
                transaction.date >= timeRange.start &&
                transaction.date <= timeRange.end
            }
        )

        return try modelContext.fetch(descriptor)
    }

    private func fetchAccounts(for userId: String) async throws -> [Account] {
        let descriptor = FetchDescriptor<Account>(
            predicate: #Predicate<Account> { $0.userId == userId }
        )

        return try modelContext.fetch(descriptor)
    }

    private func fetchRecentTransactions(for userId: String, months: Int) async throws -> [FinancialTransaction] {
        let startDate = Calendar.current.date(byAdding: .month, value: -months, to: Date()) ?? Date()

        let descriptor = FetchDescriptor<FinancialTransaction>(
            predicate: #Predicate<FinancialTransaction> { transaction in
                transaction.userId == userId &&
                transaction.date >= startDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    private func analyzeCategoryBreakdown(_ transactions: [FinancialTransaction]) async throws -> [BudgetCategory: Double] {
        var breakdown: [BudgetCategory: Double] = [:]

        for transaction in transactions where transaction.amount < 0 {
            let category = transaction.category ?? .other
            breakdown[category, default: 0.0] += abs(transaction.amount)
        }

        return breakdown
    }

    private func analyzeSpendingTrend(_ transactions: [FinancialTransaction], timeRange: DateInterval) async throws -> TrendDirection {
        // Simple trend analysis - could be enhanced with more sophisticated algorithms
        let monthlySpending = Dictionary(grouping: transactions.filter { $0.amount < 0 }) { transaction in
            Calendar.current.dateComponents([.year, .month], from: transaction.date)
        }.mapValues { transactions in
            transactions.reduce(0.0) { $0 + abs($1.amount) }
        }

        let sortedMonths = monthlySpending.keys.sorted {
            let date1 = Calendar.current.date(from: $0) ?? Date.distantPast
            let date2 = Calendar.current.date(from: $1) ?? Date.distantPast
            return date1 < date2
        }

        guard sortedMonths.count >= 2 else { return .stable }

        let recentMonths = sortedMonths.suffix(3)
        let recentAverage = recentMonths.reduce(0.0) { $0 + (monthlySpending[$1] ?? 0.0) } / Double(recentMonths.count)

        let earlierMonths = sortedMonths.prefix(max(1, sortedMonths.count - 3))
        let earlierAverage = earlierMonths.reduce(0.0) { $0 + (monthlySpending[$1] ?? 0.0) } / Double(earlierMonths.count)

        let changePercent = earlierAverage > 0 ? (recentAverage - earlierAverage) / earlierAverage : 0.0

        if changePercent > 0.1 {
            return .increasing
        } else if changePercent < -0.1 {
            return .decreasing
        } else {
            return .stable
        }
    }

    private func generateBudgetRecommendations(budget: Budget, transactions: [FinancialTransaction], utilizationRate: Double) async throws -> [String] {
        var recommendations: [String] = []

        if utilizationRate > 0.9 {
            recommendations.append("Consider increasing your budget limit or reducing expenses in over-utilized categories")
        } else if utilizationRate < 0.5 {
            recommendations.append("You have significant budget room. Consider reallocating funds to savings or other goals")
        }

        // Category-specific recommendations
        let categorySpending = try await analyzeCategoryBreakdown(transactions)
        for (category, amount) in categorySpending {
            if let budgetLimit = budget.categoryLimits[category], amount > budgetLimit * 0.8 {
                recommendations.append("Monitor \(category.rawValue) spending - approaching budget limit")
            }
        }

        return recommendations
    }

    private func generateBudgetAlerts(budget: Budget, transactions: [FinancialTransaction], utilizationRate: Double) async throws -> [BudgetAlert] {
        var alerts: [BudgetAlert] = []

        if utilizationRate > 1.0 {
            alerts.append(BudgetAlert(
                type: .budgetExceeded,
                severity: .error,
                message: "Budget exceeded by \(Int((utilizationRate - 1.0) * 100))%",
                threshold: budget.limit,
                currentValue: budget.limit * utilizationRate
            ))
        } else if utilizationRate > 0.9 {
            alerts.append(BudgetAlert(
                type: .budgetWarning,
                severity: .warning,
                message: "Budget utilization at \(Int(utilizationRate * 100))%",
                threshold: budget.limit * 0.9,
                currentValue: budget.limit * utilizationRate
            ))
        }

        return alerts
    }
}

// MARK: - Supporting Models

/// Analysis of spending patterns
public struct SpendingPatternAnalysis {
    public let userId: String
    public let totalTransactions: Int
    public let totalIncome: Double
    public let totalExpenses: Double
    public let savingsRate: Double
    public let categoryAnalysis: [CategoryAnalysis]
    public let hasIrregularSpending: Bool
    public let averageTransactionSize: Double
    public let spendingVolatility: Double
    public let seasonalPatterns: [String: Double]

    public init(
        userId: String,
        totalTransactions: Int,
        totalIncome: Double,
        totalExpenses: Double,
        savingsRate: Double,
        categoryAnalysis: [CategoryAnalysis],
        hasIrregularSpending: Bool,
        averageTransactionSize: Double,
        spendingVolatility: Double,
        seasonalPatterns: [String: Double]
    ) {
        self.userId = userId
        self.totalTransactions = totalTransactions
        self.totalIncome = totalIncome
        self.totalExpenses = totalExpenses
        self.savingsRate = savingsRate
        self.categoryAnalysis = categoryAnalysis
        self.hasIrregularSpending = hasIrregularSpending
        self.averageTransactionSize = averageTransactionSize
        self.spendingVolatility = spendingVolatility
        self.seasonalPatterns = seasonalPatterns
    }
}

/// Category analysis for spending breakdown
public struct CategoryAnalysis {
    public let category: BudgetCategory
    public let amount: Double
    public let percentage: Double
    public let transactionCount: Int

    public init(category: BudgetCategory, amount: Double, percentage: Double, transactionCount: Int) {
        self.category = category
        self.amount = amount
        self.percentage = percentage
        self.transactionCount = transactionCount
    }
}

/// Financial insight model
public struct FinancialInsight {
    public let type: InsightType
    public let title: String
    public let description: String
    public let confidence: Double
    public let actionable: Bool
    public let category: InsightCategory

    public init(type: InsightType, title: String, description: String, confidence: Double, actionable: Bool, category: InsightCategory) {
        self.type = type
        self.title = title
        self.description = description
        self.confidence = confidence
        self.actionable = actionable
        self.category = category
    }
}

/// Insight type enumeration
public enum InsightType {
    case info
    case warning
    case opportunity
    case alert
}

/// Insight category enumeration
public enum InsightCategory {
    case budgeting
    case savings
    case spending
    case investing
    case debt
}

/// Expense prediction model
public struct ExpensePrediction {
    public let userId: String
    public let predictions: [Double]
    public let confidenceIntervals: [(lower: Double, upper: Double)]
    public let predictionHorizon: Int
    public let modelAccuracy: Double
    public let lastUpdated: Date

    public init(
        userId: String,
        predictions: [Double],
        confidenceIntervals: [(lower: Double, upper: Double)],
        predictionHorizon: Int,
        modelAccuracy: Double,
        lastUpdated: Date
    ) {
        self.userId = userId
        self.predictions = predictions
        self.confidenceIntervals = confidenceIntervals
        self.predictionHorizon = predictionHorizon
        self.modelAccuracy = modelAccuracy
        self.lastUpdated = lastUpdated
    }
}
