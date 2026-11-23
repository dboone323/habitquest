import HabitQuestCore
import SwiftData
import SwiftUI

public struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ProfileViewModel()

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
                        activeStreaks: viewModel.activeStreaks,
                        completedToday: viewModel.completedToday,
                        longestStreak: viewModel.longestStreak,
                        perfectDays: viewModel.perfectDays,
                        weeklyCompletion: viewModel.weeklyCompletion
                    )

                    // Achievements Section
                    AchievementsSection(achievements: viewModel.achievements)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .onAppear {
                viewModel.setModelContext(modelContext)
                viewModel.refreshProfile()
            }
        }
    }
}

#Preview {
    ProfileView()
}
