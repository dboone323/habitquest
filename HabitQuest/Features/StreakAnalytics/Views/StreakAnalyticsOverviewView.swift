import SwiftUI

/// Overview section displaying key analytics cards
public struct StreakAnalyticsOverviewView: View {
    let data: StreakAnalyticsData
    let timeframe: StreakAnalyticsViewModel.Timeframe

    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12
        ) {
            AnalyticsCard(
                title: "Total Streaks",
                value: "\(self.data.totalActiveStreaks)",
                subtitle: "Active habits",
                color: .blue,
                icon: "flame.fill"
            )

            AnalyticsCard(
                title: "Longest Streak",
                value: "\(self.data.longestOverallStreak)",
                subtitle: "Days",
                color: .orange,
                icon: "trophy.fill"
            )

            AnalyticsCard(
                title: "Avg Consistency",
                value: "\(Int(self.data.averageConsistency * 100))%",
                subtitle: self.timeframe.title.lowercased(),
                color: .green,
                icon: "target"
            )

            AnalyticsCard(
                title: "Milestones Hit",
                value: "\(self.data.milestonesAchieved)",
                subtitle: "This period",
                color: .purple,
                icon: "star.fill"
            )
        }
    }
}
