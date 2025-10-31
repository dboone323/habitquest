//
//  DashboardListViewComponent.swift
//  MomentumFinance
//
//  Dashboard list view component for macOS three-column layout
//

import MomentumFinanceCore
import SharedKit
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
                            ReusableListItemView(account: account)
                        }
                    }

                    Section("Recent Transactions") {
                        ForEach(self.transactions.sorted { $0.date > $1.date }.prefix(10)) { transaction in
                            ReusableListItemView(transaction: transaction)
                        }
                    }
                }
                .navigationTitle("Dashboard")
                .toolbar {
                    ToolbarItem {
                        Button(action: {}).accessibilityLabel("Add New Account Button") {
                            Image(systemName: "plus")
                        }
                        .help("Add New Account")
                    }
                }
            }
        }
    }
#endif
