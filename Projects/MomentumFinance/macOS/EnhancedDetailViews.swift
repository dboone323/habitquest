// Momentum Finance - Enhanced macOS Detail Views
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import SwiftData
import SwiftUI

#if os(macOS)

    // MARK: - Enhanced Transaction Detail View

    extension Features.Transactions {
        /// Enhanced transaction detail view optimized for macOS screen space
        struct EnhancedTransactionDetailView: View {
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
                transactions.first(where: { $0.id == transactionId })
            }

            var body: some View {
                Group {
                    if let transaction {
                        VStack(spacing: 0) {
                            // Top action bar
                            HStack {
                                Picker("View", selection: $selectedTab) {
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
                                    if !isEditing {
                                        Button(action: { isEditing = true }) {
                                            Text("Edit")
                                                .frame(width: 80)
                                        }
                                        .buttonStyle(.bordered)
                                        .keyboardShortcut("e", modifiers: .command)
                                    } else {
                                        Button(action: saveChanges) {
                                            Text("Save")
                                                .frame(width: 80)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .keyboardShortcut(.return, modifiers: .command)

                                        Button(action: { isEditing = false }) {
                                            Text("Cancel")
                                                .frame(width: 80)
                                        }
                                        .buttonStyle(.bordered)
                                        .keyboardShortcut(.escape, modifiers: [])
                                    }

                                    Divider()
                                        .frame(height: 20)

                                    Menu {
                                        Button("Duplicate Transaction", action: duplicateTransaction)
                                        Button("Mark as \(transaction.isReconciled ? "Unreconciled" : "Reconciled")", action: toggleReconciled)
                                        Divider()
                                        Button("Find Similar Transactions", action: { showRelatedTransactions = true })
                                        Button("Show in Account", action: navigateToAccount)
                                        Divider()
                                        Button("Export as CSV", action: { showingExportOptions = true })
                                        Button("Print", action: printTransaction)
                                        Divider()
                                        Button("Delete Transaction", role: .destructive, action: { showingDeleteConfirmation = true })
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
                            if isEditing {
                                editView(for: transaction)
                                    .padding()
                                    .transition(.opacity)
                            } else {
                                TabView(selection: $selectedTab) {
                                    detailsView(for: transaction)
                                        .tag("details")

                                    analysisView(for: transaction)
                                        .tag("analysis")

                                    if transaction.isRecurring {
                                        seriesView(for: transaction)
                                            .tag("series")
                                    }

                                    notesView(for: transaction)
                                        .tag("notes")
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .transition(.opacity)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .alert("Delete Transaction", isPresented: $showingDeleteConfirmation) {
                            Button("Cancel", role: .cancel) {}
                            Button("Delete", role: .destructive) {
                                deleteTransaction(transaction)
                            }
                        } message: {
                            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
                        }
                        .sheet(isPresented: $showingExportOptions) {
                            ExportOptionsView(transaction: transaction)
                        }
                        .sheet(isPresented: $showRelatedTransactions) {
                            RelatedTransactionsView(transaction: transaction)
                        }
                        .onAppear {
                            // Initialize edit model if needed
                            if editedTransaction == nil {
                                editedTransaction = TransactionEditModel(from: transaction)
                            }
                        }
                    } else {
                        ContentUnavailableView("Transaction Not Found",
                                               systemImage: "exclamationmark.triangle",
                                               description: Text("The transaction you're looking for could not be found or has been deleted."))
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
                                        showRelatedTransactions = true
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

                                    Text(Calendar.current.date(byAdding: .month, value: i - 2, to: transaction.date)?.formatted(date: .abbreviated, time: .omitted) ?? "")
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

                    if !isEditing {
                        Button("Edit Notes") {
                            isEditing = true
                            selectedTab = "notes"
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }

            // MARK: - Edit View

            private func editView(for transaction: FinancialTransaction) -> some View {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Edit Transaction")
                        .font(.title2)

                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                        // Name field
                        GridRow {
                            Text("Name:")
                                .gridColumnAlignment(.trailing)

                            TextField("Transaction name", text: Binding(
                                get: { self.editedTransaction?.name ?? transaction.name },
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
                                    get: { self.editedTransaction?.amount ?? transaction.amount },
                                    set: { self.editedTransaction?.amount = $0 },
                                ), format: .currency(code: transaction.currencyCode))
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 150)

                                Picker("Type", selection: Binding(
                                    get: { self.editedTransaction?.amount ?? transaction.amount >= 0 },
                                    set: { isIncome in
                                        if let amount = self.editedTransaction?.amount {
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
                                get: { self.editedTransaction?.date ?? transaction.date },
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
                                    get: { self.editedTransaction?.categoryId ?? transaction.category?.id ?? "" },
                                    set: { self.editedTransaction?.categoryId = $0 },
                                )) {
                                    Text("None").tag("")
                                    ForEach(categories) { category in
                                        Text(category.name).tag(category.id)
                                    }
                                }
                                .labelsHidden()

                                if let subcategory = editedTransaction?.subcategory {
                                    TextField("Subcategory (optional)", text: Binding(
                                        get: { subcategory },
                                        set: { self.editedTransaction?.subcategory = $0 },
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                }
                            }
                        }

                        // Account field
                        GridRow {
                            Text("Account:")
                                .gridColumnAlignment(.trailing)

                            Picker("Account", selection: Binding(
                                get: { self.editedTransaction?.accountId ?? transaction.account?.id ?? "" },
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
                                get: { self.editedTransaction?.isReconciled ?? transaction.isReconciled },
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
                                get: { self.editedTransaction?.isRecurring ?? transaction.isRecurring },
                                set: { self.editedTransaction?.isRecurring = $0 },
                            ))
                        }

                        // Location field
                        GridRow {
                            Text("Location:")
                                .gridColumnAlignment(.trailing)

                            TextField("Transaction location", text: Binding(
                                get: { self.editedTransaction?.location ?? transaction.location ?? "" },
                                set: { self.editedTransaction?.location = $0 },
                            ))
                            .textFieldStyle(.roundedBorder)
                        }
                    }

                    Text("Notes:")
                        .padding(.top, 10)

                    TextEditor(text: Binding(
                        get: { self.editedTransaction?.notes ?? transaction.notes },
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
                }
            }

            // MARK: - Supporting Views

            private struct DetailField: View {
                let label: String
                let value: String

                var body: some View {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(value)
                            .font(.body)
                    }
                }
            }

            private struct CategoryTag: View {
                let category: ExpenseCategory

                var body: some View {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(getCategoryColor(category.colorHex))
                            .frame(width: 10, height: 10)

                        Text(category.name)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(getCategoryColor(category.colorHex).opacity(0.1))
                    .cornerRadius(4)
                }

                private func getCategoryColor(_ hex: String?) -> Color {
                    guard let hex else { return .gray }
                    // This would parse the hex color string
                    return .blue
                }
            }

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

                            Text(attachment)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(8)
                        .frame(width: 100, height: 90)
                        .background(Color(.windowBackgroundColor).opacity(0.5))
                        .cornerRadius(8)

                        if showDeleteButton {
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

            private struct BudgetImpactView: View {
                let category: ExpenseCategory
                let transactionAmount: Double

                // This would be calculated from actual budget data
                var budgetTotal: Double = 500
                var budgetSpent: Double = 325

                var body: some View {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Budget Impact")
                            .font(.headline)

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.name)
                                    .font(.subheadline)

                                Text("Monthly Budget")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                HStack {
                                    Text("\(budgetSpent.formatted(.currency(code: "USD")))")
                                    Text("of")
                                        .foregroundStyle(.secondary)
                                    Text("\(budgetTotal.formatted(.currency(code: "USD")))")
                                }
                                .font(.subheadline)

                                Text("\(Int((budgetSpent / budgetTotal) * 100))% Used")
                                    .font(.caption)
                                    .foregroundStyle(getBudgetColor(budgetSpent / budgetTotal))
                            }
                        }

                        ProgressView(value: budgetSpent, total: budgetTotal)
                            .tint(getBudgetColor(budgetSpent / budgetTotal))

                        HStack {
                            Text("This transaction: \(transactionAmount.formatted(.currency(code: "USD")))")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text("\(Int((transactionAmount / budgetTotal) * 100))% of monthly budget")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(8)
                }

                private func getBudgetColor(_ percentage: Double) -> Color {
                    if percentage < 0.7 {
                        .green
                    } else if percentage < 0.9 {
                        .yellow
                    } else {
                        .red
                    }
                }
            }

            private struct CategorySpendingChart: View {
                let category: ExpenseCategory

                // Sample data - would be real data in actual implementation
                let monthlyData = [
                    (month: "Jan", amount: 78.50),
                    (month: "Feb", amount: 92.30),
                    (month: "Mar", amount: 45.75),
                    (month: "Apr", amount: 120.00),
                    (month: "May", amount: 87.25),
                    (month: "Jun", amount: 95.50),
                ]

                var body: some View {
                    VStack(alignment: .leading, spacing: 8) {
                        Chart {
                            ForEach(monthlyData, id: \.month) { item in
                                BarMark(
                                    x: .value("Month", item.month),
                                    y: .value("Amount", item.amount),
                                )
                                .foregroundStyle(Color.blue.gradient)
                            }

                            RuleMark(y: .value("Average", 86.55))
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                                .annotation(position: .top, alignment: .trailing) {
                                    Text("Average: $86.55")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                        }

                        HStack {
                            VStack(alignment: .leading) {
                                Text("6 Month Total")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("$519.30")
                                    .font(.headline)
                            }

                            Spacer()

                            VStack(alignment: .center) {
                                Text("Monthly Average")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("$86.55")
                                    .font(.headline)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text("% of Total Spending")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("8.3%")
                                    .font(.headline)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }

            private struct MerchantSpendingChart: View {
                let merchantName: String

                // Sample data - would be real data in actual implementation
                let transactions = [
                    (date: "Feb 3", amount: 45.99),
                    (date: "Mar 5", amount: 52.25),
                    (date: "Apr 2", amount: 48.50),
                    (date: "May 7", amount: 55.75),
                    (date: "Jun 4", amount: 50.30),
                ]

                var body: some View {
                    VStack(alignment: .leading) {
                        Chart {
                            ForEach(transactions, id: \.date) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Amount", item.amount),
                                )
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                                .foregroundStyle(.blue)
                            }

                            ForEach(transactions, id: \.date) { item in
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Amount", item.amount),
                                )
                                .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }

            private struct ExportOptionsView: View {
                let transaction: FinancialTransaction
                @Environment(\.dismiss) private var dismiss

                var body: some View {
                    VStack(spacing: 20) {
                        Text("Export Transaction")
                            .font(.title)

                        Picker("Format", selection: .constant("csv")) {
                            Text("CSV").tag("csv")
                            Text("PDF").tag("pdf")
                            Text("QIF").tag("qif")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 300)

                        // Export options and controls would go here

                        HStack {
                            Button("Cancel") {
                                dismiss()
                            }
                            .buttonStyle(.bordered)

                            Spacer()

                            Button("Export") {
                                // Export logic
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top)
                    }
                    .frame(width: 400)
                    .padding()
                }
            }

            private struct RelatedTransactionsView: View {
                let transaction: FinancialTransaction
                @Environment(\.dismiss) private var dismiss

                // Sample data - would be actual transactions in implementation
                let relatedTransactions = [
                    "January Grocery Shopping",
                    "February Grocery Shopping",
                    "March Grocery Shopping",
                    "April Grocery Shopping",
                    "May Grocery Shopping",
                ]

                var body: some View {
                    VStack {
                        Text("Transactions Similar to '\(transaction.name)'")
                            .font(.headline)
                            .padding()

                        List(relatedTransactions, id: \.self) { name in
                            HStack {
                                Text(name)
                                Spacer()
                                Text("$\(Int.random(in: 45 ... 95)).\(Int.random(in: 10 ... 99))")
                                    .foregroundStyle(.red)
                            }
                        }

                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .padding()
                    }
                    .frame(width: 500, height: 400)
                }
            }

            // MARK: - Supporting Models

            private struct TransactionEditModel {
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

            // MARK: - Action Methods

            private func saveChanges() {
                guard let transaction, let editData = editedTransaction else {
                    isEditing = false
                    return
                }

                // Update transaction with edited values
                transaction.name = editData.name
                transaction.amount = editData.amount
                transaction.date = editData.date
                transaction.notes = editData.notes
                transaction.isReconciled = editData.isReconciled
                transaction.isRecurring = editData.isRecurring
                transaction.location = editData.location
                transaction.subcategory = editData.subcategory

                // Category and account relationships would be handled here

                // Save changes to the model context
                try? modelContext.save()

                isEditing = false
            }

            private func deleteTransaction(_ transaction: FinancialTransaction) {
                modelContext.delete(transaction)
                try? modelContext.save()
                // Navigate back
            }

            private func duplicateTransaction() {
                guard let original = transaction else { return }

                let duplicate = FinancialTransaction(
                    name: "Copy of \(original.name)",
                    amount: original.amount,
                    date: Date(),
                    notes: original.notes,
                    isReconciled: false,
                )

                // Copy other properties and relationships
                duplicate.isRecurring = original.isRecurring
                duplicate.location = original.location
                duplicate.subcategory = original.subcategory
                // Category and account would be set here

                modelContext.insert(duplicate)
                try? modelContext.save()
            }

            private func toggleReconciled() {
                guard let transaction else { return }
                transaction.isReconciled.toggle()
                try? modelContext.save()
            }

            private func navigateToAccount() {
                guard let transaction, let accountId = transaction.account?.id else { return }
                // Navigate to account detail
            }

            private func printTransaction() {
                // Implementation for printing
            }
        }
    }
#endif
