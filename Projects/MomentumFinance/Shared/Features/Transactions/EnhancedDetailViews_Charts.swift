// Momentum Finance - Enhanced Transaction Detail Charts
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import SwiftData
import SwiftUI

// MARK: - Chart Components

/// Chart showing spending trends for a specific category
struct CategorySpendingChart: View {
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

/// Chart showing spending patterns for a specific merchant
struct MerchantSpendingChart: View {
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
                        y: .value("Amount", item.amount),
                    )
                    .symbol(Circle().strokeBorder(lineWidth: 2))
                    .foregroundStyle(.blue)
                }

                ForEach(self.transactions, id: \.date) { item in
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
