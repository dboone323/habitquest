// Momentum Finance - Enhanced Account Detail Models for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Shared
import SwiftData
import SwiftUI

#if os(macOS)

// MARK: - Supporting Models for Enhanced Account Detail View

/// Model for editing account information
struct AccountEditModel {
    var name: String
    var type: FinancialAccount.AccountType
    var balance: Double
    var currencyCode: String
    var institution: String?
    var accountNumber: String?
    var interestRate: Double?
    var creditLimit: Double?
    var dueDate: Int?
    var includeInTotal: Bool
    var isActive: Bool
    var notes: String?

    init(from account: FinancialAccount) {
        self.name = account.name
        self.type = account.type
        self.balance = account.balance
        self.currencyCode = account.currencyCode
        self.institution = account.institution
        self.accountNumber = account.accountNumber
        self.interestRate = account.interestRate
        self.creditLimit = account.creditLimit
        self.dueDate = account.dueDate
        self.includeInTotal = account.includeInTotal
        self.isActive = account.isActive
        self.notes = account.notes
    }
}
#endif
