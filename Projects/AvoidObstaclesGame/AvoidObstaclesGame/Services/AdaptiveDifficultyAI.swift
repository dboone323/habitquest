//
// AdaptiveDifficultyAI.swift
// AvoidObstaclesGame
//
// AI-powered adaptive difficulty system that analyzes player performance
// and adjusts game difficulty dynamically for optimal challenge and engagement.
//

import Foundation
import SpriteKit

/// Simple power-up type enum for AI analysis
/// AI-powered adaptive difficulty system
/// Analyzes player behavior patterns and performance metrics to provide
/// dynamic difficulty scaling for optimal game engagement.
public class AdaptiveDifficultyAI {
    // MARK: - Properties

    /// Shared instance for game-wide access
    public static let shared = AdaptiveDifficultyAI()

    /// AI integration manager for intelligent analysis
    private let ruleBasedAnalyzer = RuleBasedDifficultyAnalyzer()

    /// Performance metrics collector
    private let metricsCollector = PlayerMetricsCollector()

    /// Difficulty adjustment engine
    private let difficultyEngine = DifficultyAdjustmentEngine()

    /// Current AI analysis state
    private var currentAnalysis: DifficultyAnalysis?

    /// Analysis update timer
    private var analysisTimer: Timer?

    /// Minimum time between AI analyses (seconds)
    private let analysisInterval: TimeInterval = 30.0

    /// Last analysis timestamp
    private var lastAnalysisTime: TimeInterval = 0

    // MARK: - Initialization

    private init() {
        setupAnalysisTimer()
    }

    deinit {
        analysisTimer?.invalidate()
    }

    /// Sets up periodic AI analysis timer
    private func setupAnalysisTimer() {
        analysisTimer = Timer.scheduledTimer(
            withTimeInterval: analysisInterval,
            repeats: true
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.performAIAnalysis()
            }
        }
    }

    // MARK: - Public Interface

    /// Records a game session for AI analysis
    /// - Parameters:
    ///   - session: Complete game session data
    ///   - playerProfile: Optional player profile for personalization
    public func recordGameSession(
        _ session: GameSession,
        playerProfile: PlayerProfile? = nil
    ) {
        metricsCollector.recordSession(session, playerProfile: playerProfile)

        // Trigger immediate analysis for significant events
        if session.wasHighScore || session.survivalTime > 120 {
            Task {
                await performAIAnalysis()
            }
        }
    }

    /// Gets current difficulty recommendation
    /// - Returns: AI-recommended difficulty adjustment
    public func getDifficultyRecommendation() async -> DifficultyAdjustment {
        // If we have a recent analysis, use it
        if let analysis = currentAnalysis,
           CACurrentMediaTime() - lastAnalysisTime < analysisInterval {
            return analysis.recommendation
        }

        // Otherwise perform new analysis
        await performAIAnalysis()
        return currentAnalysis?.recommendation ?? .maintain
    }

    /// Gets player skill assessment
    /// - Returns: Current player skill level assessment
    public func getPlayerSkillAssessment() -> PlayerSkillLevel {
        metricsCollector.assessPlayerSkill()
    }

    /// Resets AI analysis state (useful for new players)
    public func resetAnalysis() {
        metricsCollector.reset()
        currentAnalysis = nil
        lastAnalysisTime = 0
    }

    // MARK: - AI Analysis

    /// Performs rule-based analysis of player performance
    private func performAIAnalysis() async {
        let currentTime = CACurrentMediaTime()

        // Don't analyze too frequently
        guard currentTime - lastAnalysisTime >= analysisInterval else { return }

        lastAnalysisTime = currentTime

        // Collect current metrics
        let metrics = metricsCollector.getCurrentMetrics()

        // Perform rule-based analysis
        let analysis = ruleBasedAnalyzer.analyzeDifficulty(for: metrics)

        // Update current analysis
        currentAnalysis = analysis

        // Apply difficulty adjustment if needed
        if case .maintain = analysis.recommendation {
            // Keep current difficulty
        } else {
            await applyDifficultyAdjustment(analysis.recommendation)
        }
    }

    /// Builds rule-based analysis for player metrics
    private func buildAnalysisPrompt(for metrics: PlayerMetrics) -> String {
        // This method is kept for compatibility but now uses rule-based analysis
        return "Rule-based analysis for player metrics"
    }

    /// Parses rule-based response into difficulty analysis
    private func parseAIAnalysis(_ response: String, metrics: PlayerMetrics) throws -> DifficultyAnalysis {
        // Use rule-based analyzer instead
        return ruleBasedAnalyzer.analyzeDifficulty(for: metrics)
    }

    /// Applies AI-recommended difficulty adjustment
    private func applyDifficultyAdjustment(_ adjustment: DifficultyAdjustment) async {
        // Notify game coordinator of difficulty change
        NotificationCenter.default.post(
            name: NSNotification.Name("AIDifficultyAdjustment"),
            object: self,
            userInfo: [
                "adjustment": adjustment,
                "reason": currentAnalysis?.reasoning ?? "AI analysis"
            ]
        )
    }

    /// Applies fallback rule-based difficulty adjustment
    private func applyFallbackAdjustment() {
        let skillLevel = metricsCollector.assessPlayerSkill()
        let adjustment = difficultyEngine.calculateFallbackAdjustment(for: skillLevel)

        NotificationCenter.default.post(
            name: NSNotification.Name("AIDifficultyAdjustment"),
            object: self,
            userInfo: [
                "adjustment": adjustment,
                "reason": "Fallback rule-based adjustment"
            ]
        )
    }
}

