import Foundation
import SwiftUI

public enum BudgetPeriod: CaseIterable, Sendable {
    case monthly
    case quarterly
    case yearly
}

/// A lightweight stand-in for the production AI service used by the tests.
@MainActor
public final class AdvancedFinancialIntelligence: ObservableObject {
    // MARK: - Nested Types

    public struct Transaction: Identifiable, Equatable, Sendable {
        public let id: String
        public let amount: Double
        public let date: Date
        public let category: String
        public let merchant: String

        public init(id: String, amount: Double, date: Date, category: String, merchant: String) {
            self.id = id
            self.amount = amount
            self.date = date
            self.category = category
            self.merchant = merchant
        }
    }

    public enum AccountType: Sendable {
        case checking
        case savings
        case credit
        case investment
    }

    public struct Account: Identifiable, Equatable, Sendable {
        public let id: String
        public let name: String
        public let type: AccountType
        public let balance: Double

        public init(id: String, name: String, type: AccountType, balance: Double) {
            self.id = id
            self.name = name
            self.type = type
            self.balance = balance
        }
    }

    public struct AIBudget: Identifiable, Equatable, Sendable {
        public let id: String
        public let category: String
        public let amount: Double
        public let period: BudgetPeriod

        public init(id: String, category: String, amount: Double, period: BudgetPeriod) {
            self.id = id
            self.category = category
            self.amount = amount
            self.period = period
        }
    }

    public struct EnhancedFinancialInsight: Identifiable, Equatable, Sendable {
        public let id: UUID = .init()
        public let title: String
        public let description: String
        public let priority: InsightPriority
        public let type: InsightType
        public let confidence: Double
        public let impactScore: Double

        public init(
            title: String,
            description: String,
            priority: InsightPriority,
            type: InsightType,
            confidence: Double,
            impactScore: Double
        ) {
            self.title = title
            self.description = description
            self.priority = priority
            self.type = type
            self.confidence = confidence
            self.impactScore = impactScore
        }
    }

    public struct RiskAssessment: Equatable, Sendable {
        public enum Level: Sendable {
            case low
            case medium
            case high
        }

        public let score: Double
        public let level: Level

        public init(score: Double, level: Level) {
            self.score = score
            self.level = level
        }
    }

    public struct PredictiveAnalytics: Equatable, Sendable {
        public let projectedSavings: Double
        public let projectedSpending: Double

        public init(projectedSavings: Double, projectedSpending: Double) {
            self.projectedSavings = projectedSavings
            self.projectedSpending = projectedSpending
        }
    }

    public struct SpendingVelocity: Equatable, Sendable {
        public let percentageIncrease: Double

        public init(percentageIncrease: Double) {
            self.percentageIncrease = percentageIncrease
        }
    }

    public struct CategoryTrend: Equatable, Sendable {
        public let category: String
        public let isSignificant: Bool
        public let description: String
        public let priority: InsightPriority
        public let confidence: Double
        public let recommendations: [String]
        public let impactScore: Double

        public init(
            category: String,
            isSignificant: Bool,
            description: String,
            priority: InsightPriority,
            confidence: Double,
            recommendations: [String],
            impactScore: Double
        ) {
            self.category = category
            self.isSignificant = isSignificant
            self.description = description
            self.priority = priority
            self.confidence = confidence
            self.recommendations = recommendations
            self.impactScore = impactScore
        }
    }

    public struct Subscription: Equatable, Sendable {
        public let identifier: String
        public let name: String
        public let monthlyAmount: Double
        public let lastUsed: Date?

        public init(identifier: String, name: String, monthlyAmount: Double, lastUsed: Date?) {
            self.identifier = identifier
            self.name = name
            self.monthlyAmount = monthlyAmount
            self.lastUsed = lastUsed
        }
    }

    public struct Investment: Equatable, Sendable {
        public let symbol: String
        public let shares: Double
        public let currentValue: Double

        public init(symbol: String, shares: Double, currentValue: Double) {
            self.symbol = symbol
            self.shares = shares
            self.currentValue = currentValue
        }
    }

    public struct InvestmentRecommendation: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let symbol: String
        public let rationale: String

