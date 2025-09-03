<<<<<<< HEAD
import UIKit
import SwiftData
import SwiftUI
import UIKit
=======
import SwiftData
import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(AppKit)
    import AppKit
#endif
>>>>>>> 1cf3938 (Create working state for recovery)

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

<<<<<<< HEAD
#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

extension Features.Transactions {
    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case income = "Income"
        case expense = "Expense"
    }

    struct TransactionsView: View {
        @Environment(\.modelContext) private var modelContext
        @Query(sort: \FinancialTransaction.date, order: .reverse) private var transactions: [FinancialTransaction]
        @Query private var categories: [ExpenseCategory]
        @Query private var accounts: [FinancialAccount]
=======
extension Features.Transactions {
    struct TransactionsView: View {
        @Environment(\.modelContext) private var modelContext

        // Use simple stored arrays to keep builds stable when SwiftData's macros are unavailable.
        private var transactions: [FinancialTransaction] = []
        private var categories: [ExpenseCategory] = []
        private var accounts: [FinancialAccount] = []
>>>>>>> 1cf3938 (Create working state for recovery)

        @State private var searchText = ""
        @State private var selectedFilter: TransactionFilter = .all
        @State private var showingAddTransaction = false
        @State private var showingSearch = false
        @State private var selectedTransaction: FinancialTransaction?

<<<<<<< HEAD
        // Animation states
        @State private var headerVisible = false
        @State private var listVisible = false

        @State private var viewModel = Features.Transactions.TransactionsViewModel()
        @StateObject private var navigationCoordinator = NavigationCoordinator.shared

        // Theme colors
        private var backgroundColor: Color {
            #if os(iOS)
            Color(uiColor: .systemGray6)
            #else
            Color(NSColor.controlBackgroundColor)
            #endif
        }

        private var secondaryBackgroundColor: Color {
            #if os(iOS)
            Color(uiColor: .secondarySystemBackground)
            #else
            Color(NSColor.controlBackgroundColor)
            #endif
        }

        #if os(iOS)
        private let navigationStackSpacing: CGFloat = 0
        #else
        private let navigationStackSpacing: CGFloat = 20
        #endif

        init() {
            // Set up navigation appearance
            #if os(iOS)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.shadowColor = .clear

            // Title text attributes
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.label,
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
            ]

            // Large title text attributes
            appearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor.label,
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            #endif
        }
=======
        @State private var viewModel = Features.Transactions.TransactionsViewModel()
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
>>>>>>> 1cf3938 (Create working state for recovery)

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
            }

            // Apply search filter
            if !searchText.isEmpty {
                filtered = filtered.filter { transaction in
<<<<<<< HEAD
                    transaction.title.localizedCaseInsensitiveContains(searchText) ||
                        transaction.category?.name.localizedCaseInsensitiveContains(searchText) == true
=======
                    transaction.title.localizedCaseInsensitiveContains(searchText)
                        || transaction.category?.name.localizedCaseInsensitiveContains(searchText)
                            == true
>>>>>>> 1cf3938 (Create working state for recovery)
                }
            }

            return filtered
        }

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    headerSection

<<<<<<< HEAD
                    // Transaction List with Enhanced Animations
                    if filteredTransactions.isEmpty {
                        emptyStateView
                    } else {
                        transactionListView
=======
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
>>>>>>> 1cf3938 (Create working state for recovery)
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
                    Features.GlobalSearchView()
                }
                .sheet(item: $selectedTransaction) { transaction in
                    TransactionDetailView(transaction: transaction)
                }
                .onAppear {
                    viewModel.setModelContext(modelContext)
<<<<<<< HEAD
                    // Trigger header animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        headerVisible = true
                    }
                    // Trigger list animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        listVisible = true
                    }
