// Temporary Simple Dashboard View
// This is a simplified version to get the build working

import SwiftData
import SwiftUI

struct SimpleDashboardView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Query private var accounts: [FinancialAccount]
    @Query private var subscriptions: [Subscription]
    @Query private var budgets: [Budget]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Welcome Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Good Morning")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Here's a summary of your finances")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial)
                    .cornerRadius(12)

                    // Account Balances
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Account Balances")
                            .font(.headline)

                        ForEach(accounts) { account in
                            HStack {
                                Text(account.name)
                                Spacer()
                                Text("$\(account.balance, specifier: "%.2f")")
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(8)
                        }

                        if accounts.isEmpty {
                            Text("No accounts found")
                                .foregroundStyle(.secondary)
                                .italic()
                        }
                    }

                    // Subscriptions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Subscriptions")
                            .font(.headline)

                        ForEach(Array(subscriptions.prefix(3))) { subscription in
                            HStack {
                                Text(subscription.name)
                                Spacer()
                                Text("$\(subscription.amount, specifier: "%.2f")")
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(8)
                        }

                        if subscriptions.isEmpty {
                            Text("No subscriptions found")
                                .foregroundStyle(.secondary)
                                .italic()
                        }
                    }

                    // Budget Progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Budget Progress")
                            .font(.headline)

                        ForEach(budgets) { budget in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(budget.name)
                                    Spacer()
                                    Text("$\(budget.spentAmount, specifier: "%.2f") / $\(budget.limitAmount, specifier: "%.2f")")
                                        .fontWeight(.semibold)
                                }

                                ProgressView(value: budget.spentAmount, total: budget.limitAmount)
                                    .progressViewStyle(LinearProgressViewStyle())
                            }
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(8)
                        }

                        if budgets.isEmpty {
                            Text("No budgets found")
                                .foregroundStyle(.secondary)
                                .italic()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

// Connect to Features.Dashboard namespace
extension Features.Dashboard {
    typealias DashboardView = SimpleDashboardView
}