        public init(id: UUID = UUID(), symbol: String, rationale: String) {
            self.id = id
            self.symbol = symbol
            self.rationale = rationale
        }
    }

    public struct TransactionAnomaly: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let transactionId: String
        public let explanation: String

        public init(id: UUID = UUID(), transactionId: String, explanation: String) {
            self.id = id
            self.transactionId = transactionId
            self.explanation = explanation
        }
    }

    public struct CashFlowPrediction: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let monthOffset: Int
        public let projectedBalance: Double

        public init(id: UUID = UUID(), monthOffset: Int, projectedBalance: Double) {
            self.id = id
            self.monthOffset = monthOffset
            self.projectedBalance = projectedBalance
        }
    }

    public enum RiskTolerance: Sendable {
        case conservative
        case moderate
        case aggressive
    }

    public enum TimeHorizon: Sendable {
        case shortTerm
        case mediumTerm
        case longTerm
    }

    // MARK: - Published Output

    @Published public private(set) var insights: [EnhancedFinancialInsight] = []
    @Published public private(set) var riskAssessment: RiskAssessment?
    @Published public private(set) var predictiveAnalytics: PredictiveAnalytics?
    @Published public private(set) var isAnalyzing = false
    @Published public private(set) var lastAnalysisDate: Date?

    // MARK: - Internal Engines

    private let analyticsEngine = FinancialAnalyticsEngine()
    private let predictionEngine = PredictionEngine()

    public init() {}

    // MARK: - Public API

    public func generateInsights(
        from transactions: [Transaction],
        accounts: [Account],
        budgets: [AIBudget]
    ) async {
        self.isAnalyzing = true
        defer {
            self.isAnalyzing = false
            self.lastAnalysisDate = Date()
        }

        let spendingInsights = self.analyzeSpendingPatterns(transactions)
        let savingsInsights = self.analyzeSavingsOpportunities(transactions, accounts)
        let budgetInsights = self.analyzeBudgetPerformance(transactions, budgets)
        let riskInsights = self.assessFinancialRisk(transactions, accounts)
        let predictiveInsights = self.generatePredictions(transactions, accounts)

        let combinedInsights = spendingInsights
            + savingsInsights
            + budgetInsights
            + riskInsights
            + predictiveInsights

        self.insights = self.prioritizeInsights(combinedInsights)
        self.riskAssessment = self.generateRiskAssessment(transactions, accounts)
        self.predictiveAnalytics = self.generatePredictiveAnalytics(transactions, accounts)

        // Ensure the async function yields once to simulate real async work.
        await Task.yield()
    }

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

    public func predictCashFlow(
        transactions: [Transaction],
        months: Int = 12
    ) -> [CashFlowPrediction] {
        self.predictionEngine.predictCashFlow(transactions: transactions, monthsAhead: months)
    }

    public func detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {
        self.analyticsEngine.detectAnomalies(in: transactions)
    }

    // MARK: - Analytics Helpers

    private func analyzeSpendingPatterns(_ transactions: [Transaction]) -> [EnhancedFinancialInsight] {
        guard !transactions.isEmpty else { return [] }

        var insights: [EnhancedFinancialInsight] = []
        let spendingVelocity = self.calculateSpendingVelocity(transactions)

        if spendingVelocity.percentageIncrease > 20 {
            let rounded = Int(spendingVelocity.percentageIncrease.rounded())
            insights.append(
                EnhancedFinancialInsight(
                    title: "Accelerating Spending Detected",
                    description:
                    "Your spending has increased by approximately \(rounded)% this month compared to the prior month.",
                    priority: .high,
                    type: .informational,
                    confidence: 0.85,
                    impactScore: min(10, Double(rounded) / 5)
                )
            )
        }

        let categoryTrends = self.analyzeCategoryTrends(transactions)
        for trend in categoryTrends where trend.isSignificant {
            insights.append(
                EnhancedFinancialInsight(
                    title: "\(trend.category) spending trend",
                    description: trend.description,
                    priority: trend.priority,
                    type: .informational,
                    confidence: trend.confidence,
                    impactScore: trend.impactScore
                )
            )
        }

        return insights
    }

    private func analyzeSavingsOpportunities(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        let subscriptions = self.identifySubscriptions(transactions)
        let unusedSubscriptions = self.findUnusedSubscriptions(subscriptions)

        if !unusedSubscriptions.isEmpty {
            let potentialSavings = unusedSubscriptions.reduce(0) { $0 + $1.monthlyAmount }
            insights.append(
                EnhancedFinancialInsight(
                    title: "Subscription Optimization Opportunity",
                    description:
                    "You could save about $\(Int(potentialSavings)) per month by canceling \(unusedSubscriptions.count) unused subscriptions.",
                    priority: .medium,
                    type: .informational,
                    confidence: 0.8,
                    impactScore: min(9, potentialSavings / 10)
                )
            )
        }

        let liquidBalance = accounts
            .filter { $0.type == .checking || $0.type == .savings }
            .reduce(0) { $0 + $1.balance }

        if liquidBalance > 10000 {
            let projectedYield = liquidBalance * 0.045
            insights.append(
                EnhancedFinancialInsight(
                    title: "High-yield savings opportunity",
                    description:
                    "Consider moving excess cash into a high-yield account to earn around $\(Int(projectedYield)) annually.",
                    priority: .medium,
                    type: .informational,
                    confidence: 0.9,
                    impactScore: min(8, projectedYield / 1000)
                )
            )
        }

        return insights
    }

    private func analyzeBudgetPerformance(
        _ transactions: [Transaction],
        _ budgets: [AIBudget]
    ) -> [EnhancedFinancialInsight] {
        guard !budgets.isEmpty else { return [] }

        var insights: [EnhancedFinancialInsight] = []

        for budget in budgets {
            let spent = self.calculateSpentAmount(transactions, for: budget)
            guard budget.amount > 0 else { continue }
            let percentageUsed = (spent / budget.amount) * 100

            if percentageUsed > 90 {
                let remaining = max(0, budget.amount - spent)
                insights.append(
                    EnhancedFinancialInsight(
                        title: "\(budget.category) Budget Alert",
                        description:
                        "\(Int(percentageUsed))% of the \(budget.category) budget has been used. About $\(Int(remaining)) remains for the current period.",
                        priority: percentageUsed > 110 ? .high : .medium,
                        type: .budgetRecommendation,
                        confidence: 0.9,
                        impactScore: min(10, percentageUsed / 10)
                    )
                )
            }
        }

        return insights
    }

    private func assessFinancialRisk(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) -> [EnhancedFinancialInsight] {
        guard !accounts.isEmpty else { return [] }

        var insights: [EnhancedFinancialInsight] = []
        let monthlyExpenses = self.calculateMonthlyExpenses(transactions)
        let monthsCovered = FinancialAnalyticsSharedCore.emergencyCoverage(
            accounts: accounts,
            monthlyExpenses: monthlyExpenses
        )

        if monthsCovered < 3 {
            let description = monthsCovered < 1
                ? "Emergency savings cover less than a month of typical expenses."
                : "Emergency savings cover about \(String(format: "%.1f", monthsCovered)) months of expenses."

            insights.append(
                EnhancedFinancialInsight(
                    title: "Emergency fund below recommended level",
                    description: description,
                    priority: monthsCovered < 1 ? .high : .medium,
                    type: .informational,
                    confidence: 0.85,
                    impactScore: min(9, (3 - monthsCovered) * 2)
                )
            )
        }

        return insights
    }

    private func generatePredictions(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) -> [EnhancedFinancialInsight] {
        guard !transactions.isEmpty else { return [] }

        let cashFlow = FinancialAnalyticsSharedCore.cashFlowWindow(transactions: transactions)
        guard cashFlow.income > 0 || cashFlow.expenses > 0 else { return [] }

        let net = cashFlow.net

        if net < 0 {
            return [
                EnhancedFinancialInsight(
                    title: "Projected cash flow deficit",
                    description:
                    "Spending outpaced income by approximately $\(Int(abs(net))) over the last month. Consider plans to close the gap.",
                    priority: .medium,
                    type: .informational,
                    confidence: 0.75,
                    impactScore: min(8, abs(net) / 200)
                ),
            ]
        }

        if net > 500, !accounts.isEmpty {
            return [
                EnhancedFinancialInsight(
                    title: "Healthy monthly surplus",
                    description:
                    "Income exceeded expenses by roughly $\(Int(net)) over the last month. Consider allocating the surplus toward long-term goals.",
                    priority: .low,
                    type: .informational,
                    confidence: 0.7,
                    impactScore: min(6, net / 400)
                ),
            ]
        }

        return []
    }

    private func prioritizeInsights(_ insights: [EnhancedFinancialInsight]) -> [EnhancedFinancialInsight] {
        insights.sorted { first, second in
            if first.priority == second.priority {
                return first.impactScore > second.impactScore
            }
            return first.priority > second.priority
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
            Subscription(
                identifier: $0.identifier,
                name: $0.name,
                monthlyAmount: $0.averageAmount,
                lastUsed: $0.lastUsed
            )
        }
    }

    private func findUnusedSubscriptions(_ subscriptions: [Subscription]) -> [Subscription] {
        guard !subscriptions.isEmpty else { return [] }

        let summaries = subscriptions.map {
            FinancialAnalyticsSharedCore.SubscriptionSummary(
                identifier: $0.identifier,
                name: $0.name,
                averageAmount: $0.monthlyAmount,
                lastUsed: $0.lastUsed
            )
        }

        let unusedSummaries = FinancialAnalyticsSharedCore.unusedSubscriptions(summaries)
        let identifiers = Set(unusedSummaries.map(\.identifier))

        return subscriptions.filter { identifiers.contains($0.identifier) }
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
    ) -> RiskAssessment {
        let monthlyExpenses = self.calculateMonthlyExpenses(transactions)
        guard monthlyExpenses > 0 else {
            return RiskAssessment(score: 0.3, level: .low)
        }

        let coverage = FinancialAnalyticsSharedCore.emergencyCoverage(
            accounts: accounts,
            monthlyExpenses: monthlyExpenses
        )

        switch coverage {
        case ..<1:
            return RiskAssessment(score: 0.85, level: .high)
        case 1 ..< 3:
            return RiskAssessment(score: 0.6, level: .medium)
        default:
            return RiskAssessment(score: 0.35, level: .low)
        }
    }

    private func generatePredictiveAnalytics(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) -> PredictiveAnalytics {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(byAdding: .day, value: -30, to: now) ?? now

        let window = transactions.filter { $0.date >= start }
        let income = window.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let expenses = window.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }

        let projectedSpending = max(expenses, self.calculateMonthlyExpenses(transactions))
        let projectedSavings = max(0, income - projectedSpending)

        return PredictiveAnalytics(
            projectedSavings: projectedSavings,
            projectedSpending: projectedSpending
        )
    }
}

