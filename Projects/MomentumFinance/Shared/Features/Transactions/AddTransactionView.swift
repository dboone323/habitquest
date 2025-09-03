// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

extension Features.Transactions {
    struct AddTransactionView: View {
        @Environment(\.dismiss)
        private var dismiss
        @Environment(\.modelContext)
        private var modelContext

        let categories: [ExpenseCategory]
        let accounts: [FinancialAccount]

        @State private var title = ""
        @State private var amount = ""
        @State private var selectedTransactionType = TransactionType.expense
        @State private var selectedCategory: ExpenseCategory?
        @State private var selectedAccount: FinancialAccount?
        @State private var date = Date()
        @State private var notes = ""

        private var isFormValid: Bool {
            !title.isEmpty && !amount.isEmpty && Double(amount) != nil && selectedAccount != nil
        }

        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Transaction Details")) {
                        TextField("Title", text: $title)

                        TextField("Amount", text: $amount)
                        #if canImport(UIKit)
                            .keyboardType(.decimalPad)
                        #endif

                        Picker("Type", selection: $selectedTransactionType) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }

                    Section(header: Text("Category & Account")) {
                        Picker("Category", selection: $selectedCategory) {
                            Text("None").tag(nil as ExpenseCategory?)
                            ForEach(categories, id: \.name) { category in
                                Text(category.name).tag(category as ExpenseCategory?)
                            }
                        }

                        Picker("Account", selection: $selectedAccount) {
                            Text("Select Account").tag(nil as FinancialAccount?)
                            ForEach(accounts, id: \.name) { account in
                                Text(account.name).tag(account as FinancialAccount?)
                            }
                        }
                    }

                    Section(header: Text("Notes (Optional)")) {
                        TextField("Add notes...", text: $notes, axis: .vertical)
                            .lineLimit(3 ... 6)
                    }
                }
                .navigationTitle("Add Transaction")
                #if canImport(UIKit)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                    .toolbar {
                        #if canImport(UIKit)
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    dismiss()
                                }
                            }

                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Save") {
                                    saveTransaction()
                                }
                                .disabled(!isFormValid)
                            }
                        #else
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    dismiss()
                                }
                            }

                            ToolbarItem(placement: .primaryAction) {
                                Button("Save") {
                                    saveTransaction()
                                }
                                .disabled(!isFormValid)
                            }
                        #endif
                    }
            }
        }

        private func saveTransaction() {
            guard let amountValue = Double(amount),
                  let account = selectedAccount
            else { return }

            let transaction = FinancialTransaction(
                title: title,
                amount: amountValue,
                date: date,
                transactionType: selectedTransactionType,
                notes: notes.isEmpty ? nil : notes,
            )

            transaction.category = selectedCategory
            transaction.account = account

            // Update account balance
            account.updateBalance(for: transaction)

            modelContext.insert(transaction)

            try? modelContext.save()
            dismiss()
        }
    }
}
