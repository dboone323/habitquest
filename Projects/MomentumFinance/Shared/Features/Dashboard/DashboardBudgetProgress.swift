//
//  DashboardBudgetProgress.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.FinancialDashboard {
    struct DashboardBudgetProgress: View {
        let budgets: [Budget]
        let colorTheme: ColorTheme
        let themeComponents: ThemeComponents
        let onBudgetTap: (Budget) -> Void
        let onViewAllTap: () -> Void

        var body: some View {
            self.themeComponents.section(title: "Budget Progress") {
                VStack(spacing: 16) {
                    if !self.budgets.isEmpty {
                        ForEach(Array(self.budgets.prefix(3).enumerated()), id: \.offset) { index, budget in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(budget.name)
                                        .font(.subheadline)
                                        .foregroundStyle(self.colorTheme.primaryText)

                                    Spacer()

                                    self.themeComponents.currencyDisplay(
                                        amount: Decimal(budget.spentAmount),
                                        isPositive: false,
                                        font: .subheadline.weight(.medium)
                                    )

                                    Text("/")
                                        .font(.subheadline)
                                        .foregroundStyle(self.colorTheme.secondaryText)

                                    self.themeComponents.currencyDisplay(
                                        amount: Decimal(budget.limitAmount),
                                        font: .subheadline
                                    )
                                }

                                self.themeComponents.budgetProgressBar(
                                    spent: Decimal(budget.spentAmount), total: Decimal(budget.limitAmount)
                                )
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.onBudgetTap(budget)
                            }

                            if index < Array(self.budgets.prefix(3)).count - 1 {
                                Divider()
                                    .background(self.colorTheme.secondaryText.opacity(0.3))
                                    .padding(.vertical, 4)
                            }
                        }

                        if self.budgets.count > 3 {
                            Button(action: self.onViewAllTap).accessibilityLabel("Button").accessibilityLabel("Button") {
                                Text("View All \(self.budgets.count) Budgets")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(self.colorTheme.accentPrimary)
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.pie")
                                .font(.largeTitle)
                                .foregroundStyle(self.colorTheme.secondaryText)

                            Text("No Budgets Set")
                                .font(.subheadline)
                                .foregroundStyle(self.colorTheme.primaryText)

                            Text("Create budgets to track your spending")
                                .font(.caption)
                                .foregroundStyle(self.colorTheme.secondaryText)
                                .multilineTextAlignment(.center)

                            Button("Create Budget").accessibilityLabel("Button").accessibilityLabel("Button") {
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