=======
>>>>>>> 1cf3938 (Create working state for recovery)
                }
            }
        }

        @ViewBuilder
        private var headerSection: some View {
<<<<<<< HEAD
            AnimatedCard {
                VStack(spacing: 16) {
                    // Quick Transaction Stats
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("This Month")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(filteredTransactions.count) transactions")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .slideIn(from: .leading, delay: 0.1)

                        Spacer()

                        // Income/Expense Summary with Animated Counters
                        HStack(spacing: 20) {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Income")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                let income = filteredTransactions
                                    .filter { $0.transactionType == .income }
                                    .reduce(0) { $0 + $1.amount }
                                AnimatedCounter(value: income)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            .slideIn(from: .trailing, delay: 0.2)

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Expenses")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                let expenses = filteredTransactions
                                    .filter { $0.transactionType == .expense }
                                    .reduce(0) { $0 + $1.amount }
                                AnimatedCounter(value: expenses)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                            .slideIn(from: .trailing, delay: 0.3)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Enhanced Search Bar with Animation
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))

                            TextField("Search transactions...", text: $searchText)
                                .font(.body)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(backgroundColor)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

                        // Clear search button with animation
                        if !searchText.isEmpty {
                            AnimatedButton(
                                action: {
                                    #if os(iOS)
                                    HapticManager.shared.lightImpact()
                                    #endif
                                    searchText = ""
                                },
                                style: .secondary,
                                ) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 20))
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)
                    .slideIn(from: .bottom, delay: 0.4)
                    .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)

                    // Enhanced Filter Picker with Animation
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(TransactionFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .slideIn(from: .bottom, delay: 0.5)
                    .onChange(of: selectedFilter) { _, _ in
                        #if os(iOS)
                        HapticManager.shared.selection()
                        #endif
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [secondaryBackgroundColor, secondaryBackgroundColor.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom,
                    ),
                )
            .opacity(headerVisible ? 1 : 0)
            .offset(y: headerVisible ? 0 : -20)
            .animation(.easeOut(duration: 0.4), value: headerVisible)
        }

        @ViewBuilder
        private var emptyStateView: some View {
            AnimatedCard {
                VStack(spacing: 20) {
                    Spacer()

                    LoadingIndicator(style: .dots)
                        .opacity(0)
                        .overlay(
                            Image(systemName: searchText.isEmpty ? "list.bullet" : "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary.opacity(0.6))
                                .scaleEffect(headerVisible ? 1.0 : 0.5)
                                .animation(AnimationManager.Springs.bouncy.delay(0.6), value: headerVisible),
                            )

                    VStack(spacing: 8) {
                        Text(searchText.isEmpty ? "No Transactions" : "No Results Found")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text(searchText.isEmpty ?
                                "Add your first transaction to get started" :
                                "Try adjusting your search or filters")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .slideIn(from: .bottom, delay: 0.7)

                    if searchText.isEmpty {
                        FloatingActionButton(
                            action: {
                                #if os(iOS)
                                HapticManager.shared.mediumImpact()
                                #endif
                                showingAddTransaction = true
                            },
                            icon: "plus",
                            )
                        .padding(.top, 8)
                        .slideIn(from: .bottom, delay: 0.8)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .opacity(listVisible ? 1 : 0)
            .offset(y: listVisible ? 0 : 20)
            .animation(.easeOut(duration: 0.4).delay(0.1), value: listVisible)
        }

        @ViewBuilder
        private var transactionListView: some View {
            List {
                ForEach(Array(groupedTransactions.enumerated()), id: \.element.key) { groupIndex, group in
                    Section {
                        ForEach(Array(group.value.enumerated()), id: \.element.date) { itemIndex, transaction in
                            transactionRow(transaction: transaction, itemIndex: itemIndex, groupIndex: groupIndex, groupValue: group.value)
                        }
                    } header: {
                        sectionHeader(group: group, groupIndex: groupIndex)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .refreshable {
                #if os(iOS)
                HapticManager.shared.refresh()
                #endif
                // Add refresh functionality if needed
            }
            .opacity(listVisible ? 1 : 0)
            .offset(y: listVisible ? 0 : 20)
            .animation(.easeOut(duration: 0.4).delay(0.2), value: listVisible)
        }

        @ViewBuilder
        private func transactionRow(transaction: FinancialTransaction, itemIndex: Int, groupIndex: Int, groupValue: [FinancialTransaction]) -> some View {
            Button(action: {
                #if os(iOS)
                HapticManager.shared.selection()
                #endif
                selectedTransaction = transaction
            }) {
                AnimatedTransactionItem(transaction: transaction, index: itemIndex)
            }
            .buttonStyle(PlainButtonStyle())
            .slideIn(
                from: .trailing,
                delay: Double(groupIndex) * 0.1 + Double(itemIndex) * 0.05,
                )
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button("Delete", role: .destructive) {
                    #if os(iOS)
                    HapticManager.shared.deletion()
                    #endif
                    if let index = groupValue.firstIndex(
                        where: { $0.date == transaction.date },
                        ) {
                        deleteTransactions(at: IndexSet([index]), in: groupValue)
                    }
                }
            }
        }

        @ViewBuilder
        private func sectionHeader(group: (key: String, value: [FinancialTransaction]), groupIndex: Int) -> some View {
            HStack {
                Text(group.key)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                // Month total with animated counter
                let monthTotal = group.value.reduce(0) { result, transaction in
                    let transactionAmount = transaction.transactionType == .income ?
                        transaction.amount : -transaction.amount
                    return result + transactionAmount
                }
                AnimatedCounter(value: monthTotal)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(monthTotal >= 0 ? .green : .red)
            }
            .padding(.vertical, 4)
            .slideIn(from: .top, delay: Double(groupIndex) * 0.1)
=======
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
>>>>>>> 1cf3938 (Create working state for recovery)
        }

        @ToolbarContentBuilder
        private var toolbarContent: some ToolbarContent {
<<<<<<< HEAD
            #if canImport(UIKit)
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    // Search Button with Animation
                    AnimatedButton(
                        action: {
                            #if os(iOS)
                            HapticManager.shared.lightImpact()
                            #endif
                            showingSearch = true
                            navigationCoordinator.activateSearch()
                        },
                        style: .secondary,
                        ) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .semibold))
                    }

                    // Add Transaction Button with Animation
                    AnimatedButton(
                        action: {
                            #if os(iOS)
                            HapticManager.shared.mediumImpact()
                            #endif
                            showingAddTransaction = true
                        },
                        style: .primary,
                        ) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    // Search Button with Animation
                    AnimatedButton(
                        action: {
                            #if os(iOS)
                            HapticManager.shared.lightImpact()
                            #endif
                            showingSearch = true
                            navigationCoordinator.activateSearch()
                        },
                        style: .secondary,
                        ) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .semibold))
                    }

                    // Add Transaction Button with Animation
                    AnimatedButton(
                        action: {
                            #if os(iOS)
                            HapticManager.shared.mediumImpact()
                            #endif
                            showingAddTransaction = true
                        },
                        style: .primary,
                        ) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            #endif
        }

        private var groupedTransactions: [(key: String, value: [FinancialTransaction])] {
            let grouped = Dictionary(grouping: filteredTransactions) { transaction in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: transaction.date)
            }

            return grouped.sorted { $0.key > $1.key }
        }

        private func deleteTransactions(at offsets: IndexSet, in transactions: [FinancialTransaction]) {
            for index in offsets {
                let transaction = transactions[index]
                // Update account balance
                if let account = transaction.account {
                    switch transaction.transactionType {
                    case .income:
                        account.balance -= transaction.amount
                    case .expense:
                        account.balance += transaction.amount
                    }
                }
                modelContext.delete(transaction)
            }

            try? modelContext.save()
        }
    }

    // MARK: - Supporting Views

    struct EnhancedTransactionRowView: View {
        let transaction: FinancialTransaction

        var body: some View {
            HStack(spacing: 16) {
                // Enhanced Category Icon
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: transaction.category?.iconName ?? "questionmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(categoryColor)
                }

                // Transaction Details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(transaction.title)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Spacer()

                        // Transaction Amount
                        Text(transaction.formattedAmount)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(transaction.transactionType == .income ? .green : .red)
                    }

                    HStack {
                        // Category and Account
                        VStack(alignment: .leading, spacing: 2) {
                            if let categoryName = transaction.category?.name {
                                Text(categoryName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            if let accountName = transaction.account?.name {
                                Text(accountName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        // Date and Type Indicator
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(transaction.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            // Transaction type badge
                            HStack(spacing: 4) {
                                Image(systemName: transaction.transactionType == .income ?
                                        "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(transaction.transactionType == .income ? .green : .red)

                                Text(transaction.transactionType == .income ? "Income" : "Expense")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            .background(Color.clear)
            .contentShape(Rectangle())
        }

        private var categoryColor: Color {
            // Generate a consistent color based on category name
            if let categoryName = transaction.category?.name {
                let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .indigo, .cyan, .mint]
                let index = abs(categoryName.hashValue) % colors.count
                return colors[index]
            }
            return .gray
        }
    }

    struct TransactionRowView: View {
        let transaction: FinancialTransaction

        var body: some View {
            HStack(spacing: 12) {
                // Category Icon
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: transaction.category?.iconName ?? "questionmark")
                            .foregroundColor(.blue)
                    }

                // Transaction Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack {
                        Text(transaction.category?.name ?? "Uncategorized")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let account = transaction.account {
                            Text("• \(account.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Text(transaction.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Amount
                Text(transaction.formattedAmount)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.transactionType == .income ? .green : .red)
            }
            .padding(.vertical, 4)
        }
    }

    struct AddTransactionView: View {
        @Environment(\.dismiss)
        private var dismiss
        @Environment(\.modelContext)
        private var modelContext

        let categories: [ExpenseCategory]
        let accounts: [FinancialAccount]

        @State private var title = ""
        @State private var amount = ""
        @State private var selectedTransactionType = TransactionType.expense
        @State private var selectedCategory: ExpenseCategory?
        @State private var selectedAccount: FinancialAccount?
        @State private var date = Date()
        @State private var notes = ""

        private var isFormValid: Bool {
            !title.isEmpty && !amount.isEmpty && Double(amount) != nil && selectedAccount != nil
        }

        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Transaction Details")) {
                        TextField("Title", text: $title)

                        TextField("Amount", text: $amount)
                            #if canImport(UIKit)
                            .keyboardType(.decimalPad)
                        #endif

                        Picker("Type", selection: $selectedTransactionType) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }

                    Section(header: Text("Category & Account")) {
                        Picker("Category", selection: $selectedCategory) {
                            Text("None").tag(nil as ExpenseCategory?)
                            ForEach(categories, id: \.name) { category in
                                Text(category.name).tag(category as ExpenseCategory?)
                            }
                        }

                        Picker("Account", selection: $selectedAccount) {
                            Text("Select Account").tag(nil as FinancialAccount?)
                            ForEach(accounts, id: \.name) { account in
                                Text(account.name).tag(account as FinancialAccount?)
                            }
                        }
                    }

                    Section(header: Text("Notes (Optional)")) {
                        TextField("Add notes...", text: $notes, axis: .vertical)
                            .lineLimit(3 ... 6)
                    }
                }
                .navigationTitle("Add Transaction")
                #if canImport(UIKit)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    #if canImport(UIKit)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveTransaction()
                        }
                        .disabled(!isFormValid)
                    }
                    #else
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .primaryAction) {
                        Button("Save") {
                            saveTransaction()
                        }
                        .disabled(!isFormValid)
                    }
                    #endif
=======
            ToolbarItem(placement: .navigationBarTrailing) {
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
>>>>>>> 1cf3938 (Create working state for recovery)
                }
            }
        }

