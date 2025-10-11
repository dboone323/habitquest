// Momentum Finance - macOS UI Integration
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

#if os(macOS)
/// This file provides integration between the macOS three-column UI and the app's navigation system
/// It connects existing view models and data with the enhanced macOS interface

// MARK: - Navigation System Integration

extension NavigationCoordinator {
    /// Connect a ListableItem selection to the detail view navigation
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToDetail(item: ListableItem?) {
        selectedListItem = item

        // Also update the appropriate navigation path for cross-platform compatibility
        // This ensures that when switching back to iOS, we maintain proper navigation state
        guard let item else { return }

        switch item.type {
        case .account:
            if let id = item.id {
                selectedTab = 1 // Transactions tab
                transactionsNavPath.append(TransactionsDestination.accountDetail(id))
            }
        case .transaction:
            if let id = item.id {
                selectedTab = 1 // Transactions tab
                // We don't have a direct transaction detail in the iOS navigation paths
                // But we could add it or navigate to its containing account
            }
        case .budget:
            if let id = item.id {
                selectedTab = 2 // Budgets tab
                budgetsNavPath.append(BudgetsDestination.categoryDetail(id))
            }
        case .subscription:
            if let id = item.id {
                selectedTab = 3 // Subscriptions tab
                subscriptionsNavPath.append(SubscriptionsDestination.subscriptionDetail(id))
            }
        case .goal:
            if let id = item.id {
                selectedTab = 4 // Goals tab
                goalsAndReportsNavPath.append(GoalsDestination.goalDetail(id))
            }
        case .report:
            if let id = item.id {
                selectedTab = 4 // Goals tab
                // Add specific report destination if needed
            }
        }
    }

    /// Clear detail selection when changing sidebar item
    /// <#Description#>
    /// - Returns: <#description#>
    func clearDetailSelection() {
        selectedListItem = nil
    }
}

// MARK: - Main macOS Content View with Integration

