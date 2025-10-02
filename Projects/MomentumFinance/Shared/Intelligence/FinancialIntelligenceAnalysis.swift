//
//  FinancialIntelligenceAnalysis.swift
//  MomentumFinance
//
//  Created by Automated Code Generation
//  Component extracted from AdvancedFinancialIntelligence.swift
//  Contains core analysis methods for financial insights generation
//

import Foundation
import Combine

/// Component containing core financial analysis methods
/// Extracted from AdvancedFinancialIntelligence to maintain file size limits
struct FinancialIntelligenceAnalysis {
    let analyticsEngine: FinancialAnalyticsEngine
    let predictionEngine: FinancialPredictionEngine
    let helpers: FinancialIntelligenceHelpers

    // MARK: - Analysis Methods

    func analyzeSpendingPatterns(_ transactions: [Transaction]) async
        -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Analyze spending velocity
        let spendingVelocity = helpers.calculateSpendingVelocity(transactions)
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
        let categoryTrends = helpers.analyzeCategoryTrends(transactions)
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

    func analyzeSavingsOpportunities(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Identify subscription optimization opportunities
        let subscriptions = helpers.identifySubscriptions(transactions)
        let unusedSubscriptions = helpers.findUnusedSubscriptions(subscriptions)

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

    func analyzeBudgetPerformance(
        _ transactions: [Transaction],
        _ budgets: [AIBudget]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        for budget in budgets {
            let spent = helpers.calculateSpentAmount(transactions, for: budget)
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

    func assessFinancialRisk(
        _ transactions: [Transaction],
        _ accounts: [Account]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Emergency fund assessment
        let monthlyExpenses = helpers.calculateMonthlyExpenses(transactions)
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

    func generatePredictions(
        _ transactions: [Transaction],
        _: [Account]
    ) async -> [EnhancedFinancialInsight] {
        var insights: [EnhancedFinancialInsight] = []

        // Cash flow prediction
        let predictions = predictionEngine.predictCashFlow(
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
