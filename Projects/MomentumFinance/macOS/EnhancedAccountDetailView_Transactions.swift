// Momentum Finance - Transaction Views for Enhanced Account Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Shared
import SwiftUI

#if os(macOS)
/// Transaction-related view components for the enhanced account detail view
struct TransactionRow: View {
    let transaction: FinancialTransaction
    let toggleStatus: (FinancialTransaction) -> Void
    let deleteTransaction: (FinancialTransaction) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.headline)

                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(transaction.amount.formatted(.currency(code: transaction.currencyCode)))
                .foregroundStyle(transaction.amount < 0 ? .red : .green)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
        .tag(transaction.id)
        .contextMenu {
            Button("View Details") {
                // Navigate to transaction detail
            }

            Button("Edit") {
                // Edit transaction
            }

            Button(
                "Mark as \(transaction.isReconciled ? "Unreconciled" : "Reconciled")"
            ) {
                self.toggleStatus(transaction)
            }

            Divider()

            Button("Delete", role: .destructive) {
                self.deleteTransaction(transaction)
            }
        }
    }
}
#endif
