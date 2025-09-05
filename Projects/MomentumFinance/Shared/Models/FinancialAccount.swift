// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData
import SwiftUI

// MARK: - Account Types

enum AccountType: String, CaseIterable, Codable {
    case checking = "Checking"
    case savings = "Savings"
    case credit = "Credit Card"
    case investment = "Investment"
    case cash = "Cash"
}

@Model
public final class FinancialAccount {
    var name: String
    var balance: Double
    var iconName: String
    var createdDate: Date
    var accountType: AccountType
    var currencyCode: String
    var creditLimit: Double?

    // Relationships
    @Relationship(deleteRule: .cascade)
    var transactions: [FinancialTransaction] = []
    @Relationship(deleteRule: .cascade)
    var subscriptions: [Subscription] = []

    init(name: String, balance: Double, iconName: String, accountType: AccountType = .checking, currencyCode: String = "USD", creditLimit: Double? = nil) {
        self.name = name
        self.balance = balance
        self.iconName = iconName
        self.accountType = accountType
        self.currencyCode = currencyCode
        self.creditLimit = creditLimit
        self.createdDate = Date()
    }

    /// Updates the account balance based on a transaction
    @MainActor
    func updateBalance(for transaction: FinancialTransaction) {
        switch transaction.transactionType {
        case .income:
            balance += transaction.amount
        case .expense:
            balance -= transaction.amount
        }
    }
}
