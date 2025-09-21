// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

/// Represents a savings goal (e.g., "Vacation Fund") in the app.
@Model
public final class SavingsGoal {
    /// The name of the savings goal.
    public var name: String
    /// The target amount to save.
    public var targetAmount: Double
    /// The current amount saved.
    public var currentAmount: Double
    /// The optional target date to reach the goal.
    public var targetDate: Date?
    /// Optional notes or memo for the goal.
    public var notes: String?
    /// The date the goal was created.
    public var createdDate: Date

    /// Creates a new savings goal.
    /// - Parameters:
    ///   - name: The goal name.
    ///   - targetAmount: The target amount to save.
    ///   - currentAmount: The current amount saved (default: 0.0).
    ///   - targetDate: The optional target date.
    ///   - notes: Optional notes or memo.
    public init(
        name: String, targetAmount: Double, currentAmount: Double = 0.0, targetDate: Date? = nil,
        notes: String? = nil
    ) {
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.notes = notes
        self.createdDate = Date()
    }

    /// The progress toward the goal as a percentage (0.0 to 1.0).
    public var progressPercentage: Double {
        guard self.targetAmount > 0 else { return 0.0 }
        return min(1.0, self.currentAmount / self.targetAmount)
    }

    /// The remaining amount needed to reach the goal.
    public var remainingAmount: Double {
        max(0, self.targetAmount - self.currentAmount)
    }

    /// Whether the goal has been achieved.
    public var isCompleted: Bool {
        self.currentAmount >= self.targetAmount
    }

    /// The target amount formatted as a currency string.
    public var formattedTargetAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self.targetAmount)) ?? "$0.00"
    }

    /// The current amount formatted as a currency string.
    public var formattedCurrentAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self.currentAmount)) ?? "$0.00"
    }

    /// The remaining amount formatted as a currency string.
    public var formattedRemainingAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self.remainingAmount)) ?? "$0.00"
    }

    /// Adds money to the savings goal.
    /// - Parameter amount: The amount to add.
    public func addFunds(_ amount: Double) {
        self.currentAmount += amount
    }

    /// Removes money from the savings goal.
    /// - Parameter amount: The amount to remove.
    public func removeFunds(_ amount: Double) {
        self.currentAmount = max(0, self.currentAmount - amount)
    }

    /// The number of days remaining until the target date (if set).
    public var daysRemaining: Int? {
        guard let targetDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return components.day
    }

    /// Compatibility accessor: code expects `title` on goals; maps to `name`.
    public var title: String {
        self.name
    }
}
