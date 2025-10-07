//
//  BudgetListViewComponent.swift
//  MomentumFinance
//
//  Budgets list view components for macOS three-column layout
//

import SwiftData
import SwiftUI

// This file contains the Budgets list view components
// Extracted from MacOS_UI_Enhancements.swift to reduce file size

#if os(macOS)
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
#endif
