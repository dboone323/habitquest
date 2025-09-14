//
//  DashboardBudgetProgress.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.Dashboard {
    struct DashboardBudgetProgress: View {
        let budgets: [Budget]
        let colorTheme: ColorTheme
        let themeComponents: ThemeComponents
        let onBudgetTap: (Budget) -> Void
        let onViewAllTap: () -> Void

        var body: some View {
            themeComponents.section(title: "Budget Progress") {
                VStack(spacing: 16) {
                    if !budgets.isEmpty {
                        ForEach(Array(budgets.prefix(3).enumerated()), id: \.offset) { index, budget in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(budget.name)
                                        .font(.subheadline)
                                        .foregroundStyle(colorTheme.primaryText)

                                    Spacer()

                                    themeComponents.currencyDisplay(
                                        amount: Decimal(budget.spentAmount),
                                        isPositive: false,
                                        font: .subheadline.weight(.medium)
                                    )

                                    Text("/")
                                        .font(.subheadline)
                                        .foregroundStyle(colorTheme.secondaryText)

                                    themeComponents.currencyDisplay(
                                        amount: Decimal(budget.limitAmount),
                                        font: .subheadline
                                    )
                                }

                                themeComponents.budgetProgressBar(
                                    spent: Decimal(budget.spentAmount), total: Decimal(budget.limitAmount)
                                )
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onBudgetTap(budget)
                            }

                            if index < Array(budgets.prefix(3)).count - 1 {
                                Divider()
                                    .background(colorTheme.secondaryText.opacity(0.3))
                                    .padding(.vertical, 4)
                            }
                        }

                        if budgets.count > 3 {
                            Button(action: onViewAllTap).accessibilityLabel("Button") {
                                Text("View All \(budgets.count) Budgets")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(colorTheme.accentPrimary)
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.pie")
                                .font(.largeTitle)
                                .foregroundStyle(colorTheme.secondaryText)

                            Text("No Budgets Set")
                                .font(.subheadline)
                                .foregroundStyle(colorTheme.primaryText)

                            Text("Create budgets to track your spending")
                                .font(.caption)
                                .foregroundStyle(colorTheme.secondaryText)
                                .multilineTextAlignment(.center)

                            Button("Create Budget").accessibilityLabel("Button") {
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
