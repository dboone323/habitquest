//
//  TransactionRowView.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.Transactions {
    struct TransactionRowView: View {
        let transaction: FinancialTransaction
        let onTapped: () -> Void

        var body: some View {
            Button(action: self.onTapped).accessibilityLabel("Button").accessibilityLabel("Button") {
                HStack {
                    VStack(alignment: .leading) {
                        Text(self.transaction.title)
                            .font(.headline)

                        if let category = transaction.category {
                            Text(category.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(self.transaction.formattedAmount)
                            .font(.headline)
                            .foregroundColor(self.transaction.transactionType == .income ? .green : .red)

                        Text(self.transaction.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
