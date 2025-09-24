// Momentum Finance - Insights Summary Widget
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

/// A summary widget to display financial insights on the dashboard
public struct InsightsSummaryWidget: View {
    @Environment(\.modelContext) private var modelContext
    #if canImport(SwiftData)
    #if canImport(SwiftData)
    #if canImport(SwiftData)
    #if canImport(SwiftData)
    private var transactions: [FinancialTransaction] = []
    private var accounts: [FinancialAccount] = []
    private var budgets: [Budget] = []
    #else
    private var transactions: [FinancialTransaction] = []
    private var accounts: [FinancialAccount] = []
    private var budgets: [Budget] = []
    #endif
    #else
    private var transactions: [FinancialTransaction] = []
    private var accounts: [FinancialAccount] = []
    private var budgets: [Budget] = []
    #endif
    #else
    private var transactions: [FinancialTransaction] = []
    private var accounts: [FinancialAccount] = []
    private var budgets: [Budget] = []
    #endif
    #else
    private var transactions: [FinancialTransaction] = []
    private var accounts: [FinancialAccount] = []
    private var budgets: [Budget] = []
    #endif

    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)

                Spacer()

                NavigationLink(destination: InsightsView()) {
                    Text("Details")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }

            if self.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 100)
            } else if self.accounts.isEmpty {
                self.insightEmptyStateView
            } else {
                self.insightContentView
            }
        }
        .padding(15)
        .background(self.insightBackgroundColor())
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            // Simulate loading insights data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
            }
        }
    }

    // MARK: - Supporting Views

    private var insightEmptyStateView: some View {
        VStack(spacing: 10) {
            Text("No insights available yet")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Add some accounts and transactions to get started.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
    }

    private var insightContentView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Total balance insight
            let totalBalance = self.accounts.reduce(0) { $0 + $1.balance }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(self.formatCurrency(totalBalance))
                        .font(.headline)
                }

                Spacer()

                // Monthly trend indicator
                self.monthlyTrendView(value: self.calculateMonthlyChange())
            }

            Divider()

            // Recent spending
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent Spending")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(self.formatCurrency(self.calculateRecentSpending()))
                        .font(.headline)
                }

                Spacer()

                // This month vs last month comparison
                self.expenseComparisonView()
            }
        }
    }

    private func monthlyTrendView(value: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: value >= 0 ? "arrow.up.right" : "arrow.down.right")
                .foregroundColor(value >= 0 ? .green : .red)

            Text("\(abs(value), specifier: "%.1f")%")
                .font(.subheadline)
                .foregroundColor(value >= 0 ? .green : .red)
        }
    }

    private func expenseComparisonView() -> some View {
        let currentRatio = self.calculateMonthComparisonRatio()

        return HStack {
            Image(
                systemName: currentRatio <= 1.0
                    ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
            )
            .foregroundColor(currentRatio <= 1.0 ? .green : .orange)
            .imageScale(.small)

            Text(currentRatio <= 1.0 ? "On track" : "Above avg")
                .font(.caption2)
                .foregroundColor(currentRatio <= 1.0 ? .green : .orange)
        }
    }

    // MARK: - Helper Functions

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func calculateMonthlyChange() -> Double {
        // Simplified implementation - would typically use data from multiple months
        2.5 // Example: 2.5% growth
    }

    private func calculateRecentSpending() -> Double {
        // Sum of expenses in the last 7 days
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        return
            self.transactions
                .filter { $0.date > lastWeek && $0.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }
    }

    private func calculateMonthComparisonRatio() -> Double {
        // Simplified implementation - would typically compare current month vs previous month
        0.9 // Example: spending is 90% of previous month (good)
    }

    private func insightBackgroundColor() -> some View {
        #if os(iOS)
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #else
        return Color.secondary.opacity(0.1)
        #endif
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
}
