import SwiftUI

/// Consistency insights section
public struct StreakAnalyticsInsightsView: View {
    let insights: [ConsistencyInsight]

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Consistency Insights")
                .font(.title3)
                .fontWeight(.semibold)

            ConsistencyInsightView(insights: self.insights)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}
