//
// XPService.swift
// HabitQuest
//
// Service for calculating and awarding XP
//

import Foundation

class XPService {
    static let shared = XPService()
    
    func calculateXP(for habit: Habit, isStreak: Bool) -> Int {
        var xp = habit.xpValue
        
        // Difficulty multiplier
        xp *= habit.difficulty.xpMultiplier
        
        // Streak bonus
        if isStreak {
            xp += Int(Double(xp) * 0.5) // 50% bonus for keeping a streak
        }
        
        return xp
    }
    
    func awardXP(amount: Int, to profile: inout PlayerProfile) {
        profile.currentXP += amount
        // Level up logic handled by LevelingSystem
    }
}
