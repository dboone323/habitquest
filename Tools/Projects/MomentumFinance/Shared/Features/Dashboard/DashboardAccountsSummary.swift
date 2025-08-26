//
//  DashboardAccountsSummary.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.Dashboard {
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
                            .foregroundStyle(colorTheme.primaryText)

                        Spacer()

                        themeComponents.currencyDisplay(
                            amount: accounts.reduce(Decimal(0)) { $0 + $1.balance },
                            font: .headline.weight(.semibold)
                        )
                    }

                    Divider()
                        .background(colorTheme.secondaryText.opacity(0.3))

                    ForEach(accounts.prefix(3)) { account in
                        HStack {
                            Image(systemName: account.icon)
                                .font(.subheadline)
                                .foregroundStyle(colorTheme.accentPrimary)
                                .frame(width: 24, height: 24)

                            Text(account.name)
                                .font(.subheadline)
                                .foregroundStyle(colorTheme.primaryText)
                                .lineLimit(1)

                            Spacer()

                            themeComponents.currencyDisplay(
                                amount: account.balance,
                                font: .subheadline.weight(.medium)
                            )
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onAccountTap(account.id)
                        }

                        if account != accounts.prefix(3).last {
                            Divider()
                                .padding(.leading, 32)
                        }
                    }

                    if accounts.count > 3 {
                        Button(action: onViewAllTap) {
                            Text("View All \(accounts.count) Accounts")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(colorTheme.accentPrimary)
                        }
                    }
                }
                .padding()
                .background(colorTheme.primaryBackground)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
        }
    }
}
