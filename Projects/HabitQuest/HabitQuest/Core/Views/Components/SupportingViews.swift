import SwiftUI

// MARK: - Supporting Views

public struct HabitDetailSheet: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            VStack {
                Text("Habit details for \(self.habit.name)")
                    .font(.title2)
                Spacer()
            }
            .navigationTitle(self.habit.name)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { self.dismiss() }
                        .accessibilityLabel("Done")
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") { self.dismiss() }
                        .accessibilityLabel("Done")
                }
                #endif
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
                        self.exportDetailView(
                            title: "Total Active Streaks", value: "\(data.totalActiveStreaks)"
                        )
                        self.exportDetailView(
                            title: "Longest Overall Streak", value: "\(data.longestOverallStreak)"
                        )
                        self.exportDetailView(
                            title: "Average Consistency",
                            value: "\(Int(data.averageConsistency * 100))%"
                        )
                        self.exportDetailView(
                            title: "Milestones Achieved", value: "\(data.milestonesAchieved)"
                        )

                        Divider()

                        Text("Streak Distribution")
                            .font(.headline)

                        ForEach(data.streakDistribution, id: \.range) { item in
                            self.exportDetailView(title: item.range, value: "\(item.count)")
                        }

                        Divider()

                        Text("Top Performing Habits")
                            .font(.headline)

                        ForEach(data.topPerformingHabits.prefix(5), id: \.habit.id) { performer in
                            self.exportDetailView(
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
