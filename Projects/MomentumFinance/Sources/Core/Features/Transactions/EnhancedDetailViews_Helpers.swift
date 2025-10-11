// Momentum Finance - Enhanced Transaction Detail Helper Views
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import SwiftData
import SwiftUI

// MARK: - Helper View Components

/// Detail field component for displaying labeled values
struct DetailField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(self.label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(self.value)
                .font(.body)
        }
    }
}

/// Category tag component with color coding
struct CategoryTag: View {
    let category: ExpenseCategory

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(self.getCategoryColor(self.category.colorHex))
                .frame(width: 10, height: 10)

            Text(self.category.name)
                .font(.subheadline)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(self.getCategoryColor(self.category.colorHex).opacity(0.1))
        .cornerRadius(4)
    }

    private func getCategoryColor(_ hex: String?) -> Color {
        guard let hex else { return .gray }
        // This would parse the hex color string
        return .blue
    }
}

/// Budget impact view showing spending against budget
struct BudgetImpactView: View {
    let category: ExpenseCategory
    let transactionAmount: Double

    // This would be calculated from actual budget data
    var budgetTotal: Double = 500
    var budgetSpent: Double = 325

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Budget Impact")
                .font(.headline)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.category.name)
                        .font(.subheadline)

                    Text("Monthly Budget")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Text("\(self.budgetSpent.formatted(.currency(code: "USD")))")
                        Text("of")
                            .foregroundStyle(.secondary)
                        Text("\(self.budgetTotal.formatted(.currency(code: "USD")))")
                    }
                    .font(.subheadline)

                    Text("\(Int((self.budgetSpent / self.budgetTotal) * 100))% Used")
                        .font(.caption)
                        .foregroundStyle(self.getBudgetColor(self.budgetSpent / self.budgetTotal))
                }
            }

            ProgressView(value: self.budgetSpent, total: self.budgetTotal)
                .tint(self.getBudgetColor(self.budgetSpent / self.budgetTotal))

            HStack {
                Text("This transaction: \(self.transactionAmount.formatted(.currency(code: "USD")))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int((self.transactionAmount / self.budgetTotal) * 100))% of monthly budget")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }

    private func getBudgetColor(_ percentage: Double) -> Color {
        if percentage < 0.7 {
            .green
        } else if percentage < 0.9 {
            .yellow
        } else {
            .red
        }
    }
}

/// Export options view for transaction export
struct ExportOptionsView: View {
    let transaction: FinancialTransaction
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Export Transaction")
                .font(.title)

            Picker("Format", selection: .constant("csv")) {
                Text("CSV").tag("csv")
                Text("PDF").tag("pdf")
                Text("QIF").tag("qif")
            }
            .pickerStyle(.segmented)
            .frame(width: 300)

            // Export options and controls would go here

            HStack {
                Button("Cancel") {
                    self.dismiss()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Export") {
                    // Export logic
                    self.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .frame(width: 400)
        .padding()
    }
}

/// Related transactions view
struct RelatedTransactionsView: View {
    let transaction: FinancialTransaction
    @Environment(\.dismiss) private var dismiss

    // Sample data - would be actual transactions in implementation
    let relatedTransactions = [
        "January Grocery Shopping",
        "February Grocery Shopping",
        "March Grocery Shopping",
        "April Grocery Shopping",
        "May Grocery Shopping",
    ]

    var body: some View {
        VStack {
            Text("Transactions Similar to '\(self.transaction.name)'")
                .font(.headline)
                .padding()

            List(self.relatedTransactions, id: \.self) { name in
                HStack {
                    Text(name)
                    Spacer()
                    Text("$\(Int.random(in: 45 ... 95)).\(Int.random(in: 10 ... 99))")
                        .foregroundStyle(.red)
                }
            }

            Button("Close") {
                self.dismiss()
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .frame(width: 500, height: 400)
    }
}
