// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

/// Represents the billing cycle for a subscription (weekly, monthly, yearly).
public enum BillingCycle: String, CaseIterable, Codable {
    /// Weekly billing cycle.
    case weekly = "Weekly"
    /// Monthly billing cycle.
    case monthly = "Monthly"
    /// Yearly billing cycle.
    case yearly = "Yearly"

    /// Number of days in the billing cycle.
    public var daysInCycle: Int {
        switch self {
        case .weekly:
            7
        case .monthly:
            30
        case .yearly:
            365
        }
    }

    /// Date component for calculating next billing date.
    public var dateComponent: DateComponents {
        switch self {
        case .weekly:
            DateComponents(weekOfYear: 1)
        case .monthly:
            DateComponents(month: 1)
        case .yearly:
            DateComponents(year: 1)
        }
    }

    /// Calculates the next due date for this billing cycle from a given date.
    /// - Parameter date: The starting date.
    /// - Returns: The next due date as a Date.
    public func nextDueDate(from date: Date) -> Date {
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
    public var name: String
    /// The recurring payment amount.
    public var amount: Double
    /// The billing cycle for this subscription.
    public var billingCycle: BillingCycle
    /// The next due date for payment.
    public var nextDueDate: Date
    /// Whether the subscription is currently active.
    public var isActive: Bool
    /// Optional notes or memo for the subscription.
    public var notes: String?
    /// The icon name for this subscription (for UI display).
    public var icon: String

    // Relationships
    /// The category associated with this subscription (optional).
    public var category: ExpenseCategory?
    /// The financial account associated with this subscription (optional).
    public var account: FinancialAccount?
    /// Payment history for this subscription.
    @Relationship(deleteRule: .cascade, inverse: \SubscriptionPayment.subscription)
    public var payments: [SubscriptionPayment] = []

    /// Creates a new subscription.
    /// - Parameters:
    ///   - name: The subscription name.
    ///   - amount: The recurring payment amount.
    ///   - billingCycle: The billing cycle.
    ///   - nextDueDate: The next due date for payment.
    ///   - notes: Optional notes or memo.
    ///   - icon: The icon name for UI display (default: "creditcard").
    public init(
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
    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self.amount)) ?? "$0.00"
    }

    /// Returns the number of days until the next payment is due.
    public var daysUntilDue: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: self.nextDueDate)
        return max(0, components.day ?? 0)
    }

    /// Compatibility accessor: some code expects `nextBillingDate` (optional).
    /// Maps to the canonical `nextDueDate` property.
    public var nextBillingDate: Date? {
        get { self.nextDueDate }
        set {
            // If a new date is provided, update the canonical nextDueDate.
            // If nil is assigned, ignore to preserve existing non-optional storage.
            if let newValue {
                self.nextDueDate = newValue
            }
        }
    }

    /// Returns the monthly equivalent amount for budgeting calculations.
    public var monthlyEquivalent: Double {
        switch self.billingCycle {
        case .weekly:
            self.amount * 52 / 12 // Weekly * 52 weeks / 12 months
        case .monthly:
            self.amount
        case .yearly:
            self.amount / 12
        }
    }

    /// Processes a payment for this subscription: creates a transaction, updates account, and advances due date.
    /// - Parameter modelContext: The model context for inserting the transaction.
    @MainActor
    public func processPayment(modelContext: ModelContext) {
        // Create transaction for this subscription payment
        let transaction = FinancialTransaction(
            title: name,
            amount: amount,
            date: nextDueDate,
            transactionType: .expense,
            notes: "Auto-generated from subscription"
        )
        transaction.category = self.category
        transaction.account = self.account

        modelContext.insert(transaction)

        // Update account balance
        self.account?.updateBalance(for: transaction)

        // Set next due date
        self.nextDueDate = self.billingCycle.nextDueDate(from: self.nextDueDate)
    }
}

/// Represents a payment made for a subscription.
@Model
public final class SubscriptionPayment {
    /// The date the payment was made.
    public var date: Date
    /// The amount paid.
    public var amount: Double
    /// Optional notes about the payment.
    public var notes: String?

    // Relationships
    /// The subscription this payment belongs to.
    public var subscription: Subscription?

    /// Creates a new subscription payment.
    /// - Parameters:
    ///   - date: The date the payment was made.
    ///   - amount: The amount paid.
    ///   - subscription: The subscription this payment belongs to.
    ///   - notes: Optional notes about the payment.
    public init(date: Date, amount: Double, subscription: Subscription? = nil, notes: String? = nil) {
        self.date = date
        self.amount = amount
        self.subscription = subscription
        self.notes = notes
    }

    /// Returns the amount as a formatted currency string.
    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self.amount)) ?? "$0.00"
    }
}
