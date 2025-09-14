// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData
import SwiftUI

// MARK: - Account Types

/// Represents the type of a financial account (e.g., checking, savings).
enum AccountType: String, CaseIterable, Codable {
    /// Checking account.
    case checking = "Checking"
    /// Savings account.
    case savings = "Savings"
    /// Credit card account.
    case credit = "Credit Card"
    /// Investment account.
    case investment = "Investment"
    /// Cash account.
    case cash = "Cash"
}

/// Represents a financial account (e.g., checking, savings, credit card) in the app.
@Model
public final class FinancialAccount: Hashable {
    /// The name of the account (e.g., "Chase Checking").
    var name: String
    /// The current balance of the account.
    var balance: Double
    /// The icon name for this account (for UI display).
    var iconName: String
    /// The date the account was created.
    var createdDate: Date
    /// The type of account (checking, savings, etc.).
    var accountType: AccountType
    /// The currency code for this account (e.g., "USD").
    var currencyCode: String
    /// The credit limit for credit card accounts (optional).
    var creditLimit: Double?

    // Relationships
    /// All transactions associated with this account.
    @Relationship(deleteRule: .cascade)
    var transactions: [FinancialTransaction] = []
    /// All subscriptions associated with this account.
    @Relationship(deleteRule: .cascade)
    var subscriptions: [Subscription] = []

    /// Creates a new financial account.
    /// - Parameters:
    ///   - name: The account name.
    ///   - balance: The initial balance.
    ///   - iconName: The icon name for UI display.
    ///   - accountType: The type of account (default: .checking).
    ///   - currencyCode: The currency code (default: "USD").
    ///   - creditLimit: The credit limit (optional).
    init(
        name: String, balance: Double, iconName: String, accountType: AccountType = .checking,
        currencyCode: String = "USD", creditLimit: Double? = nil
    ) {
        self.name = name
        self.balance = balance
        self.iconName = iconName
        self.accountType = accountType
        self.currencyCode = currencyCode
        self.creditLimit = creditLimit
        self.createdDate = Date()
    }

    /// Updates the account balance based on a transaction.
    /// - Parameter transaction: The transaction to apply.
    @MainActor
    func updateBalance(for transaction: FinancialTransaction) {
        switch transaction.transactionType {
        case .income:
            balance += transaction.amount
        case .expense:
            balance -= transaction.amount
        case .transfer:
            // Transfer transactions don't affect the account balance
            // as they move money between accounts
            break
        }
    }

    // MARK: - Hashable Conformance

    /// Hashes the account by name, type, and creation date.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(accountType)
        hasher.combine(createdDate)
    }

    /// Compares two accounts for equality by name, type, and creation date.
    public static func == (lhs: FinancialAccount, rhs: FinancialAccount) -> Bool {
        lhs.name == rhs.name && lhs.accountType == rhs.accountType
            && lhs.createdDate == rhs.createdDate
    }
}
