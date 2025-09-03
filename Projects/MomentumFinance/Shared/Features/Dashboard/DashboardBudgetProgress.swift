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
                        ForEach(budgets.prefix(3)) { budget in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(budget.name)
                                        .font(.subheadline)
                                        .foregroundStyle(colorTheme.primaryText)

                                    Spacer()

                                    themeComponents.currencyDisplay(
                                        amount: budget.spent,
                                        isPositive: false,
                                        font: .subheadline.weight(.medium)
                                    )

                                    Text("/")
                                        .font(.subheadline)
                                        .foregroundStyle(colorTheme.secondaryText)

                                    themeComponents.currencyDisplay(
                                        amount: budget.limit,
                                        font: .subheadline
                                    )
                                }

                                themeComponents.budgetProgressBar(
                                    spent: budget.spent, total: budget.limit
                                )
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onBudgetTap(budget)
                            }

                            if budget != budgets.prefix(3).last {
                                Divider()
                                    .background(colorTheme.secondaryText.opacity(0.3))
                                    .padding(.vertical, 4)
                            }
                        }

                        if budgets.count > 3 {
                            Button(action: onViewAllTap) {
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

                            Button("Create Budget") {
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
