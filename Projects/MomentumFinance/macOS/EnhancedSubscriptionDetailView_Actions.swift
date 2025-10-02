// Momentum Finance - Action Methods for Enhanced Subscription Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)
/// Action methods for the enhanced subscription detail view
extension Features.Subscriptions.EnhancedSubscriptionDetailView {
    func saveChanges() {
        guard let subscription, let editData = editedSubscription else {
            self.isEditing = false
            return
        }

        // Update subscription with edited values
        subscription.name = editData.name
        subscription.provider = editData.provider
        subscription.amount = editData.amount
        subscription.billingCycle = editData.billingCycle
        subscription.startDate = editData.startDate
        subscription.nextPaymentDate = editData.nextPaymentDate
        subscription.notes = editData.notes
        subscription.currencyCode = editData.currencyCode
        subscription.category = editData.category
        subscription.paymentMethod = editData.paymentMethod
        subscription.autoRenews = editData.autoRenews

        // Save changes to the model context
        try? self.modelContext.save()

        self.isEditing = false
    }

    func deleteSubscription() {
        guard let subscription else { return }

        // Delete the subscription from the model context
        self.modelContext.delete(subscription)
        try? self.modelContext.save()

        // Navigate back would happen here
    }

    func addTransaction() {
        // Logic to add a new transaction for this subscription
    }

    func toggleTransactionStatus(_ transaction: FinancialTransaction) {
        transaction.isReconciled.toggle()
        try? self.modelContext.save()
    }

    func markAsPaid() {
        guard let subscription, let nextDate = subscription.nextPaymentDate else { return }

        // Create a new transaction for this payment
        let transaction = FinancialTransaction(
            name: "\(subscription.provider) - \(subscription.name)",
            amount: -subscription.amount,
            date: nextDate,
            notes: "Automatic payment for subscription",
            isReconciled: true,
        )

        transaction.subscriptionId = subscription.id

        // Calculate next payment date based on billing cycle
        if let newNextDate = calculateFuturePaymentDate(from: nextDate, offset: 1, cycle: subscription.billingCycle) {
            subscription.nextPaymentDate = newNextDate
        }

        // Add transaction to the model context
        self.modelContext.insert(transaction)
        try? self.modelContext.save()
    }

    func skipNextPayment() {
        guard let subscription, let nextDate = subscription.nextPaymentDate else { return }

        // Calculate next payment date based on billing cycle and skip one period
        if let newNextDate = calculateFuturePaymentDate(from: nextDate, offset: 1, cycle: subscription.billingCycle) {
            subscription.nextPaymentDate = newNextDate
            try? self.modelContext.save()
        }
    }

    func pauseSubscription() {
        guard let subscription else { return }

        // Store the current next payment date for later resumption
        // In a real app, you'd store this in the model
        let savedNextDate = subscription.nextPaymentDate

        // Clear the next payment date to indicate paused status
        subscription.nextPaymentDate = nil
        try? self.modelContext.save()
    }

    func exportAsPDF() {
        // Implementation for PDF export
    }

    func printSubscription() {
        // Implementation for printing
    }
}
#endif
