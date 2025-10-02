// Momentum Finance - Enhanced Budget Detail Supporting Models for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

#if os(macOS)
extension Features.Budgets.EnhancedBudgetDetailView {
    /// Supporting models for the enhanced budget detail view
    struct BudgetEditModel {
        var name: String
        var amount: Double
        var categoryId: String
        var period: String
        var notes: String
        var resetOption: String
        var rollover: Bool

        init(from budget: Budget) {
            self.name = budget.name
            self.amount = budget.amount
            self.categoryId = budget.category?.id ?? ""
            self.period = budget.period
            self.notes = budget.notes
            self.resetOption = "monthly" // Default
            self.rollover = budget.rollover
        }
    }
}
#endif
