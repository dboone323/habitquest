import UIKit
import SwiftUI

#if canImport(AppKit)
#endif

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
            return Color(UIColor.systemBackground)
            #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
            #else
            return Color.white
            #endif
        }

        private var statusColor: Color {
            if !self.subscription.isActive {
                .red
            } else if let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                      subscription.nextDueDate <= weekFromNow {
                .orange
            } else {
                .green
            }
        }

        private var statusText: String {
            if !self.subscription.isActive {
                "Inactive"
            } else if let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                      subscription.nextDueDate <= weekFromNow {
                "Due Soon"
            } else {
                "Active"
            }
        }

        private var daysUntilDue: Int {
            Calendar.current.dateComponents([.day], from: Date(), to: self.subscription.nextDueDate)
                .day
                ?? 0
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
                        ),
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(self.subscription.name.prefix(2).uppercased()))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white),
                    )

                // Main Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(self.subscription.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Spacer()

                        // Status Badge
                        Text(self.statusText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(self.statusColor),
                            )
                    }

                    HStack {
                        // Amount and Frequency
                        let amountText = self.subscription.amount.formatted(.currency(code: "USD"))
                        Text("\(amountText) / \(self.subscription.billingCycle.rawValue)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        // Next Due Date
                        if self.subscription.isActive {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                    .foregroundColor(self.statusColor)

                                if self.daysUntilDue == 0 {
                                    Text("Due Today")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(self.statusColor)
                                } else if self.daysUntilDue == 1 {
                                    Text("Due Tomorrow")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(self.statusColor)
                                } else if self.daysUntilDue > 0 {
                                    Text("Due in \(self.daysUntilDue) days")
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
                    .fill(self.backgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1),
            )
        }
    }

    // MARK: - Legacy Subscription Row View

    struct SubscriptionRowView: View {
        let subscription: Subscription

        // Cross-platform color support
        private var backgroundColor: Color {
            #if canImport(UIKit)
            return Color(UIColor.systemGroupedBackground)
            #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
            #else
            return Color.white
            #endif
        }

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.subscription.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    let amountText = self.subscription.amount.formatted(.currency(code: "USD"))
                    Text("\(amountText) / \(self.subscription.billingCycle.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(
                        "Next: \(self.subscription.nextDueDate.formatted(date: .abbreviated, time: .omitted))"
                    )
                    .font(.caption)
                    .foregroundColor(.blue)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Circle()
                        .fill(self.subscription.isActive ? Color.green : Color.red)
                        .frame(width: 8, height: 8)

                    Text(self.subscription.isActive ? "Active" : "Inactive")
                        .font(.caption)
                        .foregroundColor(self.subscription.isActive ? .green : .red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(self.backgroundColor),
            )
        }
    }
}
