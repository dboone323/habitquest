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
