import SwiftUI

/// Weekly patterns section
public struct StreakAnalyticsWeeklyView: View {
    let patterns: [WeeklyPattern]

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Patterns")
                .font(.title3)
                .fontWeight(.semibold)

            WeeklyPatternChartView(patterns: patterns)
                .frame(height: 120)
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}
