// Momentum Finance - Enhanced Transaction Detail Edit View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import SwiftData
import SwiftUI

// MARK: - Edit View Component

/// Edit view component for transaction details
struct EnhancedTransactionDetailEditView: View {
    let transaction: FinancialTransaction
    @Binding var isEditing: Bool
    @Binding var editedTransaction: TransactionEditModel?
    let categories: [ExpenseCategory]
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit Transaction")
                .font(.title2)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                // Name field
                GridRow {
                    Text("Name:")
                        .gridColumnAlignment(.trailing)

                    TextField("Transaction name", text: Binding(
                        get: { self.editedTransaction?.name ?? self.transaction.name },
                        set: { self.editedTransaction?.name = $0 },
                    ))
                    .textFieldStyle(.roundedBorder)
                }

                // Amount field
                GridRow {
                    Text("Amount:")
                        .gridColumnAlignment(.trailing)

                    HStack {
                        TextField("Amount", value: Binding(
                            get: { self.editedTransaction?.amount ?? self.transaction.amount },
                            set: { self.editedTransaction?.amount = $0 },
                        ), format: .currency(code: self.transaction.currencyCode))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)

                        Picker("Type", selection: Binding(
                            get: { self.editedTransaction?.amount ?? self.transaction.amount >= 0 },
                            set: { isIncome in
                                if let amount = editedTransaction?.amount {
                                    self.editedTransaction?.amount = isIncome ? abs(amount) : -abs(amount)
                                }
                            },
                        )) {
                            Text("Expense").tag(false)
                            Text("Income").tag(true)
                        }
                        .fixedSize()
                    }
                }

                // Date field
                GridRow {
                    Text("Date:")
                        .gridColumnAlignment(.trailing)

                    DatePicker("Date", selection: Binding(
                        get: { self.editedTransaction?.date ?? self.transaction.date },
                        set: { self.editedTransaction?.date = $0 },
                    ))
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }

                // Category field
                GridRow {
                    Text("Category:")
                        .gridColumnAlignment(.trailing)

                    VStack {
                        Picker("Category", selection: Binding(
                            get: { self.editedTransaction?.categoryId ?? self.transaction.category?.id ?? "" },
                            set: { self.editedTransaction?.categoryId = $0 },
                        )) {
                            Text("None").tag("")
                            ForEach(self.categories) { category in
                                Text(category.name).tag(category.id)
                            }
                        }
                        .labelsHidden()

                        if let subcategory = editedTransaction?.subcategory {
                            TextField(
                                "Subcategory (optional)",
                                text: Binding(
                                    get: { subcategory },
                                    set: { self.editedTransaction?.subcategory = $0 },
                                )
                            )
                            .textFieldStyle(.roundedBorder)
                        }
                    }
                }

                // Account field
                GridRow {
                    Text("Account:")
                        .gridColumnAlignment(.trailing)

                    Picker("Account", selection: Binding(
                        get: { self.editedTransaction?.accountId ?? self.transaction.account?.id ?? "" },
                        set: { self.editedTransaction?.accountId = $0 },
                    )) {
                        Text("None").tag("")
                        // This would be populated with accounts
                        Text("Checking Account").tag("checking1")
                        Text("Savings Account").tag("savings1")
                        Text("Credit Card").tag("credit1")
                    }
                    .labelsHidden()
                }

                // Status field
                GridRow {
                    Text("Status:")
                        .gridColumnAlignment(.trailing)

                    Picker("Status", selection: Binding(
                        get: { self.editedTransaction?.isReconciled ?? self.transaction.isReconciled },
                        set: { self.editedTransaction?.isReconciled = $0 },
                    )) {
                        Text("Pending").tag(false)
                        Text("Reconciled").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }

                // Recurring field
                GridRow {
                    Text("Recurring:")
                        .gridColumnAlignment(.trailing)

                    Toggle("This transaction repeats regularly", isOn: Binding(
                        get: { self.editedTransaction?.isRecurring ?? self.transaction.isRecurring },
                        set: { self.editedTransaction?.isRecurring = $0 },
                    ))
                }

                // Location field
                GridRow {
                    Text("Location:")
                        .gridColumnAlignment(.trailing)

                    TextField("Transaction location", text: Binding(
                        get: { self.editedTransaction?.location ?? self.transaction.location ?? "" },
                        set: { self.editedTransaction?.location = $0 },
                    ))
                    .textFieldStyle(.roundedBorder)
                }
            }

            Text("Notes:")
                .padding(.top, 10)

            TextEditor(text: Binding(
                get: { self.editedTransaction?.notes ?? self.transaction.notes },
                set: { self.editedTransaction?.notes = $0 },
            ))
            .font(.body)
            .frame(minHeight: 100)
            .padding(4)
            .background(Color(.textBackgroundColor))
            .cornerRadius(4)

            // Attachments section
            HStack {
                Text("Attachments:")
                    .padding(.top, 10)

                Spacer()

                Button("Add Attachment") {
                    // Logic to add attachment
                }
                .buttonStyle(.bordered)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    if let attachments = transaction.attachments, !attachments.isEmpty {
                        ForEach(attachments, id: \.self) { attachment in
                            AttachmentThumbnail(attachment: attachment, showDeleteButton: true)
                        }
                    } else {
                        Text("No attachments")
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
            }
            .frame(height: 100)

            // Action buttons
            HStack {
                Button("Cancel") {
                    self.isEditing = false
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Save Changes") {
                    self.onSave()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
    }
}

/// Model for editing transaction data
struct TransactionEditModel {
    var name: String
    var amount: Double
    var date: Date
    var notes: String
    var categoryId: String
    var accountId: String
    var isReconciled: Bool
    var isRecurring: Bool
    var location: String?
    var subcategory: String?

    init(from transaction: FinancialTransaction) {
        self.name = transaction.name
        self.amount = transaction.amount
        self.date = transaction.date
        self.notes = transaction.notes
        self.categoryId = transaction.category?.id ?? ""
        self.accountId = transaction.account?.id ?? ""
        self.isReconciled = transaction.isReconciled
        self.isRecurring = transaction.isRecurring
        self.location = transaction.location
        self.subcategory = transaction.subcategory
    }
}

/// Thumbnail view for attachments
private struct AttachmentThumbnail: View {
    let attachment: String
    var showDeleteButton: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Image(systemName: "doc.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 4)

                Text(self.attachment)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(8)
            .frame(width: 100, height: 90)
            .background(Color(.windowBackgroundColor).opacity(0.5))
            .cornerRadius(8)

            if self.showDeleteButton {
                Button(action: {}) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                        .background(Color.white.clipShape(Circle()))
                }
                .buttonStyle(.borderless)
                .offset(x: 5, y: -5)
            }
        }
    }
}
