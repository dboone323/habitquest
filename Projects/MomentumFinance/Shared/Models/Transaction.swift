// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.
// #-hidden-code
import CoreData

/// Represents a simple transaction record for legacy or compatibility use.
public struct Transaction: Identifiable, Codable {
    /// Unique identifier for the transaction.
    public var id: UUID
    /// The amount of the transaction.
    var amount: Double
    /// The date the transaction occurred.
    var date: Date
    /// The category name for this transaction.
    var category: String
    /// Optional note or memo for the transaction.
    var note: String?
    /// The type of transaction (income or expense).
    var type: TransactionType

    /// The type of transaction (income or expense).
    enum TransactionType: String, Codable {
        /// Income transaction (money received).
        case income
        /// Expense transaction (money spent).
        case expense
    }
}

// #-end-hidden-code
