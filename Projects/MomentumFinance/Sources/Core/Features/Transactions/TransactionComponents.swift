import SwiftUI

public struct TransactionEmptyStateView: View {
    let searchText: String
    let onAddTransaction: () -> Void

    public init(searchText: String, onAddTransaction: @escaping () -> Void) {
        self.searchText = searchText
        self.onAddTransaction = onAddTransaction
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(
                systemName: self.searchText.isEmpty ? "doc.text.magnifyingglass" : "magnifyingglass"
            )
            .font(.system(size: 48))
            .foregroundColor(.secondary)
            Text(self.searchText.isEmpty ? "No transactions yet" : "No transactions found")
                .font(.title2)
                .foregroundColor(.primary)
            Text(
                self.searchText.isEmpty
                    ? "Add your first transaction to get started"
                    : "Try adjusting your search or filter"
            )
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            if self.searchText.isEmpty {
                Button(action: self.onAddTransaction) {
                    Label("Add Transaction", systemImage: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .accessibilityLabel("Add Transaction")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

public struct TransactionListView: View {
    let transactions: [FinancialTransaction]
    let onTransactionTapped: (FinancialTransaction) -> Void
    let onDeleteTransaction: (FinancialTransaction) -> Void

    public init(
        transactions: [FinancialTransaction],
        onTransactionTapped: @escaping (FinancialTransaction) -> Void,
        onDeleteTransaction: @escaping (FinancialTransaction) -> Void
    ) {
        self.transactions = transactions
        self.onTransactionTapped = onTransactionTapped
        self.onDeleteTransaction = onDeleteTransaction
    }

    public var body: some View {
        List {
            ForEach(self.transactions) { transaction in
                TransactionRowView(transaction: transaction) {
                    self.onTransactionTapped(transaction)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        self.onDeleteTransaction(transaction)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .accessibilityLabel("Delete Transaction")
                }
            }
        }
        .listStyle(.plain)
    }
}

public struct TransactionRowView: View {
    let transaction: FinancialTransaction
    let onTap: () -> Void
    public init(transaction: FinancialTransaction, onTap: @escaping () -> Void) {
        self.transaction = transaction
        self.onTap = onTap
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(self.transaction.title).font(.subheadline).foregroundColor(.primary)
                Text(self.transaction.date, style: .date).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text(self.transaction.amount.formatted(.currency(code: "USD")))
                .font(.subheadline)
                .foregroundColor(self.transaction.amount >= 0 ? .green : .red)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: self.onTap)
    }
}

public struct AddTransactionView: View {
    let categories: [ExpenseCategory]
    let accounts: [FinancialAccount]
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: ExpenseCategory?
    @State private var selectedAccount: FinancialAccount?
    @State private var date = Date()
    @State private var transactionType: TransactionType = .expense

    public init(categories: [ExpenseCategory], accounts: [FinancialAccount]) {
        self.categories = categories
        self.accounts = accounts
    }

    public var body: some View {
        NavigationView {
            Form {
                Section("Transaction Details") {
                    TextField("Title", text: self.$title).accessibilityLabel("Text Field")
                    TextField("Amount", text: self.$amount).accessibilityLabel("Text Field")
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif
                    Picker("Type", selection: self.$transactionType) {
                        Text("Income").tag(TransactionType.income)
                        Text("Expense").tag(TransactionType.expense)
                        Text("Transfer").tag(TransactionType.transfer)
                    }
                }
                Section("Category & Account") {
                    Picker("Category", selection: self.$selectedCategory) {
                        Text("None").tag(ExpenseCategory?.none)
                        ForEach(self.categories) { category in
                            Text(category.name).tag(category as ExpenseCategory?)
                        }
                    }
                    Picker("Account", selection: self.$selectedAccount) {
                        Text("None").tag(FinancialAccount?.none)
                        ForEach(self.accounts) { account in
                            Text(account.name).tag(account as FinancialAccount?)
                        }
                    }
                }
                Section("Date") {
                    DatePicker(
                        "Transaction Date", selection: self.$date, displayedComponents: .date
                    )
                }
            }
            .navigationTitle("Add Transaction")
            #if os(iOS)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { self.dismiss() }.accessibilityLabel("Cancel")
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { self.saveTransaction() }.accessibilityLabel(
                            "Save Transaction"
                        ).disabled(self.title.isEmpty || self.amount.isEmpty)
                    }
                }
            #elseif os(macOS)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { self.dismiss() }.accessibilityLabel("Cancel")
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { self.saveTransaction() }.accessibilityLabel(
                            "Save Transaction"
                        ).disabled(self.title.isEmpty || self.amount.isEmpty)
                    }
                }
            #endif
        }
    }

