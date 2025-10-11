// Momentum Finance - Enhanced Account Detail Charts for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)

// MARK: - Chart Views for Enhanced Account Detail View

/// Balance trend chart showing account balance over time
struct BalanceTrendChart: View {
    let account: FinancialAccount
    let timeFrame: EnhancedAccountDetailView.TimeFrame

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

/// Spending breakdown chart showing category spending
struct SpendingBreakdownChart: View {
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
#endif
