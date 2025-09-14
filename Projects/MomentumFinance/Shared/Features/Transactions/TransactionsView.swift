import AppKit
import SwiftData
import SwiftUI
import UIKit

#if canImport(UIKit)
#endif

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
            var filtered = transactions

            // Apply type filter
            switch selectedFilter {
            case .all:
                break
            case .income:
                filtered = filtered.filter { $0.transactionType == .income }
            case .expense:
                filtered = filtered.filter { $0.transactionType == .expense }
            case .transfer:
                filtered = filtered.filter { $0.transactionType == .transfer }
            case .thisWeek, .thisMonth, .lastMonth, .thisYear, .custom:
                // For now, return all transactions for date-based filters
                // In a real implementation, these would filter by date ranges
                break
            }

            // Apply search filter
            if !searchText.isEmpty {
                filtered = filtered.filter { transaction in
                    transaction.title.localizedCaseInsensitiveContains(searchText)
                        || transaction.category?.name.localizedCaseInsensitiveContains(searchText)
                        == true
                }
            }

            return filtered
        }

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    headerSection

                    if filteredTransactions.isEmpty {
                        TransactionEmptyStateView(searchText: searchText) {
                            showingAddTransaction = true
                        }
                    } else {
                        TransactionListView(
                            transactions: filteredTransactions,
                            onTransactionTapped: { transaction in
                                selectedTransaction = transaction
                            },
                            onDeleteTransaction: deleteTransaction
                        )
                    }
                }
                .navigationTitle("Transactions")
                .toolbar {
                    toolbarContent
                }
                .sheet(isPresented: $showingAddTransaction) {
                    AddTransactionView(categories: categories, accounts: accounts)
                }
                .sheet(isPresented: $showingSearch) {
                    Features.GlobalSearch.GlobalSearchView()
                }
                .sheet(item: $selectedTransaction) { transaction in
                    TransactionDetailView(transaction: transaction)
                }
                .onAppear {
                    viewModel.setModelContext(modelContext)
                }
            }
        }

        @ViewBuilder
        private var headerSection: some View {
            VStack(spacing: 20) {
                TransactionStatsCard(transactions: filteredTransactions)

                SearchAndFilterSection(
                    searchText: $searchText,
                    selectedFilter: $selectedFilter,
                    showingSearch: $showingSearch
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
                        showingSearch = true
                        NavigationCoordinator.shared.activateSearch()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }

                    Button(action: {
                        showingAddTransaction = true
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

            modelContext.delete(transaction)
            try? modelContext.save()
        }
    }
}

#Preview {
    Features.Transactions.TransactionsView()
}
