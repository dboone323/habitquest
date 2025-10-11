// Momentum Finance - Enhanced macOS App Entry Point
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

// This file contains enhanced macOS platform optimizations for the app
// To use this file, reference ContentView_macOS() in the main app entry point

#if os(macOS)
// List view components needed for the three-column macOS layout

// Dashboard list view for the middle column
extension Features.FinancialDashboard {
    struct DashboardListView: View {
        @Environment(\.modelContext) private var modelContext
        @Query private var accounts: [FinancialAccount]
        @Query private var recentTransactions: [FinancialTransaction]
        @State private var selectedItem: ListableItem?

        var body: some View {
            List(selection: self.$selectedItem) {
                Section("Accounts") {
                    ForEach(self.accounts) { account in
                        NavigationLink(value: ListableItem(id: account.id, name: account.name, type: .account)) {
                            HStack {
                                Image(systemName: account.type == .checking ? "banknote" : "creditcard")
                                    .foregroundStyle(account.type == .checking ? .green : .blue)
                                VStack(alignment: .leading) {
                                    Text(account.name)
                                        .font(.headline)
                                    Text(account.balance.formatted(.currency(code: "USD")))
                                        .font(.subheadline)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .tag(ListableItem(id: account.id, name: account.name, type: .account))
                    }
                }

                Section("Recent Transactions") {
                    ForEach(self.recentTransactions.prefix(5)) { transaction in
                        NavigationLink(value: ListableItem(id: transaction.id, name: transaction.name, type: .transaction)) {
                            HStack {
                                Image(systemName: transaction.amount < 0 ? "arrow.down" : "arrow.up")
                                    .foregroundStyle(transaction.amount < 0 ? .red : .green)
                                VStack(alignment: .leading) {
                                    Text(transaction.name)
                                        .font(.headline)
                                    Text(transaction.amount.formatted(.currency(code: "USD")))
                                        .font(.subheadline)
                                }
                                Spacer()
                                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .tag(ListableItem(id: transaction.id, name: transaction.name, type: .transaction))
                    }
                }

                Section("Quick Actions") {
                    Button("Add New Account").accessibilityLabel("Button").accessibilityLabel("Button") {
                        // Action to add new account
                    }

                    Button("Add New Transaction").accessibilityLabel("Button").accessibilityLabel("Button") {
                        // Action to add new transaction
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem {
                    Button(action: {}).accessibilityLabel("Button").accessibilityLabel("Button") {
                        Image(systemName: "plus")
                    }
                    .help("Add New Item")
                }

                ToolbarItem {
                    Button(action: {}).accessibilityLabel("Button").accessibilityLabel("Button") {
                        Image(systemName: "arrow.clockwise")
                    }
                    .help("Refresh")
                }
            }
        }
    }
}

// Transactions list view for the middle column
extension Features.Transactions {
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
                    Button(action: {}).accessibilityLabel("Button").accessibilityLabel("Button") {
                        Image(systemName: "plus")
                    }
                    .help("Add New Transaction")
                }
            }
        }
    }

    // Transaction Detail View optimized for macOS
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
                            Button(action: { self.isEditing.toggle().accessibilityLabel("Button").accessibilityLabel("Button") }) {
                                Text(self.isEditing ? "Done" : "Edit")
                            }
                        }

                        ToolbarItem {
                            Menu {
                                Button("Duplicate", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                                Button("Export as CSV", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                                Button("Print", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                                Divider()
                                Button("Delete", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
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

// Budgets list view for the middle column
extension Features.Budgets {
    struct BudgetListView: View {
        @Environment(\.modelContext) private var modelContext
        @Query private var budgets: [Budget]
        @State private var selectedItem: ListableItem?

        var body: some View {
            List(selection: self.$selectedItem) {
                ForEach(self.budgets) { budget in
                    NavigationLink(value: ListableItem(id: budget.id, name: budget.name, type: .budget)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(budget.name)
                                    .font(.headline)
                                Spacer()
                                Text(
                                    "\(budget.spent.formatted(.currency(code: "USD"))) of \(budget.amount.formatted(.currency(code: "USD")))"
                                )
                                .font(.subheadline)
                            }

                            ProgressView(value: budget.spent, total: budget.amount)
                                .tint(self.getBudgetColor(spent: budget.spent, total: budget.amount))
                        }
                        .padding(.vertical, 4)
                    }
                    .tag(ListableItem(id: budget.id, name: budget.name, type: .budget))
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem {
                    Button(action: {}).accessibilityLabel("Button").accessibilityLabel("Button") {
                        Image(systemName: "plus")
                    }
                    .help("Add New Budget")
                }
            }
        }

        private func getBudgetColor(spent: Double, total: Double) -> Color {
            let percentage = spent / total
            if percentage < 0.7 {
                return .green
            } else if percentage < 0.9 {
                return .yellow
            } else {
                return .red
            }
        }
    }

    // Budget Detail View optimized for macOS
    struct BudgetDetailView: View {
        let budgetId: String

        @Query private var budgets: [Budget]
        @Query private var transactions: [FinancialTransaction]
        @State private var isEditing = false

        var budget: Budget? {
            self.budgets.first(where: { $0.id == self.budgetId })
        }

        var relatedTransactions: [FinancialTransaction] {
            guard let budget, let category = budget.category else {
                return []
            }

            // Get all transactions for this budget's category within the current period
            return self.transactions.filter { transaction in
                if transaction.category?.id == category.id {
                    // Check if transaction is within the current budget period
                    // This is simplified - would need actual date range logic
                    let currentMonth = Calendar.current.component(.month, from: Date())
                    let transactionMonth = Calendar.current.component(.month, from: transaction.date)
                    return currentMonth == transactionMonth
                }
                return false
            }
        }

        var body: some View {
            Group {
                if let budget {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(budget.name)
                                        .font(.largeTitle)
                                        .bold()

                                    if let category = budget.category {
                                        HStack {
                                            Image(systemName: "tag")
                                            Text("Category: \(category.name)")
                                                .font(.headline)
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text(budget.amount.formatted(.currency(code: "USD")))
                                        .font(.system(size: 28, weight: .bold))

                                    Text("Budget Limit")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Budget Progress")
                                        .font(.headline)

                                    Spacer()

                                    Text(
                                        "\(budget.spent.formatted(.currency(code: "USD"))) of \(budget.amount.formatted(.currency(code: "USD")))"
                                    )
                                }

                                ProgressView(value: budget.spent, total: budget.amount)
                                    .tint(self.getBudgetColor(spent: budget.spent, total: budget.amount))
                                    .scaleEffect(y: 2.0)
                                    .padding(.vertical, 8)

                                HStack {
                                    Text("Remaining: \((budget.amount - budget.spent).formatted(.currency(code: "USD")))")
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Text("\(Int((budget.spent / budget.amount) * 100))%")
                                        .foregroundStyle(self.getBudgetColor(spent: budget.spent, total: budget.amount))
                                        .bold()
                                }
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Related Transactions")
                                        .font(.headline)

                                    Spacer()

                                    Text("\(self.relatedTransactions.count) transactions")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                if self.relatedTransactions.isEmpty {
                                    Text("No transactions found for this budget category")
                                        .foregroundStyle(.secondary)
                                        .padding()
                                } else {
                                    // Show transactions table
                                    TransactionsTable(transactions: self.relatedTransactions)
                                }
                            }

                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .toolbar {
                        ToolbarItem {
                            Button(action: { self.isEditing.toggle().accessibilityLabel("Button").accessibilityLabel("Button") }) {
                                Text(self.isEditing ? "Done" : "Edit")
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Budget Not Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The budget you're looking for could not be found.")
                    )
                }
            }
            .navigationTitle("Budget Details")
        }

        private func getBudgetColor(spent: Double, total: Double) -> Color {
            let percentage = spent / total
            if percentage < 0.7 {
                return .green
            } else if percentage < 0.9 {
                return .yellow
            } else {
                return .red
            }
        }
    }

    struct TransactionsTable: View {
        let transactions: [FinancialTransaction]

        var body: some View {
            VStack {
                HStack {
                    Text("Date")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)

                    Text("Description")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Amount")
                        .font(.headline)
                        .frame(width: 100, alignment: .trailing)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.controlBackgroundColor))

                Divider()

                ForEach(self.transactions) { transaction in
                    HStack {
                        Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                            .frame(width: 100, alignment: .leading)

                        Text(transaction.name)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(transaction.amount.formatted(.currency(code: "USD")))
                            .frame(width: 100, alignment: .trailing)
                            .foregroundStyle(transaction.amount < 0 ? .red : .green)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    Divider()
                }
            }
            .background(Color(.windowBackgroundColor).opacity(0.3))
            .cornerRadius(8)
        }
    }
}

// Subscriptions list view for the middle column
extension Features.Subscriptions {
    struct SubscriptionListView: View {
        @Environment(\.modelContext) private var modelContext
        @Query private var subscriptions: [Subscription]
        @State private var selectedItem: ListableItem?
        @State private var groupBy: GroupOption = .date

        enum GroupOption {
            case date, amount, provider
        }

        var body: some View {
            List(selection: self.$selectedItem) {
                ForEach(self.getGroupedSubscriptions()) { group in
                    Section(header: Text(group.title)) {
                        ForEach(group.items) { subscription in
                            NavigationLink(value: ListableItem(id: subscription.id, name: subscription.name, type: .subscription)) {
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundStyle(.purple)

                                    VStack(alignment: .leading) {
                                        Text(subscription.name)
                                            .font(.headline)

                                        Text(subscription.provider)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text(subscription.amount.formatted(.currency(code: "USD")))
                                            .font(.subheadline)

                                        Text(subscription.billingCycle.displayName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .tag(ListableItem(id: subscription.id, name: subscription.name, type: .subscription))
                        }
                    }
                }
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem {
                    Picker("Group By", selection: self.$groupBy) {
                        Text("Next Payment").tag(GroupOption.date)
                        Text("Amount").tag(GroupOption.amount)
                        Text("Provider").tag(GroupOption.provider)
                    }
                    .pickerStyle(.menu)
                }

                ToolbarItem {
                    Button(action: {}).accessibilityLabel("Button").accessibilityLabel("Button") {
                        Image(systemName: "plus")
                    }
                    .help("Add New Subscription")
                }
            }
        }

        struct SubscriptionGroup: Identifiable {
            let id = UUID()
            let title: String
            let items: [Subscription]
        }

        private func getGroupedSubscriptions() -> [SubscriptionGroup] {
            switch self.groupBy {
            case .date:
                // Group by next payment date (simplified)
                let thisWeek = self.subscriptions.filter {
                    guard let nextDate = $0.nextPaymentDate else { return false }
                    return Calendar.current.isDate(nextDate, equalTo: Date(), toGranularity: .weekOfYear)
                }

                let thisMonth = self.subscriptions.filter {
                    guard let nextDate = $0.nextPaymentDate else { return false }
                    return Calendar.current.isDate(nextDate, equalTo: Date(), toGranularity: .month) &&
                        !Calendar.current.isDate(nextDate, equalTo: Date(), toGranularity: .weekOfYear)
                }

                let future = self.subscriptions.filter {
                    guard let nextDate = $0.nextPaymentDate else { return false }
                    return nextDate > Date() &&
                        !Calendar.current.isDate(nextDate, equalTo: Date(), toGranularity: .month)
                }

                var result: [SubscriptionGroup] = []
                if !thisWeek.isEmpty {
                    result.append(SubscriptionGroup(title: "Due This Week", items: thisWeek))
                }
                if !thisMonth.isEmpty {
                    result.append(SubscriptionGroup(title: "Due This Month", items: thisMonth))
                }
                if !future.isEmpty {
                    result.append(SubscriptionGroup(title: "Upcoming", items: future))
                }

                return result

            case .amount:
                // Group by price tiers
                let lowTier = self.subscriptions.filter { $0.amount < 10 }
                let midTier = self.subscriptions.filter { $0.amount >= 10 && $0.amount < 25 }
                let highTier = self.subscriptions.filter { $0.amount >= 25 }

                var result: [SubscriptionGroup] = []
                if !lowTier.isEmpty {
                    result.append(SubscriptionGroup(title: "Under $10", items: lowTier))
                }
                if !midTier.isEmpty {
                    result.append(SubscriptionGroup(title: "$10 - $25", items: midTier))
                }
                if !highTier.isEmpty {
                    result.append(SubscriptionGroup(title: "Over $25", items: highTier))
                }

                return result

            case .provider:
                // Group by provider
                let grouped = Dictionary(grouping: subscriptions) { $0.provider }
                return grouped.map {
                    SubscriptionGroup(title: $0.key, items: $0.value)
                }.sorted { $0.title < $1.title }
            }
        }
    }
}

// Goals list view for the middle column
extension Features.GoalsAndReports {
    struct GoalsListView: View {
        @Environment(\.modelContext) private var modelContext
        @Query private var goals: [SavingsGoal]
        @State private var selectedItem: ListableItem?
        @State private var viewType: ViewType = .goals

        enum ViewType {
            case goals, reports
        }

        var body: some View {
            VStack {
                Picker("View", selection: self.$viewType) {
                    Text("Savings Goals").tag(ViewType.goals)
                    Text("Reports").tag(ViewType.reports)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if self.viewType == .goals {
                    self.goalsList
                } else {
                    self.reportsList
                }
            }
            .navigationTitle("Goals & Reports")
            .toolbar {
                ToolbarItem {
                    Button(action: {}).accessibilityLabel("Button").accessibilityLabel("Button") {
                        Image(systemName: "plus")
                    }
                    .help("Add New Goal")
                }
            }
        }

        var goalsList: some View {
            List(selection: self.$selectedItem) {
                ForEach(self.goals) { goal in
                    NavigationLink(value: ListableItem(id: goal.id, name: goal.name, type: .goal)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(goal.name)
                                    .font(.headline)

                                Spacer()

                                Text(
                                    "\(goal.currentAmount.formatted(.currency(code: "USD"))) of \(goal.targetAmount.formatted(.currency(code: "USD")))"
                                )
                                .font(.subheadline)
                            }

                            ProgressView(value: goal.currentAmount, total: goal.targetAmount)
                                .tint(.blue)

                            HStack {
                                if let targetDate = goal.targetDate {
                                    Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                let percentage = Int((goal.currentAmount / goal.targetAmount) * 100)
                                Text("\(percentage)%")
                                    .font(.caption)
                                    .bold()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .tag(ListableItem(id: goal.id, name: goal.name, type: .goal))
                }
            }
        }

        var reportsList: some View {
            List(selection: self.$selectedItem) {
                NavigationLink(value: ListableItem(id: "spending", name: "Spending by Category", type: .report)) {
                    HStack {
                        Image(systemName: "chart.pie")
                            .foregroundStyle(.orange)
                        Text("Spending by Category")
                    }
                    .padding(.vertical, 8)
                }
                .tag(ListableItem(id: "spending", name: "Spending by Category", type: .report))

                NavigationLink(value: ListableItem(id: "income", name: "Income vs Expenses", type: .report)) {
                    HStack {
                        Image(systemName: "chart.bar")
                            .foregroundStyle(.green)
                        Text("Income vs Expenses")
                    }
                    .padding(.vertical, 8)
                }
                .tag(ListableItem(id: "income", name: "Income vs Expenses", type: .report))

                NavigationLink(value: ListableItem(id: "trends", name: "Monthly Spending Trends", type: .report)) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundStyle(.blue)
                        Text("Monthly Spending Trends")
                    }
                    .padding(.vertical, 8)
                }
                .tag(ListableItem(id: "trends", name: "Monthly Spending Trends", type: .report))

                NavigationLink(value: ListableItem(id: "cashflow", name: "Cash Flow Analysis", type: .report)) {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundStyle(.purple)
                        Text("Cash Flow Analysis")
                    }
                    .padding(.vertical, 8)
                }
                .tag(ListableItem(id: "cashflow", name: "Cash Flow Analysis", type: .report))
            }
        }
    }

    struct SavingsGoalDetailView: View {
        let goalId: String

        @Query private var goals: [SavingsGoal]
        @State private var isEditing = false

        var goal: SavingsGoal? {
            self.goals.first(where: { $0.id == self.goalId })
        }

        var body: some View {
            Group {
                if let goal {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(goal.name)
                                        .font(.largeTitle)
                                        .bold()

                                    if let targetDate = goal.targetDate {
                                        HStack {
                                            Image(systemName: "calendar")
                                            Text("Target Date: \(targetDate.formatted(date: .long, time: .omitted))")
                                                .font(.headline)
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text(goal.targetAmount.formatted(.currency(code: "USD")))
                                        .font(.system(size: 28, weight: .bold))

                                    Text("Target Amount")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Goal Progress")
                                        .font(.headline)

                                    Spacer()

                                    Text(
                                        "\(goal.currentAmount.formatted(.currency(code: "USD"))) of \(goal.targetAmount.formatted(.currency(code: "USD")))"
                                    )
                                }

                                ProgressView(value: goal.currentAmount, total: goal.targetAmount)
                                    .tint(.blue)
                                    .scaleEffect(y: 2.0)
                                    .padding(.vertical, 8)

                                HStack {
                                    Text("Remaining: \((goal.targetAmount - goal.currentAmount).formatted(.currency(code: "USD")))")
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    let percentage = Int((goal.currentAmount / goal.targetAmount) * 100)
                                    Text("\(percentage)% Complete")
                                        .foregroundStyle(.blue)
                                        .bold()
                                }
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)

                            // Time remaining calculation
                            if let targetDate = goal.targetDate {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Time Remaining")
                                        .font(.headline)

                                    let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0

                                    if daysRemaining > 0 {
                                        Text("\(daysRemaining) days until target date")
                                            .font(.title2)

                                        // Required monthly savings
                                        let remainingAmount = goal.targetAmount - goal.currentAmount
                                        let monthsRemaining = Double(daysRemaining) / 30.0
                                        if monthsRemaining > 0 {
                                            let requiredMonthlySavings = remainingAmount / monthsRemaining
                                            Text(
                                                "You need to save \(requiredMonthlySavings.formatted(.currency(code: "USD"))) per month to reach your goal on time."
                                            )
                                            .foregroundStyle(.secondary)
                                        }
                                    } else {
                                        Text("Target date has passed")
                                            .font(.title2)
                                            .foregroundStyle(.red)
                                    }
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)
                            }

                            // Contributions
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Recent Contributions")
                                    .font(.headline)

                                // This would show actual contributions
                                // Placeholder for now
                                Text("No recent contributions")
                                    .foregroundStyle(.secondary)
                                    .padding()
                            }

                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .toolbar {
                        ToolbarItem {
                            Button(action: { self.isEditing.toggle().accessibilityLabel("Button").accessibilityLabel("Button") }) {
                                Text(self.isEditing ? "Done" : "Edit")
                            }
                        }

                        ToolbarItem {
                            Button(action: {}).accessibilityLabel("Button").accessibilityLabel("Button") {
                                Text("Add Contribution")
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Goal Not Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The savings goal you're looking for could not be found.")
                    )
                }
            }
            .navigationTitle("Goal Details")
        }
    }

    struct ReportDetailView: View {
        let reportType: String

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(self.getReportTitle())
                        .font(.largeTitle)
                        .bold()

                    ReportChartView(reportType: self.reportType)

                    Divider()

                    Text("Analysis")
                        .font(.headline)

                    Text(
                        "This report provides insights into your \(self.getReportDescription()). Use this information to make informed financial decisions and track your progress toward your financial goals."
                    )
                    .padding()
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(8)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button("Export as PDF", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                        Button("Export as CSV", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                        Button("Print", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                        Button("Share", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }

                ToolbarItem {
                    Menu {
                        Button("Last 30 Days", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                        Button("Last 3 Months", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                        Button("Last 6 Months", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                        Button("Year to Date", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                        Button("Last 12 Months", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                        Button("Custom Range...", action: {}).accessibilityLabel("Button").accessibilityLabel("Button")
                    } label: {
                        HStack {
                            Text("Last 30 Days")
                            Image(systemName: "chevron.down")
                        }
                    }
                }
            }
            .navigationTitle("Financial Report")
        }

        private func getReportTitle() -> String {
            switch self.reportType {
            case "spending":
                "Spending by Category"
            case "income":
                "Income vs Expenses"
            case "trends":
                "Monthly Spending Trends"
            case "cashflow":
                "Cash Flow Analysis"
            default:
                "Financial Report"
            }
        }

        private func getReportDescription() -> String {
            switch self.reportType {
            case "spending":
                "spending patterns across different categories"
            case "income":
                "income compared to your expenses over time"
            case "trends":
                "spending trends over the past months"
            case "cashflow":
                "cash flow patterns and liquidity"
            default:
                "financial activity"
            }
        }
    }

    struct ReportChartView: View {
        let reportType: String

        var body: some View {
            // This is a placeholder for actual chart visualization
            // In a real implementation, this would render different charts based on the report type
            VStack {
                Text("Chart Visualization")
                    .font(.headline)

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.windowBackgroundColor).opacity(0.3))

                    Text("Chart data visualization would appear here")
                        .foregroundStyle(.secondary)
                }
                .frame(height: 300)
            }
        }
    }
}

// Sidebar navigation items
enum SidebarItem: Hashable {
    case dashboard
    case transactions
    case budgets
    case subscriptions
    case goalsAndReports
}

// Listable items for the content column
struct ListableItem: Identifiable, Hashable {
    let id: String?
    let name: String
    let type: ListItemType

    var identifier: String {
        "\(self.type)_\(self.id ?? "unknown")"
    }

    // Identifiable conformance
    var identifierId: String { self.identifier }

    // Hashable conformance
    /// <#Description#>
    /// - Returns: <#description#>
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }

    static func == (lhs: ListableItem, rhs: ListableItem) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

// Types of items that can be displayed in the content column
enum ListItemType: Hashable {
    case account
    case transaction
    case budget
    case subscription
    case goal
    case report
}

enum SortOrder {
    case dateDescending
    case dateAscending
    case amountDescending
    case amountAscending
}

// macOS-specific content view implementation using NavigationSplitView
struct ContentView_macOS: View {
    @State private var navigationCoordinator = NavigationCoordinator.shared
    @State private var selectedSidebarItem: SidebarItem? = .dashboard
    @State private var selectedListItem: ListableItem?
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        NavigationSplitView(columnVisibility: self.$columnVisibility) {
            // Sidebar column
            List(selection: self.$selectedSidebarItem) {
                Section("Main") {
                    self.sidebarItem(title: "Dashboard", icon: "house", item: .dashboard)
                    self.sidebarItem(title: "Transactions", icon: "creditcard", item: .transactions)
                    self.sidebarItem(title: "Budgets", icon: "chart.pie", item: .budgets)
                }

                Section("Planning") {
                    self.sidebarItem(title: "Subscriptions", icon: "calendar.badge.clock", item: .subscriptions)
                    self.sidebarItem(title: "Goals & Reports", icon: "chart.bar", item: .goalsAndReports)
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 220)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: self.toggleSidebar).accessibilityLabel("Button").accessibilityLabel("Button") {
                        Image(systemName: "sidebar.left")
                    }
                    .help("Toggle Sidebar")
                }
            }
        } content: {
            // Middle column content (context-sensitive list)
            Group {
                switch self.selectedSidebarItem {
                case .dashboard:
                    Features.FinancialDashboard.DashboardListView()
                case .transactions:
                    Features.Transactions.TransactionsListView()
                case .budgets:
                    Features.Budgets.BudgetListView()
                case .subscriptions:
                    Features.Subscriptions.SubscriptionListView()
                case .goalsAndReports:
                    Features.GoalsAndReports.GoalsListView()
                case .none:
                    EmptyView()
                }
            }
            .frame(minWidth: 300)
        } detail: {
            // Detail column
            Group {
                if let listItem = selectedListItem {
                    switch listItem.type {
                    case .account:
                        if let id = listItem.id {
                            Features.Transactions.AccountDetailView(accountId: id)
                        }
                    case .transaction:
                        if let id = listItem.id {
                            Features.Transactions.TransactionDetailView(transactionId: id)
                        }
                    case .budget:
                        if let id = listItem.id {
                            Features.Budgets.BudgetDetailView(budgetId: id)
                        }
                    case .subscription:
                        if let id = listItem.id {
                            Features.Subscriptions.SubscriptionDetailView(subscriptionId: id)
                        }
                    case .goal:
                        if let id = listItem.id {
                            Features.GoalsAndReports.SavingsGoalDetailView(goalId: id)
                        }
                    case .report:
                        Features.GoalsAndReports.ReportDetailView(reportType: listItem.id ?? "spending")
                    }
                } else {
                    // Default view when no item is selected
                    switch self.selectedSidebarItem {
                    case .dashboard:
                        Features.FinancialDashboard.DashboardView()
                    case .transactions:
                        Text("Select a transaction or account")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    case .budgets:
                        Text("Select a budget")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    case .subscriptions:
                        Text("Select a subscription")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    case .goalsAndReports:
                        Text("Select a goal or report")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    case .none:
                        Text("Select a category")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(minWidth: 450)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1000, minHeight: 700)
        .onAppear {
            macOSSpecificViews.configureWindow()
        }
    }

    // Helper method to create consistent sidebar items
    private func sidebarItem(title: String, icon: String, item: SidebarItem) -> some View {
        Label(title, systemImage: self.selectedSidebarItem == item ? "\(icon).fill" : icon)
            .tag(item)
    }

    // Toggle the macOS sidebar
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

// macOS-specific UI components and helpers
enum macOSSpecificViews {
    /// macOS window configuration
    static func configureWindow() {
        // Configure macOS-specific window settings
        NSApp.appearance = NSAppearance(named: .aqua)
    }

    /// macOS toolbar configuration
    static func configureToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: {}, label: {
                Image(systemName: "gear")
            })
            .help("Settings")

            Button(action: {}, label: {
                Image(systemName: "square.and.arrow.up")
            })
            .help("Export Data")
        }
    }
}

// macOS-specific view extensions
extension View {
    /// Add macOS-specific keyboard shortcuts
    /// <#Description#>
    /// - Returns: <#description#>
    func macOSKeyboardShortcuts() -> some View {
        keyboardShortcut("n", modifiers: .command)
            .keyboardShortcut("w", modifiers: .command)
    }

    /// macOS optimizations
    /// <#Description#>
    /// - Returns: <#description#>
    func macOSOptimizations() -> some View {
        preferredColorScheme(.light)
            .tint(.indigo)
    }
}
#endif
