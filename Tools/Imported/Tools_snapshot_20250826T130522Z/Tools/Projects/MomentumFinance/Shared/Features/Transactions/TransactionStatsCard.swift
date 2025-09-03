//
//  TransactionStatsCard.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.Transactions {
    struct TransactionStatsCard: View {
        let transactions: [FinancialTransaction]

        private var income: Double {
            transactions
                .filter { $0.transactionType == .income }
                .reduce(0) { $0 + $1.amount }
        }

        private var expenses: Double {
            transactions
                .filter { $0.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }
        }

        var body: some View {
            HStack {
                Text("\(transactions.count) transactions")
                    .font(.headline)

                Spacer()

                Text(income, format: .currency(code: "USD"))
                    .foregroundColor(.green)

                Text(expenses, format: .currency(code: "USD"))
                    .foregroundColor(.red)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}
