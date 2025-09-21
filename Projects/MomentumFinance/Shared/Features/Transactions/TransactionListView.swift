//
//  TransactionListView.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.Transactions {
    struct TransactionListView: View {
        let transactions: [FinancialTransaction]
        let onTransactionTapped: (FinancialTransaction) -> Void
        let onDeleteTransaction: (FinancialTransaction) -> Void

        private var groupedTransactions: [(key: String, value: [FinancialTransaction])] {
            let grouped = Dictionary(grouping: transactions) { transaction in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: transaction.date)
            }

            return grouped.sorted { $0.key > $1.key }
        }

        var body: some View {
            List {
                ForEach(Array(self.groupedTransactions.enumerated()), id: \.element.key) {
                    _, group in
                    Section {
                        ForEach(group.value, id: \.persistentModelID) { transaction in
                            Features.Transactions.TransactionRowView(transaction: transaction) {
                                self.onTransactionTapped(transaction)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive).accessibilityLabel("Button").accessibilityLabel("Button") {
                                    self.onDeleteTransaction(transaction)
                                }
                            }
                        }
                    } header: {
                        Features.Transactions.SimpleTransactionSectionHeader(group: group)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}
