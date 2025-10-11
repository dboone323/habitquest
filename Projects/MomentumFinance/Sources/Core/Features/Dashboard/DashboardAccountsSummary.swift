//
//  DashboardAccountsSummary.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.FinancialDashboard {
    struct DashboardAccountsSummary: View {
        let accounts: [FinancialAccount]
        let colorTheme: ColorTheme
        let themeComponents: ThemeComponents
        let onAccountTap: (String) -> Void
        let onViewAllTap: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Account Balances")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    HStack {
                        Text("Total Balance")
                            .font(.headline)
                            .foregroundStyle(self.colorTheme.primaryText)

                        Spacer()

                        self.themeComponents.currencyDisplay(
                            amount: self.accounts.reduce(Decimal(0)) { $0 + Decimal($1.balance) },
                            font: .headline.weight(.semibold)
                        )
                    }

                    Divider()
                        .background(self.colorTheme.secondaryText.opacity(0.3))

                    ForEach(Array(self.accounts.prefix(3))) { account in
                        HStack {
                            Image(systemName: account.iconName)
                                .font(.subheadline)
                                .foregroundStyle(self.colorTheme.accentPrimary)
                                .frame(width: 24, height: 24)

                            Text(account.name)
                                .font(.subheadline)
                                .foregroundStyle(self.colorTheme.primaryText)
                                .lineLimit(1)

                            Spacer()

                            self.themeComponents.currencyDisplay(
                                amount: Decimal(account.balance),
                                font: .subheadline.weight(.medium)
                            )
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.onAccountTap(String(describing: account.id))
                        }

                        if account != Array(self.accounts.prefix(3)).last {
                            Divider()
                                .padding(.leading, 32)
                        }
                    }

                    if self.accounts.count > 3 {
                        Button(action: self.onViewAllTap).accessibilityLabel("Button").accessibilityLabel("Button") {
                            Text("View All \(self.accounts.count) Accounts")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(self.colorTheme.accentPrimary)
                        }
                    }
                }
                .padding()
                .background(self.colorTheme.primaryBackground)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
        }
    }
}
