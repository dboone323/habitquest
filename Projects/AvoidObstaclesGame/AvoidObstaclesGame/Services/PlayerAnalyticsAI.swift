//
// PlayerAnalyticsAI.swift
// AvoidObstaclesGame
//
// AI-powered player behavior analysis system that tracks and analyzes
// player patterns to provide personalized gaming experiences.
//

import Foundation
import SpriteKit

/// Simple power-up type enum for analytics
/// Player skill level assessment
enum PlayerSkillLevel: String, Codable {
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

/// Player types for categorization
public enum PlayerType: String, Codable {
    case casual
    case rusher
    case perfectionist
    case explorer
    case speedrunner

    static func fromString(_ string: String) -> PlayerType {
        switch string.lowercased() {
        case "casual": return .casual
        case "rusher": return .rusher
        case "perfectionist": return .perfectionist
        case "explorer": return .explorer
        case "speedrunner": return .speedrunner
        default: return .casual
        }
    }
}

/// Engagement styles
public enum EngagementStyle: String, Codable {
    case focused
    case distracted
    case competitive
    case relaxed

    static func fromString(_ string: String) -> EngagementStyle {
        switch string.lowercased() {
        case "focused": return .focused
        case "distracted": return .distracted
        case "competitive": return .competitive
        case "relaxed": return .relaxed
        default: return .focused
        }
    }
}

/// Difficulty preferences
public enum DifficultyPreference: String, Codable {
    case easy
    case medium
    case hard
    case adaptive

    static func fromString(_ string: String) -> DifficultyPreference {
        switch string.lowercased() {
        case "easy": return .easy
        case "medium": return .medium
        case "hard": return .hard
        case "adaptive": return .adaptive
        default: return .medium
        }
    }
}

/// AI-powered player analytics and personalization system
/// Analyzes player behavior patterns, preferences, and performance
/// to provide personalized game experiences and recommendations.
public class PlayerAnalyticsAI {
    // MARK: - Properties

    /// Shared instance for game-wide access
    public static let shared = PlayerAnalyticsAI()

    /// Rule-based behavior analyzer
    private let behaviorAnalyzer = BehaviorPatternAnalyzer()

    /// Personalization engine
    private let personalizationEngine = PersonalizationEngine()

    /// Analytics data storage
    private var analyticsData: AnalyticsData

    /// Current player profile
    private var currentProfile: PlayerProfile?

    /// Analysis update timer
    private var analysisTimer: Timer?

    /// Minimum time between AI analyses (seconds)
    private let analysisInterval: TimeInterval = 60.0

    /// Last analysis timestamp
    private var lastAnalysisTime: TimeInterval = 0

    // MARK: - Initialization

    private init() {
        analyticsData = AnalyticsData()
        setupAnalysisTimer()
        loadPersistedData()
    }

    deinit {
        analysisTimer?.invalidate()
        savePersistedData()
    }

    /// Sets up periodic AI analysis timer
    private func setupAnalysisTimer() {
        analysisTimer = Timer.scheduledTimer(
            withTimeInterval: analysisInterval,
            repeats: true
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.performBehavioralAnalysis()
            }
        }
    }

    // MARK: - Public Interface

    /// Records player action for analysis
    /// - Parameters:
    ///   - action: The player action to record
    ///   - context: Additional context about the action
    public func recordPlayerAction(_ action: PlayerAction, context: ActionContext? = nil) {
        let timestampedAction = TimestampedAction(action: action, timestamp: Date(), context: context)
        analyticsData.recordAction(timestampedAction)

        // Trigger immediate analysis for significant actions
        if action.isSignificant {
            Task {
                await performBehavioralAnalysis()
            }
        }
    }

    /// Records game event for pattern analysis
    /// - Parameter event: The game event to record
    public func recordGameEvent(_ event: GameEvent) {
        analyticsData.recordEvent(event)

        // Update behavior patterns
        behaviorAnalyzer.updatePatterns(with: event)
    }

