import SwiftUI

/// Streak distribution chart section
public struct StreakAnalyticsDistributionView: View {
    let data: [StreakDistributionData]

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak Distribution")
                .font(.title3)
                .fontWeight(.semibold)

            StreakDistributionChartView(data: self.data)
                .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}
