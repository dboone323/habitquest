import Foundation
import Combine
import SwiftData
import SwiftUI

#if canImport(SwiftData)
#endif

//
//  AdvancedFinancialIntelligence.swift
//  MomentumFinance - Enhanced Financial AI
//
//  Created by Enhanced AI System on 9/12/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

/// Advanced AI-powered financial intelligence service
/// Provides predictive analytics, risk assessment, and smart recommendations
@MainActor
public class AdvancedFinancialIntelligence: ObservableObject {
    // MARK: - Published Properties

    @Published public var insights: [EnhancedFinancialInsight] = []
    @Published public var riskAssessment: RiskAssessment?
    @Published public var predictiveAnalytics: PredictiveAnalytics?
    @Published public var isAnalyzing = false
    @Published public var lastAnalysisDate: Date?

    // MARK: - Private Properties

    private let analyticsEngine = FinancialAnalyticsEngine()
    private let predictionEngine = PredictionEngine()
    private let riskEngine = RiskAssessmentEngine()
    private var cancellables = Set<AnyCancellable>()
    #if canImport(SwiftData)
    private let dataProvider: AdvancedFinancialDataProvider?
    private let autoAnalysisErrorHandler: (Error) -> Void
    #endif

    // MARK: - Initialization

    #if canImport(SwiftData)
    public init(
        dataProvider: AdvancedFinancialDataProvider? = nil,
        onAutoAnalysisError: @escaping (Error) -> Void = { error in
            #if DEBUG
            print("AdvancedFinancialIntelligence auto-analysis error:", error)
            #endif
        }
    ) {
        self.dataProvider = dataProvider
        self.autoAnalysisErrorHandler = onAutoAnalysisError
        self.setupAutoAnalysis()
    }
    #else
    public init() {
        self.setupAutoAnalysis()
    }
    #endif

    // MARK: - Public Methods

    /// Generate comprehensive financial insights
    public func generateInsights(
        from transactions: [Transaction],
        accounts: [Account],
        budgets: [AIBudget]
    ) async {
        self.isAnalyzing = true

        // Generate multiple types of insights concurrently
        async let spendingInsights = self.analyzeSpendingPatterns(transactions)
        async let savingsInsights = self.analyzeSavingsOpportunities(transactions, accounts)
        async let budgetInsights = self.analyzeBudgetPerformance(transactions, budgets)
        async let riskInsights = self.assessFinancialRisk(transactions, accounts)
        async let predictiveInsights = self.generatePredictions(transactions, accounts)

        let allInsights = await [
            spendingInsights,
            savingsInsights,
            budgetInsights,
            riskInsights,
            predictiveInsights,
        ].flatMap(\.self)

        // AI-powered insight ranking and prioritization
        self.insights = self.prioritizeInsights(allInsights)

        // Generate risk assessment
        self.riskAssessment = await self.generateRiskAssessment(transactions, accounts)

        // Generate predictive analytics
        self.predictiveAnalytics = await self.generatePredictiveAnalytics(transactions, accounts)

        self.lastAnalysisDate = Date()
        self.isAnalyzing = false
    }

    /// Get personalized investment recommendations
    public func getInvestmentRecommendations(
        riskTolerance: RiskTolerance,
        timeHorizon: TimeHorizon,
        currentPortfolio: [Investment]
    ) -> [InvestmentRecommendation] {
        self.analyticsEngine.generateInvestmentRecommendations(
            riskTolerance: riskTolerance,
            timeHorizon: timeHorizon,
            currentPortfolio: currentPortfolio
        )
    }

    /// Predict future cash flow
    public func predictCashFlow(
        transactions: [Transaction],
        months: Int = 12
    ) -> [CashFlowPrediction] {
        self.predictionEngine.predictCashFlow(
            transactions: transactions,
            monthsAhead: months
        )
    }

    /// Detect anomalous transactions (fraud detection)
    public func detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {
        self.analyticsEngine.detectAnomalies(in: transactions)
    }

