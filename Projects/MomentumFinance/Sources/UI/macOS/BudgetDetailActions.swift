// Momentum Finance - Budget Detail Action Methods for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

#if os(macOS)
extension Features.Budgets.BudgetDetailView {
    /// Action methods for the budget detail view
    func saveChanges() {
        guard let budget, let editData = editedBudget else {
            self.isEditing = false
            return
        }

        // Update budget with edited values
        budget.name = editData.name
        budget.amount = editData.amount
        budget.period = editData.period
        budget.notes = editData.notes
        budget.rollover = editData.rollover

        // Category relationship would be handled here

        // Save changes to the model context
        try? self.modelContext.save()

        self.isEditing = false
    }

    func deleteBudget() {
        guard let budget else { return }

        // Delete the budget from the model context
        self.modelContext.delete(budget)
        try? self.modelContext.save()

        // Navigate back would happen here
    }

    func addTransaction() {
        // Logic to add a new transaction to this budget/category
    }

    func exportAsPDF() {
        // Implementation for PDF export
    }

    func printBudget() {
        // Implementation for printing
    }
}
#endif
