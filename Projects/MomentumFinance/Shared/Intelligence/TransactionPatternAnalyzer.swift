//
//  TransactionPatternAnalyzer.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation

/// Analyzes transaction patterns to identify trends and anomalies
@MainActor
final class TransactionPatternAnalyzer {
    static let shared = TransactionPatternAnalyzer()

    private init() {}

    /// Analyze transaction patterns over time
    func analyzePatterns(transactions: [FinancialTransaction]) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        // Analyze spending by day of week
        let weekdaySpending = self.analyzeWeekdaySpending(transactions)
        if let weekdayInsight = weekdaySpending {
            insights.append(weekdayInsight)
        }

        // Analyze spending by time of month
        let monthlySpending = self.analyzeMonthlySpending(transactions)
        if let monthlyInsight = monthlySpending {
            insights.append(monthlyInsight)
        }

        // Detect unusual transactions
        let anomalies = self.detectAnomalies(transactions)
        insights.append(contentsOf: anomalies)

        return insights
    }

    private func analyzeWeekdaySpending(_ transactions: [FinancialTransaction]) -> FinancialInsight? {
        let calendar = Calendar.current
        let expenses = transactions.filter { $0.amount < 0 }

        var spendingByWeekday: [Int: Double] = [:]
        var countByWeekday: [Int: Int] = [:]

        for transaction in expenses {
            let weekday = calendar.component(.weekday, from: transaction.date)
            spendingByWeekday[weekday] = (spendingByWeekday[weekday] ?? 0) + abs(transaction.amount)
            countByWeekday[weekday] = (countByWeekday[weekday] ?? 0) + 1
        }

        guard let maxWeekday = spendingByWeekday.max(by: { $0.value < $1.value })?.key else {
            return nil
        }

        let weekdayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let dayName = weekdayNames[maxWeekday]

        return FinancialInsight(
            title: "Spending Patterns",
            description: "You tend to spend the most on \(dayName)s. Consider this when planning your budget.",
            priority: .low,
            type: .pattern,
            visualizationType: .barChart,
            data: [
                ("Highest Spending Day", Double(maxWeekday)),
                ("Average Daily Spending", spendingByWeekday.values.reduce(0, +) / Double(spendingByWeekday.count)),
            ]
        )
    }

    private func analyzeMonthlySpending(_ transactions: [FinancialTransaction]) -> FinancialInsight? {
        let calendar = Calendar.current
        let expenses = transactions.filter { $0.amount < 0 }

        var spendingByDay: [Int: Double] = [:]

        for transaction in expenses {
            let day = calendar.component(.day, from: transaction.date)
            spendingByDay[day] = (spendingByDay[day] ?? 0) + abs(transaction.amount)
        }

        guard let maxDay = spendingByDay.max(by: { $0.value < $1.value })?.key else {
            return nil
        }

        return FinancialInsight(
            title: "Monthly Spending Cycle",
            description: "You tend to spend more around the \(maxDay)th of each month. This could indicate bill payment patterns.",
            priority: .low,
            type: .pattern,
            visualizationType: .lineChart,
            data: [
                ("Peak Spending Day", Double(maxDay)),
                ("Monthly Pattern Detected", 1.0),
            ]
        )
    }

    private func detectAnomalies(_ transactions: [FinancialTransaction]) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        // Calculate average transaction amount
        let expenses = transactions.filter { $0.amount < 0 }
        guard !expenses.isEmpty else { return insights }

        let amounts = expenses.map { abs($0.amount) }
        let average = amounts.reduce(0, +) / Double(amounts.count)
        let standardDeviation = self.calculateStandardDeviation(amounts, mean: average)

        // Find transactions that are more than 2 standard deviations above the mean
        let threshold = average + (2 * standardDeviation)
        let anomalies = expenses.filter { abs($0.amount) > threshold }

        for anomaly in anomalies {
            let insight = FinancialInsight(
                title: "Unusual Transaction Detected",
                description: "A transaction of \(fi_formatCurrency(abs(anomaly.amount))) on \(anomaly.date.formatted()) seems unusually large compared to your typical spending.",
                priority: .medium,
                type: .anomaly,
                visualizationType: .barChart,
                data: [
                    ("Transaction Amount", abs(anomaly.amount)),
                    ("Average Amount", average),
                    ("Deviation", abs(anomaly.amount) - average),
                ]
            )
            insights.append(insight)
        }

        return insights
    }

    private func calculateStandardDeviation(_ values: [Double], mean: Double) -> Double {
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        return sqrt(variance)
    }
}
