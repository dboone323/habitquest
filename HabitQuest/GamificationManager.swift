import Combine
import Foundation

import SwiftData

// Enhancement #82: Gamification Rewards
// Using Core/Models/Achievement.swift

class GamificationManager: ObservableObject {
    @Published var achievements: [Achievement] = [
        Achievement(
            name: "First Step",
            description: "Complete your first habit",
            iconName: "flag.fill",
            category: .completion,
            requirement: .totalCompletions(1)
        ),
        Achievement(
            name: "On Fire",
            description: "7-day streak",
            iconName: "flame.fill",
            category: .streak,
            requirement: .streakDays(7)
        )
    ]

    func checkAchievements(habitsCompleted: Int, currentStreak: Int) {
        if habitsCompleted >= 1 {
            unlock(name: "First Step")
        }
        if currentStreak >= 7 {
            unlock(name: "On Fire")
        }
    }

    private func unlock(name: String) {
        if let index = achievements.firstIndex(where: { $0.name == name }), !achievements[index].isUnlocked {
            achievements[index].unlockedDate = Date()
            achievements[index].progress = 1.0
            // Trigger haptic or visual feedback here
            print("Unlocked: \(achievements[index].name)")
        }
    }
}
