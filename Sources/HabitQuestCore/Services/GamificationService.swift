//
// GamificationService.swift
// HabitQuestCore
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.habitquest.core", category: "GamificationService")

/// Comprehensive service for managing all game-like elements of the habit tracking experience.
/// Consolidated from legacy XPService, LevelingSystem, and AchievementService.
@MainActor
public struct GamificationService: Sendable {
    public init() {}

    // MARK: - XP & Leveling Logic

    /// Calculate the total XP required to reach a specific level.
    /// Uses an exponential curve: 100 * (1.5 ^ (level - 1))
    public func calculateXPForLevel(_ level: Int) -> Int {
        guard level > 0 else { return 0 }
        return Int(100 * pow(1.5, Double(level - 1)))
    }

    /// Calculate XP needed for the next level from current level.
    public func calculateXPForNextLevel(forLevel level: Int) -> Int {
        calculateXPForLevel(level + 1)
    }

    /// Process XP gain and handle level progression.
    @discardableResult
    public func processXPGain(experiencePoints: Int, for profile: PlayerProfile) -> (leveledUp: Bool, newLevel: Int) {
        profile.currentXP += experiencePoints

        var leveledUp = false
        var newLevel = profile.level

        while profile.currentXP >= calculateXPForLevel(newLevel + 1) {
            newLevel += 1
            leveledUp = true
        }

        if leveledUp {
            profile.level = newLevel
            profile.xpForNextLevel = calculateXPForNextLevel(forLevel: newLevel)
            logger.info("Level up! New level: \(newLevel)")
        }

        return (leveledUp: leveledUp, newLevel: newLevel)
    }

    // MARK: - Habit Progression

    /// Process habit completion and update player profile and habit stats.
    @discardableResult
    public func processHabitCompletion(habit: Habit, profile: PlayerProfile) -> (leveledUp: Bool, newLevel: Int) {
        // Award XP from the habit completion
        let xpEarned = habit.xpValue * habit.difficulty.xpMultiplier
        let levelResult = processXPGain(experiencePoints: xpEarned, for: profile)

        // Update habit streak
        updateHabitStreak(habit: habit)

        // Update longest streak in profile
        if habit.streak > profile.longestStreak {
            profile.longestStreak = habit.streak
        }

        return levelResult
    }

    /// Update the streak for a specific habit based on completion history.
    public func updateHabitStreak(habit: Habit) {
        let completedLogs = habit.logs.filter(\.isCompleted)
        guard !completedLogs.isEmpty else {
            habit.streak = 0
            return
        }

        let sortedLogs = completedLogs.sorted { $0.completionDate > $1.completionDate }
        let calendar = Calendar.current
        var currentStreak = 1

        for index in 1..<sortedLogs.count {
            let currentLog = sortedLogs[index - 1]
            let previousLog = sortedLogs[index]
            let isConsecutive: Bool

            switch habit.frequency {
            case .daily:
                let dayComponents = calendar.dateComponents([.day], from: previousLog.completionDate, to: currentLog.completionDate)
                isConsecutive = (dayComponents.day ?? 0) == 1
            case .weekly:
                let weekComponents = calendar.dateComponents([.weekOfYear], from: previousLog.completionDate, to: currentLog.completionDate)
                isConsecutive = (weekComponents.weekOfYear ?? 0) == 1
            case .monthly:
                let monthComponents = calendar.dateComponents([.month], from: previousLog.completionDate, to: currentLog.completionDate)
                isConsecutive = (monthComponents.month ?? 0) == 1
            case .custom:
                let dayComponents = calendar.dateComponents([.day], from: previousLog.completionDate, to: currentLog.completionDate)
                isConsecutive = (dayComponents.day ?? 0) == 1
            }

            if isConsecutive {
                currentStreak += 1
            } else {
                break
            }
        }

        habit.streak = currentStreak
    }

    /// Check if a habit should be performed today based on its frequency.
    public func isHabitDueToday(_ habit: Habit) -> Bool {
        guard habit.isActive else { return false }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        
        switch habit.frequency {
        case .daily:
            return true
        case .weekly:
            // For weekly, we check if it's Monday or if it hasn't been done in 7 days
            return weekday == 2 // Monday is default weekly check-in
        case .monthly:
            return calendar.component(.day, from: Date()) == 1 // First of month
        case .custom:
            return true
        }
    }

    // MARK: - Achievements Engine

    /// Provides a default set of achievements for initialization.
    public static func defaultAchievements() -> [Achievement] {
        [
            Achievement(
                name: "First Step",
                description: "Complete your first habit quest",
                iconName: "flag.fill",
                category: .completion,
                xpReward: 50,
                requirement: .totalCompletions(1)
            ),
            Achievement(
                name: "On Fire",
                description: "Maintain a 7-day streak on any habit",
                iconName: "flame.fill",
                category: .streak,
                xpReward: 100,
                requirement: .streakDays(7)
            ),
            Achievement(
                name: "Adventurer",
                description: "Reach Level 5",
                iconName: "figure.walk",
                category: .level,
                xpReward: 150,
                requirement: .reachLevel(5)
            ),
            Achievement(
                name: "Consistency Master",
                description: "Complete a perfect week (all active habits for 7 days)",
                iconName: "star.fill",
                category: .general,
                xpReward: 250,
                requirement: .perfectWeek
            )
        ]
    }

