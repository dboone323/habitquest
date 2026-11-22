import Combine
import HabitQuestCore
import SwiftData
import SwiftUI

/// ViewModel for ProfileView handling player profile data and statistics
@MainActor
public class ProfileViewModel: ObservableObject {
    @Published var level: Int = 1
    @Published var currentXP: Int = 0
    @Published var xpForNextLevel: Int = 100
    @Published var xpProgress: Float = 0.0
    @Published var longestStreak: Int = 0
    @Published var totalHabits: Int = 0
    @Published var completedToday: Int = 0
    @Published var activeStreaks: Int = 0
    @Published var perfectDays: Int = 0
    @Published var weeklyCompletion: Double = 0.0
    @Published var achievements: [Achievement] = []

    private var modelContext: ModelContext?
    private let logger = HabitQuestLogger(category: .uiCategory)
    private let gamificationService = GamificationService()

    /// Set the model context and load profile data
    func setModelContext(_ context: ModelContext) {
        modelContext = context
        loadProfile()
        loadStatistics()
        loadAchievements()
    }

    /// Refresh all profile data
    func refreshProfile() {
        loadProfile()
        loadStatistics()
        updateAchievements()
    }

    /// Load player profile data from SwiftData
    private func loadProfile() {
        guard let modelContext else { return }

        do {
            let fetchDescriptor = FetchDescriptor<PlayerProfile>()
            let profiles = try modelContext.fetch(fetchDescriptor)

            if let profile = profiles.first {
                updateProfileData(from: profile)
                logger.info("Loaded player profile - Level: \(profile.level), XP: \(profile.currentXP)")
            } else {
                createDefaultProfile()
            }
        } catch {
            logger.error("Failed to load player profile: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Update published properties from PlayerProfile model
    private func updateProfileData(from profile: PlayerProfile) {
        level = profile.level
        currentXP = profile.currentXP
        xpForNextLevel = gamificationService.calculateXPForNextLevel(forLevel: profile.level)
        
        // Manual progress calculation since we moved it from @Model to avoid service dependency in core model
        let previousLevelXP = profile.level > 1 ? gamificationService.calculateXPForLevel(profile.level - 1) : 0
        let currentLevelXP = gamificationService.calculateXPForLevel(profile.level)
        let progressInCurrentLevel = profile.currentXP - previousLevelXP
        let xpNeededForCurrentLevel = currentLevelXP - previousLevelXP
        xpProgress = xpNeededForCurrentLevel > 0 ? Float(progressInCurrentLevel) / Float(xpNeededForCurrentLevel) : 0.0
        
        longestStreak = profile.longestStreak
    }

    /// Create a default player profile
    private func createDefaultProfile() {
        guard let modelContext else { return }

        do {
            let newProfile = PlayerProfile()
            modelContext.insert(newProfile)
            try modelContext.save()

            updateProfileData(from: newProfile)
            logger.info("Created new player profile")
        } catch {
            logger.error("Failed to create player profile: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Load additional statistics from habits data
    private func loadStatistics() {
        guard let modelContext else { return }

        do {
            let habitFetchDescriptor = FetchDescriptor<Habit>()
            let allHabits = try modelContext.fetch(habitFetchDescriptor)
            totalHabits = allHabits.count

            let calendar = Calendar.current
            let today = Date()

            completedToday = allHabits.reduce(0) { count, habit in
                let logs = habit.logs 
                let todayCompletions = logs.filter { log in
                    calendar.isDate(log.completionDate, inSameDayAs: today)
                }
                return count + (todayCompletions.isEmpty ? 0 : 1)
            }

            activeStreaks = allHabits.filter { $0.streak > 0 }.count

            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
            let allLogs = allHabits.flatMap { $0.logs }
            let weekLogs = allLogs.filter { $0.completionDate >= sevenDaysAgo && $0.completionDate <= today && $0.isCompleted }
            let expectedWeekCompletions = totalHabits * 7
            weeklyCompletion = expectedWeekCompletions > 0 ? min(100.0, (Double(weekLogs.count) / Double(expectedWeekCompletions)) * 100.0) : 0.0

            var perfectDayCount = 0
            if totalHabits > 0 {
                for dayOffset in 0..<30 {
                    if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                        let completedOnDate = allHabits.filter { habit in
                            habit.logs.contains { log in
                                log.isCompleted && calendar.isDate(log.completionDate, inSameDayAs: date)
                            }
                        }.count
                        if completedOnDate == totalHabits {
                            perfectDayCount += 1
                        }
                    }
                }
            }
            perfectDays = perfectDayCount

            logger.info("Loaded statistics - Total habits: \(totalHabits), Completed today: \(completedToday)")
        } catch {
            logger.error("Failed to load statistics: \(error.localizedDescription)")
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
                let defaultAchievements = AchievementService.createDefaultAchievements()
                for achievement in defaultAchievements {
                    modelContext.insert(achievement)
                }
                try modelContext.save()
                achievements = defaultAchievements
                logger.info("Created \(defaultAchievements.count) default achievements")
            } else {
                achievements = existingAchievements
                logger.info("Loaded \(existingAchievements.count) existing achievements")
            }
        } catch {
            logger.error("Failed to load achievements: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }

    /// Update achievement progress and check for unlocks
    private func updateAchievements() {
        guard let modelContext else { return }

        do {
            let profileFetchDescriptor = FetchDescriptor<PlayerProfile>()
            let profiles = try modelContext.fetch(profileFetchDescriptor)
            guard let profile = profiles.first else { return }

            let habitFetchDescriptor = FetchDescriptor<Habit>()
            let habits = try modelContext.fetch(habitFetchDescriptor)

            let logFetchDescriptor = FetchDescriptor<HabitLog>()
            let logs = try modelContext.fetch(logFetchDescriptor)

            let newlyUnlocked = AchievementService.updateAchievementProgress(
                achievements: achievements,
                player: profile,
                habits: habits,
                recentLogs: logs
            )

            if !newlyUnlocked.isEmpty {
                try modelContext.save()
                logger.info("Updated achievements, \(newlyUnlocked.count) newly unlocked")
                updateProfileData(from: profile)
            }
        } catch {
            logger.error("Failed to update achievements: \(error.localizedDescription)")
            ErrorHandler.handle(error, showToUser: true)
        }
    }
}
