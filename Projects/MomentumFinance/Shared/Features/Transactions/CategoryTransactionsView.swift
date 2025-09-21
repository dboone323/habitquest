// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

/// A view that shows transactions filtered by a specific category
extension Features.Transactions {
    struct CategoryTransactionsView: View {
        @Environment(\.modelContext)
        private var modelContext
        @Environment(\.dismiss)
        private var dismiss

        let categoryId: PersistentIdentifier

        // Query transactions but we'll filter in computed property
        #if canImport(SwiftData)
        #if canImport(SwiftData)
        private var transactions: [FinancialTransaction] = []
        private var categories: [ExpenseCategory] = []
        #else
        private var transactions: [FinancialTransaction] = []
        private var categories: [ExpenseCategory] = []
        #endif
        #else
        private var transactions: [FinancialTransaction] = []
        private var categories: [ExpenseCategory] = []
        #endif

        // Get the specific category
        private var category: ExpenseCategory? {
            self.categories.first { $0.persistentModelID == self.categoryId }
        }

        // Filter transactions by category
        private var filteredTransactions: [FinancialTransaction] {
            guard let category else { return [] }
            return self.transactions.filter {
                $0.category?.persistentModelID == category.persistentModelID
            }
            .sorted { $0.date > $1.date }
        }

        var body: some View {
            VStack {
                if let category {
                    // Category header with icon and stats
                    VStack(spacing: 16) {
                        HStack {
                            // Category icon
                            Image(systemName: category.iconName)
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color.blue))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.name)
                                    .font(.headline)

                                Text("\(self.filteredTransactions.count) transactions")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Total amount for this category
                            VStack(alignment: .trailing) {
                                Text(self.totalAmount.formatted(.currency(code: "USD")))
                                    .font(.headline)
                                    .foregroundColor(self.totalAmount < 0 ? .red : .primary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(self.platformBackgroundColor)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
                        )
                        .padding(.horizontal)
                    }

                    // Transactions list
                    List {
                        ForEach(self.filteredTransactions) { transaction in
                            TransactionRowView(transaction: transaction, onTap: {})
                                .swipeActions {
                                    Button(role: .destructive) {
                                        self.deleteTransaction(transaction)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .accessibilityLabel("Delete")
                                }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    ContentUnavailableView(
                        "Category Not Found",
                        systemImage: "tag.slash",
                        description: Text("The selected category could not be found"),
                    )
                }
            }
            .navigationTitle(self.category?.name ?? "Category Transactions")
        }

        // Delete a transaction
        private func deleteTransaction(_ transaction: FinancialTransaction) {
            // Update account balance first
            if let account = transaction.account {
                // If it's an expense, add the amount back; if income, subtract it
                if transaction.transactionType == .expense {
                    account.balance += transaction.amount
                } else {
                    account.balance -= transaction.amount
                }
            }

            // Delete the transaction
            self.modelContext.delete(transaction)

            // Save changes
            try? self.modelContext.save()
        }

        // Calculate the total amount for this category
        private var totalAmount: Double {
            self.filteredTransactions.reduce(0) { result, transaction in
                if transaction.transactionType == .expense {
                    result - transaction.amount
                } else {
                    result + transaction.amount
                }
            }
        }

        // Cross-platform background color
        private var platformBackgroundColor: Color {
            #if canImport(UIKit)
            return Color(uiColor: .systemBackground)
            #elseif canImport(AppKit)
            return Color(nsColor: .windowBackgroundColor)
            #else
            return Color.white
            #endif
        }
    }
}
