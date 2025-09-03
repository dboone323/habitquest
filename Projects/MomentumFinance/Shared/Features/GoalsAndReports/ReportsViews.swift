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

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

struct ReportsSection: View {
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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Timeframe Picker
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Financial Summary Card
                FinancialSummaryCard(
                    transactions: filteredTransactions,
                    timeframe: selectedTimeframe,
<<<<<<< HEAD
                    )
=======
                )
>>>>>>> 1cf3938 (Create working state for recovery)
                .padding(.horizontal)

                // Spending by Category Chart
                SpendingByCategoryCard(
                    transactions: filteredTransactions,
                    categories: categories,
<<<<<<< HEAD
                    )
=======
                )
>>>>>>> 1cf3938 (Create working state for recovery)
                .padding(.horizontal)

                // Budget Performance Card
                if !budgets.isEmpty {
                    BudgetPerformanceCard(budgets: currentPeriodBudgets)
                        .padding(.horizontal)
                }

                // Recent Transactions
                RecentTransactionsCard(transactions: Array(filteredTransactions.prefix(5)))
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var filteredTransactions: [FinancialTransaction] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedTimeframe {
        case .thisWeek:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
                return transactions
            }
            return transactions.filter { weekInterval.contains($0.date) }

        case .thisMonth:
<<<<<<< HEAD
            return transactions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
=======
            return transactions.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .month)
            }
>>>>>>> 1cf3938 (Create working state for recovery)

        case .last3Months:
            guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) else {
                return transactions
            }
            return transactions.filter { $0.date >= threeMonthsAgo }

        case .thisYear:
<<<<<<< HEAD
            return transactions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .year) }
=======
            return transactions.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .year)
            }
>>>>>>> 1cf3938 (Create working state for recovery)
        }
    }

    private var currentPeriodBudgets: [Budget] {
        let calendar = Calendar.current
        let now = Date()

        return budgets.filter { budget in
            calendar.isDate(budget.month, equalTo: now, toGranularity: .month)
        }
    }
}

struct FinancialSummaryCard: View {
    let transactions: [FinancialTransaction]
    let timeframe: ReportsSection.TimeFrame

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

    private var totalIncome: Double {
        transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalExpenses: Double {
        transactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var netIncome: Double {
        totalIncome - totalExpenses
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Financial Summary - \(timeframe.rawValue)")
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(totalIncome.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Expenses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(totalExpenses.formatted(.currency(code: "USD")))
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
                    Text(netIncome.formatted(.currency(code: "USD")))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(netIncome >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SpendingByCategoryCard: View {
    let transactions: [FinancialTransaction]
    let categories: [ExpenseCategory]

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

    private var expenseTransactions: [FinancialTransaction] {
        transactions.filter { $0.transactionType == .expense }
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
        categorySpending.reduce(0) { $0 + $1.1 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.headline)
                .foregroundColor(.primary)

            if categorySpending.isEmpty {
                Text("No expenses in this period")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(categorySpending.prefix(5)), id: \.0) { category, amount in
                        HStack {
                            Text(category)
                                .font(.body)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(amount.formatted(.currency(code: "USD")))
                                    .font(.body)
                                    .fontWeight(.medium)

                                if totalSpending > 0 {
                                    Text("\(Int((amount / totalSpending) * 100))%")
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
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct BudgetPerformanceCard: View {
    let budgets: [Budget]

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

    private var onTrackBudgets: [Budget] {
        budgets.filter { !$0.isOverBudget }
    }

    private var overBudgets: [Budget] {
        budgets.filter(\.isOverBudget)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Performance")
                .font(.headline)
                .foregroundColor(.primary)

            if budgets.isEmpty {
                Text("No budgets set for this month")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    HStack {
<<<<<<< HEAD
                        Label("\(onTrackBudgets.count) On Track", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
=======
                        Label(
                            "\(onTrackBudgets.count) On Track", systemImage: "checkmark.circle.fill"
                        )
                        .foregroundColor(.green)
>>>>>>> 1cf3938 (Create working state for recovery)

                        Spacer()

                        if !overBudgets.isEmpty {
<<<<<<< HEAD
                            Label("\(overBudgets.count) Over Budget", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
=======
                            Label(
                                "\(overBudgets.count) Over Budget",
                                systemImage: "exclamationmark.triangle.fill"
                            )
                            .foregroundColor(.red)
>>>>>>> 1cf3938 (Create working state for recovery)
                        }
                    }

                    if !overBudgets.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Categories Over Budget:")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            ForEach(overBudgets.prefix(3), id: \.createdDate) { budget in
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
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct RecentTransactionsCard: View {
    let transactions: [FinancialTransaction]

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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.headline)
                .foregroundColor(.primary)

            if transactions.isEmpty {
                Text("No transactions in this period")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(transactions, id: \.date) { transaction in
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
<<<<<<< HEAD
                                .foregroundColor(transaction.transactionType == .income ? .green : .red)
=======
                                .foregroundColor(
                                    transaction.transactionType == .income ? .green : .red)
>>>>>>> 1cf3938 (Create working state for recovery)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
