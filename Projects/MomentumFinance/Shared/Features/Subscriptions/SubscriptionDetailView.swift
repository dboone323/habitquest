// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

/// A view that shows details for a specific subscription
extension Features.Subscriptions {
    struct SubscriptionDetailView: View {
        @Environment(\.modelContext)
        private var modelContext
        @Environment(\.dismiss)
        private var dismiss

        // Support both direct subscription reference and ID-based navigation
        var subscriptionId: PersistentIdentifier?
        var subscription: Subscription?

        #if canImport(SwiftData)
        #if canImport(SwiftData)
        private var subscriptions: [Subscription] = []
        private var transactions: [FinancialTransaction] = []
        #else
        private var subscriptions: [Subscription] = []
        private var transactions: [FinancialTransaction] = []
        #endif
        #else
        private var subscriptions: [Subscription] = []
        private var transactions: [FinancialTransaction] = []
        #endif

        @State private var showingProcessPaymentConfirmation = false

        // Initialize with direct subscription reference (for backward compatibility)
        init(subscription: Subscription) {
            self.subscription = subscription
            self.subscriptionId = subscription.persistentModelID
        }

        // Initialize with subscription ID (for cross-module navigation)
        init(subscriptionId: PersistentIdentifier) {
            self.subscriptionId = subscriptionId
            self.subscription = nil // Will be resolved in the resolvedSubscription property
        }

        // Resolve the subscription from ID if needed
        private var resolvedSubscription: Subscription? {
            if let subscription {
                return subscription
            }
            return self.subscriptions.first { $0.persistentModelID == self.subscriptionId }
        }

        var body: some View {
            ScrollView {
                if let subscription = resolvedSubscription {
                    VStack(spacing: 24) {
                        // Subscription Amount Header
                        VStack(spacing: 4) {
                            Text(subscription.amount.formatted(.currency(code: "USD")))
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.primary)

                            Text(self.billingFrequencyText(subscription.billingCycle))
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Toggle(
                                "Active",
                                isOn: Binding(
                                    get: { subscription.isActive },
                                    set: { newValue in
                                        subscription.isActive = newValue
                                        try? self.modelContext.save()
                                    },
                                )
                            )
                            .padding(.top, 8)
                            .toggleStyle(.switch)
                            .tint(.blue)
                        }
                        .padding(.bottom, 8)

                        // Subscription Details Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Details")
                                .font(.headline)

                            SubscriptionDetailRow(title: "Name", value: subscription.name)

                            if let category = subscription.category {
                                SubscriptionDetailRow(title: "Category", value: category.name)
                            }

                            if let account = subscription.account {
                                SubscriptionDetailRow(title: "Payment Method", value: account.name)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        // Account navigation will be implemented in future version
                                        // using NavigationCoordinator for cross-module navigation
                                    }
                            }

                            SubscriptionDetailRow(
                                title: "Next Payment",
                                value: subscription.nextDueDate.formatted(
                                    date: .long, time: .omitted
                                ),
                                highlight: self.isPaymentDueSoon(subscription),
                            )

                            SubscriptionDetailRow(
                                title: "Payment Status",
                                value: self.paymentStatusText(subscription),
                                highlight: self.isPaymentOverdue(subscription),
                            )

                            if let notes = subscription.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Text(notes)
                                        .font(.body)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(self.platformBackgroundColor)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
                        )

                        // Payment History (Placeholder)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Payment History")
                                .font(.headline)

                            let relatedTransactions = self.getRelatedTransactions(for: subscription)

                            if relatedTransactions.isEmpty {
                                Text("No payment history available")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                ForEach(relatedTransactions.prefix(5)) { transaction in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(
                                                transaction.date.formatted(
                                                    date: .abbreviated, time: .omitted
                                                )
                                            )
                                            .font(.subheadline)

                                            if let notes = transaction.notes {
                                                Text(notes)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }

                                        Spacer()

                                        Text(transaction.amount.formatted(.currency(code: "USD")))
                                            .font(.body)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.vertical, 4)

                                    if relatedTransactions.firstIndex(of: transaction)
                                        != relatedTransactions.prefix(5).count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(self.platformBackgroundColor)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
                        )

                        // Action Button
                        Button(
                            action: {
                                self.showingProcessPaymentConfirmation = true
                            },
                            label: {
                                Label("Process Payment Now", systemImage: "creditcard.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.blue),
                                    )
                                    .foregroundColor(.white)
                            }
                        )
                        .disabled(!subscription.isActive)
                    }
                    .padding()
                    .navigationTitle("Subscription Details")
                    .alert("Process Payment", isPresented: self.$showingProcessPaymentConfirmation) {
                        Button("Cancel", role: .cancel) {
                            self.showingProcessPaymentConfirmation = false
                        }
                        .accessibilityLabel("Cancel")
                        Button("Process Payment") {
                            subscription.processPayment(modelContext: self.modelContext)
                        }
                        .accessibilityLabel("Process Payment")
                    } message: {
                        Text(
                            "Process a payment of \(subscription.amount.formatted(.currency(code: "USD"))) "
                                + "for this subscription?"
                        )
                    }
                } else {
                    ContentUnavailableView(
                        "Subscription Not Found",
                        systemImage: "creditcard.slash",
                        description: Text("The requested subscription could not be found"),
                    )
                }
            }
        }

        private func billingFrequencyText(_ cycle: BillingCycle) -> String {
            switch cycle {
            case .weekly:
                "Billed Weekly"
            case .monthly:
                "Billed Monthly"
            case .yearly:
                "Billed Yearly"
            }
        }

        private func paymentStatusText(_ subscription: Subscription) -> String {
            if self.isPaymentOverdue(subscription) {
                "Overdue"
            } else if self.isPaymentDueSoon(subscription) {
                "Due Soon"
            } else {
                "Up to Date"
            }
        }

        private func isPaymentOverdue(_ subscription: Subscription) -> Bool {
            subscription.nextDueDate < Date()
        }

        private func isPaymentDueSoon(_ subscription: Subscription) -> Bool {
            let oneWeek: TimeInterval = 7 * 24 * 60 * 60
            let now = Date()
            return !self.isPaymentOverdue(subscription)
                && subscription.nextDueDate < now.addingTimeInterval(oneWeek)
        }

        private func getRelatedTransactions(for subscription: Subscription)
            -> [FinancialTransaction] {
            // In a real implementation, we would filter transactions specifically related to this subscription
            // For example, by matching notes field or subscription ID field
            self.transactions
                .filter {
                    $0.account?.id == subscription.account?.id && $0.amount == subscription.amount
                        && $0.transactionType == .expense
                }
                .sorted(by: { $0.date > $1.date })
        }

        // Cross-platform background color
        private var platformBackgroundColor: Color {
            #if canImport(UIKit)
            return Color(uiColor: .systemBackground)
            #elseif canImport(AppKit)
            return Color(nsColor: .windowBackgroundColor)
            #else
            return Color.white
            #endif
        }
    }
}

public struct SubscriptionDetailRow: View {
    let title: String
    let value: String
    var highlight: Bool = false

    public var body: some View {
        HStack {
            Text(self.title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(self.value)
                .font(.body)
                .foregroundColor(self.highlight ? .red : .primary)
        }
    }
}
