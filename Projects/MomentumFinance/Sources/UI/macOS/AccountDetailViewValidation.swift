// Momentum Finance - Validation Methods for Enhanced Account Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Shared
import SwiftData

#if os(macOS)
/// Validation methods for the enhanced account detail view
extension EnhancedAccountDetailView {
    var canSaveChanges: Bool {
        guard let editData = editedAccount else { return false }

        // Basic validation - name is required
        return !editData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasUnsavedChanges: Bool {
        guard let account, let editData = editedAccount else { return false }

        return account.name != editData.name ||
            account.type != editData.type ||
            account.balance != editData.balance ||
            account.currencyCode != editData.currencyCode ||
            account.institution != editData.institution ||
            account.accountNumber != editData.accountNumber ||
            account.interestRate != editData.interestRate ||
            account.creditLimit != editData.creditLimit ||
            account.dueDate != editData.dueDate ||
            account.includeInTotal != editData.includeInTotal ||
            account.isActive != editData.isActive ||
            account.notes != editData.notes
    }

    var validationErrors: [String] {
        guard let editData = editedAccount else { return [] }
        var errors: [String] = []

        if editData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Account name is required")
        }

        if editData.balance < 0 {
            errors.append("Balance cannot be negative")
        }

        if editData.type == .credit, let creditLimit = editData.creditLimit, creditLimit <= 0 {
            errors.append("Credit limit must be greater than zero")
        }

        if editData.type == .credit, let interestRate = editData.interestRate, interestRate < 0 {
            errors.append("Interest rate cannot be negative")
        }

        return errors
    }

    var isValidAccount: Bool {
        self.validationErrors.isEmpty && self.canSaveChanges
    }
}
#endif
