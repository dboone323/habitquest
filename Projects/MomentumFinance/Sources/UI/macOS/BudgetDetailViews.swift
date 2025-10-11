// Momentum Finance - Enhanced Budget Detail Supporting Views for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import SwiftUI

#if os(macOS)
extension Features.Budgets {
    /// Supporting views for the enhanced budget detail view
    struct CategoryBadge: View {
        let category: ExpenseCategory

        var body: some View {
            HStack(spacing: 6) {
                Circle()
                    .fill(self.getCategoryColor(self.category.colorHex))
                    .frame(width: 12, height: 12)

                Text(self.category.name)
                    .font(.headline)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(self.getCategoryColor(self.category.colorHex).opacity(0.1))
            .cornerRadius(6)
        }

        private func getCategoryColor(_ hex: String?) -> Color {
            guard let hex else { return .gray }
            // This would parse the hex color string
            return .blue
        }
    }

    struct DailyAllowanceView: View {
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
            return self.daysInMonth - day + 1 // Including today
        }

        var dailyAllowance: Double {
            let remaining = self.budget.amount - self.budget.spent
            return remaining > 0 ? remaining / Double(self.daysRemaining) : 0
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Spending Allowance")
                    .font(.headline)

                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .center, spacing: 8) {
                        Text("\((self.budget.amount - self.budget.spent).formatted(.currency(code: "USD")))")
                            .font(.system(size: 20, weight: .bold))

                        Text("Remaining")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    VStack(alignment: .center, spacing: 8) {
                        Text("\(self.daysRemaining)")
                            .font(.system(size: 20, weight: .bold))

                        Text("Days Left")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    VStack(alignment: .center, spacing: 8) {
                        Text("\(self.dailyAllowance.formatted(.currency(code: "USD")))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(self.dailyAllowance > 10 ? .green : .orange)

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

    struct SpendingTrendChart: View {
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
                    ForEach(self.dailyData, id: \.day) { item in
                        BarMark(
                            x: .value("Day", item.day),
                            y: .value("Amount", item.amount),
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }

                    // Budget limit reference line
                    RuleMark(y: .value("Daily Budget", self.budget.amount / 30.0))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(.red)
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Daily Budget: \((self.budget.amount / 30.0).formatted(.currency(code: "USD")))")
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

    struct CategoryAnalysisChart: View {
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
                ForEach(self.monthlyData, id: \.month) { item in
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

                ForEach(self.monthlyData, id: \.month) { item in
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
}
#endif
