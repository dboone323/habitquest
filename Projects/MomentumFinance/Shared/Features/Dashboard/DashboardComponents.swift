import SwiftUI

public struct DashboardSubscriptionsSection: View {
    let subscriptions: [Subscription]
    let onSubscriptionTapped: (Subscription) -> Void
    let onViewAllTapped: () -> Void
    let onAddTapped: () -> Void

    public init(
        subscriptions: [Subscription], onSubscriptionTapped: @escaping (Subscription) -> Void,
        onViewAllTapped: @escaping () -> Void, onAddTapped: @escaping () -> Void
    ) {
        self.subscriptions = subscriptions
        self.onSubscriptionTapped = onSubscriptionTapped
        self.onViewAllTapped = onViewAllTapped
        self.onAddTapped = onAddTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Subscriptions")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") { self.onViewAllTapped() }
                    .accessibilityLabel("View All")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }

            ForEach(self.subscriptions.prefix(3)) { subscription in
                HStack {
                    Text(subscription.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(subscription.amount.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture { self.onSubscriptionTapped(subscription) }
            }

            Button(action: self.onAddTapped) {
                HStack {
                    Image(systemName: "plus.circle.fill").foregroundColor(.blue)
                    Text("Add Subscription").foregroundColor(.blue)
                }.font(.subheadline)
            }
            .accessibilityLabel("Add Subscription")
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

public struct DashboardAccountsSummary: View {
    let accounts: [FinancialAccount]
    let onAccountTap: (String) -> Void
    let onViewAllTap: () -> Void
    public init(
        accounts: [FinancialAccount], onAccountTap: @escaping (String) -> Void,
        onViewAllTap: @escaping () -> Void
    ) {
        self.accounts = accounts
        self.onAccountTap = onAccountTap
        self.onViewAllTap = onViewAllTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accounts").font(.headline).foregroundColor(.primary)
                Spacer()
                Button("View All", action: self.onViewAllTap).font(.subheadline).foregroundColor(
                    .blue
                )
            }
            ForEach(self.accounts.prefix(3)) { account in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(account.name).font(.subheadline).foregroundColor(.primary)
                        Text(account.accountType.rawValue).font(.caption).foregroundColor(
                            .secondary
                        )
                    }
                    Spacer()
                    Text(account.balance.formatted(.currency(code: "USD"))).font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture { self.onAccountTap(String(describing: account.persistentModelID)) }
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

public struct DashboardBudgetProgress: View {
    let budgets: [Budget]
    let onBudgetTap: (Budget) -> Void
    let onViewAllTap: () -> Void

    public init(
        budgets: [Budget], onBudgetTap: @escaping (Budget) -> Void,
        onViewAllTap: @escaping () -> Void
    ) {
        self.budgets = budgets
        self.onBudgetTap = onBudgetTap
        self.onViewAllTap = onViewAllTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Budgets")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") { self.onViewAllTap() }
                    .accessibilityLabel("View All")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            ForEach(self.budgets.prefix(2)) { budget in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(budget.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(Int(budget.spentAmount / budget.limitAmount * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    ProgressView(value: budget.spentAmount / budget.limitAmount)
                        .progressViewStyle(
                            LinearProgressViewStyle(
                                tint: budget.spentAmount > budget.limitAmount ? .red : .green
                            )
                        )
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture { self.onBudgetTap(budget) }
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

public struct DashboardInsights: View {
    let insights: [FinancialInsight]
    let onDetailsTapped: () -> Void

    public init(insights: [FinancialInsight], onDetailsTapped: @escaping () -> Void) {
        self.insights = insights
        self.onDetailsTapped = onDetailsTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Insights")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") { self.onDetailsTapped() }
                    .accessibilityLabel("View All Insights")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            if self.insights.isEmpty {
                Text("No insights available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(self.insights.prefix(2)), id: \.id) { insight in
                    HStack(spacing: 12) {
                        Image(systemName: insight.type.icon)
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        VStack(alignment: .leading) {
                            Text(insight.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text(insight.insightDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

public struct DashboardQuickActions: View {
    let onAddTransaction: () -> Void
    let onPayBills: () -> Void
    let onViewReports: () -> Void
    let onSetGoals: () -> Void

    public init(
        onAddTransaction: @escaping () -> Void, onPayBills: @escaping () -> Void,
        onViewReports: @escaping () -> Void, onSetGoals: @escaping () -> Void
    ) {
        self.onAddTransaction = onAddTransaction
        self.onPayBills = onPayBills
        self.onViewReports = onViewReports
        self.onSetGoals = onSetGoals
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.primary)
            HStack(spacing: 16) {
                self.quickAction(
                    icon: "plus.circle.fill", title: "Add Transaction", color: .blue,
                    action: self.onAddTransaction
                )
                self.quickAction(
                    icon: "creditcard.fill", title: "Pay Bills", color: .green, action: self.onPayBills
                )
                self.quickAction(
                    icon: "chart.bar.fill", title: "View Reports", color: .purple,
                    action: self.onViewReports
                )
                self.quickAction(icon: "target", title: "Set Goals", color: .orange, action: self.onSetGoals)
            }
        }
        .padding()
        .background(platformBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    @ViewBuilder private func quickAction(
        icon: String, title: String, color: Color, action: @escaping () -> Void
    ) -> some View {
        VStack {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 50, height: 50)
                Image(systemName: icon).foregroundColor(color).font(.system(size: 24))
            }
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }.onTapGesture(perform: action)
    }
}
