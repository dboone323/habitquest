// Momentum Finance - Account Detail View for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)
/// Account detail view optimized for macOS screen real estate
struct AccountDetailView: View {
    let accountId: String

    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [FinancialAccount]
    @Query private var transactions: [FinancialTransaction]
    @State private var isEditing = false
    @State private var editedAccount: AccountEditModel?
    @State private var selectedTransactionIds: Set<String> = []
    @State private var selectedTimeFrame: TimeFrame = .last30Days
    @State private var showingDeleteConfirmation = false
    @State private var showingExportOptions = false
    @State private var validationErrors: [String: String] = [:]
    @State private var showingValidationAlert = false

    private var account: FinancialAccount? {
        self.accounts.first(where: { $0.id == self.accountId })
    }

    private var filteredTransactions: [FinancialTransaction] {
        guard let account else { return [] }

        return self.transactions
            .filter { $0.account?.id == self.accountId && self.isTransactionInSelectedTimeFrame($0.date) }
            .sorted { $0.date > $1.date }
    }

    enum TimeFrame: String, CaseIterable, Identifiable {
        case last30Days = "Last 30 Days"
        case last90Days = "Last 90 Days"
        case thisYear = "This Year"
        case lastYear = "Last Year"
        case allTime = "All Time"

        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top toolbar with actions
            HStack {
                if let account {
                    HStack(spacing: 8) {
                        Image(systemName: account.type == .checking ? "banknote" : "creditcard.fill")
                            .font(.title)
                            .foregroundStyle(account.type == .checking ? .green : .blue)

                        Text(account.name)
                            .font(.title)
                            .bold()
                    }
                }

                Spacer()

                Picker("Time Frame", selection: self.$selectedTimeFrame) {
                    ForEach(TimeFrame.allCases) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .frame(width: 150)

                Button(action: { self.isEditing.toggle().accessibilityLabel("Button").accessibilityLabel("Button") }) {
                    Text(self.isEditing ? "Done" : "Edit")
                }
                .keyboardShortcut("e", modifiers: .command)

                Menu {
                    Button("Add Transaction", action: self.addTransaction).accessibilityLabel("Button").accessibilityLabel("Button")
                    Divider()
                    Button("Export Transactions...", action: { self.showingExportOptions = true }).accessibilityLabel("Button")
                        .accessibilityLabel("Button")
                    Button("Print Account Summary", action: self.printAccountSummary).accessibilityLabel("Button")
                        .accessibilityLabel("Button")
                    Divider()
                    Button("Delete Account", role: .destructive).accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.showingDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor))

            Divider()

            if self.isEditing, let account {
                self.editView(for: account)
                    .padding()
                    .transition(.opacity)
            } else {
                self.detailView()
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Delete Account", isPresented: self.$showingDeleteConfirmation) {
            Button("Cancel", role: .cancel).accessibilityLabel("Button").accessibilityLabel("Button") {}
            Button("Delete", role: .destructive).accessibilityLabel("Button").accessibilityLabel("Button") {
                self.deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete this account? This will also delete all associated transactions and cannot be undone.")
        }
        .alert("Validation Error", isPresented: self.$showingValidationAlert) {
            Button("OK").accessibilityLabel("Button").accessibilityLabel("Button") {}
        } message: {
            Text("Please fix the validation errors before saving.")
        }
        .sheet(isPresented: self.$showingExportOptions) {
            ExportOptionsView(account: self.account, transactions: self.filteredTransactions)
                .frame(width: 500, height: 400)
        }
        .onAppear {
            // Initialize edit model if needed
            if let account, editedAccount == nil {
                self.editedAccount = AccountEditModel(from: account)
            }
        }
    }

    // MARK: - Detail View

    private func detailView() -> some View {
        guard let account else {
            return AnyView(
                ContentUnavailableView(
                    "Account Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The account you're looking for could not be found.")
                ),
            )
        }

        return AnyView(
            HStack(spacing: 0) {
                // Left panel - account details and analytics
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Account overview
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        AccountTypeBadge(type: account.type)

                                        Text(account.institution ?? "")
                                            .font(.headline)
                                    }

                                    if let accountNumber = account.accountNumber {
                                        Text("•••• \(String(accountNumber.suffix(4)))")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(account.balance.formatted(.currency(code: account.currencyCode)))
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(account.balance >= 0 ? .green : .red)

                                    Text("Current Balance")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Divider()

                            // Quick stats
                            Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 12) {
                                GridRow {
                                    DetailField(
                                        label: "Income",
                                        value: self.getIncomeTotal().formatted(.currency(code: account.currencyCode))
                                    )
                                    .foregroundStyle(.green)

                                    DetailField(
                                        label: "Expenses",
                                        value: self.getExpensesTotal().formatted(.currency(code: account.currencyCode))
                                    )
                                    .foregroundStyle(.red)
                                }

                                GridRow {
                                    DetailField(
                                        label: "Net Flow",
                                        value: self.getNetCashFlow().formatted(.currency(code: account.currencyCode))
                                    )
                                    .foregroundStyle(self.getNetCashFlow() >= 0 ? .green : .red)

                                    DetailField(label: "Transactions", value: "\(self.filteredTransactions.count)")
                                }

                                if let interestRate = account.interestRate, interestRate > 0 {
                                    GridRow {
                                        DetailField(label: "Interest Rate", value: "\(interestRate.formatted(.percent))")
                                            .gridCellColumns(2)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .padding()
                        .background(Color(.windowBackgroundColor).opacity(0.3))
                        .cornerRadius(8)

                        // Balance trend chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Balance Trend")
                                .font(.headline)

                            BalanceTrendChart(account: account, timeFrame: self.selectedTimeFrame)
                                .frame(height: 220)
                        }
                        .padding()
                        .background(Color(.windowBackgroundColor).opacity(0.3))
                        .cornerRadius(8)

                        // Spending breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Spending Breakdown")
                                .font(.headline)

                            SpendingBreakdownChart(transactions: self.filteredTransactions)
                                .frame(height: 280)
                        }
                        .padding()
                        .background(Color(.windowBackgroundColor).opacity(0.3))
                        .cornerRadius(8)

                        // Account notes
                        if let notes = account.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)

                                Text(notes)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.windowBackgroundColor).opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)
                        }

