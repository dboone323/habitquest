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
            !self.title.isEmpty && !self.amount.isEmpty && Double(self.amount) != nil && self.selectedAccount != nil
        }

        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Transaction Details")) {
                        TextField("Title", text: self.$title).accessibilityLabel("Text Field").accessibilityLabel("Text Field")

                        TextField("Amount", text: self.$amount).accessibilityLabel("Text Field").accessibilityLabel("Text Field")
                        #if canImport(UIKit)
                            .keyboardType(.decimalPad)
                        #endif

                        Picker("Type", selection: self.$selectedTransactionType) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        DatePicker("Date", selection: self.$date, displayedComponents: .date)
                    }

                    Section(header: Text("Category & Account")) {
                        Picker("Category", selection: self.$selectedCategory) {
                            Text("None").tag(nil as ExpenseCategory?)
                            ForEach(self.categories, id: \.name) { category in
                                Text(category.name).tag(category as ExpenseCategory?)
                            }
                        }

                        Picker("Account", selection: self.$selectedAccount) {
                            Text("Select Account").tag(nil as FinancialAccount?)
                            ForEach(self.accounts, id: \.name) { account in
                                Text(account.name).tag(account as FinancialAccount?)
                            }
                        }
                    }

                    Section(header: Text("Notes (Optional)")) {
                        TextField("Add notes...", text: self.$notes, axis: .vertical).accessibilityLabel("Text Field")
                            .accessibilityLabel("Text Field")
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
                            Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                                self.dismiss()
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save").accessibilityLabel("Button").accessibilityLabel("Button") {
                                self.saveTransaction()
                            }
                            .disabled(!self.isFormValid)
                        }
                        #else
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                                self.dismiss()
                            }
                        }

                        ToolbarItem(placement: .primaryAction) {
                            Button("Save").accessibilityLabel("Button").accessibilityLabel("Button") {
                                self.saveTransaction()
                            }
                            .disabled(!self.isFormValid)
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
                notes: notes.isEmpty ? nil : self.notes,
            )

            transaction.category = self.selectedCategory
            transaction.account = account

            // Update account balance
            account.updateBalance(for: transaction)

            self.modelContext.insert(transaction)

            try? self.modelContext.save()
            self.dismiss()
        }
    }
}
