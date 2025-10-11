import AppKit
import SwiftUI

#if canImport(AppKit)
#endif

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

public struct ReportsSection: View {
    let transactions: [FinancialTransaction]
    let budgets: [Budget]
    let categories: [ExpenseCategory]

    @State private var selectedTimeframe: TimeFrame = .thisMonth

    enum TimeFrame: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case last3Months = "Last 3 Months"
        case thisYear = "This Year"
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Timeframe Picker
                Picker("Timeframe", selection: self.$selectedTimeframe) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Financial Summary Card
                FinancialSummaryCard(
                    transactions: self.filteredTransactions,
                    timeframe: self.selectedTimeframe,
                )
                .padding(.horizontal)

                // Spending by Category Chart
                SpendingByCategoryCard(
                    transactions: self.filteredTransactions,
                    categories: self.categories,
                )
                .padding(.horizontal)

                // Budget Performance Card
                if !self.budgets.isEmpty {
                    BudgetPerformanceCard(budgets: self.currentPeriodBudgets)
                        .padding(.horizontal)
                }

                // Recent Transactions
                RecentTransactionsCard(transactions: Array(self.filteredTransactions.prefix(5)))
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var filteredTransactions: [FinancialTransaction] {
        let calendar = Calendar.current
        let now = Date()

        switch self.selectedTimeframe {
        case .thisWeek:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
                return self.transactions
            }
            return self.transactions.filter { weekInterval.contains($0.date) }

        case .thisMonth:
            return self.transactions.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .month)
            }

        case .last3Months:
            guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) else {
                return self.transactions
            }
            return self.transactions.filter { $0.date >= threeMonthsAgo }

        case .thisYear:
            return self.transactions.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .year)
            }
        }
    }

    private var currentPeriodBudgets: [Budget] {
        let calendar = Calendar.current
        let now = Date()

        return self.budgets.filter { budget in
            calendar.isDate(budget.month, equalTo: now, toGranularity: .month)
        }
    }
}

public struct FinancialSummaryCard: View {
    let transactions: [FinancialTransaction]
    let timeframe: ReportsSection.TimeFrame

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

    private var totalIncome: Double {
        self.transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalExpenses: Double {
        self.transactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var netIncome: Double {
        self.totalIncome - self.totalExpenses
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Financial Summary - \(self.timeframe.rawValue)")
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(self.totalIncome.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Expenses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(self.totalExpenses.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Net Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(self.netIncome.formatted(.currency(code: "USD")))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(self.netIncome >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(self.backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

public struct SpendingByCategoryCard: View {
    let transactions: [FinancialTransaction]
    let categories: [ExpenseCategory]

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

    private var expenseTransactions: [FinancialTransaction] {
        self.transactions.filter { $0.transactionType == .expense }
    }

    private var categorySpending: [(String, Double)] {
        let spending = Dictionary(grouping: expenseTransactions) { transaction in
            transaction.category?.name ?? "Uncategorized"
        }.mapValues { transactions in
            transactions.reduce(0) { $0 + $1.amount }
        }

        return spending.sorted { $0.value > $1.value }
    }

    private var totalSpending: Double {
        self.categorySpending.reduce(0) { $0 + $1.1 }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.headline)
                .foregroundColor(.primary)

            if self.categorySpending.isEmpty {
                Text("No expenses in this period")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(self.categorySpending.prefix(5)), id: \.0) { category, amount in
                        HStack {
                            Text(category)
                                .font(.body)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(amount.formatted(.currency(code: "USD")))
                                    .font(.body)
                                    .fontWeight(.medium)

                                if self.totalSpending > 0 {
                                    Text("\(Int((amount / self.totalSpending) * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(self.backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

public struct BudgetPerformanceCard: View {
    let budgets: [Budget]

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

    private var onTrackBudgets: [Budget] {
        self.budgets.filter { !$0.isOverBudget }
    }

    private var overBudgets: [Budget] {
        self.budgets.filter(\.isOverBudget)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Performance")
                .font(.headline)
                .foregroundColor(.primary)

            if self.budgets.isEmpty {
                Text("No budgets set for this month")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    HStack {
                        Label(
                            "\(self.onTrackBudgets.count) On Track",
                            systemImage: "checkmark.circle.fill"
                        )
                        .foregroundColor(.green)

                        Spacer()

                        if !self.overBudgets.isEmpty {
                            Label(
                                "\(self.overBudgets.count) Over Budget",
                                systemImage: "exclamationmark.triangle.fill"
                            )
                            .foregroundColor(.red)
                        }
                    }

                    if !self.overBudgets.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Categories Over Budget:")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            ForEach(self.overBudgets.prefix(3), id: \.createdDate) { budget in
                                HStack {
                                    Text(budget.category?.name ?? "Unknown")
                                        .font(.caption)
                                    Spacer()
                                    let overAmount = budget.spentAmount - budget.limitAmount
                                    Text("Over by \(overAmount.formatted(.currency(code: "USD")))")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
        }
        .padding()
        .background(self.backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

public struct RecentTransactionsCard: View {
    let transactions: [FinancialTransaction]

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

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.headline)
                .foregroundColor(.primary)

            if self.transactions.isEmpty {
                Text("No transactions in this period")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(self.transactions, id: \.date) { transaction in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(transaction.title)
                                    .font(.body)
                                    .fontWeight(.medium)

                                Text(transaction.formattedDate)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(transaction.formattedAmount)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(
                                    transaction.transactionType == .income ? .green : .red
                                )
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(self.backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
