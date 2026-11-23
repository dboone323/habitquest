import HabitQuestCore

import Foundation
import SwiftData

/// Service for handling streak calculations, milestone detection, and streak analytics
@MainActor
class StreakService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Streak Calculations

    /// Calculate current streak for a habit with forgiving threshold and streak freeze inventory
    /// - Parameters:
    ///   - habit: The habit to analyze
    ///   - profile: Optional player profile with streak freeze inventory
    ///   - forgivenessThreshold: Days allowed to be missed before streak resets (default from Settings)
    /// - Returns: Number of consecutive days completed up to today
    func calculateCurrentStreak(
        for habit: Habit,
        profile: PlayerProfile? = nil,
        forgivenessThreshold: Int = StreakForgivenessConfig.threshold
    ) async -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let completedLogs = habit.logs
            .filter(\.isCompleted)
            .sorted { $0.completionDate > $1.completionDate }

        guard !completedLogs.isEmpty else { return 0 }

        // Deduplicate to unique calendar days sorted descending
        var completedDays: [Date] = []
        var seenDays = Set<Date>()
        for log in completedLogs {
            let day = calendar.startOfDay(for: log.completionDate)
            if !seenDays.contains(day) {
                seenDays.insert(day)
                completedDays.append(day)
            }
        }

        guard let mostRecentDay = completedDays.first else { return 0 }

        // Check gap from most recent completion to today
        let daysSinceLast = calendar.dateComponents([.day], from: mostRecentDay, to: today).day ?? 0
        let missedDaysSinceLast = max(0, daysSinceLast - 1)

        var availableFreezes = profile?.streakFreezes ?? 0
        let freezesUsedForRecent = min(availableFreezes, missedDaysSinceLast)
        availableFreezes -= freezesUsedForRecent
        let effectiveMissedSinceLast = missedDaysSinceLast - freezesUsedForRecent

        if effectiveMissedSinceLast > forgivenessThreshold {
            return 0 // Gap exceeds forgiveness threshold and available freezes; streak broken
        }

        var streak = 1
        var previousDay = mostRecentDay

        for day in completedDays.dropFirst() {
            let daysBetween = calendar.dateComponents([.day], from: day, to: previousDay).day ?? 1
            let missedDays = max(0, daysBetween - 1)

            if missedDays == 0 {
                streak += 1
                previousDay = day
            } else {
                let freezesUsed = min(availableFreezes, missedDays)
                availableFreezes -= freezesUsed
                let effectiveMissed = missedDays - freezesUsed

                if effectiveMissed <= forgivenessThreshold {
                    streak += 1
                    previousDay = day
                } else {
                    break // Gap exceeds threshold, streak broken
                }
            }
        }

        return streak
    }

    /// Calculate longest streak for a habit with forgiving threshold
    /// - Parameters:
    ///   - habit: The habit to analyze
    ///   - forgivenessThreshold: Days allowed to be missed before streak resets
    /// - Returns: The historically longest streak for this habit
    func calculateLongestStreak(
        for habit: Habit,
        forgivenessThreshold: Int = StreakForgivenessConfig.threshold
    ) async -> Int {
        let calendar = Calendar.current

        let completedLogs = habit.logs
            .filter(\.isCompleted)
            .sorted { $0.completionDate < $1.completionDate }

        var completedDays: [Date] = []
        var seenDays = Set<Date>()
        for log in completedLogs {
            let day = calendar.startOfDay(for: log.completionDate)
            if !seenDays.contains(day) {
                seenDays.insert(day)
                completedDays.append(day)
            }
        }

        guard !completedDays.isEmpty else { return 0 }

        var longestStreak = 0
        var currentStreak = 0
        var previousDate: Date?

        for logDate in completedDays {
            if let prevDate = previousDate {
                let daysBetween = calendar.dateComponents([.day], from: prevDate, to: logDate).day ?? 0
                let missedDays = max(0, daysBetween - 1)

                if missedDays <= forgivenessThreshold {
                    currentStreak += 1
                } else {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }

            previousDate = logDate
        }

        return max(longestStreak, currentStreak)
    }

    /// Get streak data for visualization
    /// - Parameters:
    ///   - habit: The habit to analyze
    ///   - days: Number of days of history to retrieve
    /// - Returns: Array of day-by-day streak status
    func getStreakData(for habit: Habit, days: Int = 30) async -> [StreakDayData] {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: today) ?? today

        // Direct relationship navigation - eliminates predicate complexity
        let completedLogs = habit.logs.filter(\.isCompleted)
        let completedDates = Set(completedLogs.map { calendar.startOfDay(for: $0.completionDate) })

        var streakData: [StreakDayData] = []
        var currentDate = startDate

        while currentDate <= today {
            let dayStart = calendar.startOfDay(for: currentDate)
            let isCompleted = completedDates.contains(dayStart)

            streakData.append(
                StreakDayData(
                    date: currentDate,
                    isCompleted: isCompleted,
                    intensity: isCompleted ? 1.0 : 0.0
                )
            )

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return streakData
    }

    // MARK: - Milestone Detection

    /// Check if completing a habit today would achieve a new milestone
    /// - Parameters:
    ///   - habit: The habit to check
    ///   - previousStreak: The streak count before today's completion
    /// - Returns: A milestone if one was achieved, nil otherwise
    func checkForNewMilestone(habit: Habit, previousStreak: Int) async -> StreakMilestone? {
        let newStreak = await calculateCurrentStreak(for: habit)

        if StreakMilestone.isNewMilestone(streakCount: newStreak, previousCount: previousStreak) {
            return StreakMilestone.milestone(for: newStreak)
        }

        return nil
    }

    /// Get current milestone for a habit
    /// - Parameter habit: The habit to check
    /// - Returns: The highest milestone currently achieved
    func getCurrentMilestone(for habit: Habit) async -> StreakMilestone? {
        let currentStreak = await calculateCurrentStreak(for: habit)
        return StreakMilestone.milestone(for: currentStreak)
    }

    /// Get next milestone to achieve
    /// - Parameter habit: The habit to check
    /// - Returns: The next milestone in the progression
    func getNextMilestone(for habit: Habit) async -> StreakMilestone? {
        let currentStreak = await calculateCurrentStreak(for: habit)
        return StreakMilestone.nextMilestone(for: currentStreak)
    }

    /// Get progress towards next milestone (0.0 to 1.0)
    /// - Parameter habit: The habit to check
    /// - Returns: Progress percentage towards the next milestone
    func getProgressToNextMilestone(for habit: Habit) async -> Double {
        let currentStreak = await calculateCurrentStreak(for: habit)
        guard let nextMilestone = StreakMilestone.nextMilestone(for: currentStreak) else {
            return 1.0 // Already at max milestone
        }

        let previousMilestone = StreakMilestone.milestone(for: currentStreak)
        let startCount = previousMilestone.streakCount
        let targetCount = nextMilestone.streakCount

        let progress = Double(currentStreak - startCount) / Double(targetCount - startCount)
        return max(0.0, min(1.0, progress))
    }

    // MARK: - Streak Analytics

    /// Get comprehensive streak analytics for a habit
    /// - Parameter habit: The habit to analyze
    /// - Returns: A structured analytics object
    func getStreakAnalytics(for habit: Habit) async -> StreakAnalytics {
        let currentStreak = await calculateCurrentStreak(for: habit)
        let longestStreak = await calculateLongestStreak(for: habit)
        let currentMilestone = await getCurrentMilestone(for: habit)
        let nextMilestone = await getNextMilestone(for: habit)
        let progressToNext = await getProgressToNextMilestone(for: habit)

        return StreakAnalytics(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            currentMilestone: currentMilestone,
            nextMilestone: nextMilestone,
            progressToNextMilestone: progressToNext,
            streakPercentile: calculateStreakPercentile(currentStreak)
        )
    }

    /// Calculate what percentile a streak is in (for motivation)
    private func calculateStreakPercentile(_ streak: Int) -> Double {
        switch streak {
        case 0...2: 0.1
        case 3...6: 0.25
        case 7...13: 0.5
        case 14...29: 0.75
        case 30...99: 0.9
        case 100...364: 0.95
        default: 0.99
        }
    }
}