    /// Gets personalized recommendations for the current player
    /// - Returns: AI-generated personalization recommendations
    public func getPersonalizedRecommendations() async -> PersonalizationRecommendations {
        // If we have a recent analysis, use it
        if let profile = currentProfile,
           CACurrentMediaTime() - lastAnalysisTime < analysisInterval {
            return personalizationEngine.generateRecommendations(for: profile)
        }

        // Otherwise perform new analysis
        await performBehavioralAnalysis()
        return personalizationEngine.generateRecommendations(for: currentProfile ?? PlayerProfile.default)
    }

    /// Gets current player profile assessment
    /// - Returns: Current player profile with behavior patterns
    public func getCurrentPlayerProfile() -> PlayerProfile {
        currentProfile ?? PlayerProfile.default
    }

    /// Predicts player preferences for game elements
    /// - Parameter elementType: Type of game element to predict preference for
    /// - Returns: Predicted preference score (0.0 to 1.0)
    public func predictPlayerPreference(for elementType: GameElementType) async -> Double {
        let profile = await getUpdatedProfile()
        return personalizationEngine.predictPreference(for: elementType, profile: profile)
    }

    /// Gets behavioral insights for game design
    /// - Returns: AI-generated insights about player behavior
    public func getBehavioralInsights() async -> BehavioralInsights {
        let profile = await getUpdatedProfile()
        return await generateBehavioralInsights(for: profile)
    }

    /// Resets analytics data (useful for new players or testing)
    public func resetAnalytics() {
        analyticsData = AnalyticsData()
        currentProfile = nil
        lastAnalysisTime = 0
        behaviorAnalyzer.reset()
        personalizationEngine.reset()
    }

    // MARK: - AI Analysis

    /// Performs rule-based behavioral analysis
    private func performBehavioralAnalysis() async {
        let currentTime = CACurrentMediaTime()

        // Don't analyze too frequently
        guard currentTime - lastAnalysisTime >= analysisInterval else { return }

        lastAnalysisTime = currentTime

        // Get current behavior patterns
        let patterns = behaviorAnalyzer.getCurrentPatterns()

        // Perform rule-based profile generation
        let profile = generatePlayerProfile(from: patterns)

        // Update current profile
        currentProfile = profile

        // Apply personalization changes
        await applyPersonalizationChanges(for: profile)
    }

    /// Generates player profile from behavior patterns using rule-based analysis
    private func generatePlayerProfile(from patterns: BehaviorPatterns) -> PlayerProfile {
        // Determine player type based on behavior patterns
        let playerType = determinePlayerType(from: patterns)

        // Assess skill level
        let skillLevel = assessSkillLevel(from: patterns)

        // Determine engagement style
        let engagementStyle = determineEngagementStyle(from: patterns)

        // Determine difficulty preference
        let difficultyPreference = determineDifficultyPreference(from: patterns)

        // Generate personalization settings
        let personalizationSettings = generatePersonalizationSettings(for: patterns)

        // Generate behavioral insights
        let behavioralInsights = generateBehavioralInsights(for: patterns)

        // Determine suggested improvements
        let suggestedImprovements = generateSuggestedImprovements(for: patterns)

        return PlayerProfile(
            playerType: playerType,
            skillLevel: skillLevel,
            engagementStyle: engagementStyle,
            difficultyPreference: difficultyPreference,
            personalizationSettings: personalizationSettings,
            behavioralInsights: behavioralInsights,
            suggestedImprovements: suggestedImprovements,
            lastUpdated: Date(),
            behaviorPatterns: patterns
        )
    }

    /// Applies personalization changes based on profile
    private func applyPersonalizationChanges(for profile: PlayerProfile) async {
        // Notify game coordinator of personalization updates
        NotificationCenter.default.post(
            name: NSNotification.Name("AIPersonalizationUpdate"),
            object: self,
            userInfo: [
                "profile": profile,
                "recommendations": personalizationEngine.generateRecommendations(for: profile)
            ]
        )
    }