// MARK: - Internal Engines

private final class FinancialAnalyticsEngine {
    func generateInvestmentRecommendations(
        riskTolerance _: AdvancedFinancialIntelligence.RiskTolerance,
        timeHorizon _: AdvancedFinancialIntelligence.TimeHorizon,
        currentPortfolio _: [AdvancedFinancialIntelligence.Investment]
    ) -> [AdvancedFinancialIntelligence.InvestmentRecommendation] {
        []
    }

    func detectAnomalies(
        in _: [AdvancedFinancialIntelligence.Transaction]
    ) -> [AdvancedFinancialIntelligence.TransactionAnomaly] {
        []
    }
}

private final class PredictionEngine {
    func predictCashFlow(
        transactions _: [AdvancedFinancialIntelligence.Transaction],
        monthsAhead _: Int
    ) -> [AdvancedFinancialIntelligence.CashFlowPrediction] {
        []
    }
}

// MARK: - Shared Core Conformances

extension AdvancedFinancialIntelligence.Transaction: FinancialAnalyticsTransactionConvertible {
    public var faAmount: Double { self.amount }
    public var faDate: Date { self.date }
    public var faCategory: String { self.category }
    public var faMerchant: String? { self.merchant }
}

extension AdvancedFinancialIntelligence.Account: FinancialAnalyticsAccountConvertible {
    public var faType: FinancialAnalyticsAccountKind {
        switch self.type {
        case .checking:
            .checking
        case .savings:
            .savings
        case .credit:
            .credit
        case .investment:
            .investment
        }
    }

    public var faBalance: Double { self.balance }
}

extension AdvancedFinancialIntelligence.AIBudget: FinancialAnalyticsBudgetConvertible {
    public var faCategory: String { self.category }
    public var faAmount: Double { self.amount }
    public var faPeriod: FinancialAnalyticsBudgetPeriod {
        switch self.period {
        case .monthly:
            .monthly
        case .quarterly:
            .quarterly
        case .yearly:
            .yearly
        }
    }
}

public typealias Investment = AdvancedFinancialIntelligence.Investment
