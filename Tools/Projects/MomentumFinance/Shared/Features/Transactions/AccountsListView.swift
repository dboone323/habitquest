// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

extension Features.Transactions {
    struct AccountsListView: View {
<<<<<<< HEAD
        @Query private var accounts: [FinancialAccount]
=======
        #if canImport(SwiftData)
            #if canImport(SwiftData)
                private var accounts: [FinancialAccount] = []
            #else
                private var accounts: [FinancialAccount] = []
            #endif
        #else
            private var accounts: [FinancialAccount] = []
        #endif
>>>>>>> 1cf3938 (Create working state for recovery)

        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    // Total Balance Card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Balance")
                                .font(.headline)
                            Text(formattedCurrency(totalBalance))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(totalBalance >= 0 ? .primary : .red)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(backgroundColorForPlatform())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
<<<<<<< HEAD
                        )
=======
                    )
>>>>>>> 1cf3938 (Create working state for recovery)

                    // Account Cards
                    ForEach(accounts) { account in
                        NavigationLink(destination: AccountDetailView(account: account)) {
                            accountCard(for: account)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Accounts")
        }

        private func accountCard(for account: FinancialAccount) -> some View {
            HStack {
                // Account icon
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: account.iconName)
                            .foregroundColor(.blue)
                    }

                // Account details
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.name)
                        .font(.headline)
                    Text("Last updated \(formatDate(account.createdDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Balance
                Text(formattedCurrency(account.balance))
                    .font(.headline)
                    .foregroundColor(account.balance >= 0 ? .primary : .red)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColorForPlatform())
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
        }

        private var totalBalance: Double {
            accounts.reduce(0) { $0 + $1.balance }
        }

        private func backgroundColorForPlatform() -> Color {
            #if os(iOS)
<<<<<<< HEAD
            return Color(UIColor.systemBackground)
            #else
            return Color(NSColor.controlBackgroundColor)
=======
                return Color(UIColor.systemBackground)
            #else
                return Color(NSColor.controlBackgroundColor)
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }

        private func formattedCurrency(_ value: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
        }

        private func formatDate(_ date: Date) -> String {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: date, relativeTo: Date())
        }
    }
}
