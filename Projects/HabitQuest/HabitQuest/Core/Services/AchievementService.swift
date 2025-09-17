import Foundation
import SwiftData

/// Service for managing achievements and badge unlocking logic
/// Handles progress tracking, achievement unlocking, and reward distribution
enum AchievementService {
    private static let logger = Logger(category: .gameLogic)

    /// Initialize default achievements for new users
    // swiftlint:disable function_body_length
    static func createDefaultAchievements() -> [Achievement] {
        [
            // Streak Achievements
            Achievement(
                name: "First Steps",
                description: "Complete your first habit",
                iconName: "star.fill",
                category: .streak,
                xpReward: 25,
                requirement: .streakDays(1)
            ),
            Achievement(
                name: "Week Warrior",
                description: "Maintain a 7-day streak",
                iconName: "flame.fill",
                category: .streak,
                xpReward: 100,
                requirement: .streakDays(7)
            ),
            Achievement(
                name: "Unstoppable",
                description: "Maintain a 30-day streak",
                iconName: "bolt.fill",
                category: .streak,
                xpReward: 500,
                requirement: .streakDays(30)
            ),
            Achievement(
                name: "Legend",
                description: "Maintain a 100-day streak",
                iconName: "crown.fill",
                category: .streak,
                xpReward: 1000,
                isHidden: true,
                requirement: .streakDays(100)
            ),

            // Completion Achievements
            Achievement(
                name: "Getting Started",
                description: "Complete 10 habits",
                iconName: "checkmark.circle.fill",
                category: .completion,
                xpReward: 50,
                requirement: .totalCompletions(10)
            ),
            Achievement(
                name: "Quest Master",
                description: "Complete 100 habits",
                iconName: "list.bullet.circle.fill",
                category: .completion,
                xpReward: 200,
                requirement: .totalCompletions(100)
            ),
            Achievement(
                name: "Habit Hero",
                description: "Complete 500 habits",
                iconName: "shield.fill",
                category: .completion,
                xpReward: 750,
                requirement: .totalCompletions(500)
            ),

            // Level Achievements
            Achievement(
                name: "Level Up!",
                description: "Reach level 5",
                iconName: "arrow.up.circle.fill",
                category: .level,
                xpReward: 100,
                requirement: .reachLevel(5)
            ),
            Achievement(
                name: "Rising Star",
                description: "Reach level 10",
                iconName: "star.circle.fill",
                category: .level,
                xpReward: 250,
                requirement: .reachLevel(10)
            ),
            Achievement(
                name: "Master Adventurer",
                description: "Reach level 25",
                iconName: "diamond.fill",
                category: .level,
                xpReward: 1000,
                isHidden: true,
                requirement: .reachLevel(25)
            ),

            // Consistency Achievements
            Achievement(
                name: "Perfect Week",
                description: "Complete all habits for 7 consecutive days",
                iconName: "calendar.circle.fill",
                category: .consistency,
                xpReward: 300,
                requirement: .perfectWeek
            ),
            Achievement(
                name: "Variety Seeker",
                description: "Maintain 5 different active habits",
                iconName: "grid.circle.fill",
                category: .consistency,
                xpReward: 150,
                requirement: .habitVariety(5)
            ),

            // Special Achievements
            Achievement(
                name: "Early Bird",
                description: "Complete habits before 9 AM for 7 days",
                iconName: "sunrise.fill",
                category: .special,
                xpReward: 200,
                requirement: .earlyBird
            ),
            Achievement(
                name: "Night Owl",
                description: "Complete habits after 9 PM for 7 days",
                iconName: "moon.fill",
                category: .special,
                xpReward: 200,
                requirement: .nightOwl
            ),
            Achievement(
                name: "Weekend Warrior",
                description: "Complete habits on weekends for 4 weeks",
                iconName: "calendar.badge.clock",
                category: .special,
                xpReward: 300,
                requirement: .weekendWarrior
            )
        ]
    }

    /// Check and update achievement progress based on current player state
    /// - Parameters:
    ///   - achievements: All achievements to check
    ///   - player: Current player profile
    ///   - habits: All user habits
    ///   - recentLogs: Recent habit completion logs
    /// - Returns: List of newly unlocked achievements
    static func updateAchievementProgress(
        achievements: [Achievement],
        player: PlayerProfile,
        habits: [Habit],
        recentLogs: [HabitLog]
    ) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        for achievement in achievements where !achievement.isUnlocked {
            let previousProgress = achievement.progress
            let newProgress = calculateProgress(for: achievement, player: player, habits: habits, logs: recentLogs)

            achievement.progress = newProgress

            // Check if achievement was just unlocked
            if newProgress >= 1.0, previousProgress < 1.0 {
                unlockAchievement(achievement, for: player)
                newlyUnlocked.append(achievement)
                logger.info("Achievement unlocked: \(achievement.name)")
            }
        }

