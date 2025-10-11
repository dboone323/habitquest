// Momentum Finance - Enhanced Transaction Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import SwiftData
import SwiftUI

// MARK: - Enhanced Transaction Detail View

/// Enhanced transaction detail view optimized for macOS screen space
struct TransactionDetailContent: View {
    let transactionId: String

    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [FinancialTransaction]
    @Query private var categories: [ExpenseCategory]
    @State private var isEditing = false
    @State private var editedTransaction: TransactionEditModel?
    @State private var selectedTab = "details"
    @State private var showingDeleteConfirmation = false
    @State private var showingExportOptions = false
    @State private var showRelatedTransactions = false

    private var transaction: FinancialTransaction? {
        self.transactions.first(where: { $0.id == self.transactionId })
    }

    var body: some View {
        Group {
            if let transaction {
                VStack(spacing: 0) {
                    // Top action bar
                    HStack {
                        Picker("View", selection: self.$selectedTab) {
                            Text("Details").tag("details")
                            Text("Analysis").tag("analysis")
                            if transaction.isRecurring {
                                Text("Series").tag("series")
                            }
                            Text("Notes").tag("notes")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 300)

                        Spacer()

                        HStack(spacing: 12) {
                            if !self.isEditing {
                                Button(action: { self.isEditing = true }) {
                                    Text("Edit")
                                        .frame(width: 80)
                                }
                                .buttonStyle(.bordered)
                                .keyboardShortcut("e", modifiers: .command)
                            } else {
                                Button(action: self.saveChanges) {
                                    Text("Save")
                                        .frame(width: 80)
                                }
                                .buttonStyle(.borderedProminent)
                                .keyboardShortcut(.return, modifiers: .command)

                                Button(action: { self.isEditing = false }) {
                                    Text("Cancel")
                                        .frame(width: 80)
                                }
                                .buttonStyle(.bordered)
                                .keyboardShortcut(.escape, modifiers: [])
                            }

                            Divider()
                                .frame(height: 20)

                            Menu {
                                Button("Duplicate Transaction", action: self.duplicateTransaction)
                                Button(
                                    "Mark as \(transaction.isReconciled ? "Unreconciled" : "Reconciled")",
                                    action: self.toggleReconciled
                                )
                                Divider()
                                Button("Find Similar Transactions", action: { self.showRelatedTransactions = true })
                                Button("Show in Account", action: self.navigateToAccount)
                                Divider()
                                Button("Export as CSV", action: { self.showingExportOptions = true })
                                Button("Print", action: self.printTransaction)
                                Divider()
                                Button("Delete Transaction", role: .destructive, action: { self.showingDeleteConfirmation = true })
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                            .menuStyle(.borderlessButton)
                            .fixedSize()
                        }
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))

                    Divider()

                    // Main content area
                    if self.isEditing {
                        EnhancedTransactionDetailEditView(
                            transaction: transaction,
                            isEditing: self.$isEditing,
                            editedTransaction: self.$editedTransaction,
                            categories: self.categories,
                            onSave: self.saveChanges
                        )
                        .padding()
                        .transition(.opacity)
                    } else {
                        TabView(selection: self.$selectedTab) {
                            self.detailsView(for: transaction)
                                .tag("details")

                            self.analysisView(for: transaction)
                                .tag("analysis")

                            if transaction.isRecurring {
                                self.seriesView(for: transaction)
                                    .tag("series")
                            }

                            self.notesView(for: transaction)
                                .tag("notes")
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .alert("Delete Transaction", isPresented: self.$showingDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        self.deleteTransaction(transaction)
                    }
                } message: {
                    Text("Are you sure you want to delete this transaction? This action cannot be undone.")
                }
                .sheet(isPresented: self.$showingExportOptions) {
                    ExportOptionsView(transaction: transaction)
                }
                .sheet(isPresented: self.$showRelatedTransactions) {
                    RelatedTransactionsView(transaction: transaction)
                }
                .onAppear {
                    // Initialize edit model if needed
                    if self.editedTransaction == nil {
                        self.editedTransaction = TransactionEditModel(from: transaction)
                    }
                }
            } else {
                ContentUnavailableView(
                    "Transaction Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The transaction you're looking for could not be found or has been deleted.")
                )
            }
        }
    }

    // MARK: - Content Views

    private func detailsView(for transaction: FinancialTransaction) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with transaction name and amount
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(transaction.name)
                            .font(.system(size: 28, weight: .bold))

                        if let category = transaction.category {
                            HStack {
                                CategoryTag(category: category)

                                if let subcategory = transaction.subcategory, !subcategory.isEmpty {
                                    Text("•")
                                        .foregroundStyle(.secondary)
                                    Text(subcategory)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(transaction.amount.formatted(.currency(code: transaction.currencyCode)))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(transaction.amount < 0 ? .red : .green)

                        if transaction.amount < 0 {
                            Text("Expense")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Income")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Divider()

                // Core transaction details
                Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 16) {
                    GridRow {
                        DetailField(label: "Date", value: transaction.date.formatted(date: .long, time: .shortened))

                        DetailField(label: "Account", value: transaction.account?.name ?? "Unknown Account")
                    }

                    GridRow {
                        DetailField(label: "Status", value: transaction.isReconciled ? "Reconciled" : "Pending")
                            .foregroundStyle(transaction.isReconciled ? .green : .orange)

                        DetailField(label: "Method", value: transaction.paymentMethod ?? "Not specified")
                    }

                    if transaction.isRecurring {
                        GridRow {
                            DetailField(label: "Recurrence", value: "Monthly")

                            if let nextDate = transaction.date.addingTimeInterval(30 * 24 * 60 * 60) {
                                DetailField(label: "Next Due", value: nextDate.formatted(date: .abbreviated, time: .omitted))
                            }
                        }
                    }

                    if let location = transaction.location, !location.isEmpty {
                        GridRow {
                            DetailField(label: "Location", value: location)
                                .gridCellColumns(2)
                        }
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(8)

                // Notes section
                if !transaction.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)

                        Text(transaction.notes)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)
                    }
                }

                // Attachments (if any)
                if let attachments = transaction.attachments, !attachments.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Attachments")
                            .font(.headline)

                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(attachments, id: \.self) { attachment in
                                    AttachmentThumbnail(attachment: attachment)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(height: 120)
                    }
                }

                // Budget impact section
                if let category = transaction.category, transaction.amount < 0 {
                    BudgetImpactView(category: category, transactionAmount: abs(transaction.amount))
                }
            }
            .padding()
        }
    }

    private func analysisView(for transaction: FinancialTransaction) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                if let category = transaction.category, transaction.amount < 0 {
                    // Category spending trends
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category Spending Trends")
                            .font(.headline)

                        // This would be a chart showing spending in this category over time
                        CategorySpendingChart(category: category)
                            .frame(height: 220)
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(8)
                }

                // Transaction insights
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transaction Insights")
                        .font(.headline)

                    Grid(alignment: .leading) {
                        GridRow {
                            Text("Average amount:")
                                .gridColumnAlignment(.trailing)
                            Text("$87.45")
                            Text("(This transaction is 15% higher)")
                                .foregroundStyle(.orange)
                        }

                        GridRow {
                            Text("Frequency:")
                                .gridColumnAlignment(.trailing)
                            Text("Monthly")
                            Text("(Last seen 32 days ago)")
                                .foregroundStyle(.secondary)
                        }

                        if transaction.isRecurring {
                            GridRow {
                                Text("Annual cost:")
                                    .gridColumnAlignment(.trailing)
                                Text("\((transaction.amount * 12).formatted(.currency(code: transaction.currencyCode)))")
                                Text("(2.5% of yearly expenses)")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        GridRow {
                            Text("Similar transactions:")
                                .gridColumnAlignment(.trailing)
                            Text("15 found")
                            Button("View All") {
                                self.showRelatedTransactions = true
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                    .padding()
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(8)

                // Merchant analysis
                if transaction.amount < 0 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Merchant Analysis: \(transaction.name)")
                            .font(.headline)

                        // Placeholder for merchant spending chart
                        MerchantSpendingChart(merchantName: transaction.name)
                            .frame(height: 180)

                        Grid {
                            GridRow {
                                Text("Usual spend:")
                                    .gridColumnAlignment(.trailing)
                                Text("$45-$100")
                            }

                            GridRow {
                                Text("Visit frequency:")
                                    .gridColumnAlignment(.trailing)
                                Text("Monthly")
                            }

                            GridRow {
                                Text("Last 6 months:")
                                    .gridColumnAlignment(.trailing)
                                Text("$487.25 (6 transactions)")
                            }
                        }
                        .padding()
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    }

    private func seriesView(for transaction: FinancialTransaction) -> some View {
        VStack {
            Text("Recurring Transaction Series")
                .font(.headline)
                .padding()

            // This would show other transactions in the series
            List {
                ForEach(0 ..< 5) { i in
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading) {
                            Text(transaction.name)
                                .font(.headline)

                            Text(Calendar.current.date(byAdding: .month, value: i - 2, to: transaction.date)?.formatted(
                                date: .abbreviated,
                                time: .omitted
                            ) ?? "")
                                .font(.caption)
                        }

                        Spacer()

                        Text(transaction.amount.formatted(.currency(code: transaction.currencyCode)))
                            .foregroundStyle(transaction.amount < 0 ? .red : .green)

                        Image(systemName: i == 2 ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(i == 2 ? .green : .secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Spacer()

            HStack {
                Text("Total series value: \((transaction.amount * 5).formatted(.currency(code: transaction.currencyCode)))")
                    .font(.headline)

                Spacer()

                Button("Edit Series") {
                    // Implementation for editing the recurring series
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }

    private func notesView(for transaction: FinancialTransaction) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Transaction Notes")
                .font(.title2)
                .padding(.bottom, 10)

            if transaction.notes.isEmpty {
                Text("No notes have been added to this transaction.")
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView {
                    Text(transaction.notes)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.windowBackgroundColor).opacity(0.3))
                        .cornerRadius(8)
                }
            }

            Spacer()

            if !self.isEditing {
                Button("Edit Notes") {
                    self.isEditing = true
                    self.selectedTab = "notes"
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    // MARK: - Action Methods

    private var actions: TransactionDetailActions {
        TransactionDetailActions(modelContext: self.modelContext)
    }

    private func saveChanges() {
        self.actions.saveChanges(transaction: self.transaction, editedTransaction: self.editedTransaction)
        self.isEditing = false
    }

    private func deleteTransaction(_ transaction: FinancialTransaction) {
        self.actions.deleteTransaction(transaction: transaction)
        // Navigate back
    }

    private func duplicateTransaction() {
        self.actions.duplicateTransaction(original: self.transaction)
    }

    private func toggleReconciled() {
        self.actions.toggleReconciled(transaction: self.transaction)
    }

    private func navigateToAccount() {
        self.actions.navigateToAccount(transaction: self.transaction)
    }

    private func printTransaction() {
        self.actions.printTransaction(transaction: self.transaction)
    }
}