    /// Applies fallback profile generation
    private func applyFallbackProfile() async {
        let patterns = behaviorAnalyzer.getCurrentPatterns()
        let fallbackProfile = PlayerProfile.fallback(for: patterns)

        currentProfile = fallbackProfile
        await applyPersonalizationChanges(for: fallbackProfile)
    }

    /// Gets updated player profile (performs analysis if needed)
    private func getUpdatedProfile() async -> PlayerProfile {
        if let profile = currentProfile,
           CACurrentMediaTime() - lastAnalysisTime < analysisInterval {
            return profile
        }

        await performBehavioralAnalysis()
        return currentProfile ?? PlayerProfile.default
    }

    /// Generates behavioral insights using rule-based analysis
    private func generateBehavioralInsights(for profile: PlayerProfile) async -> BehavioralInsights {
        let insights = generateBehavioralInsights(for: profile.behaviorPatterns)

        return BehavioralInsights(
            insights: insights,
            profile: profile,
            generatedAt: Date()
        )
    }

    // MARK: - Persistence

    private func loadPersistedData() {
        // Load player profile only (analytics data is not persisted)
        if let data = UserDefaults.standard.data(forKey: "PlayerProfile"),
           let decoded = try? JSONDecoder().decode(PlayerProfile.self, from: data) {
            currentProfile = decoded
        }
    }

    private func savePersistedData() {
        // Save player profile only (analytics data is not persisted)
        if let profile = currentProfile,
           let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "PlayerProfile")
        }
    }
}

// MARK: - Supporting Types

/// Player action types for tracking
public enum PlayerAction {
    case tap(position: CGPoint)
    case swipe(direction: CGVector)
    case tilt(sensitivity: Double)
    case powerUpCollected(type: PowerUpType)
    case collision(type: String)
    case pause
    case resume
    case restart

    var isSignificant: Bool {
        switch self {
        case .collision, .powerUpCollected, .restart:
            return true
        default:
            return false
        }
    }
}

/// Game event types for analysis
public enum GameEvent {
    case gameStart
    case gameEnd(score: Int, survivalTime: TimeInterval)
    case difficultyIncrease(level: Int)
    case highScoreAchieved(score: Int)
    case powerUpSpawned(type: PowerUpType)
    case obstacleAvoided
    case sessionMilestone(achievement: String)
}

/// Action context for additional metadata
public struct ActionContext {
    let gameState: String?
    let difficultyLevel: Int?
    let score: Int?
    let position: CGPoint?
}

/// Timestamped action for analytics
public struct TimestampedAction {
    let action: PlayerAction
    let timestamp: Date
    let context: ActionContext?
}

/// Game element types for preference prediction
public enum GameElementType {
    case obstacle(type: String)
    case powerUp(type: PowerUpType)
    case visualEffect(style: String)
    case audioEffect(type: String)
    case challenge(type: String)
}

/// Personalization recommendations
public struct PersonalizationRecommendations {
    let obstacleDensity: Double
    let powerUpFrequency: Double
    let visualEffects: Double
    let audioIntensity: Double
    let challengeVariety: Double
    let reasoning: String
}

/// Behavioral insights from AI analysis
public struct BehavioralInsights {
    let insights: String
    let profile: PlayerProfile
    let generatedAt: Date
}

/// AI profile result from Ollama
private struct AIProfileResult: Codable {
    let player_type: String
    let skill_level: String
    let engagement_style: String
    let difficulty_preference: String
    let personalization_recommendations: PersonalizationSettings
    let behavioral_insights: String
    let suggested_improvements: [String]
}

/// Personalization settings
public struct PersonalizationSettings: Codable {
    let obstacle_density: Double
    let powerup_frequency: Double
    let visual_effects: Double
    let audio_intensity: Double
    let challenge_variety: Double
}

// MARK: - Analytics Data Storage

/// Comprehensive analytics data storage
private struct AnalyticsData {
    var actions: [TimestampedAction] = []
    var events: [GameEvent] = []
    var sessions: [GameSession] = []