        return newlyUnlocked
    }

    /// Calculate progress for a specific achievement requirement
    private static func calculateProgress(
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
            return self.calculatePerfectWeekProgress(habits: habits, logs: logs)

        case let .habitVariety(targetCount):
            let activeHabits = habits.filter { habit in
                // Consider a habit active if it has been completed in the last 7 days
                let logs = habit.logs
                let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                return logs.contains { $0.completionDate >= weekAgo }
            }
            return min(Float(activeHabits.count) / Float(targetCount), 1.0)

        case .earlyBird:
            return self.calculateTimeBasedProgress(logs: logs, beforeHour: 9, targetDays: 7)

        case .nightOwl:
            return self.calculateTimeBasedProgress(logs: logs, afterHour: 21, targetDays: 7)

        case .weekendWarrior:
            return self.calculateWeekendWarriorProgress(logs: logs)
        }
    }

    /// Unlock an achievement and award XP
    private static func unlockAchievement(_ achievement: Achievement, for player: PlayerProfile) {
        achievement.unlockedDate = Date()
        achievement.progress = 1.0

        // Award XP bonus
        let levelUpResult = GameRules.processXPGain(
            experiencePoints: achievement.xpReward,
            for: player
        )

        self.logger.info("Achievement '\(achievement.name)' unlocked! Awarded \(achievement.xpReward) XP")

        if levelUpResult.leveledUp {
            self.logger.info("Level up occurred from achievement XP! New level: \(levelUpResult.newLevel)")
        }
    }

    /// Calculate progress for perfect week achievement
    private static func calculatePerfectWeekProgress(habits: [Habit], logs: [HabitLog]) -> Float {
        let calendar = Calendar.current
        let now = Date()

        // Check last 7 days
        var consecutivePerfectDays = 0
        var maxConsecutiveDays = 0

        for dayOffset in 0 ..< 7 {
            guard let checkDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }

            let dayLogs = logs.filter { calendar.isDate($0.completionDate, inSameDayAs: checkDate) }
            let uniqueHabitsCompletedThatDay = Set(dayLogs.compactMap { $0.habit?.id })

            // Check if all active habits were completed that day
            let activeHabitsCount = habits.count // Simplified - could be more sophisticated

            if uniqueHabitsCompletedThatDay.count >= activeHabitsCount, activeHabitsCount > 0 {
                consecutivePerfectDays += 1
                maxConsecutiveDays = max(maxConsecutiveDays, consecutivePerfectDays)
            } else {
                consecutivePerfectDays = 0
            }
        }

        return min(Float(maxConsecutiveDays) / 7.0, 1.0)
    }

    /// Calculate progress for time-based achievements (early bird, night owl)
    private static func calculateTimeBasedProgress(
        logs: [HabitLog],
        beforeHour: Int? = nil,
        afterHour: Int? = nil,
        targetDays: Int
    ) -> Float {
        let calendar = Calendar.current
        let now = Date()

        var qualifyingDays = 0

        for dayOffset in 0 ..< targetDays {
            guard let checkDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }

            let dayLogs = logs.filter { calendar.isDate($0.completionDate, inSameDayAs: checkDate) }

            let qualifiesForDay = dayLogs.contains { log in
                let hour = calendar.component(.hour, from: log.completionDate)
                if let beforeHour {
                    return hour < beforeHour
                } else if let afterHour {
                    return hour >= afterHour
                }
                return false
            }

            if qualifiesForDay {
                qualifyingDays += 1
            }
        }

        return min(Float(qualifyingDays) / Float(targetDays), 1.0)
    }

    /// Calculate progress for weekend warrior achievement
    private static func calculateWeekendWarriorProgress(logs: [HabitLog]) -> Float {
        let calendar = Calendar.current
        let now = Date()

        var weekendsWithCompletions = 0

        // Check last 4 weeks
        for weekOffset in 0 ..< 4 {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) else { continue }

            // Check Saturday and Sunday of that week
            let weekendDays = [7, 1] // Saturday = 7, Sunday = 1 in Calendar
            var hasWeekendCompletion = false

            for weekday in weekendDays {
                if let weekendDate = calendar.nextDate(
                    after: weekStart,
                    matching: DateComponents(weekday: weekday),
                    matchingPolicy: .nextTime
                ) {
                    let hasCompletions = logs.contains { calendar.isDate($0.completionDate, inSameDayAs: weekendDate) }
                    if hasCompletions {
                        hasWeekendCompletion = true
                        break
                    }
                }
            }

            if hasWeekendCompletion {
                weekendsWithCompletions += 1
            }
        }

        return min(Float(weekendsWithCompletions) / 4.0, 1.0)
    }
}

// swiftlint:enable function_body_length
