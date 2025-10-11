// Momentum Finance - Action Methods for Enhanced Account Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Shared
import SwiftData

#if os(macOS)
/// Action methods for the enhanced account detail view
extension EnhancedAccountDetailView {
    func saveChanges() {
        guard let account, let editData = editedAccount else {
            self.isEditing = false
            return
        }

        // Update account with edited values
        account.name = editData.name
        account.type = editData.type
        account.balance = editData.balance
        account.currencyCode = editData.currencyCode
        account.institution = editData.institution
        account.accountNumber = editData.accountNumber
        account.interestRate = editData.interestRate
        account.creditLimit = editData.creditLimit
        account.dueDate = editData.dueDate
        account.includeInTotal = editData.includeInTotal
        account.isActive = editData.isActive
        account.notes = editData.notes

        // Save changes to the model context
        try? self.modelContext.save()

        self.isEditing = false
    }

    func deleteAccount() {
        guard let account else { return }

        // First delete all associated transactions
        for transaction in self.filteredTransactions {
            self.modelContext.delete(transaction)
        }

        // Then delete the account
        self.modelContext.delete(account)
        try? self.modelContext.save()

        // Navigate back would happen here
    }

    func addTransaction() {
        guard let account else { return }

        // Create a new transaction
        let transaction = FinancialTransaction(
            name: "New Transaction",
            amount: 0,
            date: Date(),
            notes: "",
            isReconciled: false,
        )

        // Set the account relationship
        transaction.account = account

        // Add transaction to the model context
        self.modelContext.insert(transaction)
        try? self.modelContext.save()

        // Ideally navigate to this transaction for editing
    }

    func toggleTransactionStatus(_ transaction: FinancialTransaction) {
        transaction.isReconciled.toggle()
        try? self.modelContext.save()
    }

    func deleteTransaction(_ transaction: FinancialTransaction) {
        self.modelContext.delete(transaction)
        try? self.modelContext.save()
    }

    func printAccountSummary() {
        // Implementation for printing
    }
}
#endif
