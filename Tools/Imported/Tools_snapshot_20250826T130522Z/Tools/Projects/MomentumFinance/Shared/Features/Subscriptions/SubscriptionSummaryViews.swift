<<<<<<< HEAD
import UIKit
import SwiftData
import SwiftUI
import UIKit
=======
import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif
>>>>>>> 1cf3938 (Create working state for recovery)

//
//  SubscriptionSummaryViews.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

extension Features.Subscriptions {
    // MARK: - Enhanced Subscription Summary View

    struct EnhancedSubscriptionSummaryView: View {
        let subscriptions: [Subscription]

        // Cross-platform color support
        private var backgroundColor: Color {
            #if canImport(UIKit)
<<<<<<< HEAD
            return Color(UIColor.systemBackground)
            #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
            #else
            return Color.white
=======
                return Color(UIColor.systemBackground)
            #elseif canImport(AppKit)
                return Color(NSColor.controlBackgroundColor)
            #else
                return Color.white
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }

        private var monthlyTotal: Double {
            subscriptions.reduce(0) { total, subscription in
                total + subscription.monthlyEquivalent
            }
        }

        private var yearlyTotal: Double {
            monthlyTotal * 12
        }

        private var activeSubscriptions: Int {
            subscriptions.filter(\.isActive).count
        }

        private var nextPayment: Subscription? {
            subscriptions
                .filter { $0.isActive && $0.nextDueDate > Date() }
                .min { $0.nextDueDate < $1.nextDueDate }
        }

        var body: some View {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Subscription Overview")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(activeSubscriptions) active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1),
<<<<<<< HEAD
                                    ),
                            )
                }

                // Cost Summary
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
=======
                                ),
                        )
                }

                // Cost Summary
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 12
                ) {
>>>>>>> 1cf3938 (Create working state for recovery)
                    // Monthly Total
                    VStack(spacing: 4) {
                        Text("Monthly")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(monthlyTotal.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1),
<<<<<<< HEAD
                                ),
                        )
=======
                            ),
                    )
>>>>>>> 1cf3938 (Create working state for recovery)

                    // Yearly Total
                    VStack(spacing: 4) {
                        Text("Yearly")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(yearlyTotal.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green.opacity(0.2), lineWidth: 1),
<<<<<<< HEAD
                                ),
                        )
=======
                            ),
                    )
>>>>>>> 1cf3938 (Create working state for recovery)
                }

                // Next Payment
                if let nextPayment {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Next Payment")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(nextPayment.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
<<<<<<< HEAD
                            Text(nextPayment.nextDueDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
=======
                            Text(
                                nextPayment.nextDueDate.formatted(
                                    date: .abbreviated, time: .omitted)
                            )
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
>>>>>>> 1cf3938 (Create working state for recovery)

                            Text(nextPayment.amount.formatted(.currency(code: "USD")))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 1),
<<<<<<< HEAD
                                ),
                        )
=======
                            ),
                    )
>>>>>>> 1cf3938 (Create working state for recovery)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1),
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
        }
    }

    // MARK: - Legacy Subscription Summary View

    struct SubscriptionSummaryView: View {
        let subscriptions: [Subscription]

        // Cross-platform color support
        private var backgroundColor: Color {
            #if canImport(UIKit)
<<<<<<< HEAD
            return Color(UIColor.systemGroupedBackground)
            #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
            #else
            return Color.white
=======
                return Color(UIColor.systemGroupedBackground)
            #elseif canImport(AppKit)
                return Color(NSColor.controlBackgroundColor)
            #else
                return Color.white
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }

        private var monthlyTotal: Double {
            subscriptions.reduce(0) { total, subscription in
                total + subscription.monthlyEquivalent
            }
        }

        private var yearlyTotal: Double {
            monthlyTotal * 12
        }

        var body: some View {
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Monthly Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(monthlyTotal.formatted(.currency(code: "USD")))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Yearly Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(yearlyTotal.formatted(.currency(code: "USD")))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor),
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
        }
    }
}
