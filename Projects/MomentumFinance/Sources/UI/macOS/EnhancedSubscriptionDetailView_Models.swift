// Momentum Finance - Models for Enhanced Subscription Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)
/// Supporting models for the enhanced subscription detail view
extension Features.Subscriptions.EnhancedSubscriptionDetailView {
    struct SubscriptionEditModel {
        var name: String
        var provider: String
        var amount: Double
        var billingCycle: String
        var startDate: Date?
        var nextPaymentDate: Date?
        var notes: String
        var currencyCode: String
        var category: String?
        var paymentMethod: String?
        var autoRenews: Bool

        init(from subscription: Subscription) {
            self.name = subscription.name
            self.provider = subscription.provider
            self.amount = subscription.amount
            self.billingCycle = subscription.billingCycle
            self.startDate = subscription.startDate
            self.nextPaymentDate = subscription.nextPaymentDate
            self.notes = subscription.notes
            self.currencyCode = subscription.currencyCode
            self.category = subscription.category
            self.paymentMethod = subscription.paymentMethod
            self.autoRenews = subscription.autoRenews
        }
    }
}
#endif
