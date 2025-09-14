// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

/// Represents a monthly budget for a specific category in the app.
@Model
public final class Budget {
    /// The name of the budget (e.g., "Groceries").
    var name: String
    /// The maximum allowed amount for this budget.
    var limitAmount: Double
    /// The month this budget applies to.
    var month: Date
    /// The date the budget was created.
    var createdDate: Date

    // Relationships
    /// The category associated with this budget (optional).
    var category: ExpenseCategory?

    /// Creates a new budget for a category and month.
    /// - Parameters:
    ///   - name: The budget name.
    ///   - limitAmount: The maximum allowed amount.
    ///   - month: The month for the budget.
    init(name: String, limitAmount: Double, month: Date) {
        self.name = name
        self.limitAmount = limitAmount
        self.month = month
        self.createdDate = Date()
    }

    /// The total amount spent for this budget's category and month.
    var spentAmount: Double {
        guard let category else { return 0.0 }
        return category.totalSpent(for: month)
    }

    /// The remaining amount available in the budget.
    var remainingAmount: Double {
        max(0, limitAmount - spentAmount)
    }

    /// The budget progress as a percentage (0.0 to 1.0+).
    var progressPercentage: Double {
        guard limitAmount > 0 else { return 0.0 }
        return spentAmount / limitAmount
    }

    /// Whether the budget has been exceeded.
    var isOverBudget: Bool {
        spentAmount > limitAmount
    }

    /// The limit amount formatted as a currency string.
    var formattedLimitAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: limitAmount)) ?? "$0.00"
    }

    /// The spent amount formatted as a currency string.
    var formattedSpentAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: spentAmount)) ?? "$0.00"
    }

    /// The remaining amount formatted as a currency string.
    var formattedRemainingAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: remainingAmount)) ?? "$0.00"
    }

    /// The month formatted for display (e.g., "September 2025").
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }
}
