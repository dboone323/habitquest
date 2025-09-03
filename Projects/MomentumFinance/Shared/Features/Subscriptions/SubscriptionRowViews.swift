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
//  SubscriptionRowViews.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

extension Features.Subscriptions {
    // MARK: - Enhanced Subscription Row View

    struct EnhancedSubscriptionRowView: View {
        let subscription: Subscription

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

        private var statusColor: Color {
            if !subscription.isActive {
                .red
            } else if let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()),
<<<<<<< HEAD
                      subscription.nextDueDate <= weekFromNow {
=======
                subscription.nextDueDate <= weekFromNow
            {
>>>>>>> 1cf3938 (Create working state for recovery)
                .orange
            } else {
                .green
            }
        }

        private var statusText: String {
            if !subscription.isActive {
                "Inactive"
            } else if let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()),
<<<<<<< HEAD
                      subscription.nextDueDate <= weekFromNow {
=======
                subscription.nextDueDate <= weekFromNow
            {
>>>>>>> 1cf3938 (Create working state for recovery)
                "Due Soon"
            } else {
                "Active"
            }
        }

        private var daysUntilDue: Int {
<<<<<<< HEAD
            Calendar.current.dateComponents([.day], from: Date(), to: subscription.nextDueDate).day ?? 0
=======
            Calendar.current.dateComponents([.day], from: Date(), to: subscription.nextDueDate).day
                ?? 0
>>>>>>> 1cf3938 (Create working state for recovery)
        }

        var body: some View {
            HStack(spacing: 12) {
                // Service Icon/Initial
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing,
<<<<<<< HEAD
                            ),
                        )
=======
                        ),
                    )
>>>>>>> 1cf3938 (Create working state for recovery)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(subscription.name.prefix(2).uppercased()))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white),
<<<<<<< HEAD
                        )
=======
                    )
>>>>>>> 1cf3938 (Create working state for recovery)

                // Main Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(subscription.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Spacer()

                        // Status Badge
                        Text(statusText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(statusColor),
<<<<<<< HEAD
                                )
=======
                            )
>>>>>>> 1cf3938 (Create working state for recovery)
                    }

                    HStack {
                        // Amount and Frequency
                        let amountText = subscription.amount.formatted(.currency(code: "USD"))
                        Text("\(amountText) / \(subscription.billingCycle.rawValue)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        // Next Due Date
                        if subscription.isActive {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                    .foregroundColor(statusColor)

                                if daysUntilDue == 0 {
                                    Text("Due Today")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(statusColor)
                                } else if daysUntilDue == 1 {
                                    Text("Due Tomorrow")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(statusColor)
                                } else if daysUntilDue > 0 {
                                    Text("Due in \(daysUntilDue) days")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Overdue")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }

                    // Category and Account
                    HStack {
                        if let category = subscription.category {
                            HStack(spacing: 4) {
                                Image(systemName: "tag.fill")
                                    .font(.caption2)
                                    .foregroundColor(.blue)

                                Text(category.name)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }

                        Spacer()

                        if let account = subscription.account {
                            HStack(spacing: 4) {
                                Image(systemName: "creditcard.fill")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                Text(account.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1),
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
        }
    }

    // MARK: - Legacy Subscription Row View

    struct SubscriptionRowView: View {
        let subscription: Subscription

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

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    let amountText = subscription.amount.formatted(.currency(code: "USD"))
                    Text("\(amountText) / \(subscription.billingCycle.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

<<<<<<< HEAD
                    Text("Next: \(subscription.nextDueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.blue)
=======
                    Text(
                        "Next: \(subscription.nextDueDate.formatted(date: .abbreviated, time: .omitted))"
                    )
                    .font(.caption)
                    .foregroundColor(.blue)
>>>>>>> 1cf3938 (Create working state for recovery)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Circle()
                        .fill(subscription.isActive ? Color.green : Color.red)
                        .frame(width: 8, height: 8)

                    Text(subscription.isActive ? "Active" : "Inactive")
                        .font(.caption)
                        .foregroundColor(subscription.isActive ? .green : .red)
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
