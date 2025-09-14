// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

/// Represents the billing cycle for a subscription (weekly, monthly, yearly).
enum BillingCycle: String, CaseIterable, Codable {
    /// Weekly billing cycle.
    case weekly = "Weekly"
    /// Monthly billing cycle.
    case monthly = "Monthly"
    /// Yearly billing cycle.
    case yearly = "Yearly"

    /// Number of days in the billing cycle.
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

    /// Calculates the next due date for this billing cycle from a given date.
    /// - Parameter date: The starting date.
    /// - Returns: The next due date as a Date.
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

/// Represents a recurring subscription (e.g., Netflix, gym membership) in the app.
@Model
public final class Subscription {
    /// The name of the subscription (e.g., "Netflix").
    var name: String
    /// The recurring payment amount.
    var amount: Double
    /// The billing cycle for this subscription.
    var billingCycle: BillingCycle
    /// The next due date for payment.
    var nextDueDate: Date
    /// Whether the subscription is currently active.
    var isActive: Bool
    /// Optional notes or memo for the subscription.
    var notes: String?
    /// The icon name for this subscription (for UI display).
    var icon: String

    // Relationships
    /// The category associated with this subscription (optional).
    var category: ExpenseCategory?
    /// The financial account associated with this subscription (optional).
    var account: FinancialAccount?

    /// Creates a new subscription.
    /// - Parameters:
    ///   - name: The subscription name.
    ///   - amount: The recurring payment amount.
    ///   - billingCycle: The billing cycle.
    ///   - nextDueDate: The next due date for payment.
    ///   - notes: Optional notes or memo.
    ///   - icon: The icon name for UI display (default: "creditcard").
    init(
        name: String, amount: Double, billingCycle: BillingCycle, nextDueDate: Date,
        notes: String? = nil, icon: String = "creditcard"
    ) {
        self.name = name
        self.amount = amount
        self.billingCycle = billingCycle
        self.nextDueDate = nextDueDate
        self.isActive = true
        self.notes = notes
        self.icon = icon
    }

    /// Returns the amount as a formatted currency string.
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    /// Returns the number of days until the next payment is due.
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: nextDueDate)
        return max(0, components.day ?? 0)
    }

    /// Compatibility accessor: some code expects `nextBillingDate` (optional).
    /// Maps to the canonical `nextDueDate` property.
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

    /// Returns the monthly equivalent amount for budgeting calculations.
    var monthlyEquivalent: Double {
        switch billingCycle {
        case .weekly:
            amount * 52 / 12  // Weekly * 52 weeks / 12 months
        case .monthly:
            amount
        case .yearly:
            amount / 12
        }
    }

    /// Processes a payment for this subscription: creates a transaction, updates account, and advances due date.
    /// - Parameter modelContext: The model context for inserting the transaction.
    @MainActor
    func processPayment(modelContext: ModelContext) {
        // Create transaction for this subscription payment
        let transaction = FinancialTransaction(
            title: name,
            amount: amount,
            date: nextDueDate,
            transactionType: .expense,
            notes: "Auto-generated from subscription"
        )
        transaction.category = category
        transaction.account = account

        modelContext.insert(transaction)

        // Update account balance
        account?.updateBalance(for: transaction)

        // Set next due date
        nextDueDate = billingCycle.nextDueDate(from: nextDueDate)
    }
}
