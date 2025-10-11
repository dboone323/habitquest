// Momentum Finance - macOS Goals and Reports UI Enhancements
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

#if os(macOS)
// Goals and Reports-specific UI enhancements
extension Features.GoalsAndReports {
    /// macOS-specific goals list view
    struct GoalsListView: View {
        @Environment(\.modelContext) private var modelContext
        @Query private var goals: [SavingsGoal]
        @State private var selectedItem: ListableItem?
        @State private var viewType: ViewType = .goals

        enum ViewType {
            case goals, reports
        }

        var body: some View {
            VStack {
                Picker("View", selection: self.$viewType) {
                    Text("Savings Goals").tag(ViewType.goals)
                    Text("Reports").tag(ViewType.reports)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if self.viewType == .goals {
                    self.goalsList
                } else {
                    self.reportsList
                }
            }
            .navigationTitle("Goals & Reports")
            .toolbar {
                ToolbarItem {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                    .help("Add New Goal")
                }
            }
        }

        var goalsList: some View {
            List(selection: self.$selectedItem) {
                ForEach(self.goals) { goal in
                    NavigationLink(value: ListableItem(id: goal.id, name: goal.name, type: .goal)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(goal.name)
                                    .font(.headline)

                                Spacer()

                                Text(
                                    "\(goal.currentAmount.formatted(.currency(code: "USD"))) of \(goal.targetAmount.formatted(.currency(code: "USD")))"
                                )
                                .font(.subheadline)
                            }

                            ProgressView(value: goal.currentAmount, total: goal.targetAmount)
                                .tint(.blue)

                            HStack {
                                if let targetDate = goal.targetDate {
                                    Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                let percentage = Int((goal.currentAmount / goal.targetAmount) * 100)
                                Text("\(percentage)%")
                                    .font(.caption)
                                    .bold()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .tag(ListableItem(id: goal.id, name: goal.name, type: .goal))
                }
            }
        }

        var reportsList: some View {
            List(selection: self.$selectedItem) {
                NavigationLink(value: ListableItem(id: "spending", name: "Spending by Category", type: .report)) {
                    HStack {
                        Image(systemName: "chart.pie")
                            .foregroundStyle(.orange)
                        Text("Spending by Category")
                    }
                    .padding(.vertical, 8)
                }
                .tag(ListableItem(id: "spending", name: "Spending by Category", type: .report))

                NavigationLink(value: ListableItem(id: "income", name: "Income vs Expenses", type: .report)) {
                    HStack {
                        Image(systemName: "chart.bar")
                            .foregroundStyle(.green)
                        Text("Income vs Expenses")
                    }
                    .padding(.vertical, 8)
                }
                .tag(ListableItem(id: "income", name: "Income vs Expenses", type: .report))

                NavigationLink(value: ListableItem(id: "trends", name: "Monthly Spending Trends", type: .report)) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundStyle(.blue)
                        Text("Monthly Spending Trends")
                    }
                    .padding(.vertical, 8)
                }
                .tag(ListableItem(id: "trends", name: "Monthly Spending Trends", type: .report))

                NavigationLink(value: ListableItem(id: "cashflow", name: "Cash Flow Analysis", type: .report)) {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundStyle(.purple)
                        Text("Cash Flow Analysis")
                    }
                    .padding(.vertical, 8)
                }
                .tag(ListableItem(id: "cashflow", name: "Cash Flow Analysis", type: .report))
            }
        }
    }

    /// Savings Goal Detail View optimized for macOS
    struct SavingsGoalDetailView: View {
        let goalId: String

        @Query private var goals: [SavingsGoal]
        @State private var isEditing = false

        var goal: SavingsGoal? {
            self.goals.first(where: { $0.id == self.goalId })
        }