    mutating func recordAction(_ action: TimestampedAction) {
        actions.append(action)

        // Keep only recent actions (last 1000)
        if actions.count > 1000 {
            actions.removeFirst(actions.count - 1000)
        }
    }

    mutating func recordEvent(_ event: GameEvent) {
        events.append(event)

        // Keep only recent events (last 500)
        if events.count > 500 {
            events.removeFirst(events.count - 500)
        }
    }

    func getRecentActions(limit: Int = 100) -> [TimestampedAction] {
        Array(actions.suffix(limit))
    }

    func getRecentEvents(limit: Int = 50) -> [GameEvent] {
        Array(events.suffix(limit))
    }
}

// MARK: - Behavior Analysis

/// Analyzes player behavior patterns
private class BehaviorPatternAnalyzer {
    private var actionHistory: [TimestampedAction] = []
    private var eventHistory: [GameEvent] = []

    func updatePatterns(with event: GameEvent) {
        eventHistory.append(event)

        // Keep only recent events
        if eventHistory.count > 200 {
            eventHistory.removeFirst(eventHistory.count - 200)
        }
    }

    func getCurrentPatterns() -> BehaviorPatterns {
        let recentActions = actionHistory.suffix(100)
        let recentEvents = eventHistory.suffix(50)

        return BehaviorPatterns(
            movementStyle: analyzeMovementStyle(recentActions),
            riskTolerance: analyzeRiskTolerance(recentActions, recentEvents),
            learningPattern: analyzeLearningPattern(recentEvents),
            engagementLevel: analyzeEngagementLevel(recentActions, recentEvents),
            preferredDifficulty: analyzePreferredDifficulty(recentEvents),
            powerUpPreferences: analyzePowerUpPreferences(recentActions),
            collisionPatterns: analyzeCollisionPatterns(recentActions),
            averageSessionLength: analyzeAverageSessionLength(recentEvents),
            peakPerformanceTimes: analyzePeakPerformanceTimes(recentEvents),
            improvementRate: analyzeImprovementRate(recentEvents),
            frustrationThreshold: analyzeFrustrationThreshold(recentActions, recentEvents),
            visualPreferences: analyzeVisualPreferences(recentActions),
            audioPreferences: analyzeAudioPreferences(recentActions),
            challengePreferences: analyzeChallengePreferences(recentEvents)
        )
    }

    func reset() {
        actionHistory.removeAll()
        eventHistory.removeAll()
    }

    // MARK: - Analysis Helpers

    private func analyzeMovementStyle(_ actions: ArraySlice<TimestampedAction>) -> String {
        let tapCount = actions.filter { if case .tap = $0.action { return true } else { return false } }.count
        let swipeCount = actions.filter { if case .swipe = $0.action { return true } else { return false } }.count
        let tiltCount = actions.filter { if case .tilt = $0.action { return true } else { return false } }.count

        let total = tapCount + swipeCount + tiltCount
        if total == 0 { return "unknown" }

        if Double(tapCount) / Double(total) > 0.7 { return "tap_focused" }
        if Double(swipeCount) / Double(total) > 0.7 { return "swipe_focused" }
        if Double(tiltCount) / Double(total) > 0.7 { return "tilt_focused" }

        return "mixed_control"
    }

    private func analyzeRiskTolerance(_ actions: ArraySlice<TimestampedAction>, _ events: ArraySlice<GameEvent>) -> String {
        let collisionCount = actions.filter { if case .collision = $0.action { return true } else { return false } }.count
        let powerUpCount = actions.filter { if case .powerUpCollected = $0.action { return true } else { return false } }.count

        let totalActions = actions.count
        if totalActions == 0 { return "unknown" }

        let riskRatio = Double(collisionCount) / Double(totalActions)
        let rewardRatio = Double(powerUpCount) / Double(totalActions)

        if riskRatio > 0.3 { return "high_risk" }
        if rewardRatio > 0.2 { return "reward_seeking" }
        if riskRatio < 0.1 { return "cautious" }

        return "balanced"
    }

