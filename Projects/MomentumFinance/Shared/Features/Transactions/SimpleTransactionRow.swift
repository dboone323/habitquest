//
//  SimpleTransactionRow.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.Transactions {
    struct SimpleTransactionRow: View {
        let transaction: FinancialTransaction
        let onTapped: () -> Void

        var body: some View {
            Button(action: onTapped) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(transaction.title)
                            .font(.headline)

                        if let category = transaction.category {
                            Text(category.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(transaction.formattedAmount)
                            .font(.headline)
                            .foregroundColor(transaction.transactionType == .income ? .green : .red)

                        Text(transaction.formattedDate)
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
