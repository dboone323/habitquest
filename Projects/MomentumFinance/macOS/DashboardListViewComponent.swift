//
//  DashboardListViewComponent.swift
//  MomentumFinance
//
//  Dashboard list view component for macOS three-column layout
//

import SwiftData
import SwiftUI

// This file contains the Dashboard list view component
// Extracted from MacOS_UI_Enhancements.swift to reduce file size

#if os(macOS)
// Dashboard list view for the middle column
extension Features.FinancialDashboard {
    struct DashboardListView: View {
        @Environment(\.modelContext) private var modelContext
        @Query private var accounts: [FinancialAccount]
        @Query private var transactions: [FinancialTransaction]
        @State private var selectedItem: ListableItem?

        var body: some View {
            List(selection: self.$selectedItem) {
                Section("Accounts") {
                    ForEach(self.accounts) { account in
                        NavigationLink(value: ListableItem(id: account.id, name: account.name, type: .account)) {
                            HStack {
                                Image(systemName: account.type.iconName)
                                    .foregroundStyle(account.type.color)

                                VStack(alignment: .leading) {
                                    Text(account.name)
                                        .font(.headline)

                                    Text(account.type.displayName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text(account.balance.formatted(.currency(code: "USD")))
                                        .font(.subheadline)

                                    if account.balance != account.availableBalance {
                                        Text(account.availableBalance.formatted(.currency(code: "USD")))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .tag(ListableItem(id: account.id, name: account.name, type: .account))
                    }
                }

                Section("Recent Transactions") {
                    ForEach(self.transactions.sorted { $0.date > $1.date }.prefix(10)) { transaction in
                        NavigationLink(value: ListableItem(id: transaction.id, name: transaction.name, type: .transaction)) {
                            HStack {
                                Image(systemName: transaction.amount < 0 ? "arrow.down" : "arrow.up")
                                    .foregroundStyle(transaction.amount < 0 ? .red : .green)

                                VStack(alignment: .leading) {
                                    Text(transaction.name)
                                        .font(.headline)

                                    if let account = transaction.account {
                                        Text(account.name)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text(transaction.amount.formatted(.currency(code: "USD")))
                                        .font(.subheadline)
                                        .foregroundStyle(transaction.amount < 0 ? .red : .green)

                                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .tag(ListableItem(id: transaction.id, name: transaction.name, type: .transaction))
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem {
                    Button(action: {}).accessibilityLabel("Button").accessibilityLabel("Button") {
                        Image(systemName: "plus")
                    }
                    .help("Add New Account")
                }
            }
        }
    }
}
#endif
