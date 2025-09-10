import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingAdvancedAnalytics = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Character Avatar Section
                    CharacterAvatarSection(
                        level: viewModel.level,
                        currentXP: viewModel.currentXP,
                        xpToNextLevel: viewModel.xpForNextLevel,
                        avatarImageName: "person.circle.fill"
                    )

                    // Progress Section
                    ProgressSection(
                        currentXP: viewModel.currentXP,
                        xpToNextLevel: viewModel.xpForNextLevel,
                        totalXP: viewModel.currentXP
                    )

                    // Stats Section
                    StatsSection(
                        totalHabits: viewModel.totalHabits,
                        activeStreaks: 0,
                        completedToday: viewModel.completedToday,
                        longestStreak: viewModel.longestStreak,
                        perfectDays: 0,
                        weeklyCompletion: 0.0
                    )

                    // Achievements Section
                    AchievementsSection(achievements: viewModel.achievements)

                    // Advanced Analytics Button
                    Button(action: {
                        showingAdvancedAnalytics = true
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
            .sheet(isPresented: $showingAdvancedAnalytics) {
                AdvancedAnalyticsView()
            }
        }
    }
}

struct CharacterAvatarSection: View {
    let level: Int
    let currentXP: Int
    let xpToNextLevel: Int
    let avatarImageName: String

    var body: some View {
        VStack(spacing: 12) {
            // Avatar Circle
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)

                Image(systemName: avatarImageName)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }

            // Level Badge
            Text("Level \(level)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            // XP Progress
            VStack(spacing: 4) {
                HStack {
                    Text("XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(currentXP) / \(xpToNextLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                ProgressView(value: Double(currentXP), total: Double(xpToNextLevel))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 1.5)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct ProgressSection: View {
    let currentXP: Int
    let xpToNextLevel: Int
    let totalXP: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                HStack {
                    Text("Current Level XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(currentXP) / \(xpToNextLevel)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                ProgressView(value: Double(currentXP), total: Double(xpToNextLevel))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))

                HStack {
                    Text("Total XP Earned")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(totalXP)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct StatsSection: View {
    let totalHabits: Int
    let activeStreaks: Int
    let completedToday: Int
    let longestStreak: Int
    let perfectDays: Int
    let weeklyCompletion: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(title: "Total Habits", value: "\(totalHabits)", icon: "list.bullet")
                StatCard(title: "Active Streaks", value: "\(activeStreaks)", icon: "flame")
                StatCard(title: "Completed Today", value: "\(completedToday)", icon: "checkmark.circle")
                StatCard(title: "Longest Streak", value: "\(longestStreak)", icon: "star")
                StatCard(title: "Perfect Days", value: "\(perfectDays)", icon: "crown")
                StatCard(title: "Weekly Rate", value: "\(Int(weeklyCompletion))%", icon: "percent")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AchievementsSection: View {
    let achievements: [Achievement]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if achievements.count > 3 {
                    Button("View All") {
                        // Navigate to achievements view
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            if achievements.isEmpty {
                Text("No achievements yet. Keep building habits!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(achievements.prefix(6)) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)

            Text(achievement.name)
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
        }
        .padding(8)
        .background(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AnalyticsTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analytics Overview")
                .font(.headline)
                .fontWeight(.semibold)

            Picker("Analytics Tab", selection: $selectedTab) {
                Text("Trends").tag(0)
                Text("Patterns").tag(1)
                Text("Insights").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())

            Group {
                switch selectedTab {
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
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct TrendsView: View {
    var body: some View {
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct PatternsView: View {
    var body: some View {
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct InsightsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.yellow)
                Text("AI Recommendation")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text("Consider adding a morning meditation habit. Your completion rate is 23% higher for morning activities.")
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AdvancedAnalyticsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Analytics Overview Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Streak Heat Map")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text("Advanced heat map visualization will be available when habits are selected.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)

                    // Detailed Analytics Components
                    AnalyticsInsightsCard()
                    PredictiveAnalyticsCard()
                    BehavioralPatternsCard()
                }
                .padding()
            }
            .navigationTitle("Advanced Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AnalyticsInsightsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI-Powered Insights")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                InsightRow(
                    icon: "brain",
                    title: "Optimal Scheduling",
                    insight: "Your success rate is 34% higher when habits are scheduled before 10 AM",
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
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let insight: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(insight)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct PredictiveAnalyticsCard: View {
    var body: some View {
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
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct PredictionRow: View {
    let title: String
    let probability: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(probability * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }

            ProgressView(value: probability)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 1.2)
        }
    }
}

struct BehavioralPatternsCard: View {
    var body: some View {
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
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct PatternRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(value)
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
