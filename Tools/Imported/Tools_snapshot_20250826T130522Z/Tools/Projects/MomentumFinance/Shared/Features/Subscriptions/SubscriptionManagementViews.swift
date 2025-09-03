<<<<<<< HEAD
import UIKit
import SwiftData
import SwiftUI
import UIKit
=======
import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif
>>>>>>> 1cf3938 (Create working state for recovery)

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

<<<<<<< HEAD
        @Query private var categories: [ExpenseCategory]
        @Query private var accounts: [FinancialAccount]
=======
        // Temporarily use stored-array fallbacks (no SwiftData @Query) to avoid
        // 'unknown attribute Query' compile errors on the current toolchain.
        private var categories: [ExpenseCategory] = []
        private var accounts: [FinancialAccount] = []
>>>>>>> 1cf3938 (Create working state for recovery)

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
<<<<<<< HEAD
            return Color(UIColor.systemBackground)
            #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
            #else
            return Color.white
=======
                return Color(UIColor.systemBackground)
            #elseif canImport(AppKit)
                return Color(NSColor.controlBackgroundColor)
            #else
                return Color.white
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }

        private var isValidForm: Bool {
            !name.isEmpty && !amount.isEmpty && Double(amount) != nil && Double(amount)! > 0
        }

        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Subscription Details")) {
                        TextField("Subscription Name", text: $name)

                        HStack {
                            Text("$")
                            TextField("Amount", text: $amount)
                                #if canImport(UIKit)
<<<<<<< HEAD
                                .keyboardType(.decimalPad)
                            #endif
=======
                                    .keyboardType(.decimalPad)
                                #endif
>>>>>>> 1cf3938 (Create working state for recovery)
                        }

                        Picker("Frequency", selection: $frequency) {
                            ForEach(BillingCycle.allCases, id: \.self) { freq in
                                Text(freq.rawValue.capitalized).tag(freq)
                            }
                        }

<<<<<<< HEAD
                        DatePicker("Next Due Date", selection: $nextDueDate, displayedComponents: .date)
=======
                        DatePicker(
                            "Next Due Date", selection: $nextDueDate, displayedComponents: .date)
>>>>>>> 1cf3938 (Create working state for recovery)

                        Toggle("Active", isOn: $isActive)
                    }

                    Section(header: Text("Organization")) {
                        Picker("Category", selection: $selectedCategory) {
                            Text("None").tag(ExpenseCategory?.none)
                            ForEach(categories, id: \.id) { category in
                                Text(category.name).tag(category as ExpenseCategory?)
                            }
                        }

                        Picker("Account", selection: $selectedAccount) {
                            Text("None").tag(FinancialAccount?.none)
                            ForEach(accounts, id: \.id) { account in
                                Text(account.name).tag(account as FinancialAccount?)
                            }
                        }
                    }

                    Section(header: Text("Notes")) {
                        TextField("Notes (optional)", text: $notes, axis: .vertical)
<<<<<<< HEAD
                            .lineLimit(3 ... 6)
=======
                            .lineLimit(3...6)
>>>>>>> 1cf3938 (Create working state for recovery)
                    }
                }
                .navigationTitle("Add Subscription")
                #if os(iOS)
<<<<<<< HEAD
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveSubscription()
                        }
                        .disabled(!isValidForm)
                    }
                    #else
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .primaryAction) {
                        Button("Save") {
                            saveSubscription()
                        }
                        .disabled(!isValidForm)
                    }
=======
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    #if os(iOS)
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                saveSubscription()
                            }
                            .disabled(!isValidForm)
                        }
                    #else
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }

                        ToolbarItem(placement: .primaryAction) {
                            Button("Save") {
                                saveSubscription()
                            }
                            .disabled(!isValidForm)
                        }
>>>>>>> 1cf3938 (Create working state for recovery)
                    #endif
                }
                .background(backgroundColor)
            }
        }

        private func saveSubscription() {
            guard let amountValue = Double(amount) else { return }

            let subscription = Subscription(
                name: name,
                amount: amountValue,
                billingCycle: frequency,
                nextDueDate: nextDueDate,
                notes: notes.isEmpty ? nil : notes,
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)

            subscription.category = selectedCategory
            subscription.account = selectedAccount
            subscription.isActive = isActive

            modelContext.insert(subscription)

            do {
                try modelContext.save()
                dismiss()
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
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)

                Text(title)
                    .foregroundColor(.secondary)

                Spacer()

                Text(value)
                    .fontWeight(.medium)
            }
        }
    }
}
