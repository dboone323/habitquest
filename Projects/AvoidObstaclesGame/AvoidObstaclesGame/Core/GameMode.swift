//
//  GameMode.swift
//  AvoidObstaclesGame
//
//  Defines different game modes with unique rules, objectives, and difficulty curves.
//

import Foundation

/// Represents different game modes available in AvoidObstaclesGame
enum GameMode: Hashable {
    /// Classic endless mode - survive as long as possible with increasing difficulty
    case classic

    /// Time trial - survive for a specific time period with optimal performance
    case timeTrial(duration: TimeInterval)

    /// Survival mode - survive against increasingly difficult waves
    case survival

    /// Puzzle mode - solve obstacle patterns within time limits
    case puzzle

    /// Challenge mode - complete specific objectives and patterns
    case challenge(level: Int)

    /// Custom mode - user-defined parameters
    case custom(config: CustomGameConfig)

    /// Returns a human-readable name for the game mode
    var displayName: String {
        switch self {
        case .classic:
            return "Classic"
        case .timeTrial:
            return "Time Trial"
        case .survival:
            return "Survival"
        case .puzzle:
            return "Puzzle"
        case .challenge:
            return "Challenge"
        case .custom:
            return "Custom"
        }
    }

    /// Returns a detailed description of the game mode
    var description: String {
        switch self {
        case .classic:
            return "Survive as long as possible with increasing difficulty"
        case let .timeTrial(duration):
            return "Survive for \(Int(duration)) seconds with optimal performance"
        case .survival:
            return "Face increasingly difficult waves of obstacles"
        case .puzzle:
            return "Solve complex obstacle patterns and sequences"
        case .challenge:
            return "Complete specific objectives and challenges"
        case .custom:
            return "Custom game with user-defined parameters"
        }
    }

    /// Returns the win condition for this game mode
    var winCondition: GameWinCondition {
        switch self {
        case .classic:
            return .survivalTime(minimum: nil) // No minimum, just survive
        case let .timeTrial(duration):
            return .survivalTime(minimum: duration)
        case .survival:
            return .wavesCompleted(count: 10) // Complete 10 waves
        case .puzzle:
            return .patternsSolved(count: 5) // Solve 5 patterns
        case .challenge:
            return .objectivesCompleted // Complete all objectives
        case let .custom(config):
            return config.winCondition
        }
    }

    /// Returns the scoring system for this game mode
    var scoringSystem: GameScoringSystem {
        switch self {
        case .classic:
            return .timeBased(multiplier: 1.0)
        case .timeTrial:
            return .timeBased(multiplier: 2.0) // Higher multiplier for time trials
        case .survival:
            return .waveBased(basePoints: 100)
        case .puzzle:
            return .patternBased(perfectBonus: 500)
        case .challenge:
            return .objectiveBased(bonusMultiplier: 1.5)
        case let .custom(config):
            return config.scoringSystem
        }
    }

    /// Returns the difficulty progression for this game mode
    var difficultyProgression: DifficultyProgression {
        switch self {
        case .classic:
            return .scoreBased // Standard score-based progression
        case .timeTrial:
            return .timeBased(accelerateAfter: 30.0) // Accelerate after 30 seconds
        case .survival:
            return .waveBased(wavesPerLevel: 2) // Every 2 waves increase difficulty
        case .puzzle:
            return .static(level: 3) // Fixed difficulty for puzzles
        case .challenge:
            return .objectiveBased // Difficulty based on objectives
        case let .custom(config):
            return config.difficultyProgression
        }
    }
}

/// Win conditions for different game modes
enum GameWinCondition: Hashable {
    case survivalTime(minimum: TimeInterval?)
    case wavesCompleted(count: Int)
    case patternsSolved(count: Int)
    case objectivesCompleted
    case scoreReached(target: Int)
    case custom(condition: String)
}

/// Scoring systems for different game modes
enum GameScoringSystem: Hashable {
    case timeBased(multiplier: Double)
    case waveBased(basePoints: Int)
    case patternBased(perfectBonus: Int)
    case objectiveBased(bonusMultiplier: Double)
    case custom(formula: String)
}

/// Difficulty progression types
enum DifficultyProgression: Hashable {
    case scoreBased
    case timeBased(accelerateAfter: TimeInterval)
    case waveBased(wavesPerLevel: Int)
    case `static`(level: Int)
    case objectiveBased
    case custom(pattern: String)
}

/// Configuration for custom game modes
struct CustomGameConfig: Hashable {
    let name: String
    let description: String
    let winCondition: GameWinCondition
    let scoringSystem: GameScoringSystem
    let difficultyProgression: DifficultyProgression
    let timeLimit: TimeInterval?
    let specialRules: [String]
}

/// Game mode statistics tracking
struct GameModeStats {
    var gamesPlayed: Int = 0
    var bestScore: Int = 0
    var bestTime: TimeInterval = 0
    var completionRate: Double = 0.0
    var averageScore: Double = 0.0

    mutating func update(with result: GameResult) {
        gamesPlayed += 1
        bestScore = max(bestScore, result.finalScore)
        bestTime = max(bestTime, result.survivalTime)
        averageScore = (averageScore * Double(gamesPlayed - 1) + Double(result.finalScore)) / Double(gamesPlayed)

        if result.completed {
            completionRate = (completionRate * Double(gamesPlayed - 1) + 1.0) / Double(gamesPlayed)
        } else {
            completionRate = (completionRate * Double(gamesPlayed - 1)) / Double(gamesPlayed)
        }
    }
}

/// Result of a completed game
struct GameResult {
    let finalScore: Int
    let survivalTime: TimeInterval
    let completed: Bool
    let gameMode: GameMode
    let difficultyLevel: Int
    let achievements: [String]
}
