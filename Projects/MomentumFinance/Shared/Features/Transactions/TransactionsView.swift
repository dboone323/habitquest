import UIKit
import SwiftData
import SwiftUI

#if canImport(AppKit)
#endif

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

extension Features.Transactions {
    struct TransactionsView: View {
        @Environment(\.modelContext) private var modelContext

        // Use simple stored arrays to keep builds stable when SwiftData's macros are unavailable.
        private var transactions: [FinancialTransaction] = []
        private var categories: [ExpenseCategory] = []
        private var accounts: [FinancialAccount] = []

        @State private var searchText = ""
        @State private var selectedFilter: TransactionFilter = .all
        @State private var showingAddTransaction = false
        @State private var showingSearch = false
        @State private var selectedTransaction: FinancialTransaction?

        @State private var viewModel = Features.Transactions.TransactionsViewModel()
        @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

        var filteredTransactions: [FinancialTransaction] {
            var filtered = self.transactions

            // Apply type filter
            switch self.selectedFilter {
            case .all:
                break
            case .income:
                filtered = filtered.filter { $0.transactionType == .income }
            case .expense:
                filtered = filtered.filter { $0.transactionType == .expense }
            case .transfer:
                filtered = filtered.filter { $0.transactionType == .transfer }
            }

            // Apply search filter
            if !self.searchText.isEmpty {
                filtered = filtered.filter { transaction in
                    transaction.title.localizedCaseInsensitiveContains(self.searchText)
                        || transaction.category?.name.localizedCaseInsensitiveContains(
                            self.searchText
                        )
                        == true
                }
            }

            return filtered
        }

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    self.headerSection

                    if self.filteredTransactions.isEmpty {
                        TransactionEmptyStateView(searchText: self.searchText) {
                            self.showingAddTransaction = true
                        }
                    } else {
                        TransactionListView(
                            transactions: self.filteredTransactions,
                            onTransactionTapped: { transaction in
                                self.selectedTransaction = transaction
                            },
                            onDeleteTransaction: self.deleteTransaction
                        )
                    }
                }
                .navigationTitle("Transactions")
                .toolbar {
                    self.toolbarContent
                }
                .sheet(isPresented: self.$showingAddTransaction) {
                    AddTransactionView(categories: self.categories, accounts: self.accounts)
                }
                .sheet(isPresented: self.$showingSearch) {
                    Features.GlobalSearch.GlobalSearchView()
                }
                .sheet(item: self.$selectedTransaction) { transaction in
                    TransactionDetailView(transaction: transaction)
                }
                .onAppear {
                    self.viewModel.setModelContext(self.modelContext)
                }
            }
        }

        @ViewBuilder
        private var headerSection: some View {
            VStack(spacing: 20) {
                TransactionStatsCard(transactions: self.filteredTransactions)

                SearchAndFilterSection(
                    searchText: self.$searchText,
                    selectedFilter: self.$selectedFilter,
                    showingSearch: self.$showingSearch
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }

        @ToolbarContentBuilder
        private var toolbarContent: some ToolbarContent {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    Button(action: {
                        self.showingSearch = true
                        NavigationCoordinator.shared.activateSearch()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }

                    Button(action: {
                        self.showingAddTransaction = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }

        private func deleteTransaction(_ transaction: FinancialTransaction) {
            // Update account balance
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

            self.modelContext.delete(transaction)
            try? self.modelContext.save()
        }
    }
}

#Preview {
    Features.Transactions.TransactionsView()
}
