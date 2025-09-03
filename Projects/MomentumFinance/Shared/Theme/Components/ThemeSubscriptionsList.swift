import SwiftUI

struct ThemeSubscriptionsList: View {
    let subscriptions: [(String, String, String, Double)]
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Subscriptions")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            ForEach(Array(subscriptions.enumerated()), id: \.offset) { index, subscription in
                HStack {
                    // Icon with colorful background
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.categoryColors[index % theme.categoryColors.count])
                            .frame(width: 36, height: 36)

                        Image(systemName: subscription.1)
                            .font(.caption)
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(subscription.0)
                            .font(.subheadline)
                            .foregroundStyle(theme.primaryText)

                        Text(subscription.2)
                            .font(.caption)
                            .foregroundStyle(theme.secondaryText)
                    }

                    Spacer()

                    Text(formatCurrency(subscription.3))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.expense)
                }

                if index < subscriptions.count - 1 {
                    Divider()
                        .background(theme.secondaryText.opacity(0.3))
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
    ThemeSubscriptionsList(
        subscriptions: [
            ("Netflix", "play.tv", "2025-06-15", 15.99),
            ("Spotify", "music.note", "2025-06-22", 9.99),
            ("iCloud+", "cloud", "2025-07-01", 2.99),
        ],
        theme: ColorTheme.shared
    )
}
