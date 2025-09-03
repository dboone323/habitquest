import Foundation

/// Contains all game logic and progression calculations
/// Pure functions that handle XP calculation, level progression, and habit completion rewards
struct GameRules {

    /// Calculate the total XP required to reach a specific level
    /// Uses an exponential curve: 100 * (1.5 ^ (level - 1))
    /// - Parameter level: The target level
    /// - Returns: Total XP needed to reach that level
    static func calculateXPForLevel(_ level: Int) -> Int {
        guard level > 0 else { return 0 }
        return Int(100 * pow(1.5, Double(level - 1)))
    }

    /// Calculate XP needed for the next level from current level
    /// - Parameter level: Current level
    /// - Returns: XP needed to reach the next level
    static func calculateXPForNextLevel(forLevel level: Int) -> Int {
        return calculateXPForLevel(
            level + 1
        )
    }

    /// Process habit completion and update player profile accordingly
    /// Handles XP awarding, level-ups, and streak updates
    /// - Parameters:
    ///   - habit: The habit that was completed
    ///   - profile: The player's profile to update
    /// - Returns: Tuple indicating if level up occurred and new level
    @discardableResult
    static func processHabitCompletion(habit: Habit, profile: PlayerProfile) -> (leveledUp: Bool, newLevel: Int) {
        // Award XP from the habit
        profile.currentXP += habit.xpValue

        // Check for level up
        var leveledUp = false
        var newLevel = profile.level

        while profile.currentXP >= calculateXPForLevel(newLevel + 1) {
            newLevel += 1
            leveledUp = true
        }

        if leveledUp {
            profile.level = newLevel
            profile.xpForNextLevel = calculateXPForNextLevel(forLevel: newLevel)
        }

        // Update habit streak
        updateHabitStreak(habit: habit)

        // Update longest streak if necessary
        if habit.streak > profile.longestStreak {
            profile.longestStreak = habit.streak
        }

        return (leveledUp: leveledUp, newLevel: newLevel)
    }

    /// Update the streak for a specific habit based on completion history
    /// - Parameter habit: The habit to update streak for
    private static func updateHabitStreak(habit: Habit) {
        guard !habit.logs.isEmpty else {
            habit.streak = 1
            return
        }

        let sortedLogs = habit.logs.sorted { $0.completionDate > $1.completionDate }
        let calendar = Calendar.current

        var currentStreak = 1 // Start with 1 for today's completion

        // Check consecutive days/weeks based on habit frequency
        for index in 1..<sortedLogs.count {
            let currentLog = sortedLogs[index-1]
            let previousLog = sortedLogs[index]

            let isConsecutive: Bool

            switch habit.frequency {
            case .daily:
                let dayComponents = calendar.dateComponents(
                    [.day],
                    from: previousLog.completionDate,
                    to: currentLog.completionDate
                )
                let daysBetween = dayComponents.day ?? 0
                isConsecutive = daysBetween == 1
            case .weekly:
                let weekComponents = calendar.dateComponents(
                    [.weekOfYear],
                    from: previousLog.completionDate,
                    to: currentLog.completionDate
                )
                let weeksBetween = weekComponents.weekOfYear ?? 0
                isConsecutive = weeksBetween == 1
            case .custom:
                // For custom frequency, default to daily behavior
                let dayComponents = calendar.dateComponents(
                    [.day],
                    from: previousLog.completionDate,
                    to: currentLog.completionDate
                )
                let daysBetween = dayComponents.day ?? 0
                isConsecutive = daysBetween == 1
            }

            if isConsecutive {
                currentStreak += 1
            } else {
                break
            }
        }

        habit.streak = currentStreak
    }

    /// Check if a habit is due today based on its frequency and last completion
    /// - Parameter habit: The habit to check
    /// - Returns: True if the habit should be completed today
    static func isHabitDueToday(_ habit: Habit) -> Bool {
        guard !habit.logs.isEmpty else {
            return true // New habit is always due
        }

        let calendar = Calendar.current
        let today = Date()
        let lastCompletion = habit.logs.max { $0.completionDate < $1.completionDate }?.completionDate

        guard let lastCompletion = lastCompletion else {
            return true
        }

        switch habit.frequency {
        case .daily:
            return !calendar.isDate(lastCompletion, inSameDayAs: today)
        case .weekly:
            let weeksBetween = calendar.dateComponents([.weekOfYear], from: lastCompletion, to: today).weekOfYear ?? 0
            return weeksBetween >= 1
        case .custom:
            // For custom frequency, default to daily behavior
            return !calendar.isDate(lastCompletion, inSameDayAs: today)
        }
    }

    /// Process XP gain and handle level progression (used for achievements)
    /// - Parameters:
    ///   - xp: Amount of XP to award
    ///   - profile: Player profile to update
    /// - Returns: Tuple indicating if level up occurred and new level
    @discardableResult
    static func processXPGain(
        experiencePoints: Int,
        for profile: PlayerProfile
    ) -> (leveledUp: Bool, newLevel: Int) {
        profile.currentXP += experiencePoints

        // Check for level up
        var leveledUp = false
        var newLevel = profile.level

        while profile.currentXP >= calculateXPForLevel(
            newLevel + 1
        ) {
            newLevel += 1
            leveledUp = true
        }

        if leveledUp {
            profile.level = newLevel
            profile.xpForNextLevel = calculateXPForNextLevel(forLevel: newLevel)
        }

        return (leveledUp: leveledUp, newLevel: newLevel)
    }
}
