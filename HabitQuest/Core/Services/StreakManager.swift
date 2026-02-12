import Foundation

/// Logic-only manager for streak calculations
/// Separated from StreakService to allow unit testing without SwiftData dependencies
class StreakManager {
    // MARK: - Streak Calculation

    func calculateStreak(completions: [Date]) -> Int {
        let sortedDates = completions.sorted(by: >)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Check if the most recent completion was today or yesterday
        // If the last completion was before yesterday, the streak is already 0 (unless we want to count up to the last
        // completion, but usually streak implies "current active streak")
        // The tests imply "current streak".

        // However, if the user hasn't completed it today yet, the streak from yesterday should still count?
        // Usually "current streak" includes today if completed, or is yesterday's streak if today is not yet missed.
        // But if today is missed (i.e. it's tomorrow), streak is 0.

        // Let's look at the test: testCalculateStreak_BrokenStreak (today and 3 days ago -> 1).
        // testCalculateStreak_ConsecutiveDays (today, yesterday, 2 days ago -> 3).

        // Algorithm:
        // 1. Normalize all dates to start of day.
        // 2. Iterate backwards from today.
        // 3. If date exists in completions, increment streak.
        // 4. If date is today and missing, continue to yesterday (streak doesn't break yet, but doesn't increment? Or
        // maybe it just starts checking from most recent?)

        // Actually, a standard streak calculation:
        // Find the most recent completion.
        // If it's today or yesterday, we have an active streak.
        // If it's older than yesterday, streak is 0.
        // Then count backwards from that most recent date.

        let normalizedCompletions = Set(sortedDates.map { calendar.startOfDay(for: $0) })

        if normalizedCompletions.isEmpty { return 0 }

        // Check if streak is active (completed today or yesterday)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if !normalizedCompletions.contains(today), !normalizedCompletions.contains(yesterday) {
            return 0
        }

        // Count streak
        var count = 0
        var checkDate = normalizedCompletions.contains(today) ? today : yesterday

        while normalizedCompletions.contains(checkDate) {
            count += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        return count
    }

    func resetStreak(completions: inout [Date]) {
        completions.removeAll()
    }

    // MARK: - Milestone Detection

    func checkMilestone(streak: Int) -> StreakMilestone? {
        // Check for exact milestone match
        StreakMilestone.predefinedMilestones.first { $0.streakCount == streak }
    }

    // MARK: - Statistics

    func getStatistics(completions: [Date]) -> StreakStatistics {
        let current = calculateStreak(completions: completions)

        // Calculate longest streak
        // Simple algorithm: sort dates, iterate and count consecutive days
        let sortedDates = completions.sorted(by: <)
        let calendar = Calendar.current

        var longest = 0
        var currentRun = 0
        var lastDate: Date?

        for date in sortedDates {
            let day = calendar.startOfDay(for: date)
            if let last = lastDate {
                let diff = calendar.dateComponents([.day], from: last, to: day).day ?? 0
                if diff == 1 {
                    currentRun += 1
                } else if diff > 1 {
                    longest = max(longest, currentRun)
                    currentRun = 1
                }
            } else {
                currentRun = 1
            }
            lastDate = day
        }
        longest = max(longest, currentRun)

        return StreakStatistics(
            currentStreak: current,
            longestStreak: longest,
            totalCompletions: completions.count
        )
    }

    func calculateCompletionPercentage(completed: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return (Double(completed) / Double(total)) * 100.0
    }
}

struct StreakStatistics {
    let currentStreak: Int
    let longestStreak: Int
    let totalCompletions: Int
}