/// Main macOS content view with integrated navigation
struct IntegratedMacOSContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigationCoordinator = NavigationCoordinator.shared
    @State private var searchText = ""
    @State private var isSearching = false

    // Binding to sidebar selection that updates the NavigationCoordinator
    private var selectedSidebarItemBinding: Binding<SidebarItem?> {
        Binding(
            get: { self.navigationCoordinator.selectedSidebarItem },
            set: {
                self.navigationCoordinator.selectedSidebarItem = $0
                // Clear detail selection when changing main navigation
                self.navigationCoordinator.clearDetailSelection()
            },
        )
    }

    // Binding to list item selection that updates the NavigationCoordinator
    private var selectedListItemBinding: Binding<ListableItem?> {
        Binding(
            get: { self.navigationCoordinator.selectedListItem },
            set: { self.navigationCoordinator.navigateToDetail(item: $0) },
        )
    }

    // Binding to column visibility that updates the NavigationCoordinator
    private var columnVisibilityBinding: Binding<NavigationSplitViewVisibility> {
        Binding(
            get: { self.navigationCoordinator.columnVisibility },
            set: { self.navigationCoordinator.columnVisibility = $0 },
        )
    }

    var body: some View {
        NavigationSplitView(columnVisibility: self.columnVisibilityBinding) {
            // Sidebar column with main navigation
            self.sidebar
                .frame(minWidth: 220)
        } content: {
            // Content column - list of items for the selected category
            self.contentList
                .frame(minWidth: 300)
        } detail: {
            // Detail view for the selected item
            self.detailView
                .frame(minWidth: 450)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1000, minHeight: 700)
        .macOSOptimizations()
        .withMacOSKeyboardShortcuts()
        .onAppear {
            macOSSpecificViews.configureWindow()
            // Register keyboard shortcuts
            KeyboardShortcutManager.shared.registerGlobalShortcuts()
            // Setup notification handlers
            self.setupNotificationHandlers()
        }
    }

    // MARK: - Sidebar View

    private var sidebar: some View {
        List(selection: self.selectedSidebarItemBinding) {
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
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: self.toggleSidebar).accessibilityLabel("Button").accessibilityLabel("Button") {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Sidebar")
                .keyboardShortcut("s", modifiers: .command)
            }
        }
    }

    private func sidebarItem(title: String, icon: String, item: SidebarItem) -> some View {
        Label(title, systemImage: self.navigationCoordinator.selectedSidebarItem == item ? "\(icon).fill" : icon)
            .tag(item)
    }

    private func toggleSidebar() {
        self.navigationCoordinator.toggleSidebar()
    }

    // MARK: - Content List View

    private var contentList: some View {
        Group {
            switch self.navigationCoordinator.selectedSidebarItem {
            case .dashboard:
                DashboardListView()
                    .environmentObject(self.navigationCoordinator)
            case .transactions:
                TransactionsListView()
                    .environmentObject(self.navigationCoordinator)
            case .budgets:
                BudgetListView()
                    .environmentObject(self.navigationCoordinator)
            case .subscriptions:
                SubscriptionListView()
                    .environmentObject(self.navigationCoordinator)
            case .goalsAndReports:
                GoalsListView()
                    .environmentObject(self.navigationCoordinator)
            case .none:
                EmptyView()
            }
        }
        .searchable(text: self.$searchText, placement: .toolbar, prompt: "Search")
        .onSubmit(of: .search) {
            self.performSearch()
        }
    }

    private func performSearch() {
        guard !self.searchText.isEmpty else { return }
        self.navigationCoordinator.searchQuery = self.searchText
        self.navigationCoordinator.isSearchActive = true
        self.isSearching = true
    }

    // MARK: - Detail View

    private var detailView: some View {
        Group {
            if let listItem = navigationCoordinator.selectedListItem {
                switch listItem.type {
                case .account:
                    if let id = listItem.id {
                        EnhancedAccountDetailView(accountId: id)
                            .id(listItem.id)
                    }
                case .transaction:
                    if let id = listItem.id {
                        Features.Transactions.EnhancedTransactionDetailView(transactionId: id)
                            .id(listItem.id)
                    }
                case .budget:
                    if let id = listItem.id {
                        Features.Budgets.EnhancedBudgetDetailView(budgetId: id)
                            .id(listItem.id)
                    }
                case .subscription:
                    if let id = listItem.id {
                        Features.Subscriptions.EnhancedSubscriptionDetailView(subscriptionId: id)
                            .id(listItem.id)
                    }
                case .goal:
                    if let id = listItem.id {
                        EnhancedGoalDetailView(goalId: id)
                            .id(listItem.id)
                    }
                case .report:
                    if let id = listItem.id {
                        EnhancedReportDetailView(reportType: id)
                            .id(listItem.id)
                    }
                }
            } else {
                // Default view when no item is selected
                switch self.navigationCoordinator.selectedSidebarItem {
                case .dashboard:
                    Features.FinancialDashboard.DashboardView()
                case .transactions:
                    TransactionsOverviewView()
                case .budgets:
                    BudgetsOverviewView()
                case .subscriptions:
                    SubscriptionsOverviewView()
                case .goalsAndReports:
                    GoalsAndReportsOverviewView()
                case .none:
                    WelcomeView()
                }
            }
        }
    }

    // MARK: - Notification Handlers

    private func setupNotificationHandlers() {
        // Setup notification handlers for keyboard shortcut actions
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowDashboard"), object: nil, queue: .main) { _ in
            self.navigationCoordinator.selectedSidebarItem = .dashboard
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowTransactions"), object: nil, queue: .main) { _ in
            self.navigationCoordinator.selectedSidebarItem = .transactions
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowBudgets"), object: nil, queue: .main) { _ in
            self.navigationCoordinator.selectedSidebarItem = .budgets
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowSubscriptions"), object: nil, queue: .main) { _ in
            self.navigationCoordinator.selectedSidebarItem = .subscriptions
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowGoalsAndReports"), object: nil, queue: .main) { _ in
            self.navigationCoordinator.selectedSidebarItem = .goalsAndReports
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("ToggleSidebar"), object: nil, queue: .main) { _ in
            self.toggleSidebar()
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("PerformGlobalSearch"), object: nil, queue: .main) { _ in
            self.isSearching = true
        }
    }
}

// MARK: - Dashboard List View

