//
//  FinancialIntelligencePrediction.swift
//  MomentumFinance
//
//  Created by Automated Code Generation
//  Component extracted from AdvancedFinancialIntelligence.swift
//  Contains predictive analytics functionality
//

import Foundation

/// Component containing predictive analytics methods
/// Extracted from AdvancedFinancialIntelligence to maintain file size limits
struct FinancialIntelligencePrediction {
    // MARK: - Predictive Analytics

    func generatePredictiveAnalytics(
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
