import SwiftUI

// MARK: - Dashboard Insights

public struct DashboardInsights: View {
    let insights: [String]
    let onDetailsTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)

                Spacer()

                Button("Details", action: self.onDetailsTapped).accessibilityLabel("Button").accessibilityLabel("Button")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
            }

            VStack(alignment: .leading, spacing: 12) {
                InsightItem(
                    color: .blue,
                    text: "Monthly spending is 15% lower than last month"
                )

                InsightItem(
                    color: .green,
                    text: "Savings increased by 8% this month"
                )

                InsightItem(
                    color: .orange,
                    text: "3 subscriptions will renew next week"
                )
            }
            .padding(.top, 5)
        }
        .padding(15)
        #if os(iOS)
            .background(Color(UIColor.secondarySystemBackground))
        #else
            .background(Color.secondary.opacity(0.1))
        #endif
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

public struct InsightItem: View {
    let color: Color
    let text: String

    var body: some View {
        HStack {
            Circle()
                .fill(self.color)
                .frame(width: 10, height: 10)

            Text(self.text)
                .font(.subheadline)
        }
    }
}
