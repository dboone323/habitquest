// Momentum Finance - Helper Methods for Enhanced Subscription Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)
/// Helper methods for the enhanced subscription detail view
extension Features.Subscriptions.EnhancedSubscriptionDetailView {
    func formatBillingCycle(_ cycle: String) -> String {
        switch cycle {
        case "monthly": "Billed Monthly"
        case "annual": "Billed Annually"
        case "quarterly": "Billed Quarterly"
        case "weekly": "Billed Weekly"
        case "biweekly": "Billed Biweekly"
        default: "Custom Billing"
        }
    }

    func calculateMonthlyCost(_ subscription: Subscription) -> Double {
        switch subscription.billingCycle {
        case "monthly": subscription.amount
        case "annual": subscription.amount / 12
        case "quarterly": subscription.amount / 3
        case "weekly": subscription.amount * 4.33 // Average weeks in a month
        case "biweekly": subscription.amount * 2.17 // Average bi-weeks in a month
        default: subscription.amount
        }
    }

    func calculateAnnualCost(_ subscription: Subscription) -> Double {
        switch subscription.billingCycle {
        case "monthly": subscription.amount * 12
        case "annual": subscription.amount
        case "quarterly": subscription.amount * 4
        case "weekly": subscription.amount * 52
        case "biweekly": subscription.amount * 26
        default: subscription.amount * 12
        }
    }

    func calculateTotalSpent(_ subscription: Subscription) -> Double {
        // In a real app, this would sum up actual transactions
        guard let startDate = subscription.startDate else { return 0 }

        let monthsSinceStart = Calendar.current.dateComponents([.month], from: startDate, to: Date()).month ?? 0
        return self.calculateMonthlyCost(subscription) * Double(monthsSinceStart)
    }

    func calculateFuturePaymentDate(from date: Date, offset: Int, cycle: String) -> Date {
        let calendar = Calendar.current

        switch cycle {
        case "monthly":
            return calendar.date(byAdding: .month, value: offset, to: date) ?? date
        case "annual":
            return calendar.date(byAdding: .year, value: offset, to: date) ?? date
        case "quarterly":
            return calendar.date(byAdding: .month, value: offset * 3, to: date) ?? date
        case "weekly":
            return calendar.date(byAdding: .weekOfYear, value: offset, to: date) ?? date
        case "biweekly":
            return calendar.date(byAdding: .weekOfYear, value: offset * 2, to: date) ?? date
        default:
            return calendar.date(byAdding: .month, value: offset, to: date) ?? date
        }
    }
}
#endif
