// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Observation
import SwiftData
import SwiftUI
import Shared

extension Features.Transactions {
    @MainActor
    @Observable
    final class TransactionsViewModel: BaseViewModel {
        // MARK: - State and Action Types for BaseViewModel

        struct State {
            var transactions: [FinancialTransaction] = []
            var filteredTransactions: [FinancialTransaction] = []
            var searchQuery: String = ""
            var selectedType: TransactionType?
            var isLoading: Bool = false
            var errorMessage: String?
        }

        enum Action {
            case loadTransactions
            case filterTransactions(type: TransactionType?)
            case searchTransactions(query: String)
            case deleteTransaction(FinancialTransaction)
            case createTransaction(title: String, amount: Double, type: TransactionType, category: ExpenseCategory?, account: FinancialAccount, date: Date, notes: String?)
            case setError(String?)
        }

        var state = State()
        var isLoading: Bool = false

        private var modelContext: ModelContext?

        // MARK: - BaseViewModel Protocol Implementation

        @MainActor
        func handle(_ action: Action) async {
            switch action {
            case .loadTransactions:
                await loadTransactions()
            case .filterTransactions(let type):
                filterTransactions(type: type)
            case .searchTransactions(let query):
                searchTransactions(query: query)
            case .deleteTransaction(let transaction):
                deleteTransaction(transaction)
            case .createTransaction(let title, let amount, let type, let category, let account, let date, let notes):
                createTransaction(title: title, amount: amount, type: type, category: category, account: account, date: date, notes: notes)
            case .setError(let message):
                self.state.errorMessage = message
            }
        }

        /// <#Description#>
        /// - Returns: <#description#>
        func setModelContext(_ context: ModelContext) {
            self.modelContext = context
        }

        // MARK: - Private Methods

        @MainActor
        private func loadTransactions() async {
            guard let modelContext else { return }

            self.state.isLoading = true
            defer { self.state.isLoading = false }

            do {
                let descriptor = FetchDescriptor<FinancialTransaction>(
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
                )
                let transactions = try modelContext.fetch(descriptor)
                self.state.transactions = transactions
                self.state.filteredTransactions = transactions
            } catch {
                self.state.errorMessage = "Failed to load transactions: \(error.localizedDescription)"
                Logger.logError(error, context: "Loading transactions")
            }
        }

        @MainActor
        private func filterTransactions(type: TransactionType?) {
            self.state.selectedType = type
            applyFilters()
        }

        @MainActor
        private func searchTransactions(query: String) {
            self.state.searchQuery = query
            applyFilters()
        }

        @MainActor
        private func applyFilters() {
            var filtered = self.state.transactions

            // Apply type filter
            if let type = self.state.selectedType {
                filtered = filterTransactions(filtered, by: type)
            }

            // Apply search filter
            if !self.state.searchQuery.isEmpty {
                filtered = searchTransactions(filtered, query: self.state.searchQuery)
            }

            self.state.filteredTransactions = filtered
        }

        /// Group transactions by month
        /// <#Description#>
        /// - Returns: <#description#>
        func groupTransactionsByMonth(_ transactions: [FinancialTransaction]) -> [String:
            [FinancialTransaction]
        ] {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"

            return Dictionary(grouping: transactions) { transaction in
                formatter.string(from: transaction.date)
            }
        }

        /// Get total income for a period
        /// <#Description#>
        /// - Returns: <#description#>
        func totalIncome(_ transactions: [FinancialTransaction], for period: DateInterval? = nil)
            -> Double {
            let filteredTransactions: [FinancialTransaction] =
                if let period {
                    transactions.filter { transaction in
                        period.contains(transaction.date)
                    }
                } else {
                    transactions
                }

            return
                filteredTransactions
                    .filter { $0.transactionType == .income }
                    .reduce(0.0) { $0 + $1.amount }
        }

        /// Get total expenses for a period
        /// <#Description#>
        /// - Returns: <#description#>
        func totalExpenses(_ transactions: [FinancialTransaction], for period: DateInterval? = nil)
            -> Double {
            let filteredTransactions: [FinancialTransaction] =
                if let period {
                    transactions.filter { transaction in
                        period.contains(transaction.date)
                    }
                } else {
                    transactions
                }

            return
                filteredTransactions
                    .filter { $0.transactionType == .expense }
                    .reduce(0.0) { $0 + $1.amount }
        }

        /// Get net income for a period
        /// <#Description#>
        /// - Returns: <#description#>
        func netIncome(_ transactions: [FinancialTransaction], for period: DateInterval? = nil)
            -> Double {
            self.totalIncome(transactions, for: period)
                - self.totalExpenses(transactions, for: period)
        }

        /// Get transactions for current month
        /// <#Description#>
        /// - Returns: <#description#>
        func currentMonthTransactions(_ transactions: [FinancialTransaction])
            -> [FinancialTransaction] {
            let calendar = Calendar.current
            let now = Date()

            return transactions.filter { transaction in
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
            }
        }

        /// Get recent transactions
        /// <#Description#>
        /// - Returns: <#description#>
        func recentTransactions(_ transactions: [FinancialTransaction], limit: Int = 10)
            -> [FinancialTransaction] {
            Array(
                transactions
                    .sorted { $0.date > $1.date }
                    .prefix(limit)
            )
        }

        /// Delete transaction and update account balance
        /// <#Description#>
        /// - Returns: <#description#>
        @MainActor
        private func deleteTransaction(_ transaction: FinancialTransaction) {
            guard let modelContext else { return }

            // Reverse the balance change
            if let account = transaction.account {
                switch transaction.transactionType {
                case .income:
                    account.balance -= transaction.amount
                case .expense:
                    account.balance += transaction.amount
                case .transfer:
                    // Transfer transactions don't affect account balance in delete
                    break
                }
            }

            modelContext.delete(transaction)

            do {
                try modelContext.save()
                // Remove from state
                self.state.transactions.removeAll { $0.id == transaction.id }
                applyFilters()
            } catch {
                self.state.errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
                Logger.logError(error, context: "Deleting transaction")
            }
        }

        /// Create a new transaction
        @MainActor
        private func createTransaction(
            title: String,
            amount: Double,
            type: TransactionType,
            category: ExpenseCategory?,
            account: FinancialAccount,
            date: Date = Date(),
            notes: String? = nil,
        ) {
            guard let modelContext else { return }

            let transaction = FinancialTransaction(
                title: title,
                amount: amount,
                date: date,
                transactionType: type,
                notes: notes,
            )

            transaction.category = category
            transaction.account = account

            // Update account balance
            account.updateBalance(for: transaction)

            modelContext.insert(transaction)

            do {
                try modelContext.save()
                // Add to state
                self.state.transactions.insert(transaction, at: 0)
                applyFilters()
            } catch {
                self.state.errorMessage = "Failed to create transaction: \(error.localizedDescription)"
                Logger.logError(error, context: "Creating transaction")
            }
        }

        /// Get spending by category for a given period
        /// <#Description#>
        /// - Returns: <#description#>
        func spendingByCategory(
            _ transactions: [FinancialTransaction], for period: DateInterval? = nil
        ) -> [String: Double] {
            let filteredTransactions: [FinancialTransaction] =
                if let period {
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