        var body: some View {
            Group {
                if let goal {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(goal.name)
                                        .font(.largeTitle)
                                        .bold()

                                    if let targetDate = goal.targetDate {
                                        HStack {
                                            Image(systemName: "calendar")
                                            Text("Target Date: \(targetDate.formatted(date: .long, time: .omitted))")
                                                .font(.headline)
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text(goal.targetAmount.formatted(.currency(code: "USD")))
                                        .font(.system(size: 28, weight: .bold))

                                    Text("Target Amount")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Goal Progress")
                                        .font(.headline)

                                    Spacer()

                                    Text(
                                        "\(goal.currentAmount.formatted(.currency(code: "USD"))) of \(goal.targetAmount.formatted(.currency(code: "USD")))"
                                    )
                                }

                                ProgressView(value: goal.currentAmount, total: goal.targetAmount)
                                    .tint(.blue)
                                    .scaleEffect(y: 2.0)
                                    .padding(.vertical, 8)

                                HStack {
                                    Text("Remaining: \((goal.targetAmount - goal.currentAmount).formatted(.currency(code: "USD")))")
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    let percentage = Int((goal.currentAmount / goal.targetAmount) * 100)
                                    Text("\(percentage)% Complete")
                                        .foregroundStyle(.blue)
                                        .bold()
                                }
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)

                            // Time remaining calculation
                            if let targetDate = goal.targetDate {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Time Remaining")
                                        .font(.headline)

                                    let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0

                                    if daysRemaining > 0 {
                                        Text("\(daysRemaining) days until target date")
                                            .font(.title2)

                                        // Required monthly savings
                                        let remainingAmount = goal.targetAmount - goal.currentAmount
                                        let monthsRemaining = Double(daysRemaining) / 30.0
                                        if monthsRemaining > 0 {
                                            let requiredMonthlySavings = remainingAmount / monthsRemaining
                                            Text(
                                                "You need to save \(requiredMonthlySavings.formatted(.currency(code: "USD"))) per month to reach your goal on time."
                                            )
                                            .foregroundStyle(.secondary)
                                        }
                                    } else {
                                        Text("Target date has passed")
                                            .font(.title2)
                                            .foregroundStyle(.red)
                                    }
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(8)
                            }

                            // Contributions
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Recent Contributions")
                                    .font(.headline)

                                // This would show actual contributions
                                // Placeholder for now
                                Text("No recent contributions")
                                    .foregroundStyle(.secondary)
                                    .padding()
                            }

                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .toolbar {
                        ToolbarItem {
                            Button(action: { self.isEditing.toggle() }) {
                                Text(self.isEditing ? "Done" : "Edit")
                            }
                        }

                        ToolbarItem {
                            Button(action: {}) {
                                Text("Add Contribution")
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Goal Not Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The savings goal you're looking for could not be found.")
                    )
                }
            }
            .navigationTitle("Goal Details")
        }
    }

    /// Report Detail View for macOS
    struct ReportDetailView: View {
        let reportType: String

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(self.getReportTitle())
                        .font(.largeTitle)
                        .bold()

                    ReportChartView(reportType: self.reportType)

                    Divider()

                    Text("Analysis")
                        .font(.headline)

                    Text(
                        "This report provides insights into your \(self.getReportDescription()). Use this information to make informed financial decisions and track your progress toward your financial goals."
                    )
                    .padding()
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(8)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button("Export as PDF", action: {})
                        Button("Export as CSV", action: {})
                        Button("Print", action: {})
                        Button("Share", action: {})
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }

                ToolbarItem {
                    Menu {
                        Button("Last 30 Days", action: {})
                        Button("Last 3 Months", action: {})
                        Button("Last 6 Months", action: {})
                        Button("Year to Date", action: {})
                        Button("Last 12 Months", action: {})
                        Button("Custom Range...", action: {})
                    } label: {
                        HStack {
                            Text("Last 30 Days")
                            Image(systemName: "chevron.down")
                        }
                    }
                }
            }
            .navigationTitle("Financial Report")
        }

        private func getReportTitle() -> String {
            switch self.reportType {
            case "spending":
                "Spending by Category"
            case "income":
                "Income vs Expenses"
            case "trends":
                "Monthly Spending Trends"
            case "cashflow":
                "Cash Flow Analysis"
            default:
                "Financial Report"
            }
        }

        private func getReportDescription() -> String {
            switch self.reportType {
            case "spending":
                "spending patterns across different categories"
            case "income":
                "income compared to your expenses over time"
            case "trends":
                "spending trends over the past months"
            case "cashflow":
                "cash flow patterns and liquidity"
            default:
                "financial activity"
            }
        }
    }

    struct ReportChartView: View {
        let reportType: String

        var body: some View {
            // This is a placeholder for actual chart visualization
            // In a real implementation, this would render different charts based on the report type
            VStack {
                Text("Chart Visualization")
                    .font(.headline)

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.windowBackgroundColor).opacity(0.3))

                    Text("Chart data visualization would appear here")
                        .foregroundStyle(.secondary)
                }
                .frame(height: 300)
            }
        }
    }
}
#endif