struct DashboardListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [FinancialAccount]
    @Query private var recentTransactions: [FinancialTransaction]
    @Query private var upcomingSubscriptions: [Subscription]
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

    var body: some View {
        List(selection: Binding(
            get: { self.navigationCoordinator.selectedListItem },
            set: { self.navigationCoordinator.navigateToDetail(item: $0) },
        )) {
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

            Section("Upcoming Subscriptions") {
                ForEach(self.upcomingSubscriptions) { subscription in
                    NavigationLink(value: ListableItem(id: subscription.id, name: subscription.name, type: .subscription)) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundStyle(.purple)
                            VStack(alignment: .leading) {
                                Text(subscription.name)
                                    .font(.headline)
                                if let nextDate = subscription.nextPaymentDate {
                                    Text("Due \(nextDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                }
                            }
                            Spacer()
                            Text(subscription.amount.formatted(.currency(code: "USD")))
                                .foregroundStyle(.red)
                        }
                        .padding(.vertical, 4)
                    }
                    .tag(ListableItem(id: subscription.id, name: subscription.name, type: .subscription))
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
    }
}

// MARK: - Transactions List View

struct TransactionsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [FinancialTransaction]
    @Query private var accounts: [FinancialAccount]
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var sortOrder: SortOrder = .dateDescending
    @State private var filterCategory: String?

    var filteredTransactions: [FinancialTransaction] {
        let sorted = self.sortedTransactions
        if let filterCategory {
            return sorted.filter { $0.category?.id == filterCategory }
        }
        return sorted
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
        VStack(spacing: 0) {
            HStack {
                Picker("Sort", selection: self.$sortOrder) {
                    Text("Newest First").tag(SortOrder.dateDescending)
                    Text("Oldest First").tag(SortOrder.dateAscending)
                    Text("Highest Amount").tag(SortOrder.amountDescending)
                    Text("Lowest Amount").tag(SortOrder.amountAscending)
                }
                .pickerStyle(.menu)
                .frame(width: 130)

                Spacer()

                Button(action: {
                    // Add new transaction
                }) {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.windowBackgroundColor).opacity(0.5))

            Divider()

            List(selection: Binding(
                get: { self.navigationCoordinator.selectedListItem },
                set: { self.navigationCoordinator.navigateToDetail(item: $0) },
            )) {
                Section("Accounts") {
                    ForEach(self.accounts) { account in
                        NavigationLink(value: ListableItem(id: account.id, name: account.name, type: .account)) {
                            HStack {
                                Image(systemName: account.type == .checking ? "banknote" : "creditcard")
                                    .foregroundStyle(account.type == .checking ? .green : .blue)

                                Text(account.name)
                                    .font(.headline)

                                Spacer()

                                Text(account.balance.formatted(.currency(code: "USD")))
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                        .tag(ListableItem(id: account.id, name: account.name, type: .account))
                    }
                }

                Section("Transactions") {
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
            }
            .listStyle(.inset)
            .navigationTitle("Transactions")
        }
    }
}

// MARK: - Budget List View

struct BudgetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var budgets: [Budget]
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Monthly Budgets")
                    .font(.headline)

                Spacer()

                Button(action: {
                    // Add new budget
                }) {
                    Label("Add Budget", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.windowBackgroundColor).opacity(0.5))

            Divider()

            List(selection: Binding(
                get: { self.navigationCoordinator.selectedListItem },
                set: { self.navigationCoordinator.navigateToDetail(item: $0) },
            )) {
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
            .listStyle(.inset)
            .navigationTitle("Budgets")
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

// MARK: - Subscription List View

struct SubscriptionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var subscriptions: [Subscription]
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var groupBy: GroupOption = .date

    enum GroupOption {
        case date, amount, provider
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("Group By", selection: self.$groupBy) {
                    Text("Next Payment").tag(GroupOption.date)
                    Text("Amount").tag(GroupOption.amount)
                    Text("Provider").tag(GroupOption.provider)
                }
                .pickerStyle(.menu)
                .frame(width: 150)

                Spacer()

                Button(action: {
                    // Add new subscription
                }) {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.windowBackgroundColor).opacity(0.5))

            Divider()

            List(selection: Binding(
                get: { self.navigationCoordinator.selectedListItem },
                set: { self.navigationCoordinator.navigateToDetail(item: $0) },
            )) {
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
                                        Text(subscription.amount.formatted(.currency(code: subscription.currencyCode)))
                                            .font(.subheadline)

                                        Text(subscription.billingCycle.capitalized)
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
            .listStyle(.inset)
            .navigationTitle("Subscriptions")
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

// MARK: - Goals List View

struct GoalsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [SavingsGoal]
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var viewType: ViewType = .goals

    enum ViewType {
        case goals, reports
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("View", selection: self.$viewType) {
                Text("Savings Goals").tag(ViewType.goals)
                Text("Reports").tag(ViewType.reports)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.windowBackgroundColor).opacity(0.5))

            Divider()

            if self.viewType == .goals {
                self.goalsList
            } else {
                self.reportsList
            }
        }
        .navigationTitle("Goals & Reports")
    }

    var goalsList: some View {
        List(selection: Binding(
            get: { self.navigationCoordinator.selectedListItem },
            set: { self.navigationCoordinator.navigateToDetail(item: $0) },
        )) {
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
        .listStyle(.inset)
    }

    var reportsList: some View {
        List(selection: Binding(
            get: { self.navigationCoordinator.selectedListItem },
            set: { self.navigationCoordinator.navigateToDetail(item: $0) },
        )) {
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
        .listStyle(.inset)
    }
}

// MARK: - Helper Views

struct TransactionsOverviewView: View {
    @Query private var transactions: [FinancialTransaction]
    @Query private var accounts: [FinancialAccount]

    var totalIncome: Double {
        self.transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        self.transactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
    }

    var netCashflow: Double {
        self.totalIncome - self.totalExpenses
    }

    var totalBalance: Double {
        self.accounts.reduce(0) { $0 + $1.balance }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Transactions Overview")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 10)

                // Summary cards
                HStack(spacing: 20) {
                    SummaryCard(title: "Total Income", amount: self.totalIncome, icon: "arrow.up.circle.fill", color: .green)
                    SummaryCard(title: "Total Expenses", amount: self.totalExpenses, icon: "arrow.down.circle.fill", color: .red)
                    SummaryCard(
                        title: "Net Cash Flow",
                        amount: self.netCashflow,
                        icon: "arrow.left.arrow.right.circle.fill",
                        color: self.netCashflow >= 0 ? .blue : .orange
                    )
                    SummaryCard(title: "Total Balance", amount: self.totalBalance, icon: "banknote.fill", color: .purple)
                }

                Text("Select an account or transaction from the list to view details.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 40)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    struct SummaryCard: View {
        let title: String
        let amount: Double
        let icon: String
        let color: Color

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: self.icon)
                        .font(.title2)
                        .foregroundStyle(self.color)

                    Text(self.title)
                        .font(.headline)
                }

                Text(self.amount.formatted(.currency(code: "USD")))
                    .font(.title)
                    .bold()
                    .foregroundStyle(self.color)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.windowBackgroundColor).opacity(0.3))
            .cornerRadius(10)
        }
    }
}

struct BudgetsOverviewView: View {
    @Query private var budgets: [Budget]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Budgets Overview")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)

                Text("Monthly Budget Summary")
                    .font(.title2)

                // Total budget usage
                let totalBudgeted = self.budgets.reduce(0) { $0 + $1.amount }
                let totalSpent = self.budgets.reduce(0) { $0 + $1.spent }
                let percentage = totalBudgeted > 0 ? (totalSpent / totalBudgeted) * 100 : 0

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Budgeted")
                            .font(.headline)
                        Text(totalBudgeted.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .bold()
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Spent")
                            .font(.headline)
                        Text(totalSpent.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .bold()
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Remaining")
                            .font(.headline)
                        Text((totalBudgeted - totalSpent).formatted(.currency(code: "USD")))
                            .font(.title2)
                            .bold()
                            .foregroundStyle(totalBudgeted - totalSpent > 0 ? .green : .red)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Used")
                            .font(.headline)
                        Text("\(Int(percentage))%")
                            .font(.title2)
                            .bold()
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(10)

                Text("Select a budget from the list to view details.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 40)
            }
            .padding()
        }
    }
}

struct SubscriptionsOverviewView: View {
    @Query private var subscriptions: [Subscription]

    var monthlyTotal: Double {
        self.subscriptions.reduce(0) { total, subscription in
            total + self.calculateMonthlyCost(subscription)
        }
    }

    var yearlyTotal: Double {
        self.monthlyTotal * 12
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Subscriptions Overview")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active Subscriptions")
                            .font(.headline)

                        Text("\(self.subscriptions.count)")
                            .font(.system(size: 36, weight: .bold))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monthly Cost")
                            .font(.headline)

                        Text(self.monthlyTotal.formatted(.currency(code: "USD")))
                            .font(.system(size: 36, weight: .bold))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Annual Cost")
                            .font(.headline)

                        Text(self.yearlyTotal.formatted(.currency(code: "USD")))
                            .font(.system(size: 36, weight: .bold))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(10)
                }

                Text("Select a subscription from the list to view details.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 40)
            }
            .padding()
        }
    }

    private func calculateMonthlyCost(_ subscription: Subscription) -> Double {
        switch subscription.billingCycle {
        case "monthly": subscription.amount
        case "annual": subscription.amount / 12
        case "quarterly": subscription.amount / 3
        case "weekly": subscription.amount * 4.33 // Average weeks in a month
        case "biweekly": subscription.amount * 2.17 // Average bi-weeks in a month
        default: subscription.amount
        }
    }
}