    private func analyzeLearningPattern(_ events: ArraySlice<GameEvent>) -> String {
        // Analyze score improvement over time
        let scores = events.compactMap { event -> Int? in
            if case .gameEnd(let score, _) = event { return score }
            return nil
        }

        if scores.count < 3 { return "unknown" }

        let recentAvg = Double(scores.suffix(3).reduce(0, +)) / 3.0
        let earlierAvg = Double(scores.prefix(scores.count - 3).reduce(0, +)) / Double(max(1, scores.count - 3))

        if recentAvg > earlierAvg * 1.5 { return "rapid_improvement" }
        if recentAvg > earlierAvg * 1.2 { return "steady_improvement" }
        if recentAvg < earlierAvg * 0.8 { return "plateauing" }

        return "consistent"
    }

    private func analyzeEngagementLevel(_ actions: ArraySlice<TimestampedAction>, _ events: ArraySlice<GameEvent>) -> String {
        let sessionLengths = events.compactMap { event -> TimeInterval? in
            if case .gameEnd(_, let time) = event { return time }
            return nil
        }

        if sessionLengths.isEmpty { return "unknown" }

        let avgLength = sessionLengths.reduce(0, +) / Double(sessionLengths.count)

        if avgLength > 120 { return "high_engagement" }
        if avgLength > 60 { return "moderate_engagement" }
        if avgLength > 30 { return "low_engagement" }

        return "very_low_engagement"
    }

    private func analyzePreferredDifficulty(_ events: ArraySlice<GameEvent>) -> String {
        let difficulties = events.compactMap { event -> Int? in
            if case .difficultyIncrease(let level) = event { return level }
            return nil
        }

        if difficulties.isEmpty { return "unknown" }

        let avgDifficulty = Double(difficulties.reduce(0, +)) / Double(difficulties.count)

        if avgDifficulty > 8 { return "prefers_hard" }
        if avgDifficulty > 5 { return "prefers_medium" }
        if avgDifficulty > 3 { return "prefers_easy" }

        return "prefers_very_easy"
    }

    private func analyzePowerUpPreferences(_ actions: ArraySlice<TimestampedAction>) -> [PowerUpPreference] {
        var preferences: [String: Int] = [:]

        for action in actions {
            if case .powerUpCollected(let type) = action.action {
                preferences[type.rawValue, default: 0] += 1
            }
        }

        return preferences.map { PowerUpPreference(type: PowerUpType(rawValue: $0.key) ?? .shield, frequency: $0.value) }
    }

    private func analyzeCollisionPatterns(_ actions: ArraySlice<TimestampedAction>) -> [CollisionPattern] {
        var patterns: [String: Int] = [:]

        for action in actions {
            if case .collision(let type) = action.action {
                patterns[type, default: 0] += 1
            }
        }

        return patterns.map { CollisionPattern(type: $0.key, frequency: $0.value) }
    }

    private func analyzeAverageSessionLength(_ events: ArraySlice<GameEvent>) -> TimeInterval {
        let lengths = events.compactMap { event -> TimeInterval? in
            if case .gameEnd(_, let time) = event { return time }
            return nil
        }

        return lengths.isEmpty ? 0 : lengths.reduce(0, +) / Double(lengths.count)
    }

    private func analyzePeakPerformanceTimes(_ events: ArraySlice<GameEvent>) -> [String] {
        // Simple analysis - would need more sophisticated time-based analysis
        ["morning", "afternoon"] // Placeholder
    }

    private func analyzeImprovementRate(_ events: ArraySlice<GameEvent>) -> String {
        let scores = events.compactMap { event -> Int? in
            if case .gameEnd(let score, _) = event { return score }
            return nil
        }

        if scores.count < 5 { return "unknown" }

        let firstHalf = scores.prefix(scores.count / 2)
        let secondHalf = scores.suffix(scores.count / 2)

        let firstAvg = Double(firstHalf.reduce(0, +)) / Double(firstHalf.count)
        let secondAvg = Double(secondHalf.reduce(0, +)) / Double(secondHalf.count)

        if secondAvg > firstAvg * 1.3 { return "fast" }
        if secondAvg > firstAvg * 1.1 { return "moderate" }
        if secondAvg < firstAvg * 0.9 { return "declining" }

        return "stable"
    }