/// MARK: - Supporting Types

/// Player skill level assessment
public enum PlayerSkillLevel: String, Codable {
    case beginner
    case intermediate
    case advanced
    case expert

    static func fromString(_ string: String) -> PlayerSkillLevel {
        switch string.lowercased() {
        case "beginner": return .beginner
        case "intermediate": return .intermediate
        case "advanced": return .advanced
        case "expert": return .expert
        default: return .intermediate
        }
    }
}

/// Difficulty adjustment recommendations
public enum DifficultyAdjustment: Equatable {
    case increase(magnitude: Double)
    case decrease(magnitude: Double)
    case maintain

    static func fromString(_ string: String, magnitude: Double) -> DifficultyAdjustment {
        switch string.lowercased() {
        case "increase": return .increase(magnitude: magnitude)
        case "decrease": return .decrease(magnitude: magnitude)
        case "maintain": return .maintain
        default: return .maintain
        }
    }
}

/// Complete difficulty analysis result
public struct DifficultyAnalysis {
    let skillLevel: PlayerSkillLevel
    let recommendation: DifficultyAdjustment
    let reasoning: String
    let specificChanges: [String]
    let timestamp: Date
    let metricsSnapshot: PlayerMetrics
}

/// AI analysis result from Ollama
private struct AIAnalysisResult: Codable {
    let skill_level: String
    let difficulty_adjustment: String
    let adjustment_magnitude: Double
    let reasoning: String
    let specific_changes: [String]
}

/// AI-related errors
enum AIError: Error {
    case invalidResponse
    case analysisFailed
}

// MARK: - Metrics Collection

/// Collects and analyzes player performance metrics
private class PlayerMetricsCollector {
    private var gameSessions: [GameSession] = []
    private var playerProfile: PlayerProfile?

    /// Records a game session
    func recordSession(_ session: GameSession, playerProfile: PlayerProfile?) {
        gameSessions.append(session)
        self.playerProfile = playerProfile

        // Keep only recent sessions for analysis
        if gameSessions.count > 50 {
            gameSessions.removeFirst(gameSessions.count - 50)
        }
    }