    /// Check and update achievement progress based on current player state.
    public func updateAchievementProgress(
        achievements: [Achievement],
        player: PlayerProfile,
        habits: [Habit],
        recentLogs: [HabitLog]
    ) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        for achievement in achievements where !achievement.isUnlocked {
            let previousProgress = achievement.progress
            let newProgress = calculateProgress(
                for: achievement, player: player, habits: habits, logs: recentLogs
            )

            achievement.progress = newProgress

            if newProgress >= 1.0, previousProgress < 1.0 {
                unlockAchievement(achievement, for: player)
                newlyUnlocked.append(achievement)
                logger.info("Achievement unlocked: \(achievement.name)")
            }
        }

        return newlyUnlocked
    }

    /// Unlock an achievement and award XP.
    private func unlockAchievement(_ achievement: Achievement, for player: PlayerProfile) {
        achievement.unlockedDate = Date()
        achievement.progress = 1.0
        processXPGain(experiencePoints: achievement.xpReward, for: player)
    }

    /// Calculate progress for a specific achievement requirement.
    private func calculateProgress(
        for achievement: Achievement,
        player: PlayerProfile,
        habits: [Habit],
        logs: [HabitLog]
    ) -> Float {
        switch achievement.requirement {
        case let .streakDays(targetDays):
            let maxStreak = habits.map(\.streak).max() ?? 0
            return min(Float(maxStreak) / Float(targetDays), 1.0)

        case let .totalCompletions(targetCount):
            let totalCompletions = logs.count
            return min(Float(totalCompletions) / Float(targetCount), 1.0)

        case let .reachLevel(targetLevel):
            return min(Float(player.level) / Float(targetLevel), 1.0)

        case .perfectWeek:
            return calculatePerfectWeekProgress(habits: habits, logs: logs)

        case let .habitVariety(targetCount):
            let activeHabits = habits.filter { habit in
                let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                return habit.logs.contains { $0.completionDate >= weekAgo }
            }
            return min(Float(activeHabits.count) / Float(targetCount), 1.0)

        case .earlyBird:
            return calculateTimeBasedProgress(logs: logs, beforeHour: 9, targetDays: 7)

        case .nightOwl:
            return calculateTimeBasedProgress(logs: logs, afterHour: 21, targetDays: 7)

        case .weekendWarrior:
            return calculateWeekendWarriorProgress(logs: logs)
        }
    }

    private func calculatePerfectWeekProgress(habits: [Habit], logs: [HabitLog]) -> Float {
        let calendar = Calendar.current
        let now = Date()
        var consecutivePerfectDays = 0
        var maxConsecutiveDays = 0

        for dayOffset in 0..<7 {
            guard let checkDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let dayLogs = logs.filter { calendar.isDate($0.completionDate, inSameDayAs: checkDate) }
            let uniqueHabitsCompletedThatDay = Set(dayLogs.compactMap { $0.habit?.id })
            let activeHabitsCount = habits.count

            if uniqueHabitsCompletedThatDay.count >= activeHabitsCount, activeHabitsCount > 0 {
                consecutivePerfectDays += 1
                maxConsecutiveDays = max(maxConsecutiveDays, consecutivePerfectDays)
            } else {
                consecutivePerfectDays = 0
            }
        }
        return min(Float(maxConsecutiveDays) / 7.0, 1.0)
    }

    private func calculateTimeBasedProgress(logs: [HabitLog], beforeHour: Int? = nil, afterHour: Int? = nil, targetDays: Int) -> Float {
        let calendar = Calendar.current
        let now = Date()
        var qualifyingDays = 0

        for dayOffset in 0..<targetDays {
            guard let checkDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let dayLogs = logs.filter { calendar.isDate($0.completionDate, inSameDayAs: checkDate) }
            let qualifies = dayLogs.contains { log in
                let hour = calendar.component(.hour, from: log.completionDate)
                if let beforeHour { return hour < beforeHour }
                if let afterHour { return hour >= afterHour }
                return false
            }
            if qualifies { qualifyingDays += 1 }
        }
        return min(Float(qualifyingDays) / Float(targetDays), 1.0)
    }

    private func calculateWeekendWarriorProgress(logs: [HabitLog]) -> Float {
        let calendar = Calendar.current
        let now = Date()
        var weekendsWithCompletions = 0

        for weekOffset in 0..<4 {
            let start = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) ?? now
            let weekendDays = [1, 7] // Sunday, Saturday
            let hasCompletion = logs.contains { log in
                let wd = calendar.component(.weekday, from: log.completionDate)
                let weekMatch = calendar.isDate(log.completionDate, equalTo: start, toGranularity: .weekOfYear)
                return weekMatch && weekendDays.contains(wd)
            }
            if hasCompletion { weekendsWithCompletions += 1 }
        }
        return min(Float(weekendsWithCompletions) / 4.0, 1.0)
    }
}
