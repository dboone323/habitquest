// MARK: - Dashboard List View

import MomentumFinanceCore
import SharedKit
import SwiftData
import SwiftUI

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
                    ReusableListItemView(account: account)
                }
            }

            Section("Recent Transactions") {
                ForEach(self.recentTransactions.prefix(5)) { transaction in
                    ReusableListItemView(transaction: transaction)
                }
            }

            Section("Upcoming Subscriptions") {
                ForEach(self.upcomingSubscriptions) { subscription in
                    ReusableListItemView(subscription: subscription)
                }
            }

            Section("Quick Actions") {
                Button("Add New Account").accessibilityLabel("Add New Account Button") {
                    // Action to add new account
                }

                Button("Add New Transaction").accessibilityLabel("Add New Transaction Button") {
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
                        ReusableListItemView(account: account)
                    }
                }

                Section("Transactions") {
                    ForEach(self.filteredTransactions) { transaction in
                        ReusableListItemView(transaction: transaction)
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
                    ReusableListItemView(budget: budget)
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
                            ReusableListItemView(subscription: subscription)
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
                ReusableListItemView(goal: goal)
            }
        }
        .listStyle(.inset)
    }

    var reportsList: some View {
        List(selection: Binding(
            get: { self.navigationCoordinator.selectedListItem },
            set: { self.navigationCoordinator.navigateToDetail(item: $0) }
        )) {
            ReportListItemView(reportId: "spending", title: "Spending by Category", iconName: "chart.pie", iconColor: .orange)
            ReportListItemView(reportId: "income", title: "Income vs Expenses", iconName: "chart.bar", iconColor: .green)
            ReportListItemView(reportId: "trends", title: "Monthly Spending Trends", iconName: "chart.line.uptrend.xyaxis", iconColor: .blue)
            ReportListItemView(reportId: "cashflow", title: "Cash Flow Analysis", iconName: "arrow.left.arrow.right", iconColor: .purple)
        }
        .listStyle(.inset)
    }
}
