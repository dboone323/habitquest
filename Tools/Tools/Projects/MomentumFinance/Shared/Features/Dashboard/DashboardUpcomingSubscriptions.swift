//
//  DashboardUpcomingSubscriptions.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.Dashboard {
    struct DashboardUpcomingSubscriptions: View {
        let subscriptions: [Subscription]
        let colorTheme: ColorTheme
        let themeComponents: ThemeComponents
        let onSubscriptionTap: (Subscription) -> Void
        let onViewAllTap: () -> Void

        private func formattedDateString(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }

        var body: some View {
            themeComponents.cardWithHeader(title: "Upcoming Subscriptions") {
                VStack(spacing: 16) {
                    if !subscriptions.isEmpty {
                        ForEach(Array(subscriptions.prefix(3).enumerated()), id: \.element.id) {
                            index, subscription in
                            HStack {
                                // Icon with colorful background
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            colorTheme.categoryColors[
                                                index % colorTheme.categoryColors.count
                                            ]
                                        )
                                        .frame(width: 36, height: 36)

                                    Image(systemName: subscription.icon)
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(subscription.name)
                                        .font(.subheadline)
                                        .foregroundStyle(colorTheme.primaryText)

                                    Text(formattedDateString(subscription.nextBillingDate))
                                        .font(.caption)
                                        .foregroundStyle(colorTheme.secondaryText)
                                }

                                Spacer()

                                themeComponents.currencyDisplay(
                                    amount: subscription.amount,
                                    showSign: true,
                                    font: .subheadline.weight(.medium)
                                )
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSubscriptionTap(subscription)
                            }

                            if index < min(2, subscriptions.count - 1) {
                                Divider()
                                    .background(colorTheme.secondaryText.opacity(0.3))
                            }
                        }

                        // View all subscriptions button
                        if subscriptions.count > 3 {
                            Button(action: onViewAllTap) {
                                Text("View All \(subscriptions.count) Subscriptions")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(colorTheme.accentPrimary)
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "repeat.circle")
                                .font(.largeTitle)
                                .foregroundStyle(colorTheme.secondaryText.opacity(0.6))

                            Text("No Subscriptions")
                                .font(.subheadline)
                                .foregroundStyle(colorTheme.secondaryText)

                            Text("Add your recurring subscriptions to track upcoming payments")
                                .font(.caption)
                                .foregroundStyle(colorTheme.secondaryText)
                                .multilineTextAlignment(.center)

                            Button("Add Subscription") {
                                onViewAllTap()
                            }
                            .buttonStyle(.borderedProminent)
                            .font(.caption)
                        }
                        .padding()
                    }
                }
            }
        }
    }
}
