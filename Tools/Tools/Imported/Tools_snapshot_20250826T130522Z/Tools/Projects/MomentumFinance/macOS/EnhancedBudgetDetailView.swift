// Momentum Finance - Enhanced Budget Detail View for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import SwiftData
import SwiftUI

#if os(macOS)
    extension Features.Budgets {
        /// Enhanced budget detail view optimized for macOS screen real estate
        struct EnhancedBudgetDetailView: View {
            let budgetId: String

            @Environment(\.modelContext) private var modelContext
            @Query private var budgets: [Budget]
            @Query private var transactions: [FinancialTransaction]
            @Query private var categories: [ExpenseCategory]
            @State private var isEditing = false
            @State private var editedBudget: BudgetEditModel?
            @State private var selectedTransactions: Set<String> = []
            @State private var selectedTimeFrame: TimeFrame = .currentMonth
            @State private var showingDeleteConfirmation = false

            private var budget: Budget? {
                budgets.first(where: { $0.id == budgetId })
            }

            private var relatedTransactions: [FinancialTransaction] {
                guard let budget, let categoryId = budget.category?.id else { return [] }

                let relevantTransactions = transactions.filter {
                    $0.category?.id == categoryId &&
                        $0.amount < 0 && // Only expenses
                        isTransactionInSelectedTimeFrame($0.date)
                }

                return relevantTransactions.sorted { $0.date > $1.date }
            }

            enum TimeFrame: String, CaseIterable, Identifiable {
                case currentMonth = "This Month"
                case lastMonth = "Last Month"
                case last3Months = "Last 3 Months"
                case last6Months = "Last 6 Months"
                case yearToDate = "Year to Date"
                case custom = "Custom Range"

                var id: String { self.rawValue }
            }

            var body: some View {
                VStack(spacing: 0) {
                    // Top toolbar with actions
                    HStack {
                        if let budget {
                            Text(budget.name)
                                .font(.title)
                                .bold()
                        }

                        Spacer()

                        Picker("Time Frame", selection: $selectedTimeFrame) {
                            ForEach(TimeFrame.allCases) { timeFrame in
                                Text(timeFrame.rawValue).tag(timeFrame)
                            }
                        }
                        .frame(width: 180)

                        Button(action: { isEditing.toggle() }) {
                            Text(isEditing ? "Done" : "Edit")
                        }
                        .keyboardShortcut("e", modifiers: .command)

                        Menu {
                            Button("Export as PDF", action: exportAsPDF)
                            Button("Print", action: printBudget)
                            Divider()
                            Button("Delete", role: .destructive) {
                                showingDeleteConfirmation = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))

                    Divider()

                    if isEditing, let budget {
                        editView(for: budget)
                            .padding()
                            .transition(.opacity)
                    } else {
                        detailView()
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .alert("Delete Budget", isPresented: $showingDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        deleteBudget()
                    }
                } message: {
                    Text("Are you sure you want to delete this budget? This action cannot be undone.")
                }
                .onAppear {
                    // Initialize edit model if needed
                    if let budget, editedBudget == nil {
                        editedBudget = BudgetEditModel(from: budget)
                    }
                }
            }

            // MARK: - Detail View

            private func detailView() -> some View {
                guard let budget else {
                    return AnyView(
                        ContentUnavailableView("Budget Not Found",
                                               systemImage: "exclamationmark.triangle",
                                               description: Text("The budget you're looking for could not be found.")),
                    )
                }

                return AnyView(
                    HStack(spacing: 0) {
                        // Left panel - budget details and progress
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                // Budget overview
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            if let category = budget.category {
                                                CategoryBadge(category: category)
                                                    .padding(.bottom, 4)
                                            }

                                            Text(getTimeFrameDescription())
                                                .font(.headline)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(budget.amount.formatted(.currency(code: "USD")))
                                                .font(.system(size: 28, weight: .bold))

                                            Text("Budget Limit")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Divider()

                                    // Budget progress visualization
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Budget Progress")
                                                .font(.headline)

                                            Spacer()

                                            Text("\(budget.spent.formatted(.currency(code: "USD"))) of \(budget.amount.formatted(.currency(code: "USD")))")
                                        }

                                        ProgressView(value: budget.spent, total: budget.amount)
                                            .tint(getBudgetColor(spent: budget.spent, total: budget.amount))
                                            .scaleEffect(y: 2.0)
                                            .padding(.vertical, 8)

                                        HStack {
                                            Text("Remaining: \((budget.amount - budget.spent).formatted(.currency(code: "USD")))")
                                                .foregroundStyle(.secondary)

                                            Spacer()

                                            Text("\(Int((budget.spent / budget.amount) * 100))%")
                                                .foregroundStyle(getBudgetColor(spent: budget.spent, total: budget.amount))
                                                .bold()
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)

                                // Daily spending allowance
                                DailyAllowanceView(budget: budget)

                                // Spending trend chart
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Spending Trends")
                                        .font(.headline)

                                    SpendingTrendChart(budget: budget, timeFrame: selectedTimeFrame)
                                        .frame(height: 220)
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)

                                // Category analysis (if applicable)
                                if let category = budget.category, !category.name.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Category Analysis: \(category.name)")
                                            .font(.headline)

                                        CategoryAnalysisChart(category: category)
                                            .frame(height: 180)

                                        Divider()

                                        // Category stats
                                        Grid(alignment: .leading, horizontalSpacing: 32) {
                                            GridRow {
                                                Text("Average Monthly:")
                                                    .foregroundStyle(.secondary)
                                                    .gridColumnAlignment(.trailing)

                                                Text("$347.82")
                                            }

                                            GridRow {
                                                Text("Monthly Change:")
                                                    .foregroundStyle(.secondary)
                                                    .gridColumnAlignment(.trailing)

                                                Text("+12.4%")
                                                    .foregroundStyle(.orange)
                                            }

                                            GridRow {
                                                Text("Top Merchant:")
                                                    .foregroundStyle(.secondary)
                                                    .gridColumnAlignment(.trailing)

                                                Text("Whole Foods ($128.45)")
                                            }
                                        }
                                        .padding(.top, 8)
                                    }
                                    .padding()
                                    .background(Color(.windowBackgroundColor).opacity(0.3))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)

                        Divider()

                        // Right panel - related transactions
                        VStack(spacing: 0) {
                            // Transactions header
                            HStack {
                                Text("Related Transactions")
                                    .font(.headline)

                                Spacer()

                                Button(action: addTransaction) {
                                    Label("Add", systemImage: "plus")
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.5))

                            Divider()

                            // Transactions list
                            if relatedTransactions.isEmpty {
                                ContentUnavailableView {
                                    Label("No Transactions", systemImage: "list.bullet")
                                } description: {
                                    Text("No transactions found in this category for the selected time period.")
                                } actions: {
                                    Button("Add Transaction") {
                                        addTransaction()
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .frame(maxHeight: .infinity)
                            } else {
                                List(relatedTransactions, selection: $selectedTransactions) {
                                    transactionRow(for: $0)
                                }
                                .listStyle(.inset)
                            }
                        }
                        .frame(width: 400)
                    },
                )
            }

            // MARK: - Edit View

            private func editView(for budget: Budget) -> some View {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Edit Budget")
                        .font(.title2)

                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                        // Name field
                        GridRow {
                            Text("Name:")
                                .gridColumnAlignment(.trailing)

                            TextField("Budget name", text: Binding(
                                get: { self.editedBudget?.name ?? budget.name },
                                set: { self.editedBudget?.name = $0 },
                            ))
                            .textFieldStyle(.roundedBorder)
                        }

                        // Amount field
                        GridRow {
                            Text("Amount:")
                                .gridColumnAlignment(.trailing)

                            HStack {
                                TextField("Amount", value: Binding(
                                    get: { self.editedBudget?.amount ?? budget.amount },
                                    set: { self.editedBudget?.amount = $0 },
                                ), format: .currency(code: "USD"))
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 150)
                            }
                        }

                        // Category field
                        GridRow {
                            Text("Category:")
                                .gridColumnAlignment(.trailing)

                            VStack {
                                Picker("Category", selection: Binding(
                                    get: { self.editedBudget?.categoryId ?? budget.category?.id ?? "" },
                                    set: { self.editedBudget?.categoryId = $0 },
                                )) {
                                    Text("None").tag("")
                                    ForEach(categories) { category in
                                        Text(category.name).tag(category.id)
                                    }
                                }
                                .labelsHidden()
                            }
                        }

                        // Period field
                        GridRow {
                            Text("Period:")
                                .gridColumnAlignment(.trailing)

                            Picker("Period", selection: Binding(
                                get: { self.editedBudget?.period ?? budget.period },
                                set: { self.editedBudget?.period = $0 },
                            )) {
                                Text("Monthly").tag("monthly")
                                Text("Weekly").tag("weekly")
                                Text("Annual").tag("annual")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 300)
                        }

                        // Reset options
                        GridRow {
                            Text("Reset:")
                                .gridColumnAlignment(.trailing)

                            Picker("Reset", selection: Binding(
                                get: { self.editedBudget?.resetOption ?? "monthly" },
                                set: { self.editedBudget?.resetOption = $0 },
                            )) {
                                Text("Monthly").tag("monthly")
                                Text("Never (Continuous)").tag("never")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 300)
                        }

                        // Rollover option
                        GridRow {
                            Text("Rollover:")
                                .gridColumnAlignment(.trailing)

                            Toggle("Roll over unused budget to next period", isOn: Binding(
                                get: { self.editedBudget?.rollover ?? budget.rollover },
                                set: { self.editedBudget?.rollover = $0 },
                            ))
                        }
                    }
                    .padding(.bottom, 20)

                    Text("Notes:")
                        .padding(.top, 10)

                    TextEditor(text: Binding(
                        get: { self.editedBudget?.notes ?? budget.notes },
                        set: { self.editedBudget?.notes = $0 },
                    ))
                    .font(.body)
                    .frame(minHeight: 100)
                    .padding(4)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(4)

                    HStack {
                        Spacer()

                        Button("Cancel") {
                            isEditing = false
                            // Reset edited budget to original
                            if let budget {
                                editedBudget = BudgetEditModel(from: budget)
                            }
                        }
                        .buttonStyle(.bordered)
                        .keyboardShortcut(.escape, modifiers: [])

                        Button("Save") {
                            saveChanges()
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return, modifiers: .command)
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

                    Text(transaction.amount.formatted(.currency(code: "USD")))
                        .foregroundStyle(transaction.amount < 0 ? .red : .green)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
                .contextMenu {
                    Button("View Details") {
                        // Navigate to transaction detail
                    }

                    Button("Edit") {
                        // Edit transaction
                    }

                    Divider()

                    Button("Exclude from Budget", role: .destructive) {
                        // Remove from budget calculations
                    }
                }
            }

            private struct CategoryBadge: View {
                let category: ExpenseCategory

                var body: some View {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(getCategoryColor(category.colorHex))
                            .frame(width: 12, height: 12)

                        Text(category.name)
                            .font(.headline)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(getCategoryColor(category.colorHex).opacity(0.1))
                    .cornerRadius(6)
                }

                private func getCategoryColor(_ hex: String?) -> Color {
                    guard let hex else { return .gray }
                    // This would parse the hex color string
                    return .blue
                }
            }

            private struct DailyAllowanceView: View {
                let budget: Budget

                var daysInMonth: Int {
                    let calendar = Calendar.current
                    let date = Date()
                    let range = calendar.range(of: .day, in: .month, for: date)!
                    return range.count
                }

                var daysRemaining: Int {
                    let calendar = Calendar.current
                    let date = Date()
                    let day = calendar.component(.day, from: date)
                    return daysInMonth - day + 1 // Including today
                }

                var dailyAllowance: Double {
                    let remaining = budget.amount - budget.spent
                    return remaining > 0 ? remaining / Double(daysRemaining) : 0
                }

                var body: some View {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily Spending Allowance")
                            .font(.headline)

                        HStack(alignment: .top, spacing: 20) {
                            VStack(alignment: .center, spacing: 8) {
                                Text("\((budget.amount - budget.spent).formatted(.currency(code: "USD")))")
                                    .font(.system(size: 20, weight: .bold))

                                Text("Remaining")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)

                            Divider()

                            VStack(alignment: .center, spacing: 8) {
                                Text("\(daysRemaining)")
                                    .font(.system(size: 20, weight: .bold))

                                Text("Days Left")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)

                            Divider()

                            VStack(alignment: .center, spacing: 8) {
                                Text("\(dailyAllowance.formatted(.currency(code: "USD")))")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(dailyAllowance > 10 ? .green : .orange)

                                Text("Per Day")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color(.windowBackgroundColor).opacity(0.2))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(8)
                }
            }

            private struct SpendingTrendChart: View {
                let budget: Budget
                let timeFrame: TimeFrame

                // Sample data - would be real data in actual implementation
                let dailyData = [
                    (day: "1", amount: 18.50),
                    (day: "5", amount: 42.30),
                    (day: "10", amount: 15.75),
                    (day: "15", amount: 120.00),
                    (day: "20", amount: 87.25),
                    (day: "25", amount: 25.50),
                    (day: "30", amount: 15.20),
                ]

                var body: some View {
                    VStack(alignment: .leading, spacing: 8) {
                        Chart {
                            // Daily spending bars
                            ForEach(dailyData, id: \.day) { item in
                                BarMark(
                                    x: .value("Day", item.day),
                                    y: .value("Amount", item.amount),
                                )
                                .foregroundStyle(Color.blue.gradient)
                            }

                            // Budget limit reference line
                            RuleMark(y: .value("Daily Budget", budget.amount / 30.0))
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                                .foregroundStyle(.red)
                                .annotation(position: .top, alignment: .trailing) {
                                    Text("Daily Budget: \((budget.amount / 30.0).formatted(.currency(code: "USD")))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                        }

                        HStack {
                            VStack(alignment: .leading) {
                                Text("Average Daily")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("$32.15")
                                    .font(.headline)
                            }

                            Spacer()

                            VStack(alignment: .center) {
                                Text("Total Transactions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("7")
                                    .font(.headline)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text("Highest Day")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("$120.00 (15th)")
                                    .font(.headline)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }

            private struct CategoryAnalysisChart: View {
                let category: ExpenseCategory

                // Sample data - would be real data in actual implementation
                let monthlyData = [
                    (month: "Jan", amount: 312.50),
                    (month: "Feb", amount: 342.30),
                    (month: "Mar", amount: 295.75),
                    (month: "Apr", amount: 420.00),
                    (month: "May", amount: 387.25),
                    (month: "Jun", amount: 345.50),
                ]

                var body: some View {
                    Chart {
                        ForEach(monthlyData, id: \.month) { item in
                            LineMark(
                                x: .value("Month", item.month),
                                y: .value("Amount", item.amount),
                            )
                            .foregroundStyle(.blue)
                            .symbol {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 8)
                            }
                            .interpolationMethod(.catmullRom)
                        }

                        ForEach(monthlyData, id: \.month) { item in
                            PointMark(
                                x: .value("Month", item.month),
                                y: .value("Amount", item.amount),
                            )
                            .foregroundStyle(.blue)
                        }

                        RuleMark(y: .value("Average", 350.55))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .foregroundStyle(.gray)
                            .annotation(position: .top, alignment: .trailing) {
                                Text("Average: $350.55")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }

            // MARK: - Supporting Models

            private struct BudgetEditModel {
                var name: String
                var amount: Double
                var categoryId: String
                var period: String
                var notes: String
                var resetOption: String
                var rollover: Bool

                init(from budget: Budget) {
                    self.name = budget.name
                    self.amount = budget.amount
                    self.categoryId = budget.category?.id ?? ""
                    self.period = budget.period
                    self.notes = budget.notes
                    self.resetOption = "monthly" // Default
                    self.rollover = budget.rollover
                }
            }

            // MARK: - Helper Methods

            private func getBudgetColor(spent: Double, total: Double) -> Color {
                let percentage = spent / total
                if percentage < 0.7 {
                    return .green
                } else if percentage < 0.9 {
                    return .yellow
                } else {
                    return .red
                }
            }

            private func isTransactionInSelectedTimeFrame(_ date: Date) -> Bool {
                let calendar = Calendar.current
                let today = Date()

                switch selectedTimeFrame {
                case .currentMonth:
                    return calendar.isDate(date, equalTo: today, toGranularity: .month)
                case .lastMonth:
                    guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: today) else { return false }
                    return calendar.isDate(date, equalTo: lastMonth, toGranularity: .month)
                case .last3Months:
                    guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: today) else { return false }
                    return date >= threeMonthsAgo && date <= today
                case .last6Months:
                    guard let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: today) else { return false }
                    return date >= sixMonthsAgo && date <= today
                case .yearToDate:
                    let components = calendar.dateComponents([.year], from: today)
                    guard let startOfYear = calendar.date(from: components) else { return false }
                    return date >= startOfYear && date <= today
                case .custom:
                    // Custom date range would be handled here
                    return true
                }
            }

            private func getTimeFrameDescription() -> String {
                switch selectedTimeFrame {
                case .currentMonth:
                    return "Budget for \(Date().formatted(.dateTime.month(.wide).year()))"
                case .lastMonth:
                    guard let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
                        return "Last Month"
                    }
                    return "Budget for \(lastMonth.formatted(.dateTime.month(.wide).year()))"
                case .last3Months:
                    return "Last 3 Months"
                case .last6Months:
                    return "Last 6 Months"
                case .yearToDate:
                    return "Year to Date (\(Date().formatted(.dateTime.year())))"
                case .custom:
                    return "Custom Date Range"
                }
            }

            // MARK: - Action Methods

            private func saveChanges() {
                guard let budget, let editData = editedBudget else {
                    isEditing = false
                    return
                }

                // Update budget with edited values
                budget.name = editData.name
                budget.amount = editData.amount
                budget.period = editData.period
                budget.notes = editData.notes
                budget.rollover = editData.rollover

                // Category relationship would be handled here

                // Save changes to the model context
                try? modelContext.save()

                isEditing = false
            }

            private func deleteBudget() {
                guard let budget else { return }

                // Delete the budget from the model context
                modelContext.delete(budget)
                try? modelContext.save()

                // Navigate back would happen here
            }

            private func addTransaction() {
                // Logic to add a new transaction to this budget/category
            }

            private func exportAsPDF() {
                // Implementation for PDF export
            }

            private func printBudget() {
                // Implementation for printing
            }
        }
    }
#endif