// MARK: - Supporting Data Structures

/// Represents a single day in streak visualization
public struct StreakDayData: Identifiable {
    public let id = UUID()
    let date: Date
    let isCompleted: Bool
    let intensity: Double // 0.0 to 1.0 for heat map intensity
}

/// Comprehensive streak analytics for a habit
struct StreakAnalytics {
    let currentStreak: Int
    let longestStreak: Int
    let currentMilestone: StreakMilestone?
    let nextMilestone: StreakMilestone?
    let progressToNextMilestone: Double
    let streakPercentile: Double

    /// Formatted streak description
    var streakDescription: String {
        if currentStreak == 0 {
            "Ready to start your streak!"
        } else if currentStreak == 1 {
            "1 day streak - great start!"
        } else {
            "\(currentStreak) day streak"
        }
    }

    /// Motivational message based on progress
    var motivationalMessage: String {
        guard let nextMilestone else {
            return "You've reached legendary status!"
        }

        let daysToNext = nextMilestone.streakCount - currentStreak

        if daysToNext == 1 {
            return "Just 1 more day to reach \(nextMilestone.title)!"
        } else if daysToNext <= 7 {
            return "\(daysToNext) days to \(nextMilestone.title)!"
        } else {
            return "Working towards \(nextMilestone.title)"
        }
    }
}
