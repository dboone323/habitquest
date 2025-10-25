// Momentum Finance - Enhanced macOS Detail Views
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import MomentumFinanceCore
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
                                        Button(action: { self.isEditing = true }).accessibilityLabel("Button").accessibilityLabel("Button") {
                                            Text("Edit")
                                                .frame(width: 80)
                                        }
                                        .buttonStyle(.bordered)
                                        .keyboardShortcut("e", modifiers: .command)
                                    } else {
                                        Button(action: self.saveChanges).accessibilityLabel("Button").accessibilityLabel("Button") {
                                            Text("Save")
                                                .frame(width: 80)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .keyboardShortcut(.return, modifiers: .command)

                                        Button(action: { self.isEditing = false }).accessibilityLabel("Button").accessibilityLabel("Button") {
                                            Text("Cancel")
                                                .frame(width: 80)
                                        }
                                        .buttonStyle(.bordered)
                                        .keyboardShortcut(.escape, modifiers: [])
                                    }

                                    Divider()
                                        .frame(height: 20)

                                    Menu {
                                        Button("Duplicate Transaction", action: self.duplicateTransaction).accessibilityLabel("Button")
                                        Divider()
                                        Button("Find Similar Transactions", action: { self.showRelatedTransactions = true })
                                            .accessibilityLabel("Button")
                                        Button("Show in Account", action: self.navigateToAccount).accessibilityLabel("Button")
                                        Divider()
                                        Button("Export as CSV", action: { self.showingExportOptions = true }).accessibilityLabel("Button")
                                        Button("Print", action: self.printTransaction).accessibilityLabel("Button")
                                        Divider()
                                        Button("Delete Transaction", role: .destructive, action: { self.showingDeleteConfirmation = true })
                                            .accessibilityLabel("Button")
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
                                self.editView(for: transaction)
                                    .padding()
                                    .transition(.opacity)
                            } else {
                                TabView(selection: self.$selectedTab) {
                                    self.detailsView(for: transaction)
                                        .tag("details")

                                    self.analysisView(for: transaction)
                                        .tag("analysis")

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
                                Text(transaction.title)
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
                                Text(transaction.amount.formatted(.currency(code: "USD")))
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
                                DetailField(label: "Status", value: "Active")
                                    .foregroundStyle(.green)

                                DetailField(label: "Method", value: "Not specified")
                            }

                            if transaction.amount < 0 {
                                GridRow {
                                    DetailField(label: "Recurrence", value: "One-time")

                                    DetailField(label: "Category", value: transaction.category?.name ?? "Uncategorized")
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
                        if let notes = transaction.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)

                                Text(notes)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.windowBackgroundColor).opacity(0.3))
                                    .cornerRadius(8)
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
                                    Text("One-time")
                                    Text("(Single transaction)")
                                        .foregroundStyle(.secondary)
                                }

                                GridRow {
                                    Text("Similar transactions:")
                                        .gridColumnAlignment(.trailing)
                                    Text("15 found")
                                    Button("View All").accessibilityLabel("Button").accessibilityLabel("Button") {
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
                                Text("Merchant Analysis: \(transaction.title)")
                                    .font(.headline)

                                // Placeholder for merchant spending chart
                                MerchantSpendingChart(merchantName: transaction.title)
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
                                    Text(transaction.title)
                                        .font(.headline)

                                    Text(Calendar.current.date(byAdding: .month, value: i - 2, to: transaction.date)?.formatted(
                                        date: .abbreviated,
                                        time: .omitted
                                    ) ?? "")
                                        .font(.caption)
                                }

                                Spacer()

                                Text(transaction.amount.formatted(.currency(code: "USD")))
                                    .foregroundStyle(transaction.amount < 0 ? .red : .green)

                                Image(systemName: i == 2 ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(i == 2 ? .green : .secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Spacer()

                    HStack {
                        Text("Total series value: \((transaction.amount * 5).formatted(.currency(code: "USD")))")
                            .font(.headline)

                        Spacer()

                        Button("Edit Series").accessibilityLabel("Button").accessibilityLabel("Button") {
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

                    if let notes = transaction.notes, notes.isEmpty {
                        Text("No notes have been added to this transaction.")
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ScrollView {
                            Text(transaction.notes ?? "")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)
                        }
                    }

                    Spacer()

                    if !self.isEditing {
                        Button("Edit Notes").accessibilityLabel("Button").accessibilityLabel("Button") {
                            self.isEditing = true
                            self.selectedTab = "notes"
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
                                get: { self.editedTransaction?.name ?? transaction.title },
                                set: { self.editedTransaction?.name = $0 }
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
                                    set: { self.editedTransaction?.amount = $0 }
                                ), format: .currency(code: "USD"))
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 150)

                                Picker("Type", selection: Binding(
                                    get: { self.editedTransaction?.amount ?? transaction.amount >= 0 },
                                    set: { isIncome in
                                        if let amount = editedTransaction?.amount {
                                            self.editedTransaction?.amount = isIncome ? abs(amount) : -abs(amount)
                                        }
                                    }
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
                                set: { self.editedTransaction?.date = $0 }
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
                                    get: { self.editedTransaction?.categoryId ?? transaction.category?.id.uuidString ?? "" },
                                    set: { self.editedTransaction?.categoryId = $0 }
                                )) {
                                    Text("None").tag("")
                                    ForEach(self.categories) { category in
                                        Text(category.name).tag(category.id.uuidString)
                                    }
                                }
                                .labelsHidden()
                            }
                        }
                    }

                    Text("Notes:")
                        .padding(.top, 10)

                    TextEditor(text: Binding(
                        get: { self.editedTransaction?.notes ?? transaction.notes ?? "" },
                        set: { self.editedTransaction?.notes = $0 }
                    ))
                    .font(.body)
                    .frame(minHeight: 100)
                    .padding(4)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(4)
                }
            }

            // MARK: - Supporting Views

            private struct DetailField: View {
                let label: String
                let value: String

                var body: some View {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(self.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(self.value)
                            .font(.body)
                    }
                }
            }

            private struct CategoryTag: View {
                let category: ExpenseCategory

                var body: some View {
                    HStack(spacing: 4) {
                        Image(systemName: category.iconName)
                            .foregroundStyle(.blue)
                            .frame(width: 10, height: 10)

                        Text(self.category.name)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
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
                                Text(self.category.name)
                                    .font(.subheadline)

                                Text("Monthly Budget")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                HStack {
                                    Text("\(self.budgetSpent.formatted(.currency(code: "USD")))")
                                    Text("of")
                                        .foregroundStyle(.secondary)
                                    Text("\(self.budgetTotal.formatted(.currency(code: "USD")))")
                                }
                                .font(.subheadline)

                                Text("\(Int((self.budgetSpent / self.budgetTotal) * 100))% Used")
                                    .font(.caption)
                                    .foregroundStyle(self.getBudgetColor(self.budgetSpent / self.budgetTotal))
                            }
                        }

                        ProgressView(value: self.budgetSpent, total: self.budgetTotal)
                            .tint(self.getBudgetColor(self.budgetSpent / self.budgetTotal))

                        HStack {
                            Text("This transaction: \(self.transactionAmount.formatted(.currency(code: "USD")))")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text("\(Int((self.transactionAmount / self.budgetTotal) * 100))% of monthly budget")
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
                            ForEach(self.monthlyData, id: \.month) { item in
                                BarMark(
                                    x: .value("Month", item.month),
                                    y: .value("Amount", item.amount)
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
                            ForEach(self.transactions, id: \.date) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Amount", item.amount)
                                )
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                                .foregroundStyle(.blue)
                            }

                            ForEach(self.transactions, id: \.date) { item in
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Amount", item.amount)
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
                                self.dismiss()
                            }
                            .buttonStyle(.bordered)

                            Spacer()

                            Button("Export") {
                                // Export logic
                                self.dismiss()
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
                        Text("Transactions Similar to '\(self.transaction.title)'")
                            .font(.headline)
                            .padding()

                        List(self.relatedTransactions, id: \.self) { name in
                            HStack {
                                Text(name)
                                Spacer()
                                Text("$\(Int.random(in: 45 ... 95)).\(Int.random(in: 10 ... 99))")
                                    .foregroundStyle(.red)
                            }
                        }

                        Button("Close").accessibilityLabel("Button").accessibilityLabel("Button") {
                            self.dismiss()
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
                var transactionType: TransactionType

                init(from transaction: FinancialTransaction) {
                    self.name = transaction.title
                    self.amount = transaction.amount
                    self.date = transaction.date
                    self.notes = transaction.notes ?? ""
                    self.categoryId = transaction.category?.id.uuidString ?? ""
                    self.accountId = transaction.account?.persistentModelID.description ?? ""
                    self.transactionType = transaction.transactionType
                }
            }

            // MARK: - Action Methods

            private func saveChanges() {
                guard let transaction, let editData = editedTransaction else {
                    self.isEditing = false
                    return
                }

                // Update transaction with edited values
                transaction.title = editData.name
                transaction.amount = editData.amount
                transaction.date = editData.date
                transaction.notes = editData.notes
                transaction.transactionType = editData.transactionType

                // Category and account relationships would be handled here

                // Save changes to the model context
                try? self.modelContext.save()

                self.isEditing = false
            }

            private func deleteTransaction(_ transaction: FinancialTransaction) {
                self.modelContext.delete(transaction)
                try? self.modelContext.save()
                // Navigate back
            }

            private func duplicateTransaction() {
                guard let original = transaction else { return }

                let duplicate = FinancialTransaction(
                    title: "Copy of \(original.title)",
                    amount: original.amount,
                    date: Date(),
                    transactionType: original.transactionType,
                    notes: original.notes
                )

                // Copy other properties and relationships
                // Category and account would be set here

                self.modelContext.insert(duplicate)
                try? self.modelContext.save()
            }

            private func navigateToAccount() {
                guard let transaction, let accountId = transaction.account?.persistentModelID else { return }
                // Navigate to account detail
            }

            private func printTransaction() {
                // Implementation for printing
            }
        }
    }
#endif
