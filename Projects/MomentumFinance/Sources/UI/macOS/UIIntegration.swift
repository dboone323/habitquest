// Momentum Finance - macOS UI Integration
// Copyright © 2025 Momentum Finance. All rights reserved.

import MomentumFinanceCore
import SharedKit
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
                }
            )
        }

        // Binding to list item selection that updates the NavigationCoordinator
        private var selectedListItemBinding: Binding<ListableItem?> {
            Binding(
                get: { self.navigationCoordinator.selectedListItem },
                set: { self.navigationCoordinator.navigateToDetail(item: $0) }
            )
        }

        // Binding to column visibility that updates the NavigationCoordinator
        private var columnVisibilityBinding: Binding<NavigationSplitViewVisibility> {
            Binding(
                get: { self.navigationCoordinator.columnVisibility },
                set: { self.navigationCoordinator.columnVisibility = $0 }
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
                set: { self.navigationCoordinator.navigateToDetail(item: $0) }
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
                    set: { self.navigationCoordinator.navigateToDetail(item: $0) }
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
                    set: { self.navigationCoordinator.navigateToDetail(item: $0) }
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
                    set: { self.navigationCoordinator.navigateToDetail(item: $0) }
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
                set: { self.navigationCoordinator.navigateToDetail(item: $0) }
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
                set: { self.navigationCoordinator.navigateToDetail(item: $0) }
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
#endif