    /// Gets current aggregated metrics
    func getCurrentMetrics() -> PlayerMetrics {
        guard !gameSessions.isEmpty else {
            return PlayerMetrics.empty
        }

        let recentGames = Array(gameSessions.suffix(5))

        return PlayerMetrics(
            averageScore: gameSessions.map { $0.finalScore }.average(),
            highScore: gameSessions.map { $0.finalScore }.max() ?? 0,
            averageSurvivalTime: gameSessions.map { $0.survivalTime }.average(),
            maxSurvivalTime: gameSessions.map { $0.survivalTime }.max() ?? 0,
            gamesPlayed: gameSessions.count,
            winRate: calculateWinRate(),
            averageDifficultyReached: gameSessions.map { Double($0.maxDifficultyReached) }.average(),
            collisionPatterns: analyzeCollisionPatterns(),
            powerUpUsage: analyzePowerUpUsage(),
            recentGames: GameMetrics(
                averageScore: recentGames.map { $0.finalScore }.average(),
                averageSurvivalTime: recentGames.map { $0.survivalTime }.average()
            ),
            difficultyProgression: analyzeDifficultyProgression(),
            movementPatterns: analyzeMovementPatterns(),
            behaviorPatterns: analyzeBehaviorPatterns()
        )
    }

    /// Assesses current player skill level
    func assessPlayerSkill() -> PlayerSkillLevel {
        let metrics = getCurrentMetrics()

        // Simple rule-based assessment
        if metrics.gamesPlayed < 5 {
            return .beginner
        }

        let avgScore = metrics.averageScore
        let avgSurvival = metrics.averageSurvivalTime

        if avgScore > 50000 || avgSurvival > 300 {
            return .expert
        } else if avgScore > 20000 || avgSurvival > 120 {
            return .advanced
        } else if avgScore > 5000 || avgSurvival > 45 {
            return .intermediate
        } else {
            return .beginner
        }
    }

    /// Resets all collected metrics
    func reset() {
        gameSessions.removeAll()
        playerProfile = nil
    }

    // MARK: - Analysis Helpers

    private func calculateWinRate() -> Double {
        // For this game, "wins" could be defined as reaching certain milestones
        // For now, use survival time > 60 seconds as a "win"
        let wins = gameSessions.filter { $0.survivalTime > 60 }.count
        return Double(wins) / Double(gameSessions.count)
    }

    private func analyzeCollisionPatterns() -> [CollisionPattern] {
        // Analyze collision types and frequencies
        var patterns: [String: Int] = [:]

        for session in gameSessions {
            for collision in session.collisions {
                patterns[collision.type, default: 0] += 1
            }
        }

        return patterns.map { CollisionPattern(type: $0.key, frequency: $0.value) }
    }

    private func analyzePowerUpUsage() -> [PowerUpUsage] {
        var usage: [String: Int] = [:]

        for session in gameSessions {
            for powerUp in session.powerUpsCollected {
                usage[powerUp.type.rawValue, default: 0] += 1
            }
        }

        return usage.map { PowerUpUsage(type: PowerUpType(rawValue: $0.key) ?? .shield, count: $0.value) }
    }

    private func analyzeDifficultyProgression() -> [DifficultyMilestone] {
        var milestones: [DifficultyMilestone] = []

        for session in gameSessions {
            if let milestone = session.difficultyMilestones.first {
                milestones.append(milestone)
            }
        }

        return milestones.sorted { $0.level < $1.level }
    }

    private func analyzeMovementPatterns() -> MovementPatterns {
        // Analyze movement data from sessions
        let dominantStyle = "tap_control" // Placeholder - would analyze actual movement data
        return MovementPatterns(dominantStyle: dominantStyle)
    }

    private func analyzeBehaviorPatterns() -> BehaviorPatterns {
        let metrics = getCurrentMetrics()

        // Calculate risk level based on collision patterns
        let riskLevel = metrics.collisionPatterns.isEmpty ? "low" :
            (metrics.collisionPatterns.reduce(0) { $0 + $1.frequency } > 10 ? "high" : "medium")

        // Calculate learning rate based on score improvement
        let learningRate = metrics.recentGames.averageScore > metrics.averageScore * 0.8 ? "fast" : "steady"

        // Estimate frustration tolerance
        let frustrationTolerance = metrics.averageSurvivalTime > 30 ? "high" : "medium"

        return BehaviorPatterns(
            riskLevel: riskLevel,
            learningRate: learningRate,
            frustrationTolerance: frustrationTolerance
        )
    }
}

