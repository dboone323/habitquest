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

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData
import SecurityFramework

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

    // Security fields
    /// Unique transaction ID for audit trails
    public var transactionId: String
    /// Encrypted sensitive data (notes that may contain PII)
    public var encryptedNotes: Data?
    /// Audit trail: creation timestamp
    public var createdAt: Date
    /// Audit trail: last modification timestamp
    public var modifiedAt: Date
    /// Audit trail: user who created the transaction
    public var createdBy: String
    /// Audit trail: user who last modified the transaction
    public var modifiedBy: String

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
    ///   - userId: ID of the user creating the transaction.
    public init(
        title: String, amount: Double, date: Date, transactionType: TransactionType,
        notes: String? = nil, userId: String = "system"
    ) {
        self.title = title
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.notes = notes

        // Initialize security fields
        self.transactionId = UUID().uuidString
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.createdBy = userId
        self.modifiedBy = userId

        // Encrypt sensitive notes if present
        if let notes = notes {
            self.encryptedNotes = self.encryptSensitiveData(notes)
        }

        // Log transaction creation
        self.logTransactionCreation()
    }

    /// Updates the transaction with new values and logs the change.
    /// - Parameters:
    ///   - title: New title (optional).
    ///   - amount: New amount (optional).
    ///   - date: New date (optional).
    ///   - transactionType: New transaction type (optional).
    ///   - notes: New notes (optional).
    ///   - userId: ID of the user making the change.
    public func update(
        title: String? = nil,
        amount: Double? = nil,
        date: Date? = nil,
        transactionType: TransactionType? = nil,
        notes: String? = nil,
        userId: String = "system"
    ) {
        let oldValues = [
            "title": self.title,
            "amount": String(self.amount),
            "date": self.date.description,
            "transactionType": self.transactionType.rawValue,
            "notes": self.notes ?? ""
        ]

        // Update fields
        if let title = title { self.title = title }
        if let amount = amount { self.amount = amount }
        if let date = date { self.date = date }
        if let transactionType = transactionType { self.transactionType = transactionType }
        if let notes = notes {
            self.notes = notes
            self.encryptedNotes = self.encryptSensitiveData(notes)
        }

        self.modifiedAt = Date()
        self.modifiedBy = userId

        // Log transaction update
        self.logTransactionUpdate(oldValues: oldValues, userId: userId)
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

    /// Returns decrypted notes if available, otherwise returns the plain notes.
    public var decryptedNotes: String? {
        if let encryptedNotes = encryptedNotes {
            return decryptSensitiveData(encryptedNotes)
        }
        return notes
    }

    // MARK: - Security Methods

    private func encryptSensitiveData(_ data: String) -> Data? {
        do {
            return try EncryptionService.shared.encryptString(data).encryptedData
        } catch {
            // Log encryption failure
            AuditLogger.shared.logSecurityEvent(
                eventType: .system,
                userId: createdBy,
                details: [
                    "action": "encryption_failed",
                    "transaction_id": transactionId,
                    "error": error.localizedDescription
                ],
                severity: .medium
            )
            return nil
        }
    }

    private func decryptSensitiveData(_ encryptedData: Data) -> String? {
        do {
            let encrypted = EncryptedData(
                encryptedData: encryptedData,
                keyIdentifier: "default",
                algorithm: "AES-256-GCM",
                timestamp: Date()
            )
            return try EncryptionService.shared.decryptToString(encrypted)
        } catch {
            // Log decryption failure
            AuditLogger.shared.logSecurityEvent(
                eventType: .system,
                userId: createdBy,
                details: [
                    "action": "decryption_failed",
                    "transaction_id": transactionId,
                    "error": error.localizedDescription
                ],
                severity: .high
            )
            return nil
        }
    }

    private func logTransactionCreation() {
        AuditLogger.shared.logTransaction(
            transactionId: transactionId,
            amount: amount,
            type: transactionType == .income ? .deposit : .withdrawal,
            accountId: account?.accountId ?? "unknown",
            userId: createdBy,
            details: [
                "title": title,
                "date": date.description,
                "action": "created"
            ]
        )
    }

    private func logTransactionUpdate(oldValues: [String: String], userId: String) {
        let newValues = [
            "title": title,
            "amount": String(amount),
            "date": date.description,
            "transactionType": transactionType.rawValue,
            "notes": notes ?? ""
        ]

        AuditLogger.shared.logSecurityEvent(
            eventType: .dataAccess,
            userId: userId,
            details: [
                "action": "transaction_updated",
                "transaction_id": transactionId,
                "old_values": oldValues,
                "new_values": newValues
            ],
            severity: .low
        )
    }
}
