//
// DashboardSubscriptionsSection.swift
// MomentumFinance
//
// Created by Dashboard Refactoring on 8/19/25.
//

import SwiftData
import SwiftUI

public struct DashboardSubscriptionsSection: View {
    let subscriptions: [Subscription]
    let onSubscriptionTapped: (Subscription) -> Void
    let onViewAllTapped: () -> Void
    let onAddTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming Subscriptions")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            VStack(spacing: 16) {
                if !self.subscriptions.isEmpty {
                    ForEach(self.subscriptions.prefix(3).indices, id: \.self) { index in
                        let subscription = self.subscriptions[index]
                        HStack {
                            // Icon with colorful background
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(self.categoryColor(for: index))
                                    .frame(width: 36, height: 36)

                                Image(systemName: self.subscriptionIcon(subscription))
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(subscription.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)

                                Text(self.formattedDateString(subscription.nextDueDate))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(subscription.amount.formatted(.currency(code: "USD")))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.onSubscriptionTapped(subscription)
                        }

                        if index < min(2, self.subscriptions.count - 1) {
                            Divider()
                                .background(Color.secondary.opacity(0.3))
                        }
                    }

                    // View all subscriptions button
                    if self.subscriptions.count > 3 {
                        Button(action: self.onViewAllTapped).accessibilityLabel("Button").accessibilityLabel("Button") {
                            Text("View All \(self.subscriptions.count) Subscriptions")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)
                        }
                        .padding(.top, 8)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "repeat.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text("No active subscriptions")
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        Button(action: self.onAddTapped).accessibilityLabel("Button").accessibilityLabel("Button") {
                            Text("Add Subscription")
                                .padding(.vertical, 4)
                                .frame(maxWidth: 180)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
            .padding()
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func categoryColor(for index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red]
        return colors[index % colors.count]
    }

    private func subscriptionIcon(_ subscription: Subscription) -> String {
        // Use category icon if available, otherwise provide a default based on name or type
        if let categoryIcon = subscription.category?.iconName {
            return categoryIcon
        }

        // Provide default icons based on subscription name patterns
        let name = subscription.name.lowercased()
        if name.contains("netflix") || name.contains("streaming") {
            return "tv"
        } else if name.contains("spotify") || name.contains("music") {
            return "music.note"
        } else if name.contains("icloud") || name.contains("cloud") {
            return "icloud"
        } else if name.contains("gym") || name.contains("fitness") {
            return "figure.run"
        } else if name.contains("phone") || name.contains("mobile") {
            return "phone"
        } else {
            return "repeat"
        }
    }

    private func formattedDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleSubscriptions = [
        Subscription(
            name: "Netflix", amount: 15.99, billingCycle: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 3)
        ),
        Subscription(
            name: "Spotify", amount: 9.99, billingCycle: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 7)
        ),
        Subscription(
            name: "Apple iCloud", amount: 2.99, billingCycle: .monthly,
            nextDueDate: Date().addingTimeInterval(86400 * 14)
        ),
    ]

    DashboardSubscriptionsSection(
        subscriptions: sampleSubscriptions,
        onSubscriptionTapped: { _ in },
        onViewAllTapped: {},
        onAddTapped: {}
    )
    .padding()
}