    private func saveTransaction() { self.dismiss() }
}

public struct TransactionDetailView: View {
    let transaction: FinancialTransaction
    public init(transaction: FinancialTransaction) { self.transaction = transaction }
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(self.transaction.title).font(.title).foregroundColor(.primary)
                    Text(self.transaction.amount.formatted(.currency(code: "USD"))).font(.title2)
                        .foregroundColor(self.transaction.amount >= 0 ? .green : .red)
                }
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(
                        label: "Date",
                        value: self.transaction.date.formatted(date: .long, time: .omitted)
                    )
                    DetailRow(
                        label: "Type", value: self.transaction.transactionType.rawValue.capitalized
                    )
                    if let category = transaction.category {
                        DetailRow(label: "Category", value: category.name)
                    }
                    if let account = transaction.account {
                        DetailRow(label: "Account", value: account.name)
                    }
                    if let notes = transaction.notes { DetailRow(label: "Notes", value: notes) }
                }
            }.padding()
        }.navigationTitle("Transaction Details")
    }
}

public struct TransactionStatsCard: View {
    let transactions: [FinancialTransaction]
    public init(transactions: [FinancialTransaction]) { self.transactions = transactions }
    private var totalIncome: Double {
        self.transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalExpenses: Double {
        self.transactions.filter { $0.transactionType == .expense }.reduce(0) {
            $0 + abs($1.amount)
        }
    }

    public var body: some View {
        HStack(spacing: 20) {
            StatItem(
                title: "Income", amount: self.totalIncome, color: .green,
                icon: "arrow.down.circle.fill"
            )
            StatItem(
                title: "Expenses", amount: self.totalExpenses, color: .red,
                icon: "arrow.up.circle.fill"
            )
            StatItem(
                title: "Net", amount: self.totalIncome - self.totalExpenses,
                color: (self.totalIncome - self.totalExpenses) >= 0 ? .green : .red,
                icon: "equal.circle.fill"
            )
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

public struct SearchAndFilterSection: View {
    @Binding var searchText: String
    @Binding var selectedFilter: TransactionFilter
    @Binding var showingSearch: Bool
    public init(
        searchText: Binding<String>, selectedFilter: Binding<TransactionFilter>,
        showingSearch: Binding<Bool>
    ) {
        _searchText = searchText
        _selectedFilter = selectedFilter
        _showingSearch = showingSearch
    }

    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Search transactions", text: self.$searchText).accessibilityLabel(
                    "Text Field"
                ).textFieldStyle(.plain)
                if !self.searchText.isEmpty {
                    Button(action: { self.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }.accessibilityLabel("Clear Search")
                }
            }
            .padding(12)
            .background(platformGrayColor())
            .cornerRadius(8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            title: filter.displayName, isSelected: self.selectedFilter == filter
                        ) { self.selectedFilter = filter }
                    }
                }.padding(.horizontal, 4)
            }
        }.padding(.horizontal)
    }
}

// MARK: - Helper Views

private struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(self.label).foregroundColor(.secondary).frame(width: 80, alignment: .leading)
            Text(self.value).foregroundColor(.primary)
        }
    }
}

private struct StatItem: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: self.icon).foregroundColor(self.color).font(.system(size: 20))
            Text(self.title).font(.caption).foregroundColor(.secondary)
            Text(self.amount.formatted(.currency(code: "USD"))).font(.subheadline).fontWeight(
                .semibold
            ).foregroundColor(self.color)
        }.frame(maxWidth: .infinity)
    }
}

private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: self.action) {
            Text(self.title).font(.subheadline).padding(.horizontal, 12).padding(.vertical, 6)
                .background(self.isSelected ? Color.blue : platformSecondaryGrayColor())
                .foregroundColor(self.isSelected ? .white : .primary).cornerRadius(16)
        }.accessibilityLabel(self.title)
    }
}
