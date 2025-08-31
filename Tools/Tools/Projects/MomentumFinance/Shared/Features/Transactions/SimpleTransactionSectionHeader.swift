//
//  SimpleTransactionSectionHeader.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-08-19.
//

import SwiftData
import SwiftUI

extension Features.Transactions {
    struct SimpleTransactionSectionHeader: View {
        let group: (key: String, value: [FinancialTransaction])

        private var monthTotal: Double {
            group.value.reduce(0) { result, transaction in
                let transactionAmount =
                    transaction.transactionType == .income
                        ? transaction.amount : -transaction.amount
                return result + transactionAmount
            }
        }

        var body: some View {
            HStack {
                Text(group.key)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                Text(monthTotal, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(monthTotal >= 0 ? .green : .red)
            }
            .padding(.vertical, 4)
        }
    }
}
