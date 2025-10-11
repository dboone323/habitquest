// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

/// Represents the type of a financial transaction (income, expense, or transfer).
public enum TransactionType: String, CaseIterable, Codable {
    /// Income transaction (money received).
    case income = "Income"
    /// Expense transaction (money spent).
    case expense = "Expense"
    /// Transfer transaction (money moved between accounts).
    case transfer = "Transfer"
}

/// Represents a single financial transaction (income or expense) in the app.
@Model
public final class FinancialTransaction {
    /// The title or description of the transaction.
    public var title: String
    /// The amount of money for the transaction.
    public var amount: Double
    /// The date the transaction occurred.
    public var date: Date
    /// The type of transaction (income or expense).
    public var transactionType: TransactionType
    /// Optional notes or memo for the transaction.
    public var notes: String?

    // Relationships
    /// The category associated with this transaction (optional).
    public var category: ExpenseCategory?
    /// The financial account associated with this transaction (optional).
    public var account: FinancialAccount?

    /// Creates a new financial transaction.
    /// - Parameters:
    ///   - title: The title or description.
    ///   - amount: The transaction amount.
    ///   - date: The date of the transaction.
    ///   - transactionType: The type (income or expense).
    ///   - notes: Optional notes or memo.
    public init(
        title: String, amount: Double, date: Date, transactionType: TransactionType,
        notes: String? = nil
    ) {
        self.title = title
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.notes = notes
    }

    /// Returns the amount as a formatted currency string, with a sign based on transaction type.
    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        let sign = self.transactionType == .income ? "+" : "-"
        let formattedValue = formatter.string(from: NSNumber(value: self.amount)) ?? "$0.00"

        return "\(sign)\(formattedValue)"
    }

    /// Returns the transaction date as a formatted string for display.
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self.date)
    }
}
