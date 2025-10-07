//
//  FinancialIntelligenceHelpers.swift
//  MomentumFinance
//
//  Created by Automated Code Generation
//  Component extracted from AdvancedFinancialIntelligence.swift
//  Contains utility helper methods for financial calculations
//

import Foundation

/// Component containing utility helper methods for financial intelligence
/// Extracted from AdvancedFinancialIntelligence to maintain file size limits
struct FinancialIntelligenceHelpers {
    // MARK: - Calculation Helpers

    func calculateSpendingVelocity(_ transactions: [Transaction]) -> SpendingVelocity {
        let increase = FinancialAnalyticsSharedCore.spendingVelocityIncrease(in: transactions)
        return SpendingVelocity(percentageIncrease: increase)
    }

    func analyzeCategoryTrends(_ transactions: [Transaction]) -> [CategoryTrend] {
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

    func identifySubscriptions(_ transactions: [Transaction]) -> [Subscription] {
        FinancialAnalyticsSharedCore.detectSubscriptions(in: transactions).map {
            Subscription(name: $0.name, monthlyAmount: $0.averageAmount, lastUsed: $0.lastUsed)
        }
    }

    func findUnusedSubscriptions(_ subscriptions: [Subscription]) -> [Subscription] {
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

    func calculateSpentAmount(_ transactions: [Transaction], for budget: AIBudget) -> Double {
        FinancialAnalyticsSharedCore.spentAmount(transactions: transactions, budget: budget)
    }

    func calculateMonthlyExpenses(_ transactions: [Transaction]) -> Double {
        FinancialAnalyticsSharedCore.monthlyExpenses(transactions: transactions)
    }
}
