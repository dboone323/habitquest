// Temporary Simple Dashboard View
// This is a simplified version to get the build working

import SwiftData
import SwiftUI

public struct SimpleDashboardView: View {
    @Environment(\.modelContext)
    private var modelContext
    #if canImport(SwiftData)
    #if canImport(SwiftData)
    #if canImport(SwiftData)
    private var accounts: [FinancialAccount] = []
    private var subscriptions: [Subscription] = []
    private var budgets: [Budget] = []
    #else
    private var accounts: [FinancialAccount] = []
    private var subscriptions: [Subscription] = []
    private var budgets: [Budget] = []
    #endif
    #else
    private var accounts: [FinancialAccount] = []
    private var subscriptions: [Subscription] = []
    private var budgets: [Budget] = []
    #endif
    #else
    private var accounts: [FinancialAccount] = []
    private var subscriptions: [Subscription] = []
    private var budgets: [Budget] = []
    #endif

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

                        ForEach(self.accounts) { account in
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

                        if self.accounts.isEmpty {
                            Text("No accounts found")
                                .foregroundStyle(.secondary)
                                .italic()
                        }
                    }

                    // Subscriptions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Subscriptions")
                            .font(.headline)

                        ForEach(Array(self.subscriptions.prefix(3))) { subscription in
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

                        if self.subscriptions.isEmpty {
                            Text("No subscriptions found")
                                .foregroundStyle(.secondary)
                                .italic()
                        }
                    }

                    // Budget Progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Budget Progress")
                            .font(.headline)

                        ForEach(self.budgets) { budget in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(budget.name)
                                    Spacer()
                                    Text(
                                        "$\(budget.spentAmount, specifier: "%.2f") / $\(budget.limitAmount, specifier: "%.2f")"
                                    )
                                    .fontWeight(.semibold)
                                }

                                ProgressView(value: budget.spentAmount, total: budget.limitAmount)
                                    .progressViewStyle(LinearProgressViewStyle())
                            }
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(8)
                        }

                        if self.budgets.isEmpty {
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

// Connect to Features.FinancialDashboard namespace
extension Features.FinancialDashboard {
    // Remove conflicting typealias to prevent DashboardView redeclaration error
}
