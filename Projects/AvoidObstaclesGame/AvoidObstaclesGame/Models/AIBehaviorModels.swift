//
//  AIBehaviorModels.swift
//  AvoidObstaclesGame
//
//  Data models for AI-powered player behavior analysis and adaptive difficulty system.
//

import Foundation

// MARK: - Core AI Behavior Data Models

/// Represents a complete game session for AI analysis
struct GameSessionData {
    /// All player actions recorded during the session
    var actions: [PlayerActionData] = []

    /// Current game state
    var currentState: GameState = .playing

    /// History of state changes with timestamps
    var stateHistory: [(GameState, Date)] = []

    /// All obstacle interactions during the session
    var obstacleInteractions: [ObstacleInteraction] = []

    /// When the session started
    let startTime: Date = .init()

    /// Initialize with default values
    init() {
        stateHistory.append((.playing, startTime))
    }
}

/// Represents a player action with context
struct PlayerActionData {
    /// The type of action performed
    let action: PlayerAction

    /// When the action occurred
    let timestamp: Date

    /// Additional context about the action
    let context: ActionContext?

    init(action: PlayerAction, timestamp: Date = Date(), context: ActionContext? = nil) {
        self.action = action
        self.timestamp = timestamp
        self.context = context
    }
}

/// Represents an interaction with an obstacle
struct ObstacleInteraction {
    /// Type of obstacle encountered
    let obstacleType: Obstacle.ObstacleType

    /// Whether the player successfully avoided it
    let success: Bool

    /// How long it took to react (in seconds)
    let reactionTime: TimeInterval

    /// When the interaction occurred
    let timestamp: Date

    init(obstacleType: Obstacle.ObstacleType, success: Bool, reactionTime: TimeInterval, timestamp: Date = Date()) {
        self.obstacleType = obstacleType
        self.success = success
        self.reactionTime = reactionTime
        self.timestamp = timestamp
    }
}

// MARK: - AI Analysis Data Structures

/// Result of analyzing player behavior
struct PlayerBehaviorAnalysis {
    /// Success rate (0.0 to 1.0)
    let successRate: Double

    /// Average reaction time in seconds
    let averageReactionTime: TimeInterval

    /// Player's risk-taking level
    let riskTakingLevel: RiskLevel

    /// Consistency of performance
    let consistencyLevel: ConsistencyLevel

    /// Detected fatigue indicators
    let fatigueIndicators: [FatigueIndicator]

    /// Recent actions for pattern analysis
    let recentActions: [PlayerActionData]

    /// AI predictions about future behavior
    let predictions: PlayerBehaviorPredictions

    /// Primary reason for any difficulty adjustment
    let primaryReason: DifficultyAdjustmentReason

    /// When the analysis was performed
    let startTime: Date
}

/// Risk levels for player behavior
enum RiskLevel: String, Codable, Sendable {
    case conservative
    case moderate
    case adventurous
    case reckless

    var description: String {
        switch self {
        case .conservative: return "Conservative"
        case .moderate: return "Moderate"
        case .adventurous: return "Adventurous"
        case .reckless: return "Reckless"
        }
    }
}

/// Consistency levels for player performance
enum ConsistencyLevel: String, Codable, Sendable {
    case veryInconsistent
    case inconsistent
    case moderate
    case consistent
    case veryConsistent
    case unknown

    var description: String {
        switch self {
        case .veryInconsistent: return "Very Inconsistent"
        case .inconsistent: return "Inconsistent"
        case .moderate: return "Moderate"
        case .consistent: return "Consistent"
        case .veryConsistent: return "Very Consistent"
        case .unknown: return "Unknown"
        }
    }
}

/// Indicators of player fatigue
enum FatigueIndicator: String, Codable, Sendable {
    case decliningPerformance
    case slowerReactions
    case increasedErrors
    case reducedFocus
}

/// AI insights from analysis
struct AIInsights {
    /// Recommended difficulty level
    let recommendedDifficulty: AIAdaptiveDifficulty

    /// Confidence in the recommendation (0.0 to 1.0)
    let confidence: Double

    /// Reasoning for the recommendation
    let reasoning: String

    /// Specific adjustments suggested
    let adjustments: [String]
}

// MARK: - Supporting Extensions

extension [TimeInterval] {
    /// Calculate the average of time intervals
    var average: TimeInterval {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / TimeInterval(count)
    }
}
