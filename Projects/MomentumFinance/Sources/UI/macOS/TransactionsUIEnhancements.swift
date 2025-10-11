// Momentum Finance - macOS Transactions UI Enhancements
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

#if os(macOS)
// Transactions-specific UI enhancements
extension Features.Transactions {
    /// macOS-specific transactions list view
    struct TransactionsListView: View {
        @Environment(\.modelContext) private var modelContext
        @Query private var transactions: [FinancialTransaction]
        @State private var selectedItem: ListableItem?
        @State private var searchText = ""
        @State private var sortOrder: SortOrder = .dateDescending

        var filteredTransactions: [FinancialTransaction] {
            if self.searchText.isEmpty {
                self.sortedTransactions
            } else {
                self.sortedTransactions.filter {
                    $0.name.localizedCaseInsensitiveContains(self.searchText) ||
                        $0.category?.name.localizedCaseInsensitiveContains(self.searchText) ?? false
                }
            }
        }

        var sortedTransactions: [FinancialTransaction] {
            switch self.sortOrder {
            case .dateDescending:
                self.transactions.sorted { $0.date > $1.date }
            case .dateAscending:
                self.transactions.sorted { $0.date < $1.date }
            case .amountDescending:
                self.transactions.sorted { $0.amount > $1.amount }
            case .amountAscending:
                self.transactions.sorted { $0.amount < $1.amount }
            }
        }

        var body: some View {
            List(selection: self.$selectedItem) {
                ForEach(self.filteredTransactions) { transaction in
                    NavigationLink(value: ListableItem(id: transaction.id, name: transaction.name, type: .transaction)) {
                        HStack {
                            Image(systemName: transaction.amount < 0 ? "arrow.down" : "arrow.up")
                                .foregroundStyle(transaction.amount < 0 ? .red : .green)
                            VStack(alignment: .leading) {
                                Text(transaction.name)
                                    .font(.headline)
                                if let category = transaction.category {
                                    Text(category.name)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(transaction.amount.formatted(.currency(code: "USD")))
                                    .font(.subheadline)
                                    .foregroundStyle(transaction.amount < 0 ? .red : .green)
                                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .tag(ListableItem(id: transaction.id, name: transaction.name, type: .transaction))
                }
            }
            .navigationTitle("Transactions")
            .searchable(text: self.$searchText, prompt: "Search transactions")
            .toolbar {
                ToolbarItem {
                    Picker("Sort", selection: self.$sortOrder) {
                        Text("Newest First").tag(SortOrder.dateDescending)
                        Text("Oldest First").tag(SortOrder.dateAscending)
                        Text("Highest Amount").tag(SortOrder.amountDescending)
                        Text("Lowest Amount").tag(SortOrder.amountAscending)
                    }
                    .pickerStyle(.menu)
                }

                ToolbarItem {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                    .help("Add New Transaction")
                }
            }
        }
    }

    /// Transaction Detail View optimized for macOS
    struct TransactionDetailView: View {
        let transactionId: String

        @Query private var transactions: [FinancialTransaction]
        @State private var isEditing = false

        var transaction: FinancialTransaction? {
            self.transactions.first(where: { $0.id == self.transactionId })
        }

        var body: some View {
            Group {
                if let transaction {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(transaction.name)
                                        .font(.largeTitle)
                                        .bold()

                                    if let category = transaction.category {
                                        HStack {
                                            Image(systemName: "tag")
                                            Text(category.name)
                                                .font(.headline)
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                Text(transaction.amount.formatted(.currency(code: "USD")))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(transaction.amount < 0 ? .red : .green)
                            }

                            Divider()

                            Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 20) {
                                GridRow {
                                    VStack(alignment: .leading) {
                                        Text("Date")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                        Text(transaction.date.formatted(date: .long, time: .shortened))
                                    }

                                    VStack(alignment: .leading) {
                                        Text("Account")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                        Text(transaction.account?.name ?? "Unknown Account")
                                    }
                                }

                                GridRow {
                                    VStack(alignment: .leading) {
                                        Text("Type")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                        Text(transaction.amount < 0 ? "Expense" : "Income")
                                    }

                                    VStack(alignment: .leading) {
                                        Text("Status")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                        Text(transaction.isReconciled ? "Reconciled" : "Pending")
                                            .foregroundStyle(transaction.isReconciled ? .green : .orange)
                                    }
                                }
                            }

                            if !transaction.notes.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Notes")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)

                                    Text(transaction.notes)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.windowBackgroundColor).opacity(0.3))
                                        .cornerRadius(8)
                                }
                            }

                            // Related transactions section (if applicable)
                            if transaction.isRecurring {
                                TransactionSeriesView(originalTransactionId: transaction.id)
                            }

                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .toolbar {
                        ToolbarItem {
                            Button(action: { self.isEditing.toggle() }) {
                                Text(self.isEditing ? "Done" : "Edit")
                            }
                        }

                        ToolbarItem {
                            Menu {
                                Button("Duplicate", action: {})
                                Button("Export as CSV", action: {})
                                Button("Print", action: {})
                                Divider()
                                Button("Delete", action: {})
                                    .foregroundStyle(.red)
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Transaction Not Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The transaction you're looking for could not be found.")
                    )
                }
            }
            .navigationTitle("Transaction Details")
        }
    }

    struct TransactionSeriesView: View {
        let originalTransactionId: String

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Recurring Series")
                    .font(.headline)

                Text("This transaction is part of a recurring series.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // This would show other transactions in the series
                // Placeholder for now
                Text("View all transactions in this series")
                    .foregroundStyle(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.windowBackgroundColor).opacity(0.3))
            .cornerRadius(8)
        }
    }
}
#endif
