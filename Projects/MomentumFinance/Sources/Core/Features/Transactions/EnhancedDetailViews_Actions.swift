// Momentum Finance - Enhanced Transaction Detail Actions
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import SwiftData
import SwiftUI

// MARK: - Action Methods

/// Action methods for transaction detail operations
struct TransactionDetailActions {
    let modelContext: ModelContext

    /// Save edited transaction changes
    func saveChanges(transaction: FinancialTransaction?, editedTransaction: TransactionEditModel?) {
        guard let transaction, let editData = editedTransaction else {
            return
        }

        // Update transaction with edited values
        transaction.name = editData.name
        transaction.amount = editData.amount
        transaction.date = editData.date
        transaction.notes = editData.notes
        transaction.isReconciled = editData.isReconciled
        transaction.isRecurring = editData.isRecurring
        transaction.location = editData.location
        transaction.subcategory = editData.subcategory

        // Category and account relationships would be handled here

        // Save changes to the model context
        try? self.modelContext.save()
    }

    /// Delete a transaction
    func deleteTransaction(_ transaction: FinancialTransaction) {
        self.modelContext.delete(transaction)
        try? self.modelContext.save()
        // Navigate back
    }

    /// Create a duplicate of the transaction
    func duplicateTransaction(original: FinancialTransaction?) -> FinancialTransaction? {
        guard let original else { return nil }

        let duplicate = FinancialTransaction(
            name: "Copy of \(original.name)",
            amount: original.amount,
            date: Date(),
            notes: original.notes,
            isReconciled: false,
        )

        // Copy other properties and relationships
        duplicate.isRecurring = original.isRecurring
        duplicate.location = original.location
        duplicate.subcategory = original.subcategory
        // Category and account would be set here

        self.modelContext.insert(duplicate)
        try? self.modelContext.save()

        return duplicate
    }

    /// Toggle reconciliation status
    func toggleReconciled(transaction: FinancialTransaction?) {
        guard let transaction else { return }
        transaction.isReconciled.toggle()
        try? self.modelContext.save()
    }

    /// Navigate to account detail
    func navigateToAccount(transaction: FinancialTransaction?) {
        guard let transaction, let accountId = transaction.account?.id else { return }
        // Navigate to account detail
    }

    /// Print transaction details
    func printTransaction(transaction: FinancialTransaction?) {
        // Implementation for printing
    }

    /// Export transaction data
    func exportTransaction(transaction: FinancialTransaction?, format: String = "csv") {
        // Implementation for exporting
    }

    /// Show related transactions
    func showRelatedTransactions(transaction: FinancialTransaction?) {
        // Implementation for showing related transactions
    }
}
