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
