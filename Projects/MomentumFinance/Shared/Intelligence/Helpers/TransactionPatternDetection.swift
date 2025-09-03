import Foundation

// MARK: - Transaction Pattern Detection

/// Find recurring transactions based on name, amount, and regularity
func fi_findRecurringTransactions(_ transactions: [FinancialTransaction]) -> [FinancialTransaction] {
    var transactionsByNameAndAmount: [String: [FinancialTransaction]] = [:]

    for transaction in transactions where transaction.amount < 0 {
        let simplifiedName = transaction.title.lowercased()
            .replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)

        let roundedAmount = round(abs(transaction.amount) * 100) / 100
        let key = "\(simplifiedName)_\(roundedAmount)"

        transactionsByNameAndAmount[key, default: []].append(transaction)
    }

    var recurringTransactions: [FinancialTransaction] = []

    for (_, similarTransactions) in transactionsByNameAndAmount where similarTransactions.count >= 3 {
        let sortedTransactions = similarTransactions.sorted { $0.date < $1.date }

        var intervals: [TimeInterval] = []
        for intervalIndex in 1 ..< sortedTransactions.count {
            let interval = sortedTransactions[intervalIndex].date.timeIntervalSince(
                sortedTransactions[intervalIndex - 1].date)
            intervals.append(interval)
        }

        if !intervals.isEmpty {
            let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
            var isRegular = true
            for interval in intervals where abs(interval - averageInterval) > averageInterval * 0.2 {
                isRegular = false
                break
            }

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

/// Find potential duplicate transactions within short time periods
func fi_findPotentialDuplicates(_ transactions: [FinancialTransaction]) -> [[FinancialTransaction]] {
    var transactionsByNameAndAmount: [String: [FinancialTransaction]] = [:]

    for transaction in transactions where transaction.amount < 0 {
        let simplifiedName = transaction.title.lowercased()
            .replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)

        let exactAmount = abs(transaction.amount)
        let key = "\(simplifiedName)_\(exactAmount)"

        transactionsByNameAndAmount[key, default: []].append(transaction)
    }

    var duplicateSuspects: [[FinancialTransaction]] = []

    for (_, similarTransactions) in transactionsByNameAndAmount where similarTransactions.count >= 2 {
        let sortedTransactions = similarTransactions.sorted { $0.date < $1.date }
        for dupIndex in 1 ..< sortedTransactions.count {
            let interval = sortedTransactions[dupIndex].date.timeIntervalSince(
                sortedTransactions[dupIndex - 1].date)
            if interval < 48 * 60 * 60 {
                duplicateSuspects.append([
                    sortedTransactions[dupIndex - 1], sortedTransactions[dupIndex],
                ])
                break
            }
        }
    }

    return duplicateSuspects
}

// fi_monthlyNetCashFlow is implemented in FinancialForecasting.swift (canonical location)
