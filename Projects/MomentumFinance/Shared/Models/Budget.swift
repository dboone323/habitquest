// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

/// Represents a monthly budget for a specific category in the app.
@Model
public final class Budget {
    /// Unique identifier for the budget.
    public var id = UUID()
    /// The name of the budget (e.g., "Groceries").
    public var name: String
    /// The maximum allowed amount for this budget.
    public var limitAmount: Double
    /// The month this budget applies to.
    public var month: Date
    /// The date the budget was created.
    public var createdDate: Date

    // Rollover functionality
    /// Whether rollover is enabled for this budget.
    public var rolloverEnabled: Bool = false
    /// The amount rolled over from the previous period.
    public var rolledOverAmount: Double = 0.0
    /// The maximum percentage of unused budget that can be rolled over (0.0 to 1.0).
    public var maxRolloverPercentage: Double = 1.0

    // Relationships
    /// The category associated with this budget (optional).
    public var category: ExpenseCategory?

    /// Creates a new budget for a category and month.
    /// - Parameters:
    ///   - name: The budget name.
    ///   - limitAmount: The maximum allowed amount.
    ///   - month: The month for the budget.
    public init(name: String, limitAmount: Double, month: Date) {
        self.name = name
        self.limitAmount = limitAmount
        self.month = month
        self.createdDate = Date()
    }

    /// The total amount spent for this budget's category and month.
    public var spentAmount: Double {
        guard let category else { return 0.0 }
        return category.totalSpent(for: self.month)
    }

    /// The effective budget limit including any rolled over amount.
    public var effectiveLimit: Double {
        self.limitAmount + self.rolledOverAmount
    }

    /// The remaining amount available in the budget (accounting for rollover).
    public var remainingAmount: Double {
        max(0, self.effectiveLimit - self.spentAmount)
    }

    /// The budget progress as a percentage (0.0 to 1.0+).
    public var progressPercentage: Double {
        guard self.effectiveLimit > 0 else { return 0.0 }
        return self.spentAmount / self.effectiveLimit
    }

    /// Whether the budget has been exceeded.
    public var isOverBudget: Bool {
        self.spentAmount > self.effectiveLimit
    }

    /// The limit amount formatted as a currency string.
    public var formattedLimitAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self.effectiveLimit)) ?? "$0.00"
    }

    /// The remaining amount formatted as a currency string.
    public var formattedRemainingAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self.remainingAmount)) ?? "$0.00"
    }

    /// The month formatted for display (e.g., "September 2025").
    public var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self.month)
    }

    // MARK: - Rollover Methods

    /// Calculates the amount that can be rolled over to the next period.
    /// - Returns: The rollover amount based on remaining budget and max rollover percentage.
    public func calculateRolloverAmount() -> Double {
        guard self.rolloverEnabled else { return 0.0 }

        let unusedAmount = self.remainingAmount
        let maxRolloverAmount = self.limitAmount * self.maxRolloverPercentage
        return min(unusedAmount, maxRolloverAmount)
    }

    /// Applies rollover amount to this budget.
    /// - Parameter amount: The amount to roll over from the previous period.
    public func applyRollover(_ amount: Double) {
        self.rolledOverAmount = amount
    }

    /// Resets the rolled over amount (typically called when creating a new budget period).
    public func resetRollover() {
        self.rolledOverAmount = 0.0
    }

    /// Creates a new budget for the next period with rollover applied.
    /// - Parameter nextMonth: The month for the new budget.
    /// - Returns: A new Budget instance with rollover applied.
    public func createNextPeriodBudget(for nextMonth: Date) -> Budget {
        let rolloverAmount = self.calculateRolloverAmount()

        let nextBudget = Budget(
            name: name,
            limitAmount: limitAmount,
            month: nextMonth
        )
        nextBudget.category = self.category
        nextBudget.rolloverEnabled = self.rolloverEnabled
        nextBudget.maxRolloverPercentage = self.maxRolloverPercentage
        nextBudget.applyRollover(rolloverAmount)

        return nextBudget
    }
}
