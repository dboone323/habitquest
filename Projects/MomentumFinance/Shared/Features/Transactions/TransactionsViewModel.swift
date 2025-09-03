// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Observation
import SwiftData
import SwiftUI

extension Features.Transactions {
    @MainActor
    @Observable
    final class TransactionsViewModel {
        private var modelContext: ModelContext?

<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func setModelContext(_ context: ModelContext) {
            self.modelContext = context
        }

        /// Filter transactions by type
<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func filterTransactions(_ transactions: [FinancialTransaction], by type: TransactionType?) -> [FinancialTransaction] {
            guard let type else { return transactions }
            return transactions.filter { $0.transactionType == type }
        }

        /// Search transactions by title or category
<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func searchTransactions(_ transactions: [FinancialTransaction], query: String) -> [FinancialTransaction] {
            guard !query.isEmpty else { return transactions }

            return transactions.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(query) ||
                    transaction.category?.name.localizedCaseInsensitiveContains(query) == true ||
                    transaction.notes?.localizedCaseInsensitiveContains(query) == true
            }
        }

        /// Group transactions by month
<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func groupTransactionsByMonth(_ transactions: [FinancialTransaction]) -> [String: [FinancialTransaction]] {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"

            return Dictionary(grouping: transactions) { transaction in
                formatter.string(from: transaction.date)
            }
        }

        /// Get total income for a period
<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func totalIncome(_ transactions: [FinancialTransaction], for period: DateInterval? = nil) -> Double {
            let filteredTransactions: [FinancialTransaction] = if let period {
                transactions.filter { transaction in
                    period.contains(transaction.date)
                }
            } else {
                transactions
            }

            return filteredTransactions
                .filter { $0.transactionType == .income }
                .reduce(0.0) { $0 + $1.amount }
        }

        /// Get total expenses for a period
<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func totalExpenses(_ transactions: [FinancialTransaction], for period: DateInterval? = nil) -> Double {
            let filteredTransactions: [FinancialTransaction] = if let period {
                transactions.filter { transaction in
                    period.contains(transaction.date)
                }
            } else {
                transactions
            }

            return filteredTransactions
                .filter { $0.transactionType == .expense }
                .reduce(0.0) { $0 + $1.amount }
        }

        /// Get net income for a period
<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func netIncome(_ transactions: [FinancialTransaction], for period: DateInterval? = nil) -> Double {
            totalIncome(transactions, for: period) - totalExpenses(transactions, for: period)
        }

        /// Get transactions for current month
<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func currentMonthTransactions(_ transactions: [FinancialTransaction]) -> [FinancialTransaction] {
            let calendar = Calendar.current
            let now = Date()

            return transactions.filter { transaction in
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
            }
        }

        /// Get recent transactions
<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
        func recentTransactions(_ transactions: [FinancialTransaction], limit: Int = 10) -> [FinancialTransaction] {
            Array(transactions
                    .sorted { $0.date > $1.date }
                    .prefix(limit))
        }

        /// Delete transaction and update account balance
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
        func recentTransactions(_ transactions: [FinancialTransaction], limit: Int = 10) -> [FinancialTransaction] {
            Array(transactions
                .sorted { $0.date > $1.date }
                .prefix(limit))
        }

        /// Delete transaction and update account balance
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func deleteTransaction(_ transaction: FinancialTransaction) {
            guard let modelContext else { return }

            // Reverse the balance change
            if let account = transaction.account {
                switch transaction.transactionType {
                case .income:
                    account.balance -= transaction.amount
                case .expense:
                    account.balance += transaction.amount
                }
            }

            modelContext.delete(transaction)

            do {
                try modelContext.save()
            } catch {
                Logger.logError(error, context: "Deleting transaction")
            }
        }

        /// Create a new transaction
        func createTransaction(
            title: String,
            amount: Double,
            type: TransactionType,
            category: ExpenseCategory?,
            account: FinancialAccount,
            date: Date = Date(),
            notes: String? = nil,
<<<<<<< HEAD
            ) {
=======
        ) {
>>>>>>> 1cf3938 (Create working state for recovery)
            guard let modelContext else { return }

            let transaction = FinancialTransaction(
                title: title,
                amount: amount,
                date: date,
                transactionType: type,
                notes: notes,
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)

            transaction.category = category
            transaction.account = account

            // Update account balance
            account.updateBalance(for: transaction)

            modelContext.insert(transaction)

            do {
                try modelContext.save()
            } catch {
                Logger.logError(error, context: "Creating transaction")
            }
        }

        /// Get spending by category for a given period
<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func spendingByCategory(_ transactions: [FinancialTransaction], for period: DateInterval? = nil) -> [String: Double] {
            let filteredTransactions: [FinancialTransaction] = if let period {
                transactions.filter { transaction in
                    transaction.transactionType == .expense && period.contains(transaction.date)
                }
            } else {
                transactions.filter { $0.transactionType == .expense }
            }

            var spending: [String: Double] = [:]

            for transaction in filteredTransactions {
                let categoryName = transaction.category?.name ?? "Uncategorized"
                spending[categoryName, default: 0] += transaction.amount
            }

            return spending
        }
    }
}