    // MARK: - Private Analysis Methods

    private func analyzeSpendingPatterns(_ transactions: [Transaction]) async
        -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Analyze spending velocity
        let spendingVelocity = self.calculateSpendingVelocity(transactions)
        if spendingVelocity.percentageIncrease > 20 {
            insights.append(
                EnhancedFinancialInsight(
                    title: "Accelerating Spending Detected",
                    description:
                    "Your spending has increased by \(Int(spendingVelocity.percentageIncrease))% this month. Consider reviewing your recent purchases.",
                    priority: .high,
                    type: .spendingAlert,
                    confidence: 0.9,
                    actionRecommendations: [
                        "Review recent transactions",
                        "Set stricter budget limits",
                        "Enable spending alerts",
                    ],
                    impactScore: 8.5
                )
            )
        }

        // Analyze category trends
        let categoryTrends = self.analyzeCategoryTrends(transactions)
        for trend in categoryTrends where trend.isSignificant {
            insights.append(
                EnhancedFinancialInsight(
                    title: "\(trend.category) Spending Trend",
                    description: trend.description,
                    priority: trend.priority,
                    type: .categoryInsight,
                    confidence: trend.confidence,
                    relatedCategoryId: trend.categoryId,
                    actionRecommendations: trend.recommendations,
                    impactScore: trend.impactScore
                )
            )
        }

