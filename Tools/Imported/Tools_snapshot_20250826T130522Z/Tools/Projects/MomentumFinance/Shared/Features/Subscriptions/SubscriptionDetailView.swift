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

<<<<<<< HEAD
        @Query private var subscriptions: [Subscription]
        @Query private var transactions: [FinancialTransaction]
=======
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
>>>>>>> 1cf3938 (Create working state for recovery)

        @State private var showingProcessPaymentConfirmation = false

        // Initialize with direct subscription reference (for backward compatibility)
        init(subscription: Subscription) {
            self.subscription = subscription
            self.subscriptionId = subscription.persistentModelID
        }

        // Initialize with subscription ID (for cross-module navigation)
        init(subscriptionId: PersistentIdentifier) {
            self.subscriptionId = subscriptionId
<<<<<<< HEAD
            self.subscription = nil // Will be resolved in the resolvedSubscription property
=======
            self.subscription = nil  // Will be resolved in the resolvedSubscription property
>>>>>>> 1cf3938 (Create working state for recovery)
        }

        // Resolve the subscription from ID if needed
        private var resolvedSubscription: Subscription? {
            if let subscription {
                return subscription
            }
            return subscriptions.first { $0.persistentModelID == subscriptionId }
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

                            Text(billingFrequencyText(subscription.billingCycle))
                                .font(.headline)
                                .foregroundColor(.secondary)

<<<<<<< HEAD
                            Toggle("Active", isOn: Binding(
                                get: { subscription.isActive },
                                set: { newValue in
                                    subscription.isActive = newValue
                                    try? modelContext.save()
                                },
                                ))
=======
                            Toggle(
                                "Active",
                                isOn: Binding(
                                    get: { subscription.isActive },
                                    set: { newValue in
                                        subscription.isActive = newValue
                                        try? modelContext.save()
                                    },
                                )
                            )
>>>>>>> 1cf3938 (Create working state for recovery)
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
<<<<<<< HEAD
                                value: subscription.nextDueDate.formatted(date: .long, time: .omitted),
                                highlight: isPaymentDueSoon(subscription),
                                )
=======
                                value: subscription.nextDueDate.formatted(
                                    date: .long, time: .omitted),
                                highlight: isPaymentDueSoon(subscription),
                            )
>>>>>>> 1cf3938 (Create working state for recovery)

                            SubscriptionDetailRow(
                                title: "Payment Status",
                                value: paymentStatusText(subscription),
                                highlight: isPaymentOverdue(subscription),
<<<<<<< HEAD
                                )
=======
                            )
>>>>>>> 1cf3938 (Create working state for recovery)

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
                                .fill(platformBackgroundColor)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
<<<<<<< HEAD
                            )
=======
                        )
>>>>>>> 1cf3938 (Create working state for recovery)

                        // Payment History (Placeholder)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Payment History")
                                .font(.headline)

                            let relatedTransactions = getRelatedTransactions(for: subscription)

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
<<<<<<< HEAD
                                            Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.subheadline)
=======
                                            Text(
                                                transaction.date.formatted(
                                                    date: .abbreviated, time: .omitted)
                                            )
                                            .font(.subheadline)
>>>>>>> 1cf3938 (Create working state for recovery)

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

<<<<<<< HEAD
                                    if relatedTransactions.firstIndex(of: transaction) !=
                                        relatedTransactions.prefix(5).count - 1 {
=======
                                    if relatedTransactions.firstIndex(of: transaction)
                                        != relatedTransactions.prefix(5).count - 1
                                    {
>>>>>>> 1cf3938 (Create working state for recovery)
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(platformBackgroundColor)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
<<<<<<< HEAD
                            )

                        // Action Button
                        Button(action: {
                            showingProcessPaymentConfirmation = true
                        }, label: {
                            Label("Process Payment Now", systemImage: "creditcard.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue),
                                    )
                                .foregroundColor(.white)
                        })
=======
                        )

                        // Action Button
                        Button(
                            action: {
                                showingProcessPaymentConfirmation = true
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
>>>>>>> 1cf3938 (Create working state for recovery)
                        .disabled(!subscription.isActive)
                    }
                    .padding()
                    .navigationTitle("Subscription Details")
                    .alert("Process Payment", isPresented: $showingProcessPaymentConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Process Payment") {
                            subscription.processPayment(modelContext: modelContext)
                        }
                    } message: {
<<<<<<< HEAD
                        Text("Process a payment of \(subscription.amount.formatted(.currency(code: "USD"))) " +
                                "for this subscription?")
=======
                        Text(
                            "Process a payment of \(subscription.amount.formatted(.currency(code: "USD"))) "
                                + "for this subscription?")
>>>>>>> 1cf3938 (Create working state for recovery)
                    }
                } else {
                    ContentUnavailableView(
                        "Subscription Not Found",
                        systemImage: "creditcard.slash",
                        description: Text("The requested subscription could not be found"),
<<<<<<< HEAD
                        )
=======
                    )
>>>>>>> 1cf3938 (Create working state for recovery)
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
            if isPaymentOverdue(subscription) {
                "Overdue"
            } else if isPaymentDueSoon(subscription) {
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
<<<<<<< HEAD
            return !isPaymentOverdue(subscription) &&
                subscription.nextDueDate < now.addingTimeInterval(oneWeek)
        }

        private func getRelatedTransactions(for subscription: Subscription) -> [FinancialTransaction] {
=======
            return !isPaymentOverdue(subscription)
                && subscription.nextDueDate < now.addingTimeInterval(oneWeek)
        }

        private func getRelatedTransactions(for subscription: Subscription)
            -> [FinancialTransaction]
        {
>>>>>>> 1cf3938 (Create working state for recovery)
            // In a real implementation, we would filter transactions specifically related to this subscription
            // For example, by matching notes field or subscription ID field
            transactions
                .filter {
<<<<<<< HEAD
                    $0.account?.id == subscription.account?.id &&
                        $0.amount == subscription.amount &&
                        $0.transactionType == .expense
=======
                    $0.account?.id == subscription.account?.id && $0.amount == subscription.amount
                        && $0.transactionType == .expense
>>>>>>> 1cf3938 (Create working state for recovery)
                }
                .sorted(by: { $0.date > $1.date })
        }

        // Cross-platform background color
        private var platformBackgroundColor: Color {
            #if canImport(UIKit)
<<<<<<< HEAD
            return Color(uiColor: .systemBackground)
            #elseif canImport(AppKit)
            return Color(nsColor: .windowBackgroundColor)
            #else
            return Color.white
=======
                return Color(uiColor: .systemBackground)
            #elseif canImport(AppKit)
                return Color(nsColor: .windowBackgroundColor)
            #else
                return Color.white
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }
    }
}

struct SubscriptionDetailRow: View {
    let title: String
    let value: String
    var highlight: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(highlight ? .red : .primary)
        }
    }
}