/// Difficulty adjustment engine for fallback calculations
private class DifficultyAdjustmentEngine {
    func calculateFallbackAdjustment(for skillLevel: PlayerSkillLevel) -> DifficultyAdjustment {
        switch skillLevel {
        case .beginner:
            return .decrease(magnitude: 0.3)
        case .intermediate:
            return .maintain
        case .advanced:
            return .increase(magnitude: 0.2)
        case .expert:
            return .increase(magnitude: 0.4)
        }
    }
}

/// Rule-based difficulty analyzer that provides intelligent difficulty adjustments
private class RuleBasedDifficultyAnalyzer {
    func analyzeDifficulty(for metrics: PlayerMetrics) -> DifficultyAnalysis {
        // Assess player skill level based on metrics
        let skillLevel = assessPlayerSkill(from: metrics)

        // Determine difficulty adjustment based on performance
        let recommendation = calculateDifficultyAdjustment(for: metrics, skillLevel: skillLevel)

        // Generate reasoning
        let reasoning = generateReasoning(for: recommendation, metrics: metrics, skillLevel: skillLevel)

        // Determine specific changes needed
        let specificChanges = determineSpecificChanges(for: recommendation, metrics: metrics)

        return DifficultyAnalysis(
            skillLevel: skillLevel,
            recommendation: recommendation,
            reasoning: reasoning,
            specificChanges: specificChanges,
            timestamp: Date(),
            metricsSnapshot: metrics
        )
    }

    private func assessPlayerSkill(from metrics: PlayerMetrics) -> PlayerSkillLevel {
        // Rule-based skill assessment
        let avgScore = metrics.averageScore
        let avgSurvival = metrics.averageSurvivalTime
        let gamesPlayed = metrics.gamesPlayed

        // Need minimum games for assessment
        if gamesPlayed < 3 {
            return .beginner
        }

        // Score-based assessment
        if avgScore > 50000 || avgSurvival > 300 {
            return .expert
        } else if avgScore > 20000 || avgSurvival > 120 {
            return .advanced
        } else if avgScore > 5000 || avgSurvival > 45 {
            return .intermediate
        } else {
            return .beginner
        }
    }

    private func calculateDifficultyAdjustment(for metrics: PlayerMetrics, skillLevel: PlayerSkillLevel) -> DifficultyAdjustment {
        let recentPerformance = metrics.recentGames
        let overallPerformance = metrics.averageSurvivalTime

        // If recent performance is significantly worse than overall, decrease difficulty
        if recentPerformance.averageSurvivalTime < overallPerformance * 0.6 && metrics.gamesPlayed > 5 {
            let magnitude = min(0.4, (overallPerformance - recentPerformance.averageSurvivalTime) / overallPerformance)
            return .decrease(magnitude: magnitude)
        }

        // If recent performance is significantly better, increase difficulty
        if recentPerformance.averageSurvivalTime > overallPerformance * 1.5 && metrics.gamesPlayed > 5 {
            let magnitude = min(0.3, (recentPerformance.averageSurvivalTime - overallPerformance) / overallPerformance)
            return .increase(magnitude: magnitude)
        }

        // Skill-based adjustment for consistent players
        switch skillLevel {
        case .beginner:
            return .decrease(magnitude: 0.2)
        case .intermediate:
            return .maintain
        case .advanced:
            return .increase(magnitude: 0.15)
        case .expert:
            return .increase(magnitude: 0.25)
        }
    }

    private func generateReasoning(for adjustment: DifficultyAdjustment, metrics: PlayerMetrics, skillLevel: PlayerSkillLevel) -> String {
        switch adjustment {
        case .increase(let magnitude):
            if magnitude > 0.2 {
                return "Player shows expert-level performance with high scores and long survival times. Increasing difficulty to maintain challenge."
            } else {
                return "Player is performing well above average. Gradually increasing difficulty for optimal engagement."
            }
        case .decrease(let magnitude):
            if magnitude > 0.3 {
                return "Recent performance indicates player is struggling significantly. Reducing difficulty to prevent frustration."
            } else {
                return "Player may need additional challenge adjustment. Slightly reducing difficulty for better flow."
            }
        case .maintain:
            return "Player performance is well-balanced for current skill level. Maintaining current difficulty settings."
        }
    }