        return insights
    }

    private func analyzeSavingsOpportunities(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Identify subscription optimization opportunities
        let subscriptions = self.identifySubscriptions(transactions)
        let unusedSubscriptions = self.findUnusedSubscriptions(subscriptions)

        if !unusedSubscriptions.isEmpty {
            let potentialSavings = unusedSubscriptions.reduce(0) { $0 + $1.monthlyAmount }
            insights.append(
                EnhancedFinancialInsight(
                    title: "Subscription Optimization Opportunity",
                    description:
                    "You could save $\(potentialSavings)/month by canceling \(unusedSubscriptions.count) unused subscriptions.",
                    priority: .medium,
                    type: .savingsOpportunity,
                    confidence: 0.85,
                    actionRecommendations: [
                        "Review subscription usage",
                        "Cancel unused subscriptions",
                        "Set usage reminders",
                    ],
                    potentialSavings: potentialSavings * 12, // Annual savings
                    impactScore: 7.2
                )
            )
        }

        // High-yield savings opportunities
        let cashBalance = accounts.filter { $0.type == .checking || $0.type == .savings }
            .reduce(0) { $0 + $1.balance }
        if cashBalance > 10000 {
            insights.append(
                EnhancedFinancialInsight(
                    title: "High-Yield Savings Opportunity",
                    description:
                    "Consider moving excess cash to high-yield savings to earn up to 4.5% APY.",
                    priority: .medium,
                    type: .savingsOpportunity,
                    confidence: 0.95,
                    actionRecommendations: [
                        "Research high-yield savings accounts",
                        "Compare interest rates",
                        "Consider CDs for longer terms",
                    ],
                    potentialSavings: cashBalance * 0.045, // Potential annual earnings
                    impactScore: 6.8
                )
            )
        }

        return insights
    }

    private func analyzeBudgetPerformance(
        _ transactions: [Transaction],
        _ budgets: [AIBudget]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        for budget in budgets {
            let spent = self.calculateSpentAmount(transactions, for: budget)
            let percentageUsed = spent / budget.amount * 100

            if percentageUsed > 90 {
                insights.append(
                    EnhancedFinancialInsight(
                        title: "\(budget.category) Budget Alert",
                        description:
                        "You've used \(Int(percentageUsed))% of your \(budget.category) budget. $\(budget.amount - spent) remaining.",
                        priority: percentageUsed > 100 ? .critical : .high,
                        type: .budgetAlert,
                        confidence: 0.95,
                        relatedBudgetId: budget.id,
                        actionRecommendations: [
                            "Reduce spending in this category",
                            "Consider increasing budget if necessary",
                            "Review recent transactions",
                        ],
                        impactScore: percentageUsed > 100 ? 9.5 : 8.0
                    )
                )
            }
        }

        return insights
    }

    private func assessFinancialRisk(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Emergency fund assessment
        let monthlyExpenses = self.calculateMonthlyExpenses(transactions)
        let emergencyFund = accounts.filter { $0.type == .savings }
            .reduce(0) { $0 + $1.balance }
        let monthsCovered = emergencyFund / monthlyExpenses

        if monthsCovered < 3 {
            insights.append(
                EnhancedFinancialInsight(
                    title: "Emergency Fund Below Recommended Level",
                    description:
                    "Your emergency fund covers \(monthsCovered, specifier: "%.1f") months of expenses. Experts recommend 3-6 months.",
                    priority: monthsCovered < 1 ? .critical : .high,
                    type: .riskAlert,
                    confidence: 0.9,
                    actionRecommendations: [
                        "Set up automatic savings transfers",
                        "Reduce discretionary spending temporarily",
                        "Consider side income opportunities",
                    ],
                    impactScore: monthsCovered < 1 ? 9.8 : 7.5
                )
            )
        }

        return insights
    }

    private func generatePredictions(
        _ transactions: [Transaction],
        _: [Account]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Cash flow prediction
        let predictions = self.predictionEngine.predictCashFlow(
            transactions: transactions, monthsAhead: 3
        )
        let negativeMonths = predictions.filter { $0.netCashFlow < 0 }

        if !negativeMonths.isEmpty {
            insights.append(
                EnhancedFinancialInsight(
                    title: "Potential Cash Flow Issues Ahead",
                    description:
                    "Predicted negative cash flow in \(negativeMonths.count) of the next 3 months.",
                    priority: .high,
                    type: .prediction,
                    confidence: 0.75,
                    actionRecommendations: [
                        "Review upcoming expenses",
                        "Consider increasing income",
                        "Reduce non-essential spending",
                    ],
                    impactScore: 8.2
                )
            )
        }

        return insights
    }

    // MARK: - Helper Methods

    private func setupAutoAnalysis() {
        #if canImport(SwiftData)
        guard self.dataProvider != nil else { return }
        #endif
        // Setup automatic analysis every 24 hours
        Timer.publish(every: 86400, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.performAutoAnalysis()
                }
            }
            .store(in: &self.cancellables)
    }

    private func performAutoAnalysis() async {
        #if canImport(SwiftData)
        guard let dataProvider else { return }
        if self.isAnalyzing { return }

        do {
            let snapshot = try await dataProvider.makeSnapshot()
            let payload = self.makeAutoAnalysisPayload(from: snapshot)

            if payload.transactions.isEmpty, payload.accounts.isEmpty, payload.budgets.isEmpty {
                self.insights = []
                self.riskAssessment = nil
                self.predictiveAnalytics = nil
                self.lastAnalysisDate = Date()
                return
            }

            await self.generateInsights(
                from: payload.transactions,
                accounts: payload.accounts,
                budgets: payload.budgets
            )
        } catch {
            self.autoAnalysisErrorHandler(error)
        }
        #else
        // Auto-analysis requires SwiftData-backed storage; no-op when unavailable.
        #endif
    }

    private func prioritizeInsights(_ insights: [EnhancedFinancialInsight])
        -> [EnhancedFinancialInsight] {
        insights.sorted { first, second in
            // Priority by severity first, then by impact score
            if first.priority != second.priority {
                return first.priority.rawValue > second.priority.rawValue
            }
            return first.impactScore > second.impactScore
        }
    }

    private func calculateSpendingVelocity(_ transactions: [Transaction]) -> SpendingVelocity {
        let increase = FinancialAnalyticsSharedCore.spendingVelocityIncrease(in: transactions)
        return SpendingVelocity(percentageIncrease: increase)
    }

    private func analyzeCategoryTrends(_ transactions: [Transaction]) -> [CategoryTrend] {
        FinancialAnalyticsSharedCore.categoryTrends(in: transactions).map { summary in
            let absolutePercent = abs(summary.percentChange * 100)
            let isSignificant = absolutePercent >= 25 || abs(summary.changeAmount) >= 100

            let description: String
            let priority: InsightPriority
            let recommendations: [String]

            if summary.changeAmount >= 0 {
                description =
                    "Spending in \(summary.category) increased by about \(Int(absolutePercent))% compared to the previous month."
                priority = summary.percentChange >= 0.5 ? .high : .medium
                recommendations = [
                    "Review recent purchases",
                    "Tighten the budget for \(summary.category.lowercased())",
                    "Set a spending alert for this category",
                ]
            } else {
                description =
                    "Spending in \(summary.category) decreased by about \(Int(absolutePercent))% compared to the previous month."
                priority = .low
                recommendations = [
                    "Reallocate the savings toward goals",
                    "Celebrate the improvement to reinforce the habit",
                ]
            }

            let confidence = min(0.95, 0.65 + Double(min(summary.transactionCount, 6)) * 0.05)
            let impact = min(10, max(3, absolutePercent / 10 + abs(summary.changeAmount) / 500))

            return CategoryTrend(
                category: summary.category,
                categoryId: summary.category,
                isSignificant: isSignificant,
                description: description,
                priority: priority,
                confidence: confidence,
                recommendations: recommendations,
                impactScore: impact
            )
        }
    }

    private func identifySubscriptions(_ transactions: [Transaction]) -> [Subscription] {
        FinancialAnalyticsSharedCore.detectSubscriptions(in: transactions).map {
            Subscription(name: $0.name, monthlyAmount: $0.averageAmount, lastUsed: $0.lastUsed)
        }
    }

    private func findUnusedSubscriptions(_ subscriptions: [Subscription]) -> [Subscription] {
        guard !subscriptions.isEmpty else { return [] }

        let summaries = subscriptions.enumerated().map { index, subscription in
            FinancialAnalyticsSharedCore.SubscriptionSummary(
                identifier: subscription.name.lowercased() + "-\(index)",
                name: subscription.name,
                averageAmount: subscription.monthlyAmount,
                lastUsed: subscription.lastUsed
            )
        }

        let unusedSummaries = FinancialAnalyticsSharedCore.unusedSubscriptions(summaries)
        let identifiers = Set(unusedSummaries.map(\.name))

        return subscriptions.filter { identifiers.contains($0.name) }
    }

    private func calculateSpentAmount(_ transactions: [Transaction], for budget: AIBudget) -> Double {
        FinancialAnalyticsSharedCore.spentAmount(transactions: transactions, budget: budget)
    }

    private func calculateMonthlyExpenses(_ transactions: [Transaction]) -> Double {
        FinancialAnalyticsSharedCore.monthlyExpenses(transactions: transactions)
    }

    private func generateRiskAssessment(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) async -> RiskAssessment {
        let monthlyExpenses = self.calculateMonthlyExpenses(transactions)
        guard monthlyExpenses > 0 else {
            return RiskAssessment(
                overallRiskLevel: .low,
                emergencyFundRisk: .low,
                debtRisk: .low,
                investmentRisk: .low,
                cashFlowRisk: .low
            )
        }

        let coverage = FinancialAnalyticsSharedCore.emergencyCoverage(
            accounts: accounts,
            monthlyExpenses: monthlyExpenses
        )

        let emergencyRisk: RiskLevel
        let overallRisk: RiskLevel

        switch coverage {
        case ..<1:
            emergencyRisk = .critical
            overallRisk = .high
        case 1 ..< 3:
            emergencyRisk = .high
            overallRisk = .medium
        default:
            emergencyRisk = .medium
            overallRisk = .low
        }

        return RiskAssessment(
            overallRiskLevel: overallRisk,
            emergencyFundRisk: emergencyRisk,
            debtRisk: .medium,
            investmentRisk: .moderate,
            cashFlowRisk: coverage < 3 ? .medium : .low
        )
    }

    private func generatePredictiveAnalytics(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) async -> PredictiveAnalytics {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(byAdding: .day, value: -30, to: now) ?? now

        let window = transactions.filter { $0.date >= start }
        let income = window.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let expenses = window.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
        let netCashFlow = income - expenses

        let savingsProjection = max(0, netCashFlow * 0.6)
        let budgetVarianceProjection = expenses > 0 ? min(1, income / max(expenses, 1)) : 1

        return PredictiveAnalytics(
            nextMonthSpending: max(expenses, 0),
            nextMonthIncome: max(income, 0),
            savingsProjection: savingsProjection,
            budgetVarianceProjection: budgetVarianceProjection
        )
    }
}