    private func analyzeFrustrationThreshold(_ actions: ArraySlice<TimestampedAction>, _ events: ArraySlice<GameEvent>) -> String {
        let restartCount = actions.filter { if case .restart = $0.action { return true } else { return false } }.count
        let collisionCount = actions.filter { if case .collision = $0.action { return true } else { return false } }.count

        if collisionCount == 0 { return "very_high" }

        let frustrationRatio = Double(restartCount) / Double(collisionCount)

        if frustrationRatio > 0.5 { return "low" }
        if frustrationRatio > 0.2 { return "medium" }

        return "high"
    }

    private func analyzeVisualPreferences(_ actions: ArraySlice<TimestampedAction>) -> String {
        // Placeholder - would analyze visual effect interactions
        "balanced"
    }

    private func analyzeAudioPreferences(_ actions: ArraySlice<TimestampedAction>) -> String {
        // Placeholder - would analyze audio setting changes
        "moderate"
    }

    private func analyzeChallengePreferences(_ events: ArraySlice<GameEvent>) -> String {
        // Placeholder - would analyze challenge type preferences
        "variety_seeking"
    }
}

/// Personalization engine for recommendations
private class PersonalizationEngine {
    func generateRecommendations(for profile: PlayerProfile) -> PersonalizationRecommendations {
        let settings = profile.personalizationSettings

        return PersonalizationRecommendations(
            obstacleDensity: settings.obstacle_density,
            powerUpFrequency: settings.powerup_frequency,
            visualEffects: settings.visual_effects,
            audioIntensity: settings.audio_intensity,
            challengeVariety: settings.challenge_variety,
            reasoning: profile.behavioralInsights
        )
    }

    func predictPreference(for elementType: GameElementType, profile: PlayerProfile) -> Double {
        // Simple preference prediction based on profile
        switch elementType {
        case .powerUp:
            return profile.personalizationSettings.powerup_frequency
        case .obstacle:
            return profile.personalizationSettings.obstacle_density
        case .visualEffect:
            return profile.personalizationSettings.visual_effects
        case .audioEffect:
            return profile.personalizationSettings.audio_intensity
        case .challenge:
            return profile.personalizationSettings.challenge_variety
        }
    }

    func reset() {
        // Reset any cached recommendations
    }
}

// MARK: - Data Models

/// Player profile with behavioral analysis
public struct PlayerProfile: Codable {
    let playerType: PlayerType
    let skillLevel: PlayerSkillLevel
    let engagementStyle: EngagementStyle
    let difficultyPreference: DifficultyPreference
    let personalizationSettings: PersonalizationSettings
    let behavioralInsights: String
    let suggestedImprovements: [String]
    let lastUpdated: Date
    let behaviorPatterns: BehaviorPatterns

    static let `default` = PlayerProfile(
        playerType: .casual,
        skillLevel: .beginner,
        engagementStyle: .focused,
        difficultyPreference: .medium,
        personalizationSettings: PersonalizationSettings(
            obstacle_density: 0.5,
            powerup_frequency: 0.5,
            visual_effects: 0.5,
            audio_intensity: 0.5,
            challenge_variety: 0.5
        ),
        behavioralInsights: "Default profile for new players",
        suggestedImprovements: [],
        lastUpdated: Date(),
        behaviorPatterns: BehaviorPatterns.empty
    )