    private func determineSpecificChanges(for adjustment: DifficultyAdjustment, metrics: PlayerMetrics) -> [String] {
        var changes: [String] = []

        switch adjustment {
        case .increase:
            changes.append("obstacle_speed")
            changes.append("spawn_rate")
            if metrics.powerUpUsage.count < 3 {
                changes.append("powerup_frequency")
            }
        case .decrease:
            changes.append("obstacle_speed")
            changes.append("spawn_rate")
            changes.append("powerup_frequency")
        case .maintain:
            // Minor adjustments based on specific metrics
            if metrics.collisionPatterns.count > 5 {
                changes.append("movement_sensitivity")
            }
            if metrics.averageSurvivalTime < 30 {
                changes.append("powerup_frequency")
            }
        }

        return changes
    }
}

/// MARK: - Data Models

/// Complete game session data
public struct GameSession {
    let finalScore: Int
    let survivalTime: TimeInterval
    let maxDifficultyReached: Int
    let collisions: [Collision]
    let powerUpsCollected: [PowerUp]
    let difficultyMilestones: [DifficultyMilestone]
    let wasHighScore: Bool
}

/// Player profile for personalization
public struct PlayerProfile {
    let playerId: String
    let preferredDifficulty: String
    let playStyle: String
}

/// Aggregated player metrics
public struct PlayerMetrics {
    let averageScore: Double
    let highScore: Int
    let averageSurvivalTime: Double
    let maxSurvivalTime: TimeInterval
    let gamesPlayed: Int
    let winRate: Double
    let averageDifficultyReached: Double
    let collisionPatterns: [CollisionPattern]
    let powerUpUsage: [PowerUpUsage]
    let recentGames: GameMetrics
    let difficultyProgression: [DifficultyMilestone]
    let movementPatterns: MovementPatterns
    let behaviorPatterns: BehaviorPatterns

    static let empty = PlayerMetrics(
        averageScore: 0,
        highScore: 0,
        averageSurvivalTime: 0,
        maxSurvivalTime: 0,
        gamesPlayed: 0,
        winRate: 0,
        averageDifficultyReached: 1,
        collisionPatterns: [],
        powerUpUsage: [],
        recentGames: GameMetrics(averageScore: 0, averageSurvivalTime: 0),
        difficultyProgression: [],
        movementPatterns: MovementPatterns(dominantStyle: "unknown"),
        behaviorPatterns: BehaviorPatterns(riskLevel: "unknown", learningRate: "unknown", frustrationTolerance: "unknown")
    )
}

/// Game metrics for recent performance
public struct GameMetrics {
    let averageScore: Double
    let averageSurvivalTime: Double
}

/// Collision pattern analysis
public struct CollisionPattern {
    let type: String
    let frequency: Int
}

/// Power-up usage statistics
public struct PowerUpUsage {
    let type: PowerUpType
    let count: Int
}

/// Difficulty milestone tracking
public struct DifficultyMilestone {
    let level: Int
    let timeToReach: TimeInterval
}

/// Movement pattern analysis
public struct MovementPatterns {
    let dominantStyle: String
}

/// Player behavior pattern analysis
public struct BehaviorPatterns {
    let riskLevel: String
    let learningRate: String
    let frustrationTolerance: String
}

/// Collision data
public struct Collision {
    let type: String
    let timestamp: TimeInterval
    let position: CGPoint
}

/// Power-up collection data


private extension Array where Element == Int {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        let sum = reduce(0, +)
        return Double(sum) / Double(count)
    }
}

private extension Array where Element == TimeInterval {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        let sum = reduce(0, +)
        return sum / Double(count)
    }
}
