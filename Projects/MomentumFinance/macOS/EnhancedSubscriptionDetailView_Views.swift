// Momentum Finance - View Methods for Enhanced Subscription Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)
/// View methods for the enhanced subscription detail view
extension Features.Subscriptions.EnhancedSubscriptionDetailView {
    func detailView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Subscription header
                VStack(spacing: 16) {
                    HStack(alignment: .center, spacing: 16) {
                        // Subscription icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 60, height: 60)

                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.blue)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(subscription?.name ?? "Unknown Subscription")
                                .font(.system(size: 28, weight: .bold))

                            HStack(spacing: 12) {
                                if let provider = subscription?.provider {
                                    Text(provider)
                                        .foregroundStyle(.secondary)
                                }

                                if let category = subscription?.category {
                                    Text("•")
                                        .foregroundStyle(.secondary)

                                    Text(category)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 8) {
                            Text(subscription?.amount.formatted(.currency(code: subscription?.currencyCode ?? "USD")) ?? "$0.00")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.blue)

                            Text(formatBillingCycle(subscription?.billingCycle ?? "monthly"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    // Key metrics
                    HStack(spacing: 40) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Monthly Cost")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let subscription {
                                Text(calculateMonthlyCost(subscription).formatted(.currency(code: subscription.currencyCode)))
                                    .font(.title3)
                                    .bold()
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Annual Cost")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let subscription {
                                Text(calculateAnnualCost(subscription).formatted(.currency(code: subscription.currencyCode)))
                                    .font(.title3)
                                    .bold()
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Spent")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let subscription {
                                Text(calculateTotalSpent(subscription).formatted(.currency(code: subscription.currencyCode)))
                                    .font(.title3)
                                    .bold()
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next Payment")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let nextDate = subscription?.nextPaymentDate {
                                Text(nextDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.orange)
                            } else {
                                Text("Paused")
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(12)

                // Cost analysis section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Cost Analysis")
                        .font(.title2)
                        .bold()

                    HStack(alignment: .top, spacing: 20) {
                        SubscriptionCostChart(subscription: subscription!, timespan: selectedTimespan)
                            .frame(height: 250)

                        ValueAssessmentView(subscription: subscription!)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Payment history section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Payment History")
                            .font(.title2)
                            .bold()

                        Spacer()

                        Text("\(relatedTransactions.count) payments")
                            .foregroundStyle(.secondary)
                    }

                    if relatedTransactions.isEmpty {
                        ContentUnavailableView(
                            "No Payments Found",
                            systemImage: "creditcard",
                            description: Text("No payment transactions found for this subscription.")
                        )
                        .frame(height: 200)
                    } else {
                        List(relatedTransactions, selection: $selectedTransactionIds) { transaction in
                            paymentRow(for: transaction)
                        }
                        .listStyle(.inset)
                        .frame(height: 300)
                    }
                }
            }
            .padding()
        }
    }

    func editView(for subscription: Subscription) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Edit Subscription")
                    .font(.title2)
                    .bold()

                VStack(spacing: 16) {
                    // Basic Information
                    GroupBox("Basic Information") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Name:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("Subscription Name", text: editedSubscription?.name ?? "")
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("Provider:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("Service Provider", text: editedSubscription?.provider ?? "")
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("Category:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("Category", text: editedSubscription?.category ?? "")
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding()
                    }

                    // Financial Information
                    GroupBox("Financial Information") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Amount:")
                                    .frame(width: 100, alignment: .leading)
                                TextField(
                                    "Monthly Amount",
                                    value: editedSubscription?.amount ?? 0,
                                    format: .currency(code: editedSubscription?.currencyCode ?? "USD")
                                )
                                .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("Currency:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("Currency Code", text: editedSubscription?.currencyCode ?? "USD")
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                            }

                            HStack {
                                Text("Billing Cycle:")
                                    .frame(width: 100, alignment: .leading)
                                Picker("Billing Cycle", selection: editedSubscription?.billingCycle ?? "monthly") {
                                    Text("Monthly").tag("monthly")
                                    Text("Annual").tag("annual")
                                    Text("Quarterly").tag("quarterly")
                                    Text("Weekly").tag("weekly")
                                    Text("Biweekly").tag("biweekly")
                                }
                                .frame(width: 120)
                            }
                        }
                        .padding()
                    }

                    // Dates
                    GroupBox("Important Dates") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Start Date:")
                                    .frame(width: 100, alignment: .leading)
                                DatePicker("Start Date", selection: editedSubscription?.startDate ?? Date(), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                            }

                            HStack {
                                Text("Next Payment:")
                                    .frame(width: 100, alignment: .leading)
                                DatePicker(
                                    "Next Payment",
                                    selection: editedSubscription?.nextPaymentDate ?? Date(),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                            }
                        }
                        .padding()
                    }

                    // Payment Method
                    GroupBox("Payment Method") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Payment Method:")
                                    .frame(width: 120, alignment: .leading)
                                TextField("Credit Card, Bank Account, etc.", text: editedSubscription?.paymentMethod ?? "")
                                    .textFieldStyle(.roundedBorder)
                            }

                            Toggle("Auto-renews", isOn: editedSubscription?.autoRenews ?? true)
                        }
                        .padding()
                    }

                    // Notes
                    GroupBox("Notes") {
                        TextEditor(text: editedSubscription?.notes ?? "")
                            .frame(height: 100)
                            .padding()
                    }
                }

                // Action buttons
                HStack {
                    Button("Cancel", role: .cancel) {
                        isEditing = false
                        editedSubscription = nil
                    }

                    Spacer()

                    Button("Save Changes") {
                        saveChanges()
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }
                .padding(.top)
            }
            .padding()
        }
    }
}
#endif
