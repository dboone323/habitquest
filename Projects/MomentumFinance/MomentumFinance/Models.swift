// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

// MARK: - ExpenseCategory Model

@Model
final class ExpenseCategory {
    var name: String
    var iconName: String
    var createdDate: Date

    // Relationships with proper declarations
    @Relationship(deleteRule: .cascade)
    var transactions: [FinancialTransaction] = []

    @Relationship(deleteRule: .cascade, inverse: \Budget.category)
    var budgets: [Budget] = []

    @Relationship(deleteRule: .cascade)
    var subscriptions: [Subscription] = []

    init(name: String, iconName: String) {
        self.name = name
        self.iconName = iconName
        self.createdDate = Date()
    }

    /// Calculates total spent in this category for a given month
    /// <#Description#>
    /// - Returns: <#description#>
    func totalSpent(for month: Date) -> Double {
        let calendar = Calendar.current
        let monthComponents = calendar.dateInterval(of: .month, for: month)

        guard let startOfMonth = monthComponents?.start,
              let endOfMonth = monthComponents?.end
        else {
            return 0.0
        }

        return transactions
            .filter { $0.transactionType == .expense }
            .filter { $0.date >= startOfMonth && $0.date < endOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Budget Model

@Model
final class Budget {
    var name: String
    var limitAmount: Double
    var month: Date
    var createdDate: Date

    // Relationships
    @Relationship(.inverse, "budgets")
    var category: ExpenseCategory?

    init(name: String, limitAmount: Double, month: Date) {
        self.name = name
        self.limitAmount = limitAmount
        self.month = month
        self.createdDate = Date()
    }

    /// Calculated spent amount for this budget's category and month
    var spentAmount: Double {
        guard let category else { return 0.0 }
        return category.totalSpent(for: month)
    }

    /// Remaining budget amount
    var remainingAmount: Double {
        max(0, limitAmount - spentAmount)
    }

    /// Budget progress as a percentage (0.0 to 1.0+)
    var progressPercentage: Double {
        guard limitAmount > 0 else { return 0.0 }
        return spentAmount / limitAmount
    }

    /// Whether the budget has been exceeded
    var isOverBudget: Bool {
        spentAmount > limitAmount
    }

    /// Formatted limit amount
    var formattedLimitAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: limitAmount)) ?? "$0.00"
    }

    /// Formatted spent amount
    var formattedSpentAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: spentAmount)) ?? "$0.00"
    }

    /// Formatted remaining amount
    var formattedRemainingAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: remainingAmount)) ?? "$0.00"
    }

    /// Month formatted for display
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }
}