                        // Credit account specifics
                        if account.type == .credit {
                            CreditAccountDetailsView(account: account)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)

                Divider()

                // Right panel - transactions list
                VStack(spacing: 0) {
                    // Transactions header
                    HStack {
                        Text("Transactions")
                            .font(.headline)

                        Spacer()

                        Button(action: self.addTransaction).accessibilityLabel("Button").accessibilityLabel("Button") {
                            Label("Add", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor).opacity(0.5))

                    Divider()

                    // Transactions list
                    if self.filteredTransactions.isEmpty {
                        ContentUnavailableView {
                            Label("No Transactions", systemImage: "list.bullet")
                        } description: {
                            Text("No transactions found for this account in the selected time period.")
                        } actions: {
                            Button("Add Transaction").accessibilityLabel("Button").accessibilityLabel("Button") {
                                self.addTransaction()
                            }
                            .buttonStyle(.bordered)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List(self.filteredTransactions, selection: self.$selectedTransactionIds) {
                            self.transactionRow(for: $0)
                        }
                        .listStyle(.inset)
                    }
                }
                .frame(width: 400)
            },
        )
    }

    // MARK: - Edit View

    private func editView(for account: FinancialAccount) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit Account")
                .font(.title2)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                // Name field
                GridRow {
                    Text("Name:")
                        .gridColumnAlignment(.trailing)

                    VStack(alignment: .leading) {
                        TextField("Account name", text: Binding(
                            get: { self.editedAccount?.name ?? account.name },
                            set: { newValue in
                                self.editedAccount?.name = newValue
                                self.validateAccountName(newValue)
                            },
                        ))
                        .textFieldStyle(.roundedBorder)

                        if let error = self.validationErrors["name"] {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }

                // Type field
                GridRow {
                    Text("Type:")
                        .gridColumnAlignment(.trailing)

                    Picker("Type", selection: Binding(
                        get: { self.editedAccount?.type ?? account.type },
                        set: { self.editedAccount?.type = $0 },
                    )) {
                        Text("Checking").tag(FinancialAccount.AccountType.checking)
                        Text("Savings").tag(FinancialAccount.AccountType.savings)
                        Text("Credit").tag(FinancialAccount.AccountType.credit)
                        Text("Investment").tag(FinancialAccount.AccountType.investment)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 400)
                }

                // Balance field
                GridRow {
                    Text("Balance:")
                        .gridColumnAlignment(.trailing)

                    HStack {
                        TextField("Balance", value: Binding(
                            get: { self.editedAccount?.balance ?? account.balance },
                            set: { self.editedAccount?.balance = $0 },
                        ), format: .currency(code: account.currencyCode))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)

                        Picker("Currency", selection: Binding(
                            get: { self.editedAccount?.currencyCode ?? account.currencyCode },
                            set: { self.editedAccount?.currencyCode = $0 },
                        )) {
                            Text("USD").tag("USD")
                            Text("EUR").tag("EUR")
                            Text("GBP").tag("GBP")
                            Text("CAD").tag("CAD")
                        }
                    }
                }

                // Institution field
                GridRow {
                    Text("Institution:")
                        .gridColumnAlignment(.trailing)

                    VStack(alignment: .leading) {
                        TextField("Bank or financial institution", text: Binding(
                            get: { self.editedAccount?.institution ?? account.institution ?? "" },
                            set: { newValue in
                                self.editedAccount?.institution = newValue
                                self.validateInstitution(newValue)
                            },
                        ))
                        .textFieldStyle(.roundedBorder)

                        if let error = self.validationErrors["institution"] {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }

                // Account number field
                GridRow {
                    Text("Account Number:")
                        .gridColumnAlignment(.trailing)

                    VStack(alignment: .leading) {
                        TextField("Account number", text: Binding(
                            get: { self.editedAccount?.accountNumber ?? account.accountNumber ?? "" },
                            set: { newValue in
                                self.editedAccount?.accountNumber = newValue
                                self.validateAccountNumber(newValue)
                            },
                        ))
                        .textFieldStyle(.roundedBorder)

                        if let error = self.validationErrors["accountNumber"] {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }

                // Interest rate field (for savings or credit)
                if account.type == .savings || account.type == .credit {
                    GridRow {
                        Text("Interest Rate (%):")
                            .gridColumnAlignment(.trailing)

                        TextField("Interest rate", value: Binding(
                            get: { ((self.editedAccount?.interestRate ?? account.interestRate) ?? 0) * 100 },
                            set: { self.editedAccount?.interestRate = $0 / 100 },
                        ), format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }

                // Credit limit (for credit accounts)
                if account.type == .credit {
                    GridRow {
                        Text("Credit Limit:")
                            .gridColumnAlignment(.trailing)

                        TextField("Credit limit", value: Binding(
                            get: { self.editedAccount?.creditLimit ?? account.creditLimit ?? 0 },
                            set: { self.editedAccount?.creditLimit = $0 },
                        ), format: .currency(code: account.currencyCode))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                    }

                    GridRow {
                        Text("Due Date:")
                            .gridColumnAlignment(.trailing)

                        Picker("Due Date", selection: Binding(
                            get: { self.editedAccount?.dueDate ?? account.dueDate ?? 1 },
                            set: { self.editedAccount?.dueDate = $0 },
                        )) {
                            ForEach(1 ... 31, id: \.self) { day in
                                Text("\(day)").tag(day)
                            }
                        }
                    }
                }

                // Include in total
                GridRow {
                    Text("Include in Totals:")
                        .gridColumnAlignment(.trailing)

                    Toggle("Include this account in dashboard totals", isOn: Binding(
                        get: { self.editedAccount?.includeInTotal ?? account.includeInTotal },
                        set: { self.editedAccount?.includeInTotal = $0 },
                    ))
                }

                // Active/Inactive
                GridRow {
                    Text("Status:")
                        .gridColumnAlignment(.trailing)

                    Toggle("Account is active", isOn: Binding(
                        get: { self.editedAccount?.isActive ?? account.isActive },
                        set: { self.editedAccount?.isActive = $0 },
                    ))
                }
            }
            .padding(.bottom, 20)

            Text("Notes:")
                .padding(.top, 10)

            TextEditor(text: Binding(
                get: { self.editedAccount?.notes ?? account.notes ?? "" },
                set: { newValue in
                    self.editedAccount?.notes = newValue
                    self.validateNotes(newValue)
                },
            ))
            .font(.body)
            .frame(minHeight: 100)
            .padding(4)
            .background(Color(.textBackgroundColor))
            .cornerRadius(4)

            if let error = self.validationErrors["notes"] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }

            HStack {
                Spacer()

                Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                    self.isEditing = false
                    // Reset edited account to original
                    if let account {
                        self.editedAccount = AccountEditModel(from: account)
                    }
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.escape, modifiers: [])

                Button("Save").accessibilityLabel("Button").accessibilityLabel("Button") {
                    if self.isValidForm() {
                        self.saveChanges()
                    } else {
                        self.showingValidationAlert = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(!self.isValidForm())
            }
            .padding(.top)
        }
    }

    // MARK: - Supporting Views

    private func transactionRow(for transaction: FinancialTransaction) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.headline)

                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(transaction.amount.formatted(.currency(code: transaction.currencyCode)))
                .foregroundStyle(transaction.amount < 0 ? .red : .green)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
        .tag(transaction.id)
        .contextMenu {
            Button("View Details").accessibilityLabel("Button").accessibilityLabel("Button") {
                // Navigate to transaction detail
            }

            Button("Edit").accessibilityLabel("Button").accessibilityLabel("Button") {
                // Edit transaction
            }

            Button(
                "Mark as \(transaction.isReconciled ? "Unreconciled" : "Reconciled").accessibilityLabel("Button").accessibilityLabel("Button")"
            ) {
                self.toggleTransactionStatus(transaction)
            }

            Divider()

            Button("Delete", role: .destructive).accessibilityLabel("Button").accessibilityLabel("Button") {
                self.deleteTransaction(transaction)
            }
        }
    }

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

    private struct AccountTypeBadge: View {
        let type: FinancialAccount.AccountType

        private var text: String {
            switch self.type {
            case .checking: "Checking"
            case .savings: "Savings"
            case .credit: "Credit"
            case .investment: "Investment"
            }
        }

        private var color: Color {
            switch self.type {
            case .checking: .green
            case .savings: .blue
            case .credit: .purple
            case .investment: .orange
            }
        }

        var body: some View {
            Text(self.text)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(self.color.opacity(0.1))
                .foregroundColor(self.color)
                .cornerRadius(4)
        }
    }

    private struct BalanceTrendChart: View {
        let account: FinancialAccount
        let timeFrame: TimeFrame

        // Sample data - would be real data in actual implementation
        /// <#Description#>
        /// - Returns: <#description#>
        func generateSampleData() -> [(date: String, balance: Double)] {
            [
                (date: "Jan", balance: 1250.00),
                (date: "Feb", balance: 1450.25),
                (date: "Mar", balance: 2100.50),
                (date: "Apr", balance: 1825.75),
                (date: "May", balance: 2200.00),
                (date: "Jun", balance: self.account.balance),
            ]
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Chart {
                    ForEach(self.generateSampleData(), id: \.date) { item in
                        LineMark(
                            x: .value("Month", item.date),
                            y: .value("Balance", item.balance),
                        )
                        .foregroundStyle(.blue)
                        .symbol {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8)
                        }
                        .interpolationMethod(.catmullRom)
                    }

                    ForEach(self.generateSampleData(), id: \.date) { item in
                        PointMark(
                            x: .value("Month", item.date),
                            y: .value("Balance", item.balance),
                        )
                        .foregroundStyle(.blue)
                    }

                    // Average line
                    let average = self.generateSampleData().reduce(0) { $0 + $1.balance } / Double(self.generateSampleData().count)
                    RuleMark(y: .value("Average", average))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundStyle(.gray)
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Average: \(average.formatted(.currency(code: self.account.currencyCode)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                }

                HStack {
                    VStack(alignment: .leading) {
                        Text("Starting Balance")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$1,250.00")
                            .font(.subheadline)
                    }

                    Spacer()

                    VStack(alignment: .center) {
                        Text("Change")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("+\((self.account.balance - 1250).formatted(.currency(code: self.account.currencyCode)))")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("Current Balance")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(self.account.balance.formatted(.currency(code: self.account.currencyCode)))")
                            .font(.subheadline)
                            .bold()
                    }
                }
                .padding(.top, 10)
            }
        }
    }

    private struct SpendingBreakdownChart: View {
        let transactions: [FinancialTransaction]

        // This would normally calculate categories from actual transactions
        private var categories: [(name: String, amount: Double, color: Color)] {
            [
                ("Groceries", 450.00, .green),
                ("Dining", 320.50, .blue),
                ("Entertainment", 150.25, .purple),
                ("Shopping", 280.75, .orange),
                ("Utilities", 190.30, .red),
            ]
        }

        private var totalSpending: Double {
            self.categories.reduce(0) { $0 + $1.amount }
        }

        var body: some View {
            VStack(spacing: 20) {
                // Pie chart
                HStack {
                    ZStack {
                        PieChartView(categories: self.categories)
                            .frame(width: 180, height: 180)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(self.categories, id: \.name) { category in
                            HStack {
                                Rectangle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)

                                Text(category.name)
                                    .font(.subheadline)

                                Spacer()

                                Text(category.amount.formatted(.currency(code: "USD")))
                                    .font(.subheadline)

                                Text("(\(Int((category.amount / self.totalSpending) * 100))%)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.leading)
                }

                Divider()

                // Top merchants
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Merchants")
                        .font(.headline)

                    HStack {
                        Text("Merchant")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 120, alignment: .leading)

                        Spacer()

                        Text("Transactions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 100, alignment: .center)

                        Text("Total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 100, alignment: .trailing)
                    }

                    Divider()

                    VStack(spacing: 6) {
                        MerchantRow(name: "Whole Foods", count: 5, total: 245.75)
                        MerchantRow(name: "Amazon", count: 3, total: 157.92)
                        MerchantRow(name: "Starbucks", count: 8, total: 42.35)
                    }
                }
            }
        }

        struct MerchantRow: View {
            let name: String
            let count: Int
            let total: Double

            var body: some View {
                HStack {
                    Text(self.name)
                        .frame(width: 120, alignment: .leading)

                    Spacer()

                    Text("\(self.count)")
                        .frame(width: 100, alignment: .center)

                    Text(self.total.formatted(.currency(code: "USD")))
                        .frame(width: 100, alignment: .trailing)
                }
                .padding(.vertical, 2)
            }
        }

        struct PieChartView: View {
            let categories: [(name: String, amount: Double, color: Color)]

            var body: some View {
                let total = self.categories.reduce(0) { $0 + $1.amount }
                let sortedCategories = self.categories.sorted { $0.amount > $1.amount }

                Canvas { context, size in
                    // Define the center and radius
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = min(size.width, size.height) / 2

                    // Keep track of the start angle
                    var startAngle: Double = 0

                    // Draw each category as a pie slice
                    for category in sortedCategories {
                        let angleSize = (category.amount / total) * 360
                        let endAngle = startAngle + angleSize

                        // Create a path for the slice
                        var path = Path()
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(startAngle),
                            endAngle: .degrees(endAngle),
                            clockwise: false
                        )
                        path.closeSubpath()

                        // Fill the slice with the category color
                        context.fill(path, with: .color(category.color))

                        // Update the start angle for the next slice
                        startAngle = endAngle
                    }

                    // Add a white circle in the center for a donut chart effect
                    let innerRadius = radius * 0.6
                    let innerCirclePath = Path(ellipseIn: CGRect(
                        x: center.x - innerRadius,
                        y: center.y - innerRadius,
                        width: innerRadius * 2,
                        height: innerRadius * 2
                    ))
                    context.fill(innerCirclePath, with: .color(.white))
                }
            }
        }
    }

    private struct CreditAccountDetailsView: View {
        let account: FinancialAccount

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Credit Account Details")
                    .font(.headline)

                Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 12) {
                    GridRow {
                        DetailField(
                            label: "Credit Limit",
                            value: (self.account.creditLimit ?? 0).formatted(.currency(code: self.account.currencyCode)),
                        )

                        DetailField(
                            label: "Available Credit",
                            value: ((self.account.creditLimit ?? 0) - abs(self.account.balance))
                                .formatted(.currency(code: self.account.currencyCode)),
                        )
                    }

                    GridRow {
                        DetailField(
                            label: "Interest Rate",
                            value: ((self.account.interestRate ?? 0) * 100).formatted(.number.precision(.fractionLength(2))) + "%",
                        )

                        if let dueDate = account.dueDate {
                            DetailField(label: "Payment Due", value: "Every \(dueDate.ordinal) of month")
                        }
                    }

                    GridRow {
                        DetailField(
                            label: "Utilization",
                            value: "\(((self.account.creditLimit ?? 0) - abs(self.account.balance)) / (self.account.creditLimit ?? 1) * 100, specifier: "%.2f")%"
                        )
                        .gridCellColumns(2)
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(8)

                // Credit utilization chart
                if let creditLimit = account.creditLimit, creditLimit > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Credit Utilization")
                            .font(.subheadline)

                        ProgressView(value: abs(self.account.balance), total: creditLimit)
                            .tint(self.getCreditUtilizationColor(used: abs(self.account.balance), limit: creditLimit))

                        HStack {
                            Text("Used: \(abs(self.account.balance).formatted(.currency(code: self.account.currencyCode)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text("Limit: \(creditLimit.formatted(.currency(code: self.account.currencyCode)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor).opacity(0.3))
            .cornerRadius(8)
        }

        private func getCreditUtilizationColor(used: Double, limit: Double) -> Color {
            let percentage = used / limit
            if percentage < 0.3 {
                return .green
            } else if percentage < 0.7 {
                return .yellow
            } else {
                return .red
            }
        }
    }

    private struct ExportOptionsView: View {
        let account: FinancialAccount?
        let transactions: [FinancialTransaction]
        @State private var exportFormat: ExportFormat = .csv
        @State private var dateRange: DateRange = .all
        @State private var customStartDate = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        @State private var customEndDate = Date()
        @Environment(\.dismiss) private var dismiss

        enum ExportFormat: String, CaseIterable {
            case csv = "CSV"
            case pdf = "PDF"
            case qif = "QIF"
        }

        enum DateRange: String, CaseIterable {
            case last30Days = "Last 30 Days"
            case last90Days = "Last 90 Days"
            case thisYear = "This Year"
            case custom = "Custom Range"
            case all = "All Transactions"
        }

        var body: some View {
            VStack(spacing: 20) {
                Text("Export Account Transactions")
                    .font(.title2)
                    .padding(.vertical)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export Format")
                            .font(.headline)

                        Picker("Format", selection: self.$exportFormat) {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 300)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date Range")
                            .font(.headline)

                        Picker("Date Range", selection: self.$dateRange) {
                            ForEach(DateRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 400)
                    }

                    if self.dateRange == .custom {
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("Start Date")
                                    .font(.subheadline)
                                DatePicker("", selection: self.$customStartDate, displayedComponents: .date)
                                    .labelsHidden()
                            }

                            VStack(alignment: .leading) {
                                Text("End Date")
                                    .font(.subheadline)
                                DatePicker("", selection: self.$customEndDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export Details")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Account Name: \(self.account?.name ?? "Unknown")")
                            Text("• Transaction Count: \(self.transactions.count)")
                            Text("• Fields: Date, Description, Category, Amount, Balance")

                            if self.exportFormat == .pdf {
                                Text("• Includes account summary and balance chart")
                            }
                        }
                        .font(.subheadline)
                    }
                }

                Spacer()

                HStack {
                    Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.dismiss()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Export").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.performExport()
                        self.dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top)
            }
            .padding()
        }

        private func performExport() {
            // Export logic would go here
        }
    }

    // MARK: - Supporting Models

    private struct AccountEditModel {
        var name: String
        var type: FinancialAccount.AccountType
        var balance: Double
        var currencyCode: String
        var institution: String?
        var accountNumber: String?
        var interestRate: Double?
        var creditLimit: Double?
        var dueDate: Int?
        var includeInTotal: Bool
        var isActive: Bool
        var notes: String?

        init(from account: FinancialAccount) {
            self.name = account.name
            self.type = account.type
            self.balance = account.balance
            self.currencyCode = account.currencyCode
            self.institution = account.institution
            self.accountNumber = account.accountNumber
            self.interestRate = account.interestRate
            self.creditLimit = account.creditLimit
            self.dueDate = account.dueDate
            self.includeInTotal = account.includeInTotal
            self.isActive = account.isActive
            self.notes = account.notes
        }
    }

    // MARK: - Helper Methods

    private func isTransactionInSelectedTimeFrame(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()

        switch self.selectedTimeFrame {
        case .last30Days:
            guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) else { return false }
            return date >= thirtyDaysAgo && date <= today
        case .last90Days:
            guard let ninetyDaysAgo = calendar.date(byAdding: .day, value: -90, to: today) else { return false }
            return date >= ninetyDaysAgo && date <= today
        case .thisYear:
            var components = calendar.dateComponents([.year], from: today)
            guard let startOfYear = calendar.date(from: components) else { return false }
            return date >= startOfYear && date <= today
        case .lastYear:
            var componentsThisYear = calendar.dateComponents([.year], from: today)
            guard let startOfThisYear = calendar.date(from: componentsThisYear),
                  let startOfLastYear = calendar.date(byAdding: .year, value: -1, to: startOfThisYear),
                  let endOfLastYear = calendar.date(byAdding: .day, value: -1, to: startOfThisYear) else { return false }
            return date >= startOfLastYear && date <= endOfLastYear
        case .allTime:
            return true
        }
    }

    private func getIncomeTotal() -> Double {
        self.filteredTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }

    private func getExpensesTotal() -> Double {
        self.filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
    }

    private func getNetCashFlow() -> Double {
        self.getIncomeTotal() - self.getExpensesTotal()
    }

    // MARK: - Action Methods

    private func saveChanges() {
        guard let account, let editData = editedAccount else {
            self.isEditing = false
            return
        }

        // Update account with edited values
        account.name = editData.name
        account.type = editData.type
        account.balance = editData.balance
        account.currencyCode = editData.currencyCode
        account.institution = editData.institution
        account.accountNumber = editData.accountNumber
        account.interestRate = editData.interestRate
        account.creditLimit = editData.creditLimit
        account.dueDate = editData.dueDate
        account.includeInTotal = editData.includeInTotal
        account.isActive = editData.isActive
        account.notes = editData.notes

        // Save changes to the model context
        try? self.modelContext.save()

        self.isEditing = false
    }

    private func deleteAccount() {
        guard let account else { return }

        // First delete all associated transactions
        for transaction in self.filteredTransactions {
            self.modelContext.delete(transaction)
        }

        // Then delete the account
        self.modelContext.delete(account)
        try? self.modelContext.save()

        // Navigate back would happen here
    }

    private func addTransaction() {
        guard let account else { return }

        // Create a new transaction
        let transaction = FinancialTransaction(
            name: "New Transaction",
            amount: 0,
            date: Date(),
            notes: "",
            isReconciled: false,
        )

        // Set the account relationship
        transaction.account = account

        // Add transaction to the model context
        self.modelContext.insert(transaction)
        try? self.modelContext.save()

        // Ideally navigate to this transaction for editing
    }

    private func toggleTransactionStatus(_ transaction: FinancialTransaction) {
        transaction.isReconciled.toggle()
        try? self.modelContext.save()
    }

    private func deleteTransaction(_ transaction: FinancialTransaction) {
        self.modelContext.delete(transaction)
        try? self.modelContext.save()
    }

    private func printAccountSummary() {
        // Implementation for printing
    }

    // MARK: - Validation Methods

    private func validateAccountName(_ name: String) {
        do {
            try InputValidator.validateTextInput(name, maxLength: 100)
            self.validationErrors.removeValue(forKey: "name")
        } catch {
            self.validationErrors["name"] = error.localizedDescription
        }
    }

    private func validateInstitution(_ institution: String) {
        do {
            try InputValidator.validateTextInput(institution, maxLength: 100)
            self.validationErrors.removeValue(forKey: "institution")
        } catch {
            self.validationErrors["institution"] = error.localizedDescription
        }
    }

    private func validateAccountNumber(_ number: String) {
        do {
            try InputValidator.validateTextInput(number, maxLength: 50)
            self.validationErrors.removeValue(forKey: "accountNumber")
        } catch {
            self.validationErrors["accountNumber"] = error.localizedDescription
        }
    }

    private func validateNotes(_ notes: String) {
        do {
            try InputValidator.validateTextInput(notes, maxLength: 1000)
            self.validationErrors.removeValue(forKey: "notes")
        } catch {
            self.validationErrors["notes"] = error.localizedDescription
        }
    }

    private func isValidForm() -> Bool {
        self.validationErrors.isEmpty
    }
}

// Extension to add ordinal suffix to numbers
extension Int {
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
#endif
