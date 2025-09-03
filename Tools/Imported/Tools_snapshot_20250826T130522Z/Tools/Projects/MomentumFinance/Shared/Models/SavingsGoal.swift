// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

@Model
final class SavingsGoal {
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var targetDate: Date?
    var notes: String?
    var createdDate: Date

    init(name: String, targetAmount: Double, currentAmount: Double = 0.0, targetDate: Date? = nil, notes: String? = nil) {
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.notes = notes
        self.createdDate = Date()
    }

    /// Progress as a percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0.0 }
        return min(1.0, currentAmount / targetAmount)
    }

    /// Remaining amount to reach goal
    var remainingAmount: Double {
        max(0, targetAmount - currentAmount)
    }

    /// Whether the goal has been achieved
    var isCompleted: Bool {
        currentAmount >= targetAmount
    }

    /// Formatted target amount
    var formattedTargetAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: targetAmount)) ?? "$0.00"
    }

    /// Formatted current amount
    var formattedCurrentAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: currentAmount)) ?? "$0.00"
    }

    /// Formatted remaining amount
    var formattedRemainingAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: remainingAmount)) ?? "$0.00"
    }

    /// Add money to the savings goal
    /// <#Description#>
    /// - Returns: <#description#>
    func addFunds(_ amount: Double) {
        currentAmount += amount
    }

    /// Remove money from the savings goal
    /// <#Description#>
    /// - Returns: <#description#>
    func removeFunds(_ amount: Double) {
        currentAmount = max(0, currentAmount - amount)
    }

    /// Days remaining until target date
    var daysRemaining: Int? {
        guard let targetDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return components.day
    }
<<<<<<< HEAD
=======

    /// Compatibility accessor: code expects `title` on goals; map to `name`.
    var title: String {
        name
    }
>>>>>>> 1cf3938 (Create working state for recovery)
}
