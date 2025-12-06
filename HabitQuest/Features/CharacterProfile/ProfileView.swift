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
                    Button(
                        action: {
                            self.showingAdvancedAnalytics = true
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
            .sheet(isPresented: self.$showingAdvancedAnalytics) {
                AdvancedAnalyticsView()
            }
        }
    }
}

#Preview {
    ProfileView()
}
