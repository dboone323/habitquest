import Foundation

// Enhancement #82: Gamification Rewards
// Uses an in-memory representation for runtime safety in non-persistent flows.

struct GamificationAchievement: Equatable {
    let name: String
    let achievementDescription: String
    let iconName: String
    let category: AchievementCategory
    var unlockedDate: Date?
    var progress: Float

    var isUnlocked: Bool {
        unlockedDate != nil
    }
}

struct GamificationManager {
    var achievements: [GamificationAchievement] = [
        GamificationAchievement(
            name: "First Step",
            achievementDescription: "Complete your first habit",
            iconName: "flag.fill",
            category: .completion,
            unlockedDate: nil,
            progress: 0
        ),
        GamificationAchievement(
            name: "On Fire",
            achievementDescription: "7-day streak",
            iconName: "flame.fill",
            category: .streak,
            unlockedDate: nil,
            progress: 0
        ),
    ]

    mutating func checkAchievements(habitsCompleted: Int, currentStreak: Int) {
        if habitsCompleted >= 1 {
            unlock(name: "First Step")
        }
        if currentStreak >= 7 {
            unlock(name: "On Fire")
        }
    }

    private mutating func unlock(name: String) {
        if let index = achievements.firstIndex(where: { $0.name == name }), !achievements[index].isUnlocked {
            achievements[index].unlockedDate = Date()
            achievements[index].progress = 1.0
        }
    }
}
