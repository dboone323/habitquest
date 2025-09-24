//
// GameDifficulty.swift
// AvoidObstaclesGame
//
// Manages game difficulty progression based on score
//

import Foundation

/// Represents the difficulty settings for the AvoidObstaclesGame.
/// Adjusts obstacle spawn rate, speed, and score multiplier based on the player's score.
struct GameDifficulty {
    /// Time interval (in seconds) between obstacle spawns.
    let spawnInterval: Double
    /// Speed of falling obstacles.
    let obstacleSpeed: Double
    /// Score multiplier for this difficulty level.
    let scoreMultiplier: Double
    /// Chance of spawning a power-up instead of an obstacle (0.0 to 1.0)
    let powerUpSpawnChance: Double

    /// Returns the appropriate difficulty settings for a given score.
    /// - Parameter score: The player's current score.
    /// - Returns: A `GameDifficulty` instance with tuned parameters.
    static func getDifficulty(for score: Int) -> GameDifficulty {
        switch score {
        case 0 ..< 10:
            GameDifficulty(spawnInterval: 1.2, obstacleSpeed: 3.5, scoreMultiplier: 1.0, powerUpSpawnChance: 0.02)
        case 10 ..< 25:
            GameDifficulty(spawnInterval: 1.0, obstacleSpeed: 3.0, scoreMultiplier: 1.2, powerUpSpawnChance: 0.03)
        case 25 ..< 50:
            GameDifficulty(spawnInterval: 0.8, obstacleSpeed: 2.5, scoreMultiplier: 1.5, powerUpSpawnChance: 0.04)
        case 50 ..< 100:
            GameDifficulty(spawnInterval: 0.6, obstacleSpeed: 2.0, scoreMultiplier: 2.0, powerUpSpawnChance: 0.05)
        case 100 ..< 200:
            GameDifficulty(spawnInterval: 0.5, obstacleSpeed: 1.5, scoreMultiplier: 2.5, powerUpSpawnChance: 0.06)
        default:
            GameDifficulty(spawnInterval: 0.4, obstacleSpeed: 1.2, scoreMultiplier: 3.0, powerUpSpawnChance: 0.08)
        }
    }

    /// Returns the difficulty level as an integer for a given score.
    /// - Parameter score: The player's current score.
    /// - Returns: An integer representing the difficulty level (1 = easiest).
    static func getDifficultyLevel(for score: Int) -> Int {
        switch score {
        case 0 ..< 10: 1
        case 10 ..< 25: 2
        case 25 ..< 50: 3
        case 50 ..< 100: 4
        case 100 ..< 200: 5
        default: 6
        }
    }
}
