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

extension Features.GoalsAndReports {
    struct EnhancedReportsSection: View {
        let transactions: [FinancialTransaction]
        let budgets: [Budget]
        let categories: [ExpenseCategory]

        @State private var selectedTimeframe: TimeFrame = .thisMonth

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

        enum TimeFrame: String, CaseIterable {
            case thisWeek = "This Week"
            case thisMonth = "This Month"
            case last3Months = "Last 3 Months"
            case thisYear = "This Year"
        }

        var body: some View {
            ScrollView {
                LazyVStack(spacing: 20) {
                    headerSection

                    if !filteredTransactions.isEmpty {
                        contentSection
                    } else {
                        emptyStateSection
                    }
                }
                .padding(.vertical)
            }
            .background(backgroundColor)
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

                timeframePicker
            }
            .padding(.horizontal)
        }

        private var timeframePicker: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        timeframeButton(for: timeframe)
                    }
                }
                .padding(.horizontal)
            }
        }

        private func timeframeButton(for timeframe: TimeFrame) -> some View {
            let isSelected = selectedTimeframe == timeframe

            return Button(
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTimeframe = timeframe
                    }
                },
                label: {
                    Text(timeframe.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(buttonBackground(isSelected: isSelected))
                },
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
        }

        private func buttonBackground(isSelected: Bool) -> some View {
            RoundedRectangle(cornerRadius: 20)
                .fill(
<<<<<<< HEAD
                    isSelected ?
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing,
                            ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.1)]),
                            startPoint: .leading,
                            endPoint: .trailing,
                            ),
                    )
=======
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
>>>>>>> 1cf3938 (Create working state for recovery)
        }

        private var contentSection: some View {
            VStack(spacing: 20) {
                EnhancedFinancialSummaryCard(
                    transactions: filteredTransactions,
                    timeframe: selectedTimeframe,
<<<<<<< HEAD
                    )
=======
                )
>>>>>>> 1cf3938 (Create working state for recovery)
                .padding(.horizontal)

                Text("Spending by Category - Coming Soon")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)

                if !budgets.isEmpty {
                    Text("Budget Performance - Coming Soon")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                Text("Recent Transactions - Coming Soon")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
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

                    Text("No transactions found for \(selectedTimeframe.rawValue.lowercased())")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1)),
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
            .padding(.horizontal)
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

            case .last3Months:
                guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) else {
=======
                return transactions.filter {
                    calendar.isDate($0.date, equalTo: now, toGranularity: .month)
                }

            case .last3Months:
                guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)
                else {
>>>>>>> 1cf3938 (Create working state for recovery)
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

    // Helper views for enhanced reports section
    struct EnhancedFinancialSummaryCard: View {
        let transactions: [FinancialTransaction]
        let timeframe: EnhancedReportsSection.TimeFrame

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
                Text("Financial Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                HStack(spacing: 16) {
                    // Income
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.green)

                            Text("Income")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Text(totalIncome.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1),
<<<<<<< HEAD
                                ),
                        )
=======
                            ),
                    )
>>>>>>> 1cf3938 (Create working state for recovery)

                    // Expenses
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.red)

                            Text("Expenses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Text(totalExpenses.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.red.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1),
<<<<<<< HEAD
                                ),
                        )
=======
                            ),
                    )
>>>>>>> 1cf3938 (Create working state for recovery)
                }

                // Net Income
                VStack(spacing: 8) {
                    Text("Net Income")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(netIncome.formatted(.currency(code: "USD")))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(netIncome >= 0 ? .green : .red)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    (netIncome >= 0 ? Color.green : Color.red).opacity(0.05),
<<<<<<< HEAD
                                    (netIncome >= 0 ? Color.green : Color.red).opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing,
                                ),
                            )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke((netIncome >= 0 ? Color.green : Color.red).opacity(0.2), lineWidth: 1),
                            ),
                    )
=======
                                    (netIncome >= 0 ? Color.green : Color.red).opacity(0.1),
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing,
                            ),
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    (netIncome >= 0 ? Color.green : Color.red).opacity(0.2),
                                    lineWidth: 1),
                        ),
                )
>>>>>>> 1cf3938 (Create working state for recovery)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1),
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
        }
    }
}

#Preview {
    Features.GoalsAndReports.EnhancedReportsSection(
        transactions: [],
        budgets: [],
        categories: [],
<<<<<<< HEAD
        )
=======
    )
>>>>>>> 1cf3938 (Create working state for recovery)
}
