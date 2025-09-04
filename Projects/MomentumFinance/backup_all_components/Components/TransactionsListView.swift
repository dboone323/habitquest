// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

extension Features.Transactions {
    struct TransactionsListView: View {
        let transactions: [FinancialTransaction]
        let isVisible: Bool
        let onTransactionSelected: (FinancialTransaction) -> Void
        let onTransactionDeleted: (FinancialTransaction) -> Void

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
                ForEach(Array(groupedTransactions.enumerated()), id: \.element.key) { _, group in
                    Section {
                        ForEach(group.value, id: \.persistentModelID) { transaction in
                            TransactionRow(
                                transaction: transaction,
                                onTapped: { onTransactionSelected(transaction) }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    onTransactionDeleted(transaction)
                                }
                            }
                        }
                    } header: {
                        TransactionSectionHeader(group: group)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.easeOut(duration: 0.4).delay(0.2), value: isVisible)
        }
    }

    struct TransactionRow: View {
        let transaction: FinancialTransaction
        let onTapped: () -> Void

        private var categoryColor: Color {
            switch transaction.transactionType {
            case .income:
                .green
            case .expense:
                .red
            }
        }

        var body: some View {
            Button(action: onTapped) {
                HStack(spacing: 16) {
                    // Category Icon
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 48, height: 48)

                        Image(systemName: transaction.category?.iconName ?? "questionmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(categoryColor)
                    }

                    // Transaction Details
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(transaction.title)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            Spacer()

                            Text(transaction.formattedAmount)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(transaction.transactionType == .income ? .green : .red)
                        }

                        HStack {
                            if let category = transaction.category {
                                Text(category.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(transaction.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    struct TransactionSectionHeader: View {
        let group: (key: String, value: [FinancialTransaction])

        private var monthTotal: Double {
            group.value.reduce(0) { result, transaction in
                let transactionAmount = transaction.transactionType == .income
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

                Text(monthTotal.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(monthTotal >= 0 ? .green : .red)
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    let sampleTransactions = [
        FinancialTransaction(title: "Grocery Store", amount: 45.67, date: Date(), transactionType: .expense),
        FinancialTransaction(title: "Salary", amount: 3000.00, date: Date(), transactionType: .income),
        FinancialTransaction(title: "Coffee", amount: 4.50, date: Date().addingTimeInterval(-86400), transactionType: .expense),
    ]

    Features.Transactions.TransactionsListView(
        transactions: sampleTransactions,
        isVisible: true,
        onTransactionSelected: { _ in },
        onTransactionDeleted: { _ in }
    )
}
