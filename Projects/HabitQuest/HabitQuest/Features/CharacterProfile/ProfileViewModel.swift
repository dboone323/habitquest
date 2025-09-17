import Combine
import SwiftData
import SwiftUI

/// ViewModel for ProfileView handling player profile data and statistics
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var level: Int = 1
    @Published var currentXP: Int = 0
    @Published var xpForNextLevel: Int = 100
    @Published var xpProgress: Float = 0.0
    @Published var longestStreak: Int = 0
    @Published var totalHabits: Int = 0
    @Published var completedToday: Int = 0
    @Published var achievements: [Achievement] = []
    @Published var analytics: HabitAnalytics = .empty

    private var modelContext: ModelContext?
    private let logger = Logger(category: .uiCategory)
    private var analyticsService: AnalyticsService?

    /// Set the model context and load profile data
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        self.analyticsService = AnalyticsService(modelContext: context)
        self.loadProfile()
        self.loadStatistics()
        self.loadAchievements()
        self.loadAnalytics()
    }

    /// Refresh all profile data
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func refreshProfile() {
        self.loadProfile()
        self.loadStatistics()
        self.updateAchievements()
        self.loadAnalytics()
    }

    /// Load analytics data
    private func loadAnalytics() {
        Task {
            let newAnalytics = await analyticsService?.getAnalytics()
            await MainActor.run {
                self.analytics = newAnalytics ?? HabitAnalytics.empty
            }
        }
    }

    /// Load player profile data from SwiftData
    private func loadProfile() {
        guard let modelContext else { return }

        do {
            let fetchDescriptor = FetchDescriptor<PlayerProfile>()
            let profiles = try modelContext.fetch(fetchDescriptor)

            if let profile = profiles.first {
                self.updateProfileData(from: profile)
                self.logger.info("Loaded player profile - Level: \(profile.level), XP: \(profile.currentXP)")
            } else {
                // Create default profile if none exists
                self.createDefaultProfile()
            }

        } catch {
            self.logger.error("Failed to load player profile: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Update published properties from PlayerProfile model
    private func updateProfileData(from profile: PlayerProfile) {
        self.level = profile.level
        self.currentXP = profile.currentXP
        self.xpForNextLevel = GameRules.calculateXPForNextLevel(forLevel: profile.level)
        self.xpProgress = profile.xpProgress
        self.longestStreak = profile.longestStreak
    }

    /// Create a default player profile
    private func createDefaultProfile() {
        guard let modelContext else { return }

        do {
            let newProfile = PlayerProfile()
            modelContext.insert(newProfile)
            try modelContext.save()

            self.updateProfileData(from: newProfile)
            self.logger.info("Created new player profile")

        } catch {
            self.logger.error("Failed to create player profile: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Load additional statistics from habits data
    private func loadStatistics() {
        guard let modelContext else { return }

        do {
            // Load all habits
            let habitFetchDescriptor = FetchDescriptor<Habit>()
            let allHabits = try modelContext.fetch(habitFetchDescriptor)
            self.totalHabits = allHabits.count

            // Calculate completed today
            let calendar = Calendar.current
            let today = Date()

            self.completedToday = allHabits.reduce(0) { count, habit in
                let logs = habit.logs // Remove optional binding since logs is not optional
                let todayCompletions = logs.filter { log in
                    calendar.isDate(log.completionDate, inSameDayAs: today)
                }
                return count + (todayCompletions.isEmpty ? 0 : 1)
            }

            self.logger.info("Loaded statistics - Total habits: \(self.totalHabits), Completed today: \(self.completedToday)")

        } catch {
            self.logger.error("Failed to load statistics: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Load achievements from SwiftData or create default ones
    private func loadAchievements() {
        guard let modelContext else { return }

        do {
            let fetchDescriptor = FetchDescriptor<Achievement>()
            let existingAchievements = try modelContext.fetch(fetchDescriptor)

            if existingAchievements.isEmpty {
                // Create default achievements for new users
                let defaultAchievements = AchievementService.createDefaultAchievements()
                for achievement in defaultAchievements {
                    modelContext.insert(achievement)
                }
                try modelContext.save()
                self.achievements = defaultAchievements
                self.logger.info("Created \(defaultAchievements.count) default achievements")
            } else {
                self.achievements = existingAchievements
                self.logger.info("Loaded \(existingAchievements.count) existing achievements")
            }

        } catch {
            self.logger.error("Failed to load achievements: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Update achievement progress and check for unlocks
    private func updateAchievements() {
        guard let modelContext else { return }

        do {
            // Get player profile and all habits/logs
            let profileFetchDescriptor = FetchDescriptor<PlayerProfile>()
            let profiles = try modelContext.fetch(profileFetchDescriptor)
            guard let profile = profiles.first else { return }

            let habitFetchDescriptor = FetchDescriptor<Habit>()
            let habits = try modelContext.fetch(habitFetchDescriptor)

            let logFetchDescriptor = FetchDescriptor<HabitLog>()
            let logs = try modelContext.fetch(logFetchDescriptor)

            // Update achievement progress
            let newlyUnlocked = AchievementService.updateAchievementProgress(
                achievements: self.achievements,
                player: profile,
                habits: habits,
                recentLogs: logs
            )

            if !newlyUnlocked.isEmpty {
                try modelContext.save()
                self.logger.info("Updated achievements, \(newlyUnlocked.count) newly unlocked")

                // Update profile data after potential XP gains
                self.updateProfileData(from: profile)
            }

        } catch {
            self.logger.error("Failed to update achievements: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }
}