public enum BudgetPeriod {
    case monthly, yearly
}

public struct Investment {
    let symbol: String
    let shares: Double
    let currentValue: Double
}

public enum RiskTolerance {
    case conservative, moderate, aggressive
}

public enum TimeHorizon {
    case shortTerm, mediumTerm, longTerm
}

// MARK: - Supporting Engines

private class FinancialAnalyticsEngine {
    func generateInvestmentRecommendations(
        riskTolerance _: RiskTolerance,
        timeHorizon _: TimeHorizon,
        currentPortfolio _: [Investment]
    ) -> [InvestmentRecommendation] {
        // Implementation would go here
        []
    }

    func detectAnomalies(in _: [Transaction]) -> [TransactionAnomaly] {
        // Implementation would go here
        []
    }
}

private class PredictionEngine {
    func predictCashFlow(transactions _: [Transaction], monthsAhead _: Int) -> [CashFlowPrediction] {
        // Implementation would go here
        []
    }
}

private class RiskAssessmentEngine {
    // Implementation would go here
}

#if canImport(SwiftData)
public struct AdvancedFinancialDomainSnapshot {
    public let transactions: [FinancialTransaction]
    public let accounts: [FinancialAccount]
    public let budgets: [Budget]

    public init(
        transactions: [FinancialTransaction],
        accounts: [FinancialAccount],
        budgets: [Budget]
    ) {
        self.transactions = transactions
        self.accounts = accounts
        self.budgets = budgets
    }
}

