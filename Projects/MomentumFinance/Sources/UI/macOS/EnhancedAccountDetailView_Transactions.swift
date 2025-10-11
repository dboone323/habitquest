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
                Text(self.transaction.name)
                    .font(.headline)

                Text(self.transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(self.transaction.amount.formatted(.currency(code: self.transaction.currencyCode)))
                .foregroundStyle(self.transaction.amount < 0 ? .red : .green)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
        .tag(self.transaction.id)
        .contextMenu {
            Button("View Details") {
                // Navigate to transaction detail
            }

            Button("Edit") {
                // Edit transaction
            }

            Button(
                "Mark as \(self.transaction.isReconciled ? "Unreconciled" : "Reconciled")"
            ) {
                self.toggleStatus(self.transaction)
            }

            Divider()

            Button("Delete", role: .destructive) {
                self.deleteTransaction(self.transaction)
            }
        }
    }
}
#endif
