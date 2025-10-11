//
//  DashboardUpcomingSubscriptions.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.FinancialDashboard {
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
            self.themeComponents.cardWithHeader(title: "Upcoming Subscriptions") {
                VStack(spacing: 16) {
                    if !self.subscriptions.isEmpty {
                        ForEach(Array(self.subscriptions.prefix(3).enumerated()), id: \.element.id) {
                            index, subscription in
                            HStack {
                                // Icon with colorful background
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            self.colorTheme.categoryColors[
                                                index % self.colorTheme.categoryColors.count
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
                                        .foregroundStyle(self.colorTheme.primaryText)

                                    Text(subscription.nextBillingDate.map(self.formattedDateString) ?? "No date set")
                                        .font(.caption)
                                        .foregroundStyle(self.colorTheme.secondaryText)
                                }

                                Spacer()

                                self.themeComponents.currencyDisplay(
                                    amount: Decimal(subscription.amount),
                                    showSign: true,
                                    font: .subheadline.weight(.medium)
                                )
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.onSubscriptionTap(subscription)
                            }

                            if index < min(2, self.subscriptions.count - 1) {
                                Divider()
                                    .background(self.colorTheme.secondaryText.opacity(0.3))
                            }
                        }

                        // View all subscriptions button
                        if self.subscriptions.count > 3 {
                            Button(action: self.onViewAllTap).accessibilityLabel("Button").accessibilityLabel("Button") {
                                Text("View All \(self.subscriptions.count) Subscriptions")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(self.colorTheme.accentPrimary)
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "repeat.circle")
                                .font(.largeTitle)
                                .foregroundStyle(self.colorTheme.secondaryText.opacity(0.6))

                            Text("No Subscriptions")
                                .font(.subheadline)
                                .foregroundStyle(self.colorTheme.secondaryText)

                            Text("Add your recurring subscriptions to track upcoming payments")
                                .font(.caption)
                                .foregroundStyle(self.colorTheme.secondaryText)
                                .multilineTextAlignment(.center)

                            Button("Add Subscription").accessibilityLabel("Button").accessibilityLabel("Button") {
                                self.onViewAllTap()
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
