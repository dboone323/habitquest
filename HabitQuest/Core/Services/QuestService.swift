//
// QuestService.swift
// HabitQuest
//
// Manages quests and challenges
//

import Foundation

struct Quest: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let rewardXP: Int
    let requirement: QuestRequirement
    var progress: Int = 0
    var isCompleted: Bool = false
}

enum QuestRequirement {
    case completeHabits(count: Int)
    case maintainStreak(days: Int)
    case completeCategory(category: HabitCategory, count: Int)
}

class QuestService {
    static let shared = QuestService()
    
    func generateDailyQuests() -> [Quest] {
        return [
            Quest(
                title: "Daily Grinder",
                description: "Complete 3 habits today",
                rewardXP: 50,
                requirement: .completeHabits(count: 3)
            ),
            Quest(
                title: "Streak Keeper",
                description: "Maintain a streak for any habit",
                rewardXP: 30,
                requirement: .maintainStreak(days: 1)
            ),
            Quest(
                title: "Health Nut",
                description: "Complete 1 health habit",
                rewardXP: 25,
                requirement: .completeCategory(category: .health, count: 1)
            )
        ]
    }
}
