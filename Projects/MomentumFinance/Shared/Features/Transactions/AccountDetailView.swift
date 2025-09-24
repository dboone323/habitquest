// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import SwiftUI

public struct AccountDetailView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    let account: FinancialAccount

    // Use a stored-array of transactions (populate from the account relationship)
    private var transactions: [FinancialTransaction] = []
    @State private var showingAddTransaction = false
    @State private var timeRange: TimeRange = .month

    let categories: [ExpenseCategory]
    let accounts: [FinancialAccount]

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "3 Months"
        case year = "Year"
        case all = "All Time"

        var days: Int? {
            switch self {
            case .week:
                7
            case .month:
                30
            case .quarter:
                90
            case .year:
                365
            case .all:
                nil
            }
        }
    }

    init(account: FinancialAccount, categories: [ExpenseCategory], accounts: [FinancialAccount]) {
        self.account = account
        self.categories = categories
        self.accounts = accounts

        // Populate transactions from the provided account relationship if available.
        // This avoids using the SwiftData @Query attribute which may not be available
        // on all toolchains in this workspace.
        self.transactions = account.transactions
    }

    var filteredTransactions: [FinancialTransaction] {
        guard let days = timeRange.days else {
            return self.transactions
        }

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return self.transactions.filter { $0.date >= cutoffDate }
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Account Summary Card
                VStack(spacing: 16) {
                    // Account Icon and Balance
                    VStack(spacing: 8) {
                        Image(systemName: self.account.iconName)
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.2)),
                            )

                        Text(self.account.name)
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Current Balance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(self.formattedCurrency(self.account.balance))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(self.account.balance >= 0 ? .primary : .red)
                    }

                    // Activity Summary
                    HStack(spacing: 20) {
                        StatView(
                            title: "Income",
                            value: self.formattedCurrency(self.incomeSummary),
                            color: .green,
                        )

                        Divider()

                        StatView(
                            title: "Expenses",
                            value: self.formattedCurrency(self.expenseSummary),
                            color: .red,
                        )
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(self.backgroundColorForPlatform())
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
                )

                // Time Filter
                Picker("Time Range", selection: self.$timeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Activity Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity")
                        .font(.headline)
                        .padding(.horizontal)

                    // Chart comes here
                    if self.filteredTransactions.isEmpty {
                        ContentUnavailableView(
                            "No Transactions",
                            systemImage: "chart.line.downtrend.xyaxis",
                            description: Text(
                                "No transaction data available for the selected time period."
                            ),
                        )
                        .frame(height: 200)
                    } else {
                        ActivityChartView(transactions: self.filteredTransactions)
                            .frame(height: 200)
                    }
                }
                .padding(.vertical)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(self.backgroundColorForPlatform())
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
                )

                // Transactions List
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Transactions")
                            .font(.headline)

                        Spacer()

                        Button(
                            action: {
                                self.showingAddTransaction = true
                            },
                            label: {
                                Image(systemName: "plus.circle")
                            }
                        )
                    }
                    .padding(.horizontal)

                    if self.filteredTransactions.isEmpty {
                        ContentUnavailableView(
                            "No Transactions",
                            systemImage: "list.bullet",
                            description: Text(
                                "No transactions in this account for the selected time period."
                            ),
                        )
                        .frame(height: 100)
                    } else {
                        ForEach(self.filteredTransactions.prefix(5)) { transaction in
                            TransactionRowView(transaction: transaction, onTap: {})
                                .padding(.horizontal, 16)
                        }

                        if self.filteredTransactions.count > 5 {
                            NavigationLink(destination: Features.Transactions.TransactionsView()) {
                                Text("View All \(self.filteredTransactions.count) Transactions")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding(.top, 8)
                            }
                        }
                    }
                }
                .padding(.vertical)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(self.backgroundColorForPlatform())
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
                )
            }
            .padding()
        }
        .navigationTitle("Account Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(
                        action: {
                            self.showingAddTransaction = true
                        },
                        label: {
                            Label("Add Transaction", systemImage: "plus")
                        }
                    )

                    Button(
                        action: {
                            // Future implementation: Edit account details
                        },
                        label: {
                            Label("Edit Account", systemImage: "pencil")
                        }
                    )
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: self.$showingAddTransaction) {
            AddTransactionView(categories: self.categories, accounts: self.accounts)
        }
    }

    private var incomeSummary: Double {
        self.filteredTransactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
    }

    private var expenseSummary: Double {
        self.filteredTransactions
            .filter { $0.transactionType == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    private func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: abs(value))) ?? "$0.00"
    }

    private func backgroundColorForPlatform() -> Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
}

public struct StatView: View {
    let title: String
    let value: String
    let color: Color

    public var body: some View {
        VStack(spacing: 4) {
            Text(self.title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(self.value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(self.color)
        }
        .frame(maxWidth: .infinity)
    }
}

public struct ActivityChartView: View {
    let transactions: [FinancialTransaction]

    struct DailyTransactionData: Identifiable {
        let id = UUID()
        let date: Date
        let income: Double
        let expense: Double

        var day: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd"
            return formatter.string(from: self.date)
        }
    }

    var chartData: [DailyTransactionData] {
        let calendar = Calendar.current
        let today = Date()
        let numberOfDays = 14 // Show last 2 weeks

        // Create data for each day
        var result: [DailyTransactionData] = []
        for dayOffset in (0 ..< numberOfDays).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                // Get start and end of day
                let startOfDay = calendar.startOfDay(for: date)
                guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
                    continue
                }

                // Filter transactions for this day
                let dayTransactions = self.transactions.filter {
                    $0.date >= startOfDay && $0.date < endOfDay
                }

                // Calculate income and expense totals
                let income =
                    dayTransactions
                        .filter { $0.transactionType == .income }
                        .reduce(0) { $0 + $1.amount }

                let expense =
                    dayTransactions
                        .filter { $0.transactionType == .expense }
                        .reduce(0) { $0 + $1.amount }

                result.append(DailyTransactionData(date: date, income: income, expense: expense))
            }
        }

        return result
    }

    public var body: some View {
        Chart {
            ForEach(self.chartData) { data in
                LineMark(
                    x: .value("Day", data.day),
                    y: .value("Income", data.income),
                    series: .value("Type", "Income"),
                )
                .foregroundStyle(.green)
                .symbol(Circle().strokeBorder(lineWidth: 2))
                .symbolSize(30)

                LineMark(
                    x: .value("Day", data.day),
                    y: .value("Expense", data.expense),
                    series: .value("Type", "Expense"),
                )
                .foregroundStyle(.red)
                .symbol(Circle().strokeBorder(lineWidth: 2))
                .symbolSize(30)
            }
        }
        .chartLegend(position: .top)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .padding()
    }
}
