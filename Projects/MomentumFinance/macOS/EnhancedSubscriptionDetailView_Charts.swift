// Momentum Finance - Chart Components for Enhanced Subscription Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)
/// Chart components for the enhanced subscription detail view
extension Features.Subscriptions.EnhancedSubscriptionDetailView {
    struct SubscriptionCostChart: View {
        let subscription: Subscription
        let timespan: Timespan

        // Sample data - would be real data in actual implementation
        /// <#Description#>
        /// - Returns: <#description#>
        func generateSampleData() -> [(month: String, amount: Double)] {
            [
                (month: "Jun", amount: self.subscription.amount),
                (month: "Jul", amount: self.subscription.amount),
                (month: "Aug", amount: self.subscription.amount),
                (month: "Sep", amount: self.subscription.amount),
                (month: "Oct", amount: self.subscription.amount),
                (month: "Nov", amount: self.subscription.amount),
            ]
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Chart {
                    ForEach(self.generateSampleData(), id: \.month) { item in
                        BarMark(
                            x: .value("Month", item.month),
                            y: .value("Amount", item.amount),
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }

                    RuleMark(y: .value("Average", self.subscription.amount))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Monthly: \(self.subscription.amount.formatted(.currency(code: self.subscription.currencyCode)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                }
            }
        }
    }

    struct ValueAssessmentView: View {
        let subscription: Subscription

        // Sample usage data - in a real app, this would be tracked
        @State private var usageRating: Double = 0.7 // 0-1 scale

        // Calculate cost per use
        private var costPerUse: Double {
            // Assuming monthly billing and usage 5 times per month
            self.subscription.amount / 5.0
        }

        private var valueAssessment: String {
            if self.usageRating > 0.8 {
                "Excellent Value"
            } else if self.usageRating > 0.5 {
                "Good Value"
            } else if self.usageRating > 0.3 {
                "Fair Value"
            } else {
                "Poor Value"
            }
        }

        private var valueColor: Color {
            if self.usageRating > 0.8 {
                .green
            } else if self.usageRating > 0.5 {
                .blue
            } else if self.usageRating > 0.3 {
                .orange
            } else {
                .red
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Value Assessment")
                    .font(.headline)

                HStack {
                    VStack(alignment: .center, spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                                .frame(width: 100, height: 100)

                            Circle()
                                .trim(from: 0, to: self.usageRating)
                                .stroke(self.valueColor, lineWidth: 10)
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))

                            VStack {
                                Text(self.valueAssessment)
                                    .font(.headline)
                                    .foregroundStyle(self.valueColor)

                                Text("\(Int(self.usageRating * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Text("Usage Rating")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 20)

                    Divider()
                        .padding(.horizontal, 10)

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Monthly Cost")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(self.subscription.amount.formatted(.currency(code: self.subscription.currencyCode)))
                                .font(.title2)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Estimated Cost Per Use")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(self.costPerUse.formatted(.currency(code: self.subscription.currencyCode)))
                                .font(.title3)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Similar Subscriptions Average")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(
                                "\((self.subscription.amount * 0.9).formatted(.currency(code: self.subscription.currencyCode))) - \((self.subscription.amount * 1.1).formatted(.currency(code: self.subscription.currencyCode)))"
                            )
                            .font(.body)
                        }
                    }

                    Divider()
                        .padding(.vertical, 4)

                    // Value improvement suggestions
                    Text("Value Improvement Suggestions")
                        .font(.subheadline)
                        .bold()

                    VStack(alignment: .leading, spacing: 6) {
                        BulletPoint(text: "Consider switching to annual billing to save 16%")
                        BulletPoint(text: "3 similar services found with lower monthly costs")
                        BulletPoint(text: "Usage has decreased by 30% in the last 2 months")
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(8)
            }
        }
    }

    struct BulletPoint: View {
        let text: String

        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .padding(.top, 6)

                Text(self.text)
            }
        }
    }
}
#endif