@MainActor
public protocol AdvancedFinancialDataProvider: AnyObject {
    func makeSnapshot() async throws -> AdvancedFinancialDomainSnapshot
}

@MainActor
public final class SwiftDataAdvancedFinancialDataProvider: AdvancedFinancialDataProvider {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func makeSnapshot() async throws -> AdvancedFinancialDomainSnapshot {
        let transactions = try self.modelContext.fetch(FetchDescriptor<FinancialTransaction>())
        let accounts = try self.modelContext.fetch(FetchDescriptor<FinancialAccount>())
        let budgets = try self.modelContext.fetch(FetchDescriptor<Budget>())

        return AdvancedFinancialDomainSnapshot(
            transactions: transactions,
            accounts: accounts,
            budgets: budgets
        )
    }
}
#endif

// End of AdvancedFinancialIntelligence class and related types

// MARK: - Enhanced Financial Insight Model

public struct EnhancedFinancialInsight: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let priority: InsightPriority
    public let type: InsightType
    public let confidence: Double
    public let relatedAccountId: String?
    public let relatedTransactionId: String?
    public let relatedCategoryId: String?
    public let relatedBudgetId: String?
    public let actionRecommendations: [String]
    public let potentialSavings: Double?
    public let impactScore: Double // 0-10 scale
    public let createdAt: Date

    public init(
        title: String,
        description: String,
        priority: InsightPriority,
        type: InsightType,
        confidence: Double = 0.8,
        relatedAccountId: String? = nil,
        relatedTransactionId: String? = nil,
        relatedCategoryId: String? = nil,
        relatedBudgetId: String? = nil,
        actionRecommendations: [String] = [],
        potentialSavings: Double? = nil,
        impactScore: Double = 5.0
    ) {
        self.title = title
        self.description = description
        self.priority = priority
        self.type = type
        self.confidence = confidence
        self.relatedAccountId = relatedAccountId
        self.relatedTransactionId = relatedTransactionId
        self.relatedCategoryId = relatedCategoryId
        self.relatedBudgetId = relatedBudgetId
        self.actionRecommendations = actionRecommendations
        self.potentialSavings = potentialSavings
        self.impactScore = impactScore
        self.createdAt = Date()
    }
}

