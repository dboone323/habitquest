// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

enum BillingCycle: String, CaseIterable, Codable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    /// Number of days in the billing cycle
    var daysInCycle: Int {
        switch self {
        case .weekly:
            7
        case .monthly:
            30
        case .yearly:
            365
        }
    }

    /// Calculate next due date from a given date
    /// <#Description#>
    /// - Returns: <#description#>
    func nextDueDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }
}

@Model
final class Subscription {
    var name: String
    var amount: Double
    var billingCycle: BillingCycle
    var nextDueDate: Date
    var isActive: Bool
    var notes: String?

    // Relationships
    var category: ExpenseCategory?
    var account: FinancialAccount?

    init(name: String, amount: Double, billingCycle: BillingCycle, nextDueDate: Date, notes: String? = nil) {
        self.name = name
        self.amount = amount
        self.billingCycle = billingCycle
        self.nextDueDate = nextDueDate
        self.isActive = true
        self.notes = notes
    }

    /// Formatted amount string
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    /// Days until next payment
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: nextDueDate)
        return max(0, components.day ?? 0)
    }

<<<<<<< HEAD
=======
    /// Compatibility accessor: some code expects `nextBillingDate` (optional).
    /// Keep this as a computed property mapping to the canonical `nextDueDate`.
    /// Return an Optional so callers can use `guard let` / conditional binding.
    var nextBillingDate: Date? {
        get { nextDueDate }
        set {
            // If a new date is provided, update the canonical nextDueDate.
            // If nil is assigned, ignore to preserve existing non-optional storage.
            if let newValue {
                nextDueDate = newValue
            }
        }
    }

>>>>>>> 1cf3938 (Create working state for recovery)
    /// Monthly equivalent amount for budgeting calculations
    var monthlyEquivalent: Double {
        switch billingCycle {
        case .weekly:
            amount * 52 / 12 // Weekly * 52 weeks / 12 months
        case .monthly:
            amount
        case .yearly:
            amount / 12
        }
    }

    /// Updates next due date and creates a transaction
    @MainActor
    /// <#Description#>
    /// - Returns: <#description#>
    func processPayment(modelContext: ModelContext) {
        // Create transaction for this subscription payment
        let transaction = FinancialTransaction(
            title: name,
            amount: amount,
            date: nextDueDate,
            transactionType: .expense,
            notes: "Auto-generated from subscription",
<<<<<<< HEAD
            )
=======
        )
>>>>>>> 1cf3938 (Create working state for recovery)
        transaction.category = category
        transaction.account = account

        modelContext.insert(transaction)

        // Update account balance
        account?.updateBalance(for: transaction)

        // Set next due date
        nextDueDate = billingCycle.nextDueDate(from: nextDueDate)
    }
}
