// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

public enum TransactionType: String, CaseIterable, Codable {
    case income = "Income"
    case expense = "Expense"
}

@Model
public final class FinancialTransaction: @unchecked Sendable {
    var title: String
    var amount: Double
    var date: Date
    var transactionType: TransactionType
    var notes: String?

    // Relationships
    var category: ExpenseCategory?
    var account: FinancialAccount?

    init(title: String, amount: Double, date: Date, transactionType: TransactionType, notes: String? = nil) {
        self.title = title
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.notes = notes
    }

    /// Formatted amount string with proper sign
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        let sign = transactionType == .income ? "+" : "-"
        let formattedValue = formatter.string(from: NSNumber(value: amount)) ?? "$0.00"

        return "\(sign)\(formattedValue)"
    }

    /// Date formatted for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
