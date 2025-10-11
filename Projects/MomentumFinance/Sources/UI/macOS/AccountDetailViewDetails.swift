// Momentum Finance - Enhanced Account Detail Supporting Views for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Shared
import SwiftData
import SwiftUI

#if os(macOS)

// MARK: - Supporting Views for Enhanced Account Detail View

/// Detail field component for displaying labeled values
struct AccountDetailField: View {
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

/// Account type badge for displaying account types with color coding
struct AccountTypeBadge: View {
    let type: FinancialAccount.AccountType

    private var text: String {
        switch self.type {
        case .checking: "Checking"
        case .savings: "Savings"
        case .credit: "Credit"
        case .investment: "Investment"
        }
    }

    private var color: Color {
        switch self.type {
        case .checking: .green
        case .savings: .blue
        case .credit: .purple
        case .investment: .orange
        }
    }

    var body: some View {
        Text(self.text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(self.color.opacity(0.1))
            .foregroundColor(self.color)
            .cornerRadius(4)
    }
}

/// Credit account specific details view
struct CreditAccountDetailsView: View {
    let account: FinancialAccount

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Credit Account Details")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 12) {
                GridRow {
                    AccountDetailField(
                        label: "Credit Limit",
                        value: (self.account.creditLimit ?? 0).formatted(.currency(code: self.account.currencyCode)),
                    )

                    AccountDetailField(
                        label: "Available Credit",
                        value: ((self.account.creditLimit ?? 0) - abs(self.account.balance))
                            .formatted(.currency(code: self.account.currencyCode)),
                    )
                }

                GridRow {
                    AccountDetailField(
                        label: "Interest Rate",
                        value: ((self.account.interestRate ?? 0) * 100).formatted(.number.precision(.fractionLength(2))) + "%",
                    )

                    if let dueDate = account.dueDate {
                        AccountDetailField(label: "Payment Due", value: "Every \(dueDate.ordinal) of month")
                    }
                }

                GridRow {
                    AccountDetailField(
                        label: "Utilization",
                        value: "\(((self.account.creditLimit ?? 0) - abs(self.account.balance)) / (self.account.creditLimit ?? 1) * 100, specifier: "%.2f")%"
                    )
                    .gridCellColumns(2)
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor).opacity(0.3))
            .cornerRadius(8)

            // Credit utilization chart
            if let creditLimit = account.creditLimit, creditLimit > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Credit Utilization")
                        .font(.subheadline)

                    ProgressView(value: abs(self.account.balance), total: creditLimit)
                        .tint(self.getCreditUtilizationColor(used: abs(self.account.balance), limit: creditLimit))

                    HStack {
                        Text("Used: \(abs(self.account.balance).formatted(.currency(code: self.account.currencyCode)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text("Limit: \(creditLimit.formatted(.currency(code: self.account.currencyCode)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }

    private func getCreditUtilizationColor(used: Double, limit: Double) -> Color {
        let percentage = used / limit
        if percentage < 0.3 {
            return .green
        } else if percentage < 0.7 {
            return .yellow
        } else {
            return .red
        }
    }
}
#endif
