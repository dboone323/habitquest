// Momentum Finance - macOS Subscriptions UI Enhancements
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

#if os(macOS)
// Subscriptions-specific UI enhancements
extension Features.Subscriptions {
    /// macOS-specific subscriptions list view
    struct SubscriptionListView: View {
        @Environment(\.modelContext) private var modelContext
        @Query private var subscriptions: [Subscription]
        @State private var selectedItem: ListableItem?
        @State private var groupBy: GroupOption = .date

        enum GroupOption {
            case date, amount, provider
        }

        var body: some View {
            List(selection: self.$selectedItem) {
                ForEach(self.getGroupedSubscriptions()) { group in
                    Section(header: Text(group.title)) {
                        ForEach(group.items) { subscription in
                            NavigationLink(value: ListableItem(id: subscription.id, name: subscription.name, type: .subscription)) {
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundStyle(.purple)

                                    VStack(alignment: .leading) {
                                        Text(subscription.name)
                                            .font(.headline)

                                        Text(subscription.provider)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text(subscription.amount.formatted(.currency(code: "USD")))
                                            .font(.subheadline)

                                        Text(subscription.billingCycle.displayName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .tag(ListableItem(id: subscription.id, name: subscription.name, type: .subscription))
                        }
                    }
                }
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem {
                    Picker("Group By", selection: self.$groupBy) {
                        Text("Next Payment").tag(GroupOption.date)
                        Text("Amount").tag(GroupOption.amount)
                        Text("Provider").tag(GroupOption.provider)
                    }
                    .pickerStyle(.menu)
                }

                ToolbarItem {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                    .help("Add New Subscription")
                }
            }
        }

        struct SubscriptionGroup: Identifiable {
            let id = UUID()
            let title: String
            let items: [Subscription]
        }

        private func getGroupedSubscriptions() -> [SubscriptionGroup] {
            switch self.groupBy {
            case .date:
                // Group by next payment date (simplified)
                let thisWeek = self.subscriptions.filter {
                    guard let nextDate = $0.nextPaymentDate else { return false }
                    return Calendar.current.isDate(nextDate, equalTo: Date(), toGranularity: .weekOfYear)
                }

                let thisMonth = self.subscriptions.filter {
                    guard let nextDate = $0.nextPaymentDate else { return false }
                    return Calendar.current.isDate(nextDate, equalTo: Date(), toGranularity: .month) &&
                        !Calendar.current.isDate(nextDate, equalTo: Date(), toGranularity: .weekOfYear)
                }

                let future = self.subscriptions.filter {
                    guard let nextDate = $0.nextPaymentDate else { return false }
                    return nextDate > Date() &&
                        !Calendar.current.isDate(nextDate, equalTo: Date(), toGranularity: .month)
                }

                var result: [SubscriptionGroup] = []
                if !thisWeek.isEmpty {
                    result.append(SubscriptionGroup(title: "Due This Week", items: thisWeek))
                }
                if !thisMonth.isEmpty {
                    result.append(SubscriptionGroup(title: "Due This Month", items: thisMonth))
                }
                if !future.isEmpty {
                    result.append(SubscriptionGroup(title: "Upcoming", items: future))
                }

                return result

            case .amount:
                // Group by price tiers
                let lowTier = self.subscriptions.filter { $0.amount < 10 }
                let midTier = self.subscriptions.filter { $0.amount >= 10 && $0.amount < 25 }
                let highTier = self.subscriptions.filter { $0.amount >= 25 }

                var result: [SubscriptionGroup] = []
                if !lowTier.isEmpty {
                    result.append(SubscriptionGroup(title: "Under $10", items: lowTier))
                }
                if !midTier.isEmpty {
                    result.append(SubscriptionGroup(title: "$10 - $25", items: midTier))
                }
                if !highTier.isEmpty {
                    result.append(SubscriptionGroup(title: "Over $25", items: highTier))
                }

                return result

            case .provider:
                // Group by provider
                let grouped = Dictionary(grouping: subscriptions) { $0.provider }
                return grouped.map {
                    SubscriptionGroup(title: $0.key, items: $0.value)
                }.sorted { $0.title < $1.title }
            }
        }
    }
}
#endif
