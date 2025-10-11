import AppKit
import SwiftUI

#if canImport(AppKit)
#endif

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

extension Features.GoalsAndReports {
    struct EnhancedReportsSection: View {
        let transactions: [FinancialTransaction]
        let budgets: [Budget]
        let categories: [ExpenseCategory]

        @State private var selectedTimeframe: TimeFrame = .thisMonth

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

        enum TimeFrame: String, CaseIterable {
            case thisWeek = "This Week"
            case thisMonth = "This Month"
            case last3Months = "Last 3 Months"
            case thisYear = "This Year"
        }

        var body: some View {
            ScrollView {
                LazyVStack(spacing: 20) {
                    self.headerSection

                    if !self.filteredTransactions.isEmpty {
                        self.contentSection
                    } else {
                        self.emptyStateSection
                    }
                }
                .padding(.vertical)
            }
            .background(self.backgroundColor)
        }

        private var headerSection: some View {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Financial Reports")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text("Analyze your financial patterns")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                self.timeframePicker
            }
            .padding(.horizontal)
        }

        private var timeframePicker: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        self.timeframeButton(for: timeframe)
                    }
                }
                .padding(.horizontal)
            }
        }

        private func timeframeButton(for timeframe: TimeFrame) -> some View {
            let isSelected = self.selectedTimeframe == timeframe

            return Button(timeframe.rawValue) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.selectedTimeframe = timeframe
                }
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(self.buttonBackground(isSelected: isSelected))
            .accessibilityLabel("Timeframe: \(timeframe.rawValue)")
        }

        private func buttonBackground(isSelected: Bool) -> some View {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    isSelected
                        ? LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing,
                        )
                        : LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.1)]),
                            startPoint: .leading,
                            endPoint: .trailing,
                        ),
                )
        }

        private var contentSection: some View {
            VStack(spacing: 20) {
                EnhancedFinancialSummaryCard(
                    transactions: self.filteredTransactions,
                    timeframe: self.selectedTimeframe,
                )
                .padding(.horizontal, 16)

                // Spending by Category Chart
                SpendingByCategoryChart(transactions: self.filteredTransactions)
                    .padding(.horizontal, 16)

                if !self.budgets.isEmpty {
                    // Budget Performance Chart
                    BudgetPerformanceChart(
                        budgets: self.currentPeriodBudgets, transactions: self.filteredTransactions
                    )
                    .padding(.horizontal, 16)
                }

                // Recent Transactions List
                RecentTransactionsList(transactions: Array(self.filteredTransactions.prefix(5)))
                    .padding(.horizontal, 16)
            }
        }

        private var emptyStateSection: some View {
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)

                VStack(spacing: 8) {
                    Text("No Data Available")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(
                        "No transactions found for \(self.selectedTimeframe.rawValue.lowercased())"
                    )
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1)),
            )
            .padding(.horizontal, 16)
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
                guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)
                else {
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

    // Simple Financial Summary Card
    struct EnhancedFinancialSummaryCard: View {
        let transactions: [FinancialTransaction]
        let timeframe: EnhancedReportsSection.TimeFrame

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Financial Summary")
                    .font(.headline)
                    .fontWeight(.semibold)

                VStack(spacing: 8) {
                    Text("Income: $\(self.incomeAmount)")
                        .foregroundColor(.green)

                    Text("Expenses: $\(self.expenseAmount)")
                        .foregroundColor(.red)

                    Text("Net: $\(self.netAmount)")
                        .foregroundColor(self.netValue >= 0 ? .green : .red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }

        private var incomeAmount: String {
            let total = self.transactions.filter { $0.transactionType == .income }.reduce(0) {
                $0 + $1.amount
            }
            return String(format: "%.2f", total)
        }

        private var expenseAmount: String {
            let total = self.transactions.filter { $0.transactionType == .expense }.reduce(0) {
                $0 + $1.amount
            }
            return String(format: "%.2f", total)
        }

        private var netValue: Double {
            let income = self.transactions.filter { $0.transactionType == .income }.reduce(0) {
                $0 + $1.amount
            }
            let expenses = self.transactions.filter { $0.transactionType == .expense }.reduce(0) {
                $0 + $1.amount
            }
            return income - expenses
        }

        private var netAmount: String {
            String(format: "%.2f", self.netValue)
        }
    }

    // Helper views for enhanced reports section
    struct SpendingByCategoryChart: View {
        let transactions: [FinancialTransaction]

        private var categorySpending: [(String, Double)] {
            let expenseTransactions = self.transactions.filter { $0.transactionType == .expense }
            var spendingByCategory: [String: Double] = [:]

            for transaction in expenseTransactions {
                let categoryName = transaction.category?.name ?? "Uncategorized"
                spendingByCategory[categoryName, default: 0] += transaction.amount
            }

            return spendingByCategory.sorted { $0.value > $1.value }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Spending by Category")
                    .font(.headline)
                    .fontWeight(.semibold)

                if self.categorySpending.isEmpty {
                    Text("No expense data available")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    VStack(spacing: 12) {
                        ForEach(self.categorySpending.prefix(5), id: \.0) { category, amount in
                            HStack {
                                Text(category)
                                    .font(.subheadline)
                                Spacer()
                                Text(amount.formatted(.currency(code: "USD")))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
        }
    }

    struct BudgetPerformanceChart: View {
        let budgets: [Budget]
        let transactions: [FinancialTransaction]

        private var budgetPerformance: [(Budget, Double, Double)] {
            self.budgets.map { budget in
                let spent =
                    self.transactions
                        .filter {
                            $0.category?.name == budget.category?.name && $0.transactionType == .expense
                        }
                        .reduce(0) { $0 + $1.amount }
                return (budget, spent, budget.limitAmount)
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Budget Performance")
                    .font(.headline)
                    .fontWeight(.semibold)

                if self.budgetPerformance.isEmpty {
                    Text("No budget data available")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    VStack(spacing: 12) {
                        ForEach(self.budgetPerformance, id: \.0.id) { budget, spent, budgeted in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(budget.category?.name ?? "Unknown")
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 8)
                                            .cornerRadius(4)

                                        Rectangle()
                                            .fill(spent > budgeted ? Color.red : Color.green)
                                            .frame(
                                                width: min(
                                                    geometry.size.width * (spent / budgeted),
                                                    geometry.size.width
                                                ), height: 8
                                            )
                                            .cornerRadius(4)
                                    }
                                }
                                .frame(height: 8)

                                HStack {
                                    Text("Spent: \(spent.formatted(.currency(code: "USD")))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Budget: \(budgeted.formatted(.currency(code: "USD")))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
        }
    }

    struct RecentTransactionsList: View {
        let transactions: [FinancialTransaction]

        private var sortedTransactions: [FinancialTransaction] {
            Array(self.transactions.sorted { $0.date > $1.date }.prefix(5))
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)

                if self.transactions.isEmpty {
                    self.emptyStateView
                } else {
                    self.transactionsListView
                }
            }
        }

        private var emptyStateView: some View {
            Text("No recent transactions")
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
        }

        private var transactionsListView: some View {
            VStack(spacing: 8) {
                ForEach(self.sortedTransactions, id: \.id) { transaction in
                    self.transactionRow(for: transaction)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
            )
        }

        private func transactionRow(for transaction: FinancialTransaction) -> some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(transaction.category?.name ?? "Uncategorized")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(transaction.amount.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(transaction.transactionType == .income ? .green : .red)
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
