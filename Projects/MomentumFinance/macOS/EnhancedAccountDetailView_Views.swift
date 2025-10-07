// Momentum Finance - View Methods for Enhanced Account Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)
/// View methods for the enhanced account detail view
extension EnhancedAccountDetailView {
    func detailView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Account summary section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Account Summary")
                        .font(.title2)
                        .bold()

                    HStack(spacing: 40) {
                        AccountDetailField(label: "Balance", value: self.account?.formattedBalance ?? "N/A")
                        AccountDetailField(label: "Type", value: self.account?.type.rawValue.capitalized ?? "N/A")
                        AccountDetailField(label: "Institution", value: self.account?.institution ?? "N/A")
                        AccountDetailField(label: "Account Number", value: self.account?.accountNumber ?? "N/A")
                    }

                    if let account = self.account, account.type == .credit {
                        HStack(spacing: 40) {
                            AccountDetailField(label: "Credit Limit", value: account.formattedCreditLimit)
                            AccountDetailField(label: "Available Credit", value: account.formattedAvailableCredit)
                            AccountDetailField(label: "Credit Utilization", value: account.formattedCreditUtilization)
                        }
                    }

                    if let account = self.account, let interestRate = account.interestRate {
                        AccountDetailField(
                            label: "Interest Rate",
                            value: "\(interestRate.formatted(.percent.precision(.fractionLength(2))))"
                        )
                    }

                    if let account = self.account, let dueDate = account.dueDate {
                        AccountDetailField(label: "Due Date", value: dueDate.formatted(date: .abbreviated, time: .omitted))
                    }

                    if let account = self.account, let notes = account.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.headline)
                            Text(notes)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Charts section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Analytics")
                        .font(.title2)
                        .bold()

                    HStack(alignment: .top, spacing: 20) {
                        BalanceTrendChart(account: self.account, transactions: self.filteredTransactions)
                            .frame(height: 300)

                        SpendingBreakdownChart(transactions: self.filteredTransactions)
                            .frame(height: 300)
                    }
                }

                // Transactions section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recent Transactions")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Text("\(self.filteredTransactions.count) transactions")
                            .foregroundStyle(.secondary)
                    }

                    if self.filteredTransactions.isEmpty {
                        Text("No transactions found for the selected time period.")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        List(self.filteredTransactions, selection: self.$selectedTransactionIds) { transaction in
                            TransactionRow(transaction: transaction)
                                .contextMenu {
                                    Button("Toggle Status") {
                                        self.toggleTransactionStatus(transaction)
                                    }
                                    Button("Delete", role: .destructive) {
                                        self.deleteTransaction(transaction)
                                    }
                                }
                        }
                        .frame(height: 400)
                    }
                }
            }
            .padding()
        }
    }

    func editView(for account: FinancialAccount) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Edit Account")
                    .font(.title2)
                    .bold()

                VStack(spacing: 16) {
                    // Basic Information
                    GroupBox("Basic Information") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Name:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("Account Name", text: self.editedAccount?.name ?? "")
                                    .textFieldStyle(.roundedBorder)
                                    .onChange(of: self.editedAccount?.name ?? "") { _, newValue in
                                        self.validateAccountName(newValue)
                                    }
                            }

                            HStack {
                                Text("Type:")
                                    .frame(width: 100, alignment: .leading)
                                Picker("Account Type", selection: self.editedAccount?.type ?? .checking) {
                                    ForEach(FinancialAccount.AccountType.allCases, id: \.self) { type in
                                        Text(type.rawValue.capitalized).tag(type)
                                    }
                                }
                                .frame(width: 200)
                            }

                            HStack {
                                Text("Institution:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("Bank Name", text: self.editedAccount?.institution ?? "")
                                    .textFieldStyle(.roundedBorder)
                                    .onChange(of: self.editedAccount?.institution ?? "") { _, newValue in
                                        self.validateInstitution(newValue)
                                    }
                            }

                            HStack {
                                Text("Account #:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("Account Number", text: self.editedAccount?.accountNumber ?? "")
                                    .textFieldStyle(.roundedBorder)
                                    .onChange(of: self.editedAccount?.accountNumber ?? "") { _, newValue in
                                        self.validateAccountNumber(newValue)
                                    }
                            }
                        }
                        .padding()
                    }

                    // Financial Information
                    GroupBox("Financial Information") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Balance:")
                                    .frame(width: 100, alignment: .leading)
                                TextField(
                                    "Current Balance",
                                    value: self.editedAccount?.balance ?? 0,
                                    format: .currency(code: self.editedAccount?.currencyCode ?? "USD")
                                )
                                .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("Currency:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("Currency Code", text: self.editedAccount?.currencyCode ?? "USD")
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)
                            }

                            if self.editedAccount?.type == .credit {
                                HStack {
                                    Text("Credit Limit:")
                                        .frame(width: 100, alignment: .leading)
                                    TextField(
                                        "Credit Limit",
                                        value: self.editedAccount?.creditLimit ?? 0,
                                        format: .currency(code: self.editedAccount?.currencyCode ?? "USD")
                                    )
                                    .textFieldStyle(.roundedBorder)
                                }

                                HStack {
                                    Text("Interest Rate:")
                                        .frame(width: 100, alignment: .leading)
                                    TextField(
                                        "Interest Rate",
                                        value: self.editedAccount?.interestRate ?? 0,
                                        format: .percent.precision(.fractionLength(2))
                                    )
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)
                                }

                                HStack {
                                    Text("Due Date:")
                                        .frame(width: 100, alignment: .leading)
                                    DatePicker("Due Date", selection: self.editedAccount?.dueDate ?? Date(), displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                            }
                        }
                        .padding()
                    }

                    // Settings
                    GroupBox("Settings") {
                        VStack(spacing: 12) {
                            Toggle("Include in Total Balance", isOn: self.editedAccount?.includeInTotal ?? true)
                            Toggle("Account is Active", isOn: self.editedAccount?.isActive ?? true)
                        }
                        .padding()
                    }

                    // Notes
                    GroupBox("Notes") {
                        TextEditor(text: self.editedAccount?.notes ?? "")
                            .frame(height: 100)
                            .onChange(of: self.editedAccount?.notes ?? "") { _, newValue in
                                self.validateNotes(newValue)
                            }
                            .padding()
                    }
                }

                // Validation errors
                if !self.validationErrors.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Please fix the following errors:")
                            .foregroundStyle(.red)
                            .bold()

                        ForEach(Array(self.validationErrors.keys.sorted()), id: \.self) { key in
                            if let error = self.validationErrors[key] {
                                Text("• \(error)")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Action buttons
                HStack {
                    Button("Cancel", role: .cancel) {
                        self.isEditing = false
                        self.editedAccount = nil
                        self.validationErrors.removeAll()
                    }

                    Spacer()

                    Button("Save Changes") {
                        if self.isValidForm() {
                            self.saveChanges()
                        } else {
                            self.showingValidationAlert = true
                        }
                    }
                    .disabled(!self.isValidForm())
                    .keyboardShortcut(.return, modifiers: .command)
                }
                .padding(.top)
            }
            .padding()
        }
        .alert("Validation Error", isPresented: self.$showingValidationAlert) {
            Button("OK") {}
        } message: {
            Text("Please fix all validation errors before saving.")
        }
    }
}
#endif
