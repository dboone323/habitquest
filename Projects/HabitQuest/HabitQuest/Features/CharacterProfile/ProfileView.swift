import SwiftData
import SwiftUI

public struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingAdvancedAnalytics = false

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Character Avatar Section
                    CharacterAvatarSection(
                        level: self.viewModel.level,
                        currentXP: self.viewModel.currentXP,
                        xpToNextLevel: self.viewModel.xpForNextLevel,
                        avatarImageName: "person.circle.fill"
                    )

                    // Progress Section
                    ProgressSection(
                        currentXP: self.viewModel.currentXP,
                        xpToNextLevel: self.viewModel.xpForNextLevel,
                        totalXP: self.viewModel.currentXP
                    )

                    // Stats Section
                    StatsSection(
                        totalHabits: self.viewModel.totalHabits,
                        activeStreaks: 0,
                        completedToday: self.viewModel.completedToday,
                        longestStreak: self.viewModel.longestStreak,
                        perfectDays: 0,
                        weeklyCompletion: 0.0
                    )

                    // Achievements Section
                    AchievementsSection(achievements: self.viewModel.achievements)

                    // Advanced Analytics Button
                    Button(action: {
                        self.showingAdvancedAnalytics = true
                    }) {
                        HStack {
                            Image(systemName: "chart.bar.xaxis")
                            Text("Advanced Analytics")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                    }

                    // Analytics Tab View
                    AnalyticsTabView()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: self.$showingAdvancedAnalytics) {
                AdvancedAnalyticsView()
            }
        }
    }
}

public struct AnalyticsTabView: View {
    @State private var selectedTab = 0

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analytics Overview")
                .font(.headline)
                .fontWeight(.semibold)

            Picker("Analytics Tab", selection: self.$selectedTab) {
                Text("Trends").tag(0)
                Text("Patterns").tag(1)
                Text("Insights").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())

            Group {
                switch self.selectedTab {
                case 0:
                    TrendsView()
                case 1:
                    PatternsView()
                case 2:
                    InsightsView()
                default:
                    TrendsView()
                }
            }
            .frame(minHeight: 200)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
    }
}

public struct TrendsView: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("Completion Rate")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("↗ 12%")
                    .font(.caption)
                    .foregroundColor(.green)
            }

            HStack {
                Image(systemName: "flame")
                    .foregroundColor(.orange)
                Text("Streak Performance")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("↗ 8%")
                    .font(.caption)
                    .foregroundColor(.green)
            }

            HStack {
                Image(systemName: "star")
                    .foregroundColor(.yellow)
                Text("XP Growth")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("↗ 15%")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

public struct PatternsView: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("Best Time")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("9:00 AM")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text("Most Active Day")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("Monday")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: "heart")
                    .foregroundColor(.red)
                Text("Mood Correlation")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("Positive")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

public struct InsightsView: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.yellow)
                Text("AI Recommendation")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text(
                "Consider adding a morning meditation habit. Your completion rate is 23% higher for morning activities."
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.vertical, 4)

            HStack {
                Image(systemName: "target")
                    .foregroundColor(.green)
                Text("Next Milestone")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text("You're 3 days away from your longest streak record!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

public struct AdvancedAnalyticsView: View {
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Analytics Overview Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Streak Heat Map")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(
                            "Advanced heat map visualization will be available when habits are selected."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16)

                    // Detailed Analytics Components
                    AnalyticsInsightsCard()
                    PredictiveAnalyticsCard()
                    BehavioralPatternsCard()
                }
                .padding()
            }
            .navigationTitle("Advanced Analytics")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        self.dismiss()
                    }
                    .accessibilityLabel("Button")
                }
            }
            #endif
        }
    }
}

public struct AnalyticsInsightsCard: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI-Powered Insights")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                InsightRow(
                    icon: "brain",
                    title: "Optimal Scheduling",
                    insight:
                        "Your success rate is 34% higher when habits are scheduled before 10 AM",
                    color: .blue
                )

                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Streak Prediction",
                    insight: "89% probability of maintaining current streak for next 7 days",
                    color: .green
                )

                InsightRow(
                    icon: "heart.text.square",
                    title: "Mood Correlation",
                    insight: "Meditation habit strongly correlates with improved daily mood scores",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
    }
}

public struct InsightRow: View {
    let icon: String
    let title: String
    let insight: String
    let color: Color

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: self.icon)
                .font(.title3)
                .foregroundColor(self.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(self.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(self.insight)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

public struct PredictiveAnalyticsCard: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Predictive Analytics")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                PredictionRow(
                    title: "7-Day Streak Success",
                    probability: 0.89,
                    color: .green
                )

                PredictionRow(
                    title: "Monthly Goal Achievement",
                    probability: 0.76,
                    color: .orange
                )

                PredictionRow(
                    title: "Habit Consistency",
                    probability: 0.92,
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
    }
}

public struct PredictionRow: View {
    let title: String
    let probability: Double
    let color: Color

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(self.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(self.probability * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(self.color)
            }

            ProgressView(value: self.probability)
                .progressViewStyle(LinearProgressViewStyle(tint: self.color))
                .scaleEffect(x: 1, y: 1.2)
        }
    }
}

public struct BehavioralPatternsCard: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Behavioral Patterns")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                PatternRow(
                    icon: "clock.fill",
                    title: "Peak Performance Time",
                    value: "8:00 - 10:00 AM",
                    color: .blue
                )

                PatternRow(
                    icon: "calendar.badge.clock",
                    title: "Most Consistent Day",
                    value: "Tuesday",
                    color: .green
                )

                PatternRow(
                    icon: "moon.stars.fill",
                    title: "Evening Habit Success",
                    value: "67% completion rate",
                    color: .purple
                )

                PatternRow(
                    icon: "figure.walk",
                    title: "Activity Correlation",
                    value: "Exercise boosts other habits by 24%",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
    }
}

public struct PatternRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    public var body: some View {
        HStack {
            Image(systemName: self.icon)
                .font(.title3)
                .foregroundColor(self.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(self.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(self.value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProfileView()
}