// MARK: - Supporting Types

public enum InsightPriority: Int, CaseIterable, Hashable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
}

public enum InsightType: Hashable {
    case spendingAlert
    case savingsOpportunity
    case budgetAlert
    case categoryInsight
    case riskAlert
    case prediction
    case recommendation
}

public struct RiskAssessment {
    let overallRiskLevel: RiskLevel
    let emergencyFundRisk: RiskLevel
    let debtRisk: RiskLevel
    let investmentRisk: RiskLevel
    let cashFlowRisk: RiskLevel
}

public enum RiskLevel {
    case low, medium, moderate, high, critical
}

public struct PredictiveAnalytics {
    let nextMonthSpending: Double
    let nextMonthIncome: Double
    let savingsProjection: Double
    let budgetVarianceProjection: Double // 0-1 scale
}

public struct SpendingVelocity {
    let percentageIncrease: Double
}

public struct CategoryTrend {
    let category: String
    let categoryId: String
    let isSignificant: Bool
    let description: String
    let priority: InsightPriority
    let confidence: Double
    let recommendations: [String]
    let impactScore: Double
}

public struct Subscription {
    let name: String
    let monthlyAmount: Double
    let lastUsed: Date?
}

public struct InvestmentRecommendation {
    let type: String
    let allocation: Double
    let riskLevel: RiskLevel
    let expectedReturn: Double
}

public struct CashFlowPrediction {
    let month: Date
    let predictedIncome: Double
    let predictedExpenses: Double
    let netCashFlow: Double
}

public struct TransactionAnomaly {
    let transaction: Transaction
    let anomalyType: AnomalyType
    let confidence: Double
}

public enum AnomalyType {
    case unusualAmount
    case unusualMerchant
    case unusualLocation
    case unusualTime
    case possibleFraud
}

// MARK: - Placeholder Types (these should exist in your actual models)

public struct Transaction {
    let id: String
    let amount: Double
    let date: Date
    let category: String
    let merchant: String?
}

public struct Account {
    let id: String
    let name: String
    let type: AccountType
    let balance: Double
}

public enum AccountType {
    case checking, savings, investment, credit
}

public struct Budget {
    let id: String
    let category: String
    let amount: Double
    let period: BudgetPeriod
}

/// Lightweight struct for AI budget analysis (not the main Budget model).
public struct AIBudget {
    let id: String
    let category: String
    let amount: Double
    let period: BudgetPeriod
}

extension AdvancedFinancialIntelligence.Transaction: FinancialAnalyticsTransactionConvertible {
    var faAmount: Double { self.amount }
    var faDate: Date { self.date }
    var faCategory: String { self.category }
    var faMerchant: String? { self.merchant }
}

extension AdvancedFinancialIntelligence.Account: FinancialAnalyticsAccountConvertible {
    var faType: FinancialAnalyticsAccountKind {
        switch self.type {
        case .checking:
            .checking
        case .savings:
            .savings
        case .investment:
            .investment
        case .credit:
            .credit
        }
    }

    var faBalance: Double { self.balance }
}

extension AdvancedFinancialIntelligence.AIBudget: FinancialAnalyticsBudgetConvertible {
    var faCategory: String { self.category }
    var faAmount: Double { self.amount }
    var faPeriod: FinancialAnalyticsBudgetPeriod {
        switch self.period {
        case .monthly:
            .monthly
        case .yearly:
            .yearly
        }
    }
}
