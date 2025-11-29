//
// LevelingSystem.swift
// HabitQuest
//
// Manages player level progression
//

import Foundation

class LevelingSystem {
    static let shared = LevelingSystem()
    
    func xpForNextLevel(currentLevel: Int) -> Int {
        // Quadratic curve: 100 * level^2
        return 100 * (currentLevel * currentLevel)
    }
    
    func checkLevelUp(profile: inout PlayerProfile) -> Bool {
        let requiredXP = xpForNextLevel(currentLevel: profile.level)
        
        if profile.currentXP >= requiredXP {
            profile.currentXP -= requiredXP
            profile.level += 1
            return true
        }
        
        return false
    }
    
    func getProgress(profile: PlayerProfile) -> Double {
        let requiredXP = xpForNextLevel(currentLevel: profile.level)
        return Double(profile.currentXP) / Double(requiredXP)
    }
}
