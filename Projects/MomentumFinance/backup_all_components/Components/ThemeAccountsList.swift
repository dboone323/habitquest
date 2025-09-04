import SwiftUI

struct ThemeAccountsList: View {
    let accounts: [(String, String, Double)]
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accounts")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            ForEach(Array(accounts.enumerated()), id: \.offset) { index, account in
                HStack {
                    Image(systemName: account.1)
                        .font(.subheadline)
                        .foregroundStyle(theme.accentPrimary)
                        .frame(width: 24, height: 24)

                    Text(account.0)
                        .font(.subheadline)
                        .foregroundStyle(theme.primaryText)

                    Spacer()

                    Text(formatCurrency(account.2))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.primaryText)
                }

                if index < accounts.count - 1 {
                    Divider()
                        .background(theme.secondaryText.opacity(0.3))
                        .padding(.leading, 32)
                }
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

#Preview {
    ThemeAccountsList(
        accounts: [
            ("Checking", "banknote", 1250.50),
            ("Savings", "dollarsign.circle", 4320.75),
            ("Investment", "chart.line.uptrend.xyaxis", 8640.25),
        ],
        theme: ColorTheme.shared
    )
}