    static func fallback(for patterns: BehaviorPatterns) -> PlayerProfile {
        // Generate fallback profile based on basic pattern analysis
        let skillLevel: PlayerSkillLevel = patterns.averageSessionLength > 60 ? .intermediate : .beginner
        let playerType: PlayerType = patterns.riskTolerance == "high_risk" ? .rusher : .casual

        return PlayerProfile(
            playerType: playerType,
            skillLevel: skillLevel,
            engagementStyle: .focused,
            difficultyPreference: .medium,
            personalizationSettings: PersonalizationSettings(
                obstacle_density: 0.5,
                powerup_frequency: 0.5,
                visual_effects: 0.5,
                audio_intensity: 0.5,
                challenge_variety: 0.5
            ),
            behavioralInsights: "Fallback profile based on basic pattern analysis",
            suggestedImprovements: ["Continue playing to unlock AI personalization"],
            lastUpdated: Date(),
            behaviorPatterns: patterns
        )
    }
}

/// Behavior patterns analysis
public struct BehaviorPatterns: Codable {
    let movementStyle: String
    let riskTolerance: String
    let learningPattern: String
    let engagementLevel: String
    let preferredDifficulty: String
    let powerUpPreferences: [PowerUpPreference]
    let collisionPatterns: [CollisionPattern]
    let averageSessionLength: TimeInterval
    let peakPerformanceTimes: [String]
    let improvementRate: String
    let frustrationThreshold: String
    let visualPreferences: String
    let audioPreferences: String
    let challengePreferences: String

    static let empty = BehaviorPatterns(
        movementStyle: "unknown",
        riskTolerance: "unknown",
        learningPattern: "unknown",
        engagementLevel: "unknown",
        preferredDifficulty: "unknown",
        powerUpPreferences: [],
        collisionPatterns: [],
        averageSessionLength: 0,
        peakPerformanceTimes: [],
        improvementRate: "unknown",
        frustrationThreshold: "unknown",
        visualPreferences: "unknown",
        audioPreferences: "unknown",
        challengePreferences: "unknown"
    )
}

/// Power-up preference tracking
public struct PowerUpPreference: Codable {
    let type: PowerUpType
    let frequency: Int
}

/// Collision pattern for analysis
public struct CollisionPattern: Codable {
    let type: String
    let frequency: Int
}

/// Game session for analytics
public struct GameSession {
    let startTime: Date
    let endTime: Date
    let score: Int
    let survivalTime: TimeInterval
    let actions: [TimestampedAction]
    let events: [GameEvent]
}

// MARK: - Rule-Based Profile Generation

private extension PlayerAnalyticsAI {
    /// Determines player type based on behavior patterns
    private func determinePlayerType(from patterns: BehaviorPatterns) -> PlayerType {
        // Analyze behavior patterns to determine player type
        if patterns.collisionPatterns.contains(where: { $0.frequency > 10 }) {
            return .rusher // High collision rate suggests rushing behavior
        }

        if patterns.powerUpPreferences.count > 2 && patterns.powerUpPreferences.allSatisfy({ $0.frequency > 5 }) {
            return .perfectionist // Uses all power-ups frequently
        }

        if patterns.averageSessionLength > 180 {
            return .explorer // Long sessions suggest exploration
        }

        if patterns.improvementRate == "fast" && patterns.collisionPatterns.count < 3 {
            return .speedrunner // Fast improvement with few collisions
        }

        return .casual // Default type
    }

    /// Assesses skill level based on behavior patterns
    private func assessSkillLevel(from patterns: BehaviorPatterns) -> PlayerSkillLevel {
        // Assess skill based on various metrics
        var skillScore = 0

        if patterns.averageSessionLength > 120 { skillScore += 2 }
        else if patterns.averageSessionLength > 60 { skillScore += 1 }

        if patterns.collisionPatterns.count < 5 { skillScore += 2 }
        else if patterns.collisionPatterns.count < 10 { skillScore += 1 }

        if patterns.improvementRate == "fast" { skillScore += 2 }
        else if patterns.improvementRate == "moderate" { skillScore += 1 }

        if patterns.powerUpPreferences.count > 2 { skillScore += 1 }

        switch skillScore {
        case 0...2: return .beginner
        case 3...4: return .intermediate
        case 5...6: return .advanced
        default: return .expert
        }
    }

