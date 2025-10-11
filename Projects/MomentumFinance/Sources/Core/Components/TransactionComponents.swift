import Foundation
import SwiftUI
import enum Shared.TransactionModels.TransactionFilter
import struct Shared.CoreFinancialModels.FinancialTransaction

// Import transaction types
public struct TransactionEmptyStateView: View {
    public let searchText: String
    public let onAddTransaction: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text(self.searchText.isEmpty ? "No Transactions" : "No Results")
                .font(.title2)
                .fontWeight(.semibold)

            Text(
                self.searchText.isEmpty
                    ? "Start tracking your finances by adding your first transaction"
                    : "No transactions match your search criteria"
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            if self.searchText.isEmpty {
                Button("Add Transaction") {
                    self.onAddTransaction()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Add Transaction")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    public init(searchText: String, onAddTransaction: @escaping () -> Void) {
        self.searchText = searchText
        self.onAddTransaction = onAddTransaction
    }
}

public struct TransactionListView: View {
    public let transactions: [FinancialTransaction]
    public let onTransactionTapped: (FinancialTransaction) -> Void
    public let onDeleteTransaction: (FinancialTransaction) -> Void

    public var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(0 ..< self.transactions.count, id: \.self) { index in
                TransactionRowView(
                    transaction: self.transactions[index],
                    onTap: { self.onTransactionTapped(self.transactions[index]) },
                    onDelete: { self.onDeleteTransaction(self.transactions[index]) }
                )
            }
        }
        .padding(.horizontal)
    }

    public init(
        transactions: [FinancialTransaction],
        onTransactionTapped: @escaping (FinancialTransaction) -> Void,
        onDeleteTransaction: @escaping (FinancialTransaction) -> Void
    ) {
        self.transactions = transactions
        self.onTransactionTapped = onTransactionTapped
        self.onDeleteTransaction = onDeleteTransaction
    }
}

public struct TransactionRowView: View {
    public let transaction: FinancialTransaction
    public let onTap: () -> Void
    public let onDelete: (() -> Void)?

    public var body: some View {
        HStack(spacing: 12) {
            // Transaction icon
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "creditcard")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(self.transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(self.transaction.category?.name ?? "Category") • Today")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("$\(self.transaction.amount, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .onTapGesture(perform: self.onTap)
    }

    public init(
        transaction: FinancialTransaction, onTap: @escaping () -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.transaction = transaction
        self.onTap = onTap
        self.onDelete = onDelete
    }
}

public struct AddTransactionView: View {
    public let categories: [Any]
    public let accounts: [Any]
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Transaction")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Categories: \(self.categories.count), Accounts: \(self.accounts.count)")
                    .foregroundColor(.secondary)

                Text("Transaction form would go here")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            self.dismiss()
                        }
                        .accessibilityLabel("Cancel")
                    }

                    ToolbarItem(placement: .primaryAction) {
                        Button("Save") {
                            self.dismiss()
                        }
                        .fontWeight(.semibold)
                        .accessibilityLabel("Save")
                    }
                }
        }
    }

    public init(categories: [Any], accounts: [Any]) {
        self.categories = categories
        self.accounts = accounts
    }
}

public struct TransactionDetailView: View {
    public let transaction: Any
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Transaction header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Transaction Details")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("$0.00")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    // Transaction info
                    VStack(alignment: .leading, spacing: 12) {
                        self.detailRow("Category", "General")
                        self.detailRow("Date", "Today")
                        self.detailRow("Account", "Checking")
                        self.detailRow("Description", "Transaction details")
                    }

                    Spacer()
                }
                .padding()
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        self.dismiss()
                    }
                    .accessibilityLabel("Done")
                }
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }

    public init(transaction: Any) {
        self.transaction = transaction
    }
}

public struct TransactionStatsCard: View {
    public let transactions: [Any]

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transaction Stats")
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                VStack(alignment: .leading) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$0.00")
                        .font(.title3)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Transactions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(self.transactions.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    public init(transactions: [Any]) {
        self.transactions = transactions
    }
}

public struct SearchAndFilterSection: View {
    @Binding public var searchText: String
    @Binding public var selectedFilter: TransactionFilter
    @Binding public var showingSearch: Bool

    public var body: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search transactions...", text: self.$searchText)
                    .textFieldStyle(PlainTextFieldStyle())

                Button(action: { self.showingSearch = true }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .foregroundColor(.blue)
                }
                .accessibilityLabel("Filter")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        self.filterChip(filter.displayName, self.selectedFilter == filter, filter)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func filterChip(_ title: String, _ isSelected: Bool, _ filter: TransactionFilter)
        -> some View {
        Button(action: {
            self.selectedFilter = filter
        }) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .accessibilityLabel("Filter by \(title)")
    }

    public init(
        searchText: Binding<String>,
        selectedFilter: Binding<TransactionFilter>,
        showingSearch: Binding<Bool>
    ) {
        _searchText = searchText
        _selectedFilter = selectedFilter
        _showingSearch = showingSearch
    }
}