struct GoalsAndReportsOverviewView: View {
    @Query private var goals: [SavingsGoal]

    var totalSaved: Double {
        self.goals.reduce(0) { $0 + $1.currentAmount }
    }

    var totalTarget: Double {
        self.goals.reduce(0) { $0 + $1.targetAmount }
    }

    var percentComplete: Double {
        self.totalTarget > 0 ? (self.totalSaved / self.totalTarget) * 100 : 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Goals & Reports Overview")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)

                Text("Savings Progress")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Total Saved")
                            .font(.headline)

                        Spacer()

                        Text("\(self.totalSaved.formatted(.currency(code: "USD"))) of \(self.totalTarget.formatted(.currency(code: "USD")))"
                        )
                        .bold()
                    }

                    ProgressView(value: self.totalSaved, total: self.totalTarget)
                        .tint(.blue)
                        .scaleEffect(y: 2.0)
                        .padding(.vertical, 8)

                    Text("\(Int(self.percentComplete))% Complete")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(10)

                Text("Select a goal or report from the list to view details.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 40)
            }
            .padding()
        }
    }
}

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("Welcome to Momentum Finance")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Select a category from the sidebar to get started")
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
                .frame(height: 40)

            HStack(spacing: 30) {
                self.quickAccessButton("Transactions", icon: "creditcard.fill", color: .blue).accessibilityLabel("Button")
                    .accessibilityLabel("Button") {
                        NotificationCenter.default.post(name: NSNotification.Name("ShowTransactions"), object: nil)
                    }

                self.quickAccessButton("Budgets", icon: "chart.pie.fill", color: .orange).accessibilityLabel("Button")
                    .accessibilityLabel("Button") {
                        NotificationCenter.default.post(name: NSNotification.Name("ShowBudgets"), object: nil)
                    }

                self.quickAccessButton("Goals", icon: "target", color: .green).accessibilityLabel("Button").accessibilityLabel("Button") {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowGoalsAndReports"), object: nil)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func quickAccessButton(
        _ title: String,
        icon: String,
        color: Color,
        action: @escaping ().accessibilityLabel("Button") -> Void
    ) -> some View {
        VStack {
            Button(action: action).accessibilityLabel("Button").accessibilityLabel("Button") {
                VStack(spacing: 15) {
                    Image(systemName: icon)
                        .font(.system(size: 34))
                        .foregroundStyle(color)

                    Text(title)
                        .fontWeight(.medium)
                }
                .padding()
                .frame(width: 150, height: 150)
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Placeholder Detail Views

struct EnhancedAccountDetailView: View {
    let accountId: String

    var body: some View {
        Text("Enhanced Account Detail View for \(self.accountId)")
            .font(.largeTitle)
    }
}

struct EnhancedGoalDetailView: View {
    let goalId: String

    var body: some View {
        Text("Enhanced Goal Detail View for \(self.goalId)")
            .font(.largeTitle)
    }
}

struct EnhancedReportDetailView: View {
    let reportType: String

    var body: some View {
        Text("Enhanced Report View: \(self.reportType)")
            .font(.largeTitle)
    }
}
#endif