    /// Determines engagement style based on behavior patterns
    private func determineEngagementStyle(from patterns: BehaviorPatterns) -> EngagementStyle {
        if patterns.averageSessionLength > 120 {
            return .focused
        }

        if patterns.collisionPatterns.count > 8 {
            return .distracted // Many collisions suggest distraction
        }

        if patterns.improvementRate == "fast" {
            return .competitive
        }

        return .relaxed
    }

    /// Determines difficulty preference based on behavior patterns
    private func determineDifficultyPreference(from patterns: BehaviorPatterns) -> DifficultyPreference {
        if patterns.collisionPatterns.count > 10 {
            return .easy
        }

        if patterns.averageSessionLength > 90 && patterns.collisionPatterns.count < 5 {
            return .hard
        }

        if patterns.improvementRate == "fast" {
            return .adaptive
        }

        return .medium
    }

    /// Generates personalization settings based on behavior patterns
    private func generatePersonalizationSettings(for patterns: BehaviorPatterns) -> PersonalizationSettings {
        var obstacleDensity = 0.5
        var powerUpFrequency = 0.5
        var visualEffects = 0.5
        var audioIntensity = 0.5
        var challengeVariety = 0.5

        // Adjust based on behavior patterns
        if patterns.collisionPatterns.count > 8 {
            obstacleDensity = 0.3 // Reduce obstacles for struggling players
            powerUpFrequency = 0.8 // Increase power-ups
        } else if patterns.collisionPatterns.count < 3 {
            obstacleDensity = 0.7 // Increase obstacles for skilled players
            powerUpFrequency = 0.3 // Reduce power-ups
        }

        if patterns.averageSessionLength > 120 {
            visualEffects = 0.8 // Enhance visuals for engaged players
            audioIntensity = 0.7
        }

        if patterns.powerUpPreferences.count > 2 {
            challengeVariety = 0.8 // Increase variety for power-up users
        }

        return PersonalizationSettings(
            obstacle_density: obstacleDensity,
            powerup_frequency: powerUpFrequency,
            visual_effects: visualEffects,
            audio_intensity: audioIntensity,
            challenge_variety: challengeVariety
        )
    }

    /// Generates behavioral insights based on behavior patterns
    private func generateBehavioralInsights(for patterns: BehaviorPatterns) -> String {
        var insights = [String]()

        if patterns.collisionPatterns.count > 8 {
            insights.append("Player struggles with obstacle avoidance")
        } else if patterns.collisionPatterns.count < 3 {
            insights.append("Player excels at obstacle avoidance")
        }

        if patterns.powerUpPreferences.count > 2 {
            insights.append("Player actively seeks and uses power-ups")
        }

        if patterns.averageSessionLength > 120 {
            insights.append("Player enjoys longer gaming sessions")
        } else if patterns.averageSessionLength < 30 {
            insights.append("Player prefers shorter, quicker sessions")
        }

        if patterns.improvementRate == "fast" {
            insights.append("Player shows rapid skill improvement")
        }

        return insights.joined(separator: ". ") + "."
    }

    /// Generates suggested improvements based on behavior patterns
    private func generateSuggestedImprovements(for patterns: BehaviorPatterns) -> [String] {
        var improvements = [String]()

        if patterns.collisionPatterns.count > 8 {
            improvements.append("Consider adding tutorial elements for obstacle avoidance")
            improvements.append("Increase power-up frequency to help struggling players")
        }

        if patterns.powerUpPreferences.isEmpty {
            improvements.append("Consider making power-ups more visible or accessible")
        }

        if patterns.averageSessionLength < 30 {
            improvements.append("Consider adding quick-play modes for shorter sessions")
        }

        if patterns.improvementRate == "declining" {
            improvements.append("Consider adding varied challenges to maintain engagement")
        }

        if improvements.isEmpty {
            improvements.append("Game balance appears appropriate for this player type")
        }

        return improvements
    }
}
