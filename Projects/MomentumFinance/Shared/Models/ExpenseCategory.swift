// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

/// Represents a spending category (e.g., Groceries, Utilities) for expenses in the app.
@Model
public final class ExpenseCategory: Hashable {
    /// Unique identifier for the category.
    public var id: UUID
    /// The name of the category (e.g., "Groceries").
    public var name: String
    /// The icon name for this category (for UI display).
    public var iconName: String
    /// The date the category was created.
    public var createdDate: Date

    // Relationships
    /// All transactions associated with this category.
    @Relationship(deleteRule: .cascade, inverse: \FinancialTransaction.category)
    public var transactions: [FinancialTransaction] = []
    /// All budgets associated with this category.
    @Relationship(deleteRule: .cascade, inverse: \Budget.category)
    public var budgets: [Budget] = []
    /// All subscriptions associated with this category.
    @Relationship(deleteRule: .cascade, inverse: \Subscription.category)
    public var subscriptions: [Subscription] = []

    /// Creates a new expense category.
    /// - Parameters:
    ///   - name: The category name.
    ///   - iconName: The icon name for UI display.
    public init(name: String, iconName: String) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.createdDate = Date()
    }

    /// Calculates the total amount spent in this category for a given month.
    /// - Parameter month: The month to calculate spending for.
    /// - Returns: The total spent as a Double.
    public func totalSpent(for month: Date) -> Double {
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
        hasher.combine(self.id)
    }

    /// Compares two categories for equality by their unique identifier.
    public static func == (lhs: ExpenseCategory, rhs: ExpenseCategory) -> Bool {
        lhs.id == rhs.id
    }
}
