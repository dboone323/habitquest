// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Observation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class SubscriptionsViewModel {
    private var modelContext: ModelContext?

    /// <#Description#>
    /// - Returns: <#description#>
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// Get subscriptions due this week
    /// <#Description#>
    /// - Returns: <#description#>
    func subscriptionsDueThisWeek(_ subscriptions: [Subscription]) -> [Subscription] {
        let calendar = Calendar.current
        let now = Date()
        let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: now) ?? now

        return subscriptions.filter { subscription in
            subscription.isActive && subscription.nextDueDate >= now && subscription.nextDueDate <= endOfWeek
        }
    }

    /// Get subscriptions due today
    /// <#Description#>
    /// - Returns: <#description#>
    func subscriptionsDueToday(_ subscriptions: [Subscription]) -> [Subscription] {
        let calendar = Calendar.current
        let now = Date()

        return subscriptions.filter { subscription in
            subscription.isActive && calendar.isDate(subscription.nextDueDate, inSameDayAs: now)
        }
    }

    /// Get overdue subscriptions
    /// <#Description#>
    /// - Returns: <#description#>
    func overdueSubscriptions(_ subscriptions: [Subscription]) -> [Subscription] {
        let now = Date()
        return subscriptions.filter { subscription in
            subscription.isActive && subscription.nextDueDate < now
        }
    }

    /// Calculate total monthly amount for active subscriptions
    /// <#Description#>
    /// - Returns: <#description#>
    func totalMonthlyAmount(_ subscriptions: [Subscription]) -> Double {
        subscriptions
            .filter(\.isActive)
            .reduce(0.0) { total, subscription in
                // Convert subscription amount to monthly equivalent
                let monthlyAmount: Double = switch subscription.billingCycle {
                case .weekly:
                    subscription.amount * 4.33 // Average weeks per month
                case .monthly:
                    subscription.amount
                case .yearly:
                    subscription.amount / 12.0
                }
                return total + monthlyAmount
            }
    }

    /// Process overdue subscriptions (generate transactions and update next due dates)
    /// <#Description#>
    /// - Returns: <#description#>
    func processOverdueSubscriptions(_ subscriptions: [Subscription]) {
        guard let modelContext else { return }

        let overdue = self.overdueSubscriptions(subscriptions)

        for subscription in overdue {
            subscription.processPayment(modelContext: modelContext)
        }

        try? modelContext.save()
    }

    /// Schedule renewal notifications for subscriptions
    /// <#Description#>
    /// - Returns: <#description#>
    func scheduleSubscriptionNotifications(for _: [Subscription]) {
        // Temporarily disabled due to compilation issues
        // NotificationManager.shared.scheduleSubscriptionNotifications(for: subscriptions)
    }

    /// Get subscriptions grouped by frequency
    /// <#Description#>
    /// - Returns: <#description#>
    func subscriptionsGroupedByFrequency(_ subscriptions: [Subscription]) -> [String: [Subscription]] {
        var grouped: [String: [Subscription]] = [:]

        for subscription in subscriptions {
            let frequencyKey = subscription.billingCycle.rawValue.capitalized
            if grouped[frequencyKey] == nil {
                grouped[frequencyKey] = []
            }
            grouped[frequencyKey]?.append(subscription)
        }

        return grouped
    }
}
