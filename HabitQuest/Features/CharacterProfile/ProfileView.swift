import HabitQuestCore
import SwiftData
import SwiftUI

public struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingAchievementGallery = false
    @State private var selectedAchievement: Achievement?

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
                    AchievementsSection(
                        achievements: viewModel.achievements,
                        onViewAll: {
                            selectedAchievement = nil
                            showingAchievementGallery = true
                        },
                        onSelectAchievement: { achievement in
                            guard !achievement.isHidden || achievement.isUnlocked else { return }
                            selectedAchievement = achievement
                            showingAchievementGallery = true
                        }
                    )
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingAchievementGallery) {
                AchievementGalleryView(
                    achievements: viewModel.achievements,
                    selectedAchievement: selectedAchievement
                )
            }
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
