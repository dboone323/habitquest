//
// DashboardAccountsSummary.swift
// MomentumFinance
//
// Created by Dashboard Refactoring on 8/19/25.
//

import SwiftUI

struct DashboardAccountsSummary: View {
    let accounts: [FinancialAccount]
    let onAccountTapped: (String) -> Void
    let onViewAllTapped: () -> Void

    private var totalBalance: Decimal {
        accounts.reduce(0) { $0 + $1.balance }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Balances")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 12) {
                HStack {
                    Text("Total Balance")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(totalBalance.formatted(.currency(code: "USD")))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }

                Divider()
                    .background(Color.secondary.opacity(0.3))

                ForEach(accounts.prefix(3)) { account in
                    HStack {
                        Image(systemName: account.icon)
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                            .frame(width: 24, height: 24)

                        Text(account.name)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Spacer()

                        Text(account.balance.formatted(.currency(code: account.currencyCode)))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onAccountTapped(account.id)
                    }

                    if account != accounts.prefix(3).last {
                        Divider()
                            .padding(.leading, 32)
                    }
                }

                if accounts.count > 3 {
                    Button(action: onViewAllTapped) {
                        Text("View All \(accounts.count) Accounts")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let sampleAccounts = [
        FinancialAccount(
            name: "Checking", accountType: .checking, balance: 2500.00, currencyCode: "USD"
        ),
        FinancialAccount(
            name: "Savings", accountType: .savings, balance: 15000.00, currencyCode: "USD"
        ),
        FinancialAccount(
            name: "Credit Card", accountType: .creditCard, balance: -1200.00, currencyCode: "USD"
        ),
        FinancialAccount(
            name: "Investment", accountType: .investment, balance: 25000.00, currencyCode: "USD"
        ),
    ]

    DashboardAccountsSummary(
        accounts: sampleAccounts,
        onAccountTapped: { _ in },
        onViewAllTapped: {}
    )
    .padding()
}
