import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif

extension Features.GoalsAndReports {
    struct EnhancedFinancialSummaryCard: View {
        let transactions: [FinancialTransaction]
        let timeframe: EnhancedReportsSection.TimeFrame

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Financial Summary")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Income: $\(calculateIncome())")
                    .foregroundColor(.green)

                Text("Expenses: $\(calculateExpenses())")
                    .foregroundColor(.red)

                Text("Net: $\(calculateNet())")
                    .foregroundColor(calculateNet() >= 0 ? .green : .red)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }

        private func calculateIncome() -> String {
            let total = transactions.filter { $0.transactionType == .income }.reduce(0) {
                $0 + $1.amount
            }
            return String(format: "%.2f", total)
        }

        private func calculateExpenses() -> String {
            let total = transactions.filter { $0.transactionType == .expense }.reduce(0) {
                $0 + $1.amount
            }
            return String(format: "%.2f", total)
        }

        private func calculateNet() -> Double {
            let income = transactions.filter { $0.transactionType == .income }.reduce(0) {
                $0 + $1.amount
            }
            let expenses = transactions.filter { $0.transactionType == .expense }.reduce(0) {
                $0 + $1.amount
            }
            return income - expenses
        }
    }
}