<<<<<<< HEAD
        private func saveTransaction() {
            guard let amountValue = Double(amount),
                  let account = selectedAccount else { return }

            let transaction = FinancialTransaction(
                title: title,
                amount: amountValue,
                date: date,
                transactionType: selectedTransactionType,
                notes: notes.isEmpty ? nil : notes,
                )

            transaction.category = selectedCategory
            transaction.account = account

            // Update account balance
            account.updateBalance(for: transaction)

            modelContext.insert(transaction)

            try? modelContext.save()
            dismiss()
        }
    }

    struct TransactionDetailView: View {
        let transaction: FinancialTransaction
        @Environment(\.dismiss)
        private var dismiss

        var body: some View {
            NavigationView {
                VStack(spacing: 20) {
                    // Amount Display
                    VStack(spacing: 8) {
                        Text(transaction.formattedAmount)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(transaction.transactionType == .income ? .green : .red)

                        Text(transaction.transactionType.rawValue)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()

                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "Title", value: transaction.title)
                        DetailRow(label: "Date", value: transaction.formattedDate)

                        if let category = transaction.category {
                            DetailRow(label: "Category", value: category.name)
                        }

                        if let account = transaction.account {
                            DetailRow(label: "Account", value: account.name)
                        }

                        if let notes = transaction.notes, !notes.isEmpty {
                            DetailRow(label: "Notes", value: notes)
                        }
                    }
                    .padding()

                    Spacer()
                }
                .navigationTitle("Transaction Details")
                #if canImport(UIKit)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    #if canImport(UIKit)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                    #else
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                    #endif
                }
            }
        }
    }

    struct DetailRow: View {
        let label: String
        let value: String

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }

    #Preview {
        Features.Transactions.TransactionsView()
    }
=======
        private func deleteTransaction(_ transaction: FinancialTransaction) {
            // Update account balance
            if let account = transaction.account {
                switch transaction.transactionType {
                case .income:
                    account.balance -= transaction.amount
                case .expense:
                    account.balance += transaction.amount
                }
            }

            modelContext.delete(transaction)
            try? modelContext.save()
        }
    }
}

#Preview {
    Features.Transactions.TransactionsView()
>>>>>>> 1cf3938 (Create working state for recovery)
}
