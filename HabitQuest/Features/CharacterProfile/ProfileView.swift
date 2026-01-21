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
                    Button(
                        action: {
                            showingAdvancedAnalytics = true
                        },
                        label: {
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
                    )

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

#Preview {
    ProfileView()
}
