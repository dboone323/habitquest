//
//  TransactionPatternAnalyzer.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation

/// Specialized analyzer for detecting recurring transactions and payment patterns
struct TransactionPatternAnalyzer {

    init() {}

    /// Finds recurring transactions based on name similarity, amount, and timing patterns
    /// - Parameter transactions: Array of financial transactions to analyze
    /// - Returns: Array of transactions identified as recurring payments
    func findRecurringTransactions(_ transactions: [FinancialTransaction]) -> [FinancialTransaction] {
        // Group transactions by name similarity and similar amount
        var transactionsByNameAndAmount: [String: [FinancialTransaction]] = [:]

        for transaction in transactions where transaction.amount < 0 {
            // Generate a key that combines a simplified name and amount range
            let simplifiedName = transaction.title.lowercased()
                .replacingOccurrences(
                    of: "[^a-z0-9]", with: "", options: String.CompareOptions.regularExpression
                )

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

        for (_, similarTransactions) in transactionsByNameAndAmount
            where similarTransactions.count >= 3
        {
            // Sort by date
            let sortedTransactions = similarTransactions.sorted { $0.date < $1.date }

            // Check if the intervals between transactions are regular
            var isRegular = true
            var intervals: [TimeInterval] = []

            for txIndex in 1 ..< sortedTransactions.count {
                let interval = sortedTransactions[txIndex].date.timeIntervalSince(
                    sortedTransactions[txIndex - 1].date)
                intervals.append(interval)
            }

            // Check if the intervals are similar
            if !intervals.isEmpty {
                let averageInterval = intervals.reduce(0, +) / Double(intervals.count)

                // Check if the intervals are within 20% of the average
                for interval in intervals
                    where abs(interval - averageInterval) > averageInterval * 0.2
                {
                    isRegular = false
                    break
                }

                // Check if the interval is roughly a month, week, or year
                let isMonthly =
                    averageInterval >= 28 * 24 * 60 * 60 && averageInterval <= 31 * 24 * 60 * 60
                let isWeekly =
                    averageInterval >= 6.5 * 24 * 60 * 60 && averageInterval <= 7.5 * 24 * 60 * 60
                let isYearly =
                    averageInterval >= 360 * 24 * 60 * 60 && averageInterval <= 370 * 24 * 60 * 60

                if isRegular && (isMonthly || isWeekly || isYearly) {
                    recurringTransactions.append(sortedTransactions.last!)
                }
            }
        }

        return recurringTransactions
    }

    /// Finds potential duplicate transactions based on name similarity, amount, and timing
    /// - Parameter transactions: Array of financial transactions to analyze
    /// - Returns: Array of transaction pairs that may be duplicates
    func findPotentialDuplicates(_ transactions: [FinancialTransaction]) -> [[FinancialTransaction]] {
        // Group transactions by similar name and amount
        var transactionsByNameAndAmount: [String: [FinancialTransaction]] = [:]

        for transaction in transactions where transaction.amount < 0 {
            // Generate a key that combines a simplified name and exact amount
            let simplifiedName = transaction.title.lowercased()
                .replacingOccurrences(
                    of: "[^a-z0-9]", with: "", options: String.CompareOptions.regularExpression
                )

            let exactAmount = abs(transaction.amount)
            let key = "\(simplifiedName)_\(exactAmount)"

            if transactionsByNameAndAmount[key] == nil {
                transactionsByNameAndAmount[key] = []
            }

            transactionsByNameAndAmount[key]?.append(transaction)
        }

        // Find transactions with the same name and amount that occurred close together
        var duplicateSuspects: [[FinancialTransaction]] = []

        for (_, similarTransactions) in transactionsByNameAndAmount
            where similarTransactions.count >= 2
        {
            // Sort by date
            let sortedTransactions = similarTransactions.sorted { $0.date < $1.date }

            // Check for transactions that are less than 48 hours apart
            for txIndex in 1 ..< sortedTransactions.count {
                let interval = sortedTransactions[txIndex].date.timeIntervalSince(
                    sortedTransactions[txIndex - 1].date)
                if interval < 48 * 60 * 60 {
                    duplicateSuspects.append([
                        sortedTransactions[txIndex - 1], sortedTransactions[txIndex],
                    ])
                    break
                }
            }
        }

        return duplicateSuspects
    }

    /// Extracts machine learning features from a transaction for categorization
    /// - Parameter transaction: Transaction to extract features from
    /// - Returns: Dictionary of features for ML processing
    func extractTransactionFeatures(_ transaction: FinancialTransaction) -> [String: Any] {
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
    /// Returns the start of the month for a given date
    /// - Parameter date: The date to find the start of month for
    /// - Returns: The start of the month date
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
