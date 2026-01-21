import SwiftUI

// MARK: - Supporting Views

public struct HabitDetailSheet: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            VStack {
                Text("Habit details for \(habit.name)")
                    .font(.title2)
                Spacer()
            }
            .navigationTitle(habit.name)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                            .accessibilityLabel("Done")
                    }
                }
        }
    }
}

public struct AnalyticsExportView: View {
    let analyticsData: StreakAnalyticsData?

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Export Streak Analytics")
                        .font(.title2)
                        .fontWeight(.semibold)

                    if let data = analyticsData {
                        exportDetailView(
                            title: "Total Active Streaks", value: "\(data.totalActiveStreaks)"
                        )
                        exportDetailView(
                            title: "Longest Overall Streak", value: "\(data.longestOverallStreak)"
                        )
                        exportDetailView(
                            title: "Average Consistency",
                            value: "\(Int(data.averageConsistency * 100))%"
                        )
                        exportDetailView(
                            title: "Milestones Achieved", value: "\(data.milestonesAchieved)"
                        )

                        Divider()

                        Text("Streak Distribution")
                            .font(.headline)

                        ForEach(data.streakDistribution, id: \.range) { item in
                            exportDetailView(title: item.range, value: "\(item.count)")
                        }

                        Divider()

                        Text("Top Performing Habits")
                            .font(.headline)

                        ForEach(data.topPerformingHabits.prefix(5), id: \.habit.id) { performer in
                            exportDetailView(
                                title: performer.habit.name,
                                value: "\(performer.currentStreak) days"
                            )
                        }
                    } else {
                        Text("No analytics data available for export.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Export Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private func exportDetailView(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}
