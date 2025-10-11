import AppKit
import SwiftUI

#if canImport(AppKit)
#endif

//
//  SubscriptionManagementViews.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

extension Features.Subscriptions {
    // MARK: - Add Subscription View

    struct AddSubscriptionView: View {
        @Environment(\.dismiss)
        private var dismiss
        @Environment(\.modelContext)
        private var modelContext

        // Temporarily use stored-array fallbacks (no SwiftData @Query) to avoid
        // 'unknown attribute Query' compile errors on the current toolchain.
        private var categories: [ExpenseCategory] = []
        private var accounts: [FinancialAccount] = []

        @State private var name = ""
        @State private var amount = ""
        @State private var frequency = BillingCycle.monthly
        @State private var nextDueDate = Date()
        @State private var selectedCategory: ExpenseCategory?
        @State private var selectedAccount: FinancialAccount?
        @State private var notes = ""
        @State private var isActive = true

        // Cross-platform color support
        private var backgroundColor: Color {
            #if canImport(UIKit)
            return Color(UIColor.systemBackground)
            #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
            #else
            return Color.white
            #endif
        }

        private var isValidForm: Bool {
            !self.name.isEmpty && !self.amount.isEmpty && Double(self.amount) != nil
                && Double(self.amount)! > 0
        }

        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Subscription Details")) {
                        TextField("Subscription Name", text: self.$name).accessibilityLabel("Text Field").accessibilityLabel(
                            "Text Field"
                        )

                        HStack {
                            Text("$")
                            TextField("Amount", text: self.$amount).accessibilityLabel("Text Field").accessibilityLabel("Text Field")
                            #if canImport(UIKit)
                                .keyboardType(.decimalPad)
                            #endif
                        }

                        Picker("Frequency", selection: self.$frequency) {
                            ForEach(BillingCycle.allCases, id: \.self) { freq in
                                Text(freq.rawValue.capitalized).tag(freq)
                            }
                        }

                        DatePicker(
                            "Next Due Date", selection: self.$nextDueDate,
                            displayedComponents: .date
                        )

                        Toggle("Active", isOn: self.$isActive)
                    }

                    Section(header: Text("Organization")) {
                        Picker("Category", selection: self.$selectedCategory) {
                            Text("None").tag(ExpenseCategory?.none)
                            ForEach(self.categories, id: \.id) { category in
                                Text(category.name).tag(category as ExpenseCategory?)
                            }
                        }

                        Picker("Account", selection: self.$selectedAccount) {
                            Text("None").tag(FinancialAccount?.none)
                            ForEach(self.accounts, id: \.id) { account in
                                Text(account.name).tag(account as FinancialAccount?)
                            }
                        }
                    }

                    Section(header: Text("Notes")) {
                        TextField("Notes (optional).accessibilityLabel("Text Field")", text: self.$notes, axis: .vertical)
                            .lineLimit(3 ... 6)
                            .accessibilityLabel("Text Field")
                    }
                }
                .navigationTitle("Add Subscription")
                #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                    .toolbar(content: {
                        #if os(iOS)
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel").accessibilityLabel("Button") {
                                self.dismiss()
                            }
                            .accessibilityLabel("Cancel Button")
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save").accessibilityLabel("Button") {
                                self.saveSubscription()
                            }
                            .disabled(!self.isValidForm)
                            .accessibilityLabel("Save Button")
                        }
                        #else
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel").accessibilityLabel("Button") {
                                self.dismiss()
                            }
                            .accessibilityLabel("Cancel Button")
                        }

                        ToolbarItem(placement: .primaryAction) {
                            Button("Save").accessibilityLabel("Button") {
                                self.saveSubscription()
                            }
                            .disabled(!self.isValidForm)
                            .accessibilityLabel("Save Button")
                        }
                        #endif
                    })
                    .background(self.backgroundColor)
            }
        }

        private func saveSubscription() {
            guard let amountValue = Double(amount) else { return }

            let subscription = Subscription(
                name: name,
                amount: amountValue,
                billingCycle: frequency,
                nextDueDate: nextDueDate,
                notes: notes.isEmpty ? nil : self.notes,
            )

            subscription.category = self.selectedCategory
            subscription.account = self.selectedAccount
            subscription.isActive = self.isActive

            self.modelContext.insert(subscription)

            do {
                try self.modelContext.save()
                self.dismiss()
            } catch {
                Logger.logError(error, context: "Failed to save subscription")
            }
        }
    }

    // MARK: - Detail Row Utility View

    struct DetailRow: View {
        let title: String
        let value: String
        let icon: String

        var body: some View {
            HStack {
                Image(systemName: self.icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)

                Text(self.title)
                    .foregroundColor(.secondary)

                Spacer()

                Text(self.value)
                    .fontWeight(.medium)
            }
        }
    }
}
