import SwiftUI

struct ThemeFinancialSummaryCard: View {
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Financial Summary")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            HStack(spacing: 16) {
                summaryItem(
                    title: "Income",
                    value: "$5,840.00",
                    icon: "arrow.down.circle.fill",
                    color: theme.income
                )

                summaryItem(
                    title: "Expenses",
                    value: "$3,250.75",
                    icon: "arrow.up.circle.fill",
                    color: theme.expense
                )

                summaryItem(
                    title: "Saved",
                    value: "$2,589.25",
                    icon: "dollarsign.circle.fill",
                    color: theme.savings
                )
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                Text("Savings Goal Progress")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)

                HStack {
                    Text("$2,589.25")
                        .font(.caption)
                        .foregroundStyle(theme.primaryText)

                    Spacer()

                    Text("$5,000.00")
                        .font(.caption)
                        .foregroundStyle(theme.primaryText)
                }

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(theme.secondaryBackground)
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(theme.savings)
                        .frame(width: CGFloat(320) * 0.85 * 0.52, height: 8)
                        .cornerRadius(4)
                }

                Text("52% of goal reached")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    private func summaryItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(theme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ThemeFinancialSummaryCard(theme: ColorTheme.shared)
}
