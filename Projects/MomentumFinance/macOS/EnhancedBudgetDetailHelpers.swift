// Momentum Finance - Enhanced Budget Detail Helper Methods for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftUI

#if os(macOS)
extension Features.Budgets.EnhancedBudgetDetailView {
    /// Helper methods for the enhanced budget detail view
    static func getBudgetColor(spent: Double, total: Double) -> Color {
        let percentage = spent / total
        if percentage < 0.7 {
            return .green
        } else if percentage < 0.9 {
            return .yellow
        } else {
            return .red
        }
    }

    static func isTransactionInSelectedTimeFrame(_ date: Date, timeFrame: TimeFrame) -> Bool {
        let calendar = Calendar.current
        let today = Date()

        switch timeFrame {
        case .currentMonth:
            return calendar.isDate(date, equalTo: today, toGranularity: .month)
        case .lastMonth:
            guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: today) else { return false }
            return calendar.isDate(date, equalTo: lastMonth, toGranularity: .month)
        case .last3Months:
            guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: today) else { return false }
            return date >= threeMonthsAgo && date <= today
        case .last6Months:
            guard let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: today) else { return false }
            return date >= sixMonthsAgo && date <= today
        case .yearToDate:
            let components = calendar.dateComponents([.year], from: today)
            guard let startOfYear = calendar.date(from: components) else { return false }
            return date >= startOfYear && date <= today
        case .custom:
            // Custom date range would be handled here
            return true
        }
    }

    static func getTimeFrameDescription(timeFrame: TimeFrame) -> String {
        switch timeFrame {
        case .currentMonth:
            return "Budget for \(Date().formatted(.dateTime.month(.wide).year()))"
        case .lastMonth:
            guard let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
                return "Last Month"
            }
            return "Budget for \(lastMonth.formatted(.dateTime.month(.wide).year()))"
        case .last3Months:
            return "Last 3 Months"
        case .last6Months:
            return "Last 6 Months"
        case .yearToDate:
            return "Year to Date (\(Date().formatted(.dateTime.year())))"
        case .custom:
            return "Custom Date Range"
        }
    }
}
#endif
