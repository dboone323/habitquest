//
//  DashboardWelcomeHeader.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftUI

extension Features.FinancialDashboard {
    struct DashboardWelcomeHeader: View {
        let greeting: String
        let wellnessPercentage: Int
        let totalBalance: Double
        let monthlyIncome: Double
        let monthlyExpenses: Double

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Good \(self.greeting)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()

                    Menu {
                        Button(action: {
                            // Refresh action
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }

                Text("Here's a summary of your finances")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)

                // Financial Wellness Score
                HStack(spacing: 16) {
                    Text("Financial Wellness")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 170, height: 8)

                        RoundedRectangle(cornerRadius: 10)
                            .fill(.green)
                            .frame(width: 170 * Double(self.wellnessPercentage) / 100, height: 8)
                    }

                    Text("\(self.wellnessPercentage)%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 2)
            }
        }
    }
}
