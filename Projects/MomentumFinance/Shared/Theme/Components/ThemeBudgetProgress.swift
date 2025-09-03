import SwiftUI

struct ThemeBudgetProgress: View {
    let budgets: [(String, Double, Double)]
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Progress")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            ForEach(Array(budgets.enumerated()), id: \.offset) { index, budget in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(budget.0)
                            .font(.subheadline)
                            .foregroundStyle(theme.primaryText)

                        Spacer()

                        Text(formatCurrency(budget.1))
                            .font(.subheadline)
                            .foregroundStyle(theme.primaryText)

                        Text("/")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)

                        Text(formatCurrency(budget.2))
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)
                    }

                    // Progress bar
                    progressBar(spent: budget.1, total: budget.2)
                }

                if index < budgets.count - 1 {
                    Divider()
                        .background(theme.secondaryText.opacity(0.3))
                        .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    private func progressBar(spent: Double, total: Double) -> some View {
        let progress = min(1.0, spent / total)
        let color: Color =
            switch progress {
            case 0 ..< 0.8:
                theme.budgetUnder
            case 0.8 ..< 1.0:
                theme.budgetNear
            default:
                theme.budgetOver
            }

        return VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(theme.secondaryBackground)
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)

                Spacer()
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

#Preview {
    ThemeBudgetProgress(
        budgets: [
            ("Groceries", 420.0, 500.0),
            ("Dining Out", 280.0, 300.0),
            ("Entertainment", 150.0, 100.0),
        ],
        theme: ColorTheme.shared
    )
}
