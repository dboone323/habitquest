// Momentum Finance - Transaction Components for Enhanced Subscription Detail View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import Shared
import SwiftData
import SwiftUI

#if os(macOS)
/// Transaction-related components for the enhanced subscription detail view
extension Features.Subscriptions.EnhancedSubscriptionDetailView {
    func paymentRow(for transaction: FinancialTransaction) -> some View {
        HStack(spacing: 12) {
            // Transaction icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: transaction.isReconciled ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(transaction.isReconciled ? .green : .gray)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let notes = transaction.notes, !notes.isEmpty {
                        Text("•")
                            .foregroundStyle(.secondary)

                        Text(notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(abs(transaction.amount).formatted(.currency(code: "USD")))
                    .font(.headline)
                    .foregroundStyle(transaction.amount < 0 ? .red : .green)

                Text(transaction.isReconciled ? "Paid" : "Pending")
                    .font(.caption)
                    .foregroundStyle(transaction.isReconciled ? .green : .orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(transaction.isReconciled ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: { self.toggleTransactionStatus(transaction) }) {
                Label(
                    transaction.isReconciled ? "Mark as Pending" : "Mark as Paid",
                    systemImage: transaction.isReconciled ? "circle" : "checkmark.circle.fill"
                )
            }

            Divider()

            Button(role: .destructive) {
                self.modelContext.delete(transaction)
                try? self.modelContext.save()
            } label: {
                Label("Delete Transaction", systemImage: "trash")
            }
        }
    }
}
#endif
