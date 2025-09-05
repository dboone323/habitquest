// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

@Model
public final class ExpenseCategory: Hashable {
    var name: String
    var iconName: String
    var createdDate: Date

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \FinancialTransaction.category)
    var transactions: [FinancialTransaction] = []
    @Relationship(deleteRule: .cascade, inverse: \Budget.category)
    var budgets: [Budget] = []
    @Relationship(deleteRule: .cascade, inverse: \Subscription.category)
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

    // MARK: - Hashable Conformance

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ExpenseCategory, rhs: ExpenseCategory) -> Bool {
        lhs.id == rhs.id
    }
}
