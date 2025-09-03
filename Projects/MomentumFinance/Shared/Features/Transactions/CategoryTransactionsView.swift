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
<<<<<<< HEAD
        @Query private var transactions: [FinancialTransaction]
        @Query private var categories: [ExpenseCategory]
=======
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
>>>>>>> 1cf3938 (Create working state for recovery)

        // Get the specific category
        private var category: ExpenseCategory? {
            categories.first { $0.persistentModelID == categoryId }
        }

        // Filter transactions by category
        private var filteredTransactions: [FinancialTransaction] {
            guard let category else { return [] }
<<<<<<< HEAD
            return transactions.filter { $0.category?.persistentModelID == category.persistentModelID }
                .sorted { $0.date > $1.date }
=======
            return transactions.filter {
                $0.category?.persistentModelID == category.persistentModelID
            }
            .sorted { $0.date > $1.date }
>>>>>>> 1cf3938 (Create working state for recovery)
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

                                Text("\(filteredTransactions.count) transactions")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Total amount for this category
                            VStack(alignment: .trailing) {
                                Text(totalAmount.formatted(.currency(code: "USD")))
                                    .font(.headline)
                                    .foregroundColor(totalAmount < 0 ? .red : .primary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(platformBackgroundColor)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
<<<<<<< HEAD
                            )
=======
                        )
>>>>>>> 1cf3938 (Create working state for recovery)
                        .padding(.horizontal)
                    }

                    // Transactions list
                    List {
                        ForEach(filteredTransactions) { transaction in
                            Features.Transactions.TransactionRowView(transaction: transaction)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        deleteTransaction(transaction)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    ContentUnavailableView(
                        "Category Not Found",
                        systemImage: "tag.slash",
                        description: Text("The selected category could not be found"),
<<<<<<< HEAD
                        )
=======
                    )
>>>>>>> 1cf3938 (Create working state for recovery)
                }
            }
            .navigationTitle(category?.name ?? "Category Transactions")
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
            modelContext.delete(transaction)

            // Save changes
            try? modelContext.save()
        }

        // Calculate the total amount for this category
        private var totalAmount: Double {
            filteredTransactions.reduce(0) { result, transaction in
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
<<<<<<< HEAD
            return Color(uiColor: .systemBackground)
            #elseif canImport(AppKit)
            return Color(nsColor: .windowBackgroundColor)
            #else
            return Color.white
=======
                return Color(uiColor: .systemBackground)
            #elseif canImport(AppKit)
                return Color(nsColor: .windowBackgroundColor)
            #else
                return Color.white
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }
    }
}
