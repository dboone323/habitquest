// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

/// Represents a spending category (e.g., Groceries, Utilities) for expenses in the app.
@Model
public final class ExpenseCategory: Hashable {
    /// The name of the category (e.g., "Groceries").
    var name: String
    /// The icon name for this category (for UI display).
    var iconName: String
    /// The date the category was created.
    var createdDate: Date

    // Relationships
    /// All transactions associated with this category.
    @Relationship(deleteRule: .cascade, inverse: \FinancialTransaction.category)
    var transactions: [FinancialTransaction] = []
    /// All budgets associated with this category.
    @Relationship(deleteRule: .cascade, inverse: \Budget.category)
    var budgets: [Budget] = []
    /// All subscriptions associated with this category.
    @Relationship(deleteRule: .cascade, inverse: \Subscription.category)
    var subscriptions: [Subscription] = []

    /// Creates a new expense category.
    /// - Parameters:
    ///   - name: The category name.
    ///   - iconName: The icon name for UI display.
    init(name: String, iconName: String) {
        self.name = name
        self.iconName = iconName
        self.createdDate = Date()
    }

    /// Calculates the total amount spent in this category for a given month.
    /// - Parameter month: The month to calculate spending for.
    /// - Returns: The total spent as a Double.
    func totalSpent(for month: Date) -> Double {
        let calendar = Calendar.current
        let monthComponents = calendar.dateInterval(of: .month, for: month)

        guard let startOfMonth = monthComponents?.start,
              let endOfMonth = monthComponents?.end
        else {
            return 0.0
        }

        return
            self.transactions
                .filter { $0.transactionType == .expense }
                .filter { $0.date >= startOfMonth && $0.date < endOfMonth }
                .reduce(0) { $0 + $1.amount }
    }

    // MARK: - Hashable Conformance

    /// Hashes the unique identifier for this category.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Compares two categories for equality by their unique identifier.
    public static func == (lhs: ExpenseCategory, rhs: ExpenseCategory) -> Bool {
        lhs.id == rhs.id
    }
}
