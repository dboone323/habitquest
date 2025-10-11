//
//  FinancialMLModels.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation

/// Machine learning models for financial analysis and predictions
@MainActor
final class FinancialMLModels {
    static let shared = FinancialMLModels()

    private init() {}

    /// Analyze spending patterns using simple statistical methods
    func analyzeSpendingPatterns(transactions: [FinancialTransaction]) -> [String: Any] {
        let expenses = transactions.filter { $0.amount < 0 }
        let totalSpent = expenses.reduce(0) { $0 + abs($1.amount) }

        // Simple categorization by amount ranges
        let smallTransactions = expenses.filter { abs($0.amount) < 50 }
        let mediumTransactions = expenses.filter { abs($0.amount) >= 50 && abs($0.amount) < 200 }
        let largeTransactions = expenses.filter { abs($0.amount) >= 200 }

        return [
            "totalSpent": totalSpent,
            "smallTransactionCount": smallTransactions.count,
            "mediumTransactionCount": mediumTransactions.count,
            "largeTransactionCount": largeTransactions.count,
            "averageTransactionSize": totalSpent / Double(expenses.count),
            "transactionFrequency": Double(expenses.count) / 30.0, // per day
        ]
    }

    /// Predict future spending based on historical data
    func predictFutureSpending(historicalData: [Double], months: Int) -> [Double] {
        guard !historicalData.isEmpty else { return [] }

        // Simple linear regression for prediction
        let n = Double(historicalData.count)
        let sumX = (0 ..< historicalData.count).reduce(0.0) { $0 + Double($1) }
        let sumY = historicalData.reduce(0.0, +)
        let sumXY = (0 ..< historicalData.count).reduce(0.0) { $0 + Double($1) * historicalData[$1] }
        let sumXX = (0 ..< historicalData.count).reduce(0.0) { $0 + Double($1 * $1) }

        let slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n

        // Generate predictions
        var predictions: [Double] = []
        for i in 1 ... months {
            let prediction = slope * (n + Double(i)) + intercept
            predictions.append(max(0, prediction)) // Ensure non-negative
        }

        return predictions
    }

    /// Classify transactions into categories using simple rules
    func classifyTransaction(_ transaction: FinancialTransaction) -> String {
        let description = transaction.description.lowercased()
        let amount = abs(transaction.amount)

        // Simple rule-based classification
        if description.contains("grocery") || description.contains("food") || description.contains("restaurant") {
            return "Food & Dining"
        } else if description.contains("gas") || description.contains("fuel") || description.contains("transport") {
            return "Transportation"
        } else if description.contains("rent") || description.contains("mortgage") || description.contains("utility") {
            return "Housing"
        } else if description.contains("amazon") || description.contains("shopping") || amount > 100 {
            return "Shopping"
        } else if description.contains("entertainment") || description.contains("movie") || description.contains("game") {
            return "Entertainment"
        } else {
            return "Other"
        }
    }
}
