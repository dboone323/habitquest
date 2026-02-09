import SwiftUI

public struct StatsSection: View {
    let totalHabits: Int
    let activeStreaks: Int
    let completedToday: Int
    let longestStreak: Int
    let perfectDays: Int
    let weeklyCompletion: Double

    public init(
        totalHabits: Int,
        activeStreaks: Int,
        completedToday: Int,
        longestStreak: Int,
        perfectDays: Int,
        weeklyCompletion: Double
    ) {
        self.totalHabits = totalHabits
        self.activeStreaks = activeStreaks
        self.completedToday = completedToday
        self.longestStreak = longestStreak
        self.perfectDays = perfectDays
        self.weeklyCompletion = weeklyCompletion
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(title: "Total Habits", value: "\(totalHabits)", icon: "list.bullet")
                StatCard(title: "Active Streaks", value: "\(activeStreaks)", icon: "flame")
                StatCard(
                    title: "Completed Today", value: "\(completedToday)", icon: "checkmark.circle"
                )
                StatCard(title: "Longest Streak", value: "\(longestStreak)", icon: "star")
                StatCard(title: "Perfect Days", value: "\(perfectDays)", icon: "crown")
                StatCard(title: "Weekly Rate", value: "\(Int(weeklyCompletion))%", icon: "percent")
            }
        }
        .padding()
        #if os(iOS)
            .background(Color(.systemGray6))
        #else
            .background(Color(nsColor: .windowBackgroundColor))
        #endif
            .cornerRadius(16)
    }
}

public struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    public init(title: String, value: String, icon: String) {
        self.title = title
        self.value = value
        self.icon = icon
    }

    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        #if os(iOS)
            .background(Color(.systemBackground))
        #else
            .background(Color(nsColor: .windowBackgroundColor))
        #endif
            .cornerRadius(12)
    }
}
