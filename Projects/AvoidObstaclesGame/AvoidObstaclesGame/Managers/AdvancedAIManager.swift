//
// AdvancedAIManager.swift
// AvoidObstaclesGame
//
// Advanced AI system providing predictive game state analysis,
// dynamic content generation, and intelligent game adaptation.
//

import Foundation
import SpriteKit
import Combine

/// Advanced AI manager for sophisticated game intelligence
@MainActor
final class AdvancedAIManager: @unchecked Sendable {
    // MARK: - Properties

    /// Shared instance
    static let shared = AdvancedAIManager()

    /// Predictive game state analyzer
    private let predictiveAnalyzer = PredictiveGameStateAnalyzer()

    /// Dynamic content generator
    private let contentGenerator = DynamicContentGenerator()

    /// Emotion recognition system
    private let emotionAnalyzer = EmotionRecognitionSystem()

    /// Multi-modal AI coordinator
    private let multimodalCoordinator = MultimodalAICoordinator()

    /// Reinforcement learning agent
    private let reinforcementLearner = ReinforcementLearningAgent()

    /// Performance metrics publisher
    let aiPerformancePublisher = PassthroughSubject<AdvancedAIPerformanceData, Never>()

    /// Current game context
    private var currentGameContext: GameContext?

    /// Analysis update timer
    private var analysisTimer: Timer?

    /// Content generation timer
    private var contentTimer: Timer?

    // MARK: - Initialization

    private init() {
        setupTimers()
        setupMultimodalCoordination()
    }

    @MainActor
    deinit {
        analysisTimer?.invalidate()
        contentTimer?.invalidate()
    }

    // MARK: - Public Interface

    /// Updates game context for AI analysis
    /// - Parameter context: Current game context
    func updateGameContext(_ context: GameContext) {
        currentGameContext = context
        multimodalCoordinator.updateContext(context)
    }

    /// Performs predictive game state analysis
    /// - Returns: AI predictions and recommendations
    @MainActor
    func performPredictiveAnalysis() async -> PredictiveAnalysisResult {
        guard let context = currentGameContext else {
            return PredictiveAnalysisResult.empty
        }

        return await predictiveAnalyzer.analyzeGameState(context)
    }

    /// Generates dynamic content based on player behavior
    /// - Parameter playerProfile: Current player profile
    /// - Returns: Generated content suggestions
    @MainActor
    func generateDynamicContent(for playerProfile: PlayerProfile) async -> DynamicContentPackage {
        return await contentGenerator.generateContent(for: playerProfile)
    }

    /// Analyzes player emotion from behavior patterns
    /// - Parameter behaviorData: Recent player behavior data
    /// - Returns: Emotion analysis result
    @MainActor
    func analyzePlayerEmotion(from behaviorData: BehaviorData) async -> EmotionAnalysisResult {
        return await emotionAnalyzer.analyzeEmotion(from: behaviorData)
    }

    /// Learns from player interaction using reinforcement learning
    /// - Parameter interaction: Player interaction data
    func learnFromInteraction(_ interaction: PlayerInteraction) {
        reinforcementLearner.learn(from: interaction)
    }

    /// Gets AI-driven game adaptation recommendations
    /// - Returns: Adaptation recommendations
    @MainActor
    func getAdaptationRecommendations() async -> AdaptationRecommendations {
        guard let context = currentGameContext else {
            return AdaptationRecommendations.empty
        }

        let predictiveResult = await performPredictiveAnalysis()
        let reinforcementInsights = reinforcementLearner.getInsights()

        return AdaptationRecommendations(
            difficultyAdjustments: predictiveResult.difficultyRecommendations,
            contentSuggestions: predictiveResult.contentSuggestions,
            behavioralAdaptations: reinforcementInsights.behavioralAdaptations,
            performanceOptimizations: predictiveResult.performanceOptimizations
        )
    }

    /// Resets AI learning state
    func resetAILearning() {
        reinforcementLearner.reset()
        predictiveAnalyzer.reset()
        contentGenerator.reset()
    }

    // MARK: - Private Methods

    private func setupTimers() {
        // Predictive analysis every 3 seconds
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.performPeriodicAnalysis()
            }
        }

        // Content generation every 30 seconds
        contentTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.performContentGeneration()
            }
        }
    }

    private func setupMultimodalCoordination() {
        // Connect different AI systems
        multimodalCoordinator.connectSystems(
            predictive: predictiveAnalyzer,
            content: contentGenerator,
            emotion: emotionAnalyzer,
            reinforcement: reinforcementLearner
        )
    }

    @MainActor
    private func performPeriodicAnalysis() async {
        let analysisResult = await performPredictiveAnalysis()

        // Publish performance data
        let performanceData = AdvancedAIPerformanceData(
            analysisTime: analysisResult.analysisTime,
            predictionAccuracy: analysisResult.confidence,
            contentGenerationRate: 0.0, // Will be updated by content generation
            adaptationEffectiveness: analysisResult.effectiveness
        )

        aiPerformancePublisher.send(performanceData)

        // Apply real-time adaptations if confidence is high
        if analysisResult.confidence > 0.8 {
            await applyRealTimeAdaptations(analysisResult)
        }
    }

    @MainActor
    private func performContentGeneration() async {
        guard let profile = await getCurrentPlayerProfile() else { return }

        let contentPackage = await generateDynamicContent(for: profile)

        // Apply generated content
        await applyDynamicContent(contentPackage)
    }

    @MainActor
    private func applyRealTimeAdaptations(_ analysis: PredictiveAnalysisResult) async {
        // Apply difficulty adjustments
        for adjustment in analysis.difficultyRecommendations {
            await applyDifficultyAdjustment(adjustment)
        }

        // Apply content suggestions
        for suggestion in analysis.contentSuggestions {
            await applyContentSuggestion(suggestion)
        }
    }

    @MainActor
    private func applyDynamicContent(_ content: DynamicContentPackage) async {
        // Apply obstacle modifications
        for modification in content.obstacleModifications {
            await applyObstacleModification(modification)
        }

        // Apply power-up adjustments
        for adjustment in content.powerUpAdjustments {
            await applyPowerUpAdjustment(adjustment)
        }

        // Apply visual enhancements
        for enhancement in content.visualEnhancements {
            await applyVisualEnhancement(enhancement)
        }
    }

    @MainActor
    private func getCurrentPlayerProfile() async -> PlayerProfile? {
        return PlayerAnalyticsAI.shared.getCurrentPlayerProfile()
    }

    // MARK: - Adaptation Application Methods

    @MainActor
    private func applyDifficultyAdjustment(_ adjustment: DifficultyAdjustment) async {
        // Implementation would integrate with existing difficulty system
        print("Applying difficulty adjustment: \(adjustment.description)")
    }

    @MainActor
    private func applyContentSuggestion(_ suggestion: ContentSuggestion) async {
        // Implementation would modify game content
        print("Applying content suggestion: \(suggestion.description)")
    }

    @MainActor
    private func applyObstacleModification(_ modification: ObstacleModification) async {
        // Implementation would modify obstacle generation
        print("Applying obstacle modification: \(modification.description)")
    }

    @MainActor
    private func applyPowerUpAdjustment(_ adjustment: PowerUpAdjustment) async {
        // Implementation would adjust power-up spawning
        print("Applying power-up adjustment: \(adjustment.description)")
    }

    @MainActor
    private func applyVisualEnhancement(_ enhancement: VisualEnhancement) async {
        // Implementation would apply visual changes
        print("Applying visual enhancement: \(enhancement.description)")
    }
}

// MARK: - Supporting Types

/// Game context for AI analysis
struct GameContext {
    let currentScore: Int
    let playerPosition: CGPoint
    let obstacles: [ObstacleData]
    let powerUps: [PowerUpData]
    let gameState: GameState
    let difficultyLevel: Int
    let sessionTime: TimeInterval
    let playerHealth: Double
}

/// Predictive analysis result
struct PredictiveAnalysisResult: Sendable {
    let difficultyRecommendations: [DifficultyAdjustment]
    let contentSuggestions: [ContentSuggestion]
    let performanceOptimizations: [String]
    let confidence: Double
    let analysisTime: TimeInterval
    let effectiveness: Double

    static let empty = PredictiveAnalysisResult(
        difficultyRecommendations: [],
        contentSuggestions: [],
        performanceOptimizations: [],
        confidence: 0.0,
        analysisTime: 0.0,
        effectiveness: 0.0
    )
}

/// Dynamic content package
struct DynamicContentPackage {
    let obstacleModifications: [ObstacleModification]
    let powerUpAdjustments: [PowerUpAdjustment]
    let visualEnhancements: [VisualEnhancement]
    let audioAdjustments: [AudioAdjustment]
}

/// Emotion analysis result
struct EmotionAnalysisResult {
    let primaryEmotion: PlayerEmotion
    let intensity: Double
    let confidence: Double
    let suggestedActions: [String]
}

/// Adaptation recommendations
struct AdaptationRecommendations: Sendable {
    let difficultyAdjustments: [DifficultyAdjustment]
    let contentSuggestions: [ContentSuggestion]
    let behavioralAdaptations: [BehavioralAdaptation]
    let performanceOptimizations: [String]

    static let empty = AdaptationRecommendations(
        difficultyAdjustments: [],
        contentSuggestions: [],
        behavioralAdaptations: [],
        performanceOptimizations: []
    )
}

/// Advanced AI performance data
struct AdvancedAIPerformanceData {
    let analysisTime: TimeInterval
    let predictionAccuracy: Double
    let contentGenerationRate: Double
    let adaptationEffectiveness: Double
}

/// Player interaction data
struct PlayerInteraction {
    let action: PlayerAction
    let context: GameContext
    let timestamp: Date
    let outcome: InteractionOutcome
}

/// Behavior data for emotion analysis
struct BehaviorData {
    let recentActions: [PlayerAction]
    let reactionTimes: [TimeInterval]
    let successRate: Double
    let sessionDuration: TimeInterval
    let collisionPatterns: [CollisionPattern]
}

// MARK: - AI Component Classes

/// Predictive game state analyzer
@MainActor
class PredictiveGameStateAnalyzer {
    private var historicalStates: [GameStateSnapshot] = []
    private let maxHistorySize = 100

    func analyzeGameState(_ context: GameContext) async -> PredictiveAnalysisResult {
        let startTime = Date()

        // Add current state to history
        let snapshot = GameStateSnapshot(from: context, timestamp: Date())
        historicalStates.append(snapshot)

        // Maintain history size
        if historicalStates.count > maxHistorySize {
            historicalStates.removeFirst()
        }

        // Perform predictive analysis
        let predictions = await performPredictiveAnalysis()

        let analysisTime = Date().timeIntervalSince(startTime)
        let confidence = calculateConfidence(predictions)
        let effectiveness = calculateEffectiveness(predictions)

        return PredictiveAnalysisResult(
            difficultyRecommendations: predictions.difficultyAdjustments,
            contentSuggestions: predictions.contentSuggestions,
            performanceOptimizations: predictions.performanceOptimizations,
            confidence: confidence,
            analysisTime: analysisTime,
            effectiveness: effectiveness
        )
    }

    private func performPredictiveAnalysis() async -> PredictiveAnalysisData {
        // Analyze patterns in historical data
        let patternAnalysis = analyzePatterns()

        // Generate predictions based on patterns
        let difficultyAdjustments = generateDifficultyAdjustments(from: patternAnalysis)
        let contentSuggestions = generateContentSuggestions(from: patternAnalysis)
        let performanceOptimizations = generatePerformanceOptimizations(from: patternAnalysis)

        return PredictiveAnalysisData(
            difficultyAdjustments: difficultyAdjustments,
            contentSuggestions: contentSuggestions,
            performanceOptimizations: performanceOptimizations
        )
    }

    private func analyzePatterns() -> PatternAnalysis {
        guard historicalStates.count >= 3 else {
            return PatternAnalysis.empty
        }

        // Analyze score progression
        let scores = historicalStates.map { Double($0.score) }
        let scoreTrend = calculateTrend(scores)

        // Analyze difficulty progression
        let difficulties = historicalStates.map { Double($0.difficultyLevel) }
        let difficultyTrend = calculateTrend(difficulties)

        // Analyze obstacle patterns
        let obstacleCounts = historicalStates.map { Double($0.obstacleCount) }
        let obstacleTrend = calculateTrend(obstacleCounts)

        return PatternAnalysis(
            scoreTrend: scoreTrend,
            difficultyTrend: difficultyTrend,
            obstacleTrend: obstacleTrend,
            riskPatterns: analyzeRiskPatterns(),
            engagementPatterns: analyzeEngagementPatterns()
        )
    }

    private func calculateTrend(_ values: [Double]) -> Double {
        guard values.count >= 2 else { return 0.0 }

        let recent = Array(values.suffix(3))
        let earlier = Array(values.prefix(max(1, values.count - 3)))

        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let earlierAvg = earlier.reduce(0, +) / Double(earlier.count)

        return (recentAvg - earlierAvg) / max(earlierAvg, 1.0)
    }

    private func analyzeRiskPatterns() -> RiskPattern {
        let recentStates = historicalStates.suffix(5)
        let collisionRate = Double(recentStates.filter { $0.collisionCount > 0 }.count) / Double(recentStates.count)

        return RiskPattern(
            collisionRate: collisionRate,
            riskLevel: collisionRate > 0.3 ? .reckless : collisionRate > 0.1 ? .adventurous : .conservative
        )
    }

    private func analyzeEngagementPatterns() -> EngagementPattern {
        let recentStates = historicalStates.suffix(10)
        let avgSessionTime = recentStates.map { $0.sessionTime }.reduce(0, +) / Double(recentStates.count)

        return EngagementPattern(
            averageSessionTime: avgSessionTime,
            engagementLevel: avgSessionTime > 120 ? .veryHigh : avgSessionTime > 60 ? .high : avgSessionTime > 30 ? .medium : .low
        )
    }

    private func generateDifficultyAdjustments(from analysis: PatternAnalysis) -> [DifficultyAdjustment] {
        var adjustments: [DifficultyAdjustment] = []

        // Adjust based on score trend
        if analysis.scoreTrend < -0.2 {
            adjustments.append(.decrease(magnitude: 0.3))
        } else if analysis.scoreTrend > 0.3 {
            adjustments.append(.increase(magnitude: 0.2))
        }

        // Adjust based on risk patterns
        if analysis.riskPatterns.riskLevel == .reckless {
            adjustments.append(.decrease(magnitude: 0.4))
        }

        return adjustments
    }

    private func generateContentSuggestions(from analysis: PatternAnalysis) -> [ContentSuggestion] {
        var suggestions: [ContentSuggestion] = []

        // Suggest content based on engagement
        if analysis.engagementPatterns.engagementLevel == .low {
            suggestions.append(ContentSuggestion(
                type: .powerUpIncrease,
                priority: .high,
                reason: "Low engagement detected, increase rewards"
            ))
        }

        // Suggest based on obstacle trends
        if analysis.obstacleTrend > 0.2 {
            suggestions.append(ContentSuggestion(
                type: .obstacleVariety,
                priority: .medium,
                reason: "Player adapting to obstacle patterns"
            ))
        }

        return suggestions
    }

    private func generatePerformanceOptimizations(from analysis: PatternAnalysis) -> [String] {
        var optimizations: [String] = []

        // Optimize based on patterns
        if analysis.scoreTrend < -0.1 {
            optimizations.append("Reduce visual complexity for struggling players")
        }

        return optimizations
    }

    private func calculateConfidence(_ predictions: PredictiveAnalysisData) -> Double {
        // Calculate confidence based on data quality and consistency
        let dataPoints = Double(historicalStates.count)
        let baseConfidence = min(dataPoints / 20.0, 1.0) // Max confidence with 20+ data points

        // Adjust based on prediction consistency
        let adjustmentCount = predictions.difficultyAdjustments.count +
                             predictions.contentSuggestions.count +
                             predictions.performanceOptimizations.count

        let consistencyFactor = adjustmentCount > 3 ? 0.9 : adjustmentCount > 1 ? 0.95 : 1.0

        return baseConfidence * consistencyFactor
    }

    private func calculateEffectiveness(_ predictions: PredictiveAnalysisData) -> Double {
        // Simplified effectiveness calculation
        // In production, this would compare predictions against actual outcomes
        return 0.75 // Placeholder
    }

    func reset() {
        historicalStates.removeAll()
    }
}

/// Dynamic content generator
@MainActor
class DynamicContentGenerator {
    private var generatedContent: [GeneratedContent] = []
    private let contentTemplates = ContentTemplates()

    func generateContent(for profile: PlayerProfile) async -> DynamicContentPackage {
        // Generate content based on player preferences and behavior
        let obstacleMods = await generateObstacleModifications(for: profile)
        let powerUpAdjustments = generatePowerUpAdjustments(for: profile)
        let visualEnhancements = generateVisualEnhancements(for: profile)
        let audioAdjustments = generateAudioAdjustments(for: profile)

        let package = DynamicContentPackage(
            obstacleModifications: obstacleMods,
            powerUpAdjustments: powerUpAdjustments,
            visualEnhancements: visualEnhancements,
            audioAdjustments: audioAdjustments
        )

        // Store generated content for analysis
        generatedContent.append(GeneratedContent(
            package: package,
            profile: profile,
            timestamp: Date()
        ))

        return package
    }

    private func generateObstacleModifications(for profile: PlayerProfile) async -> [ObstacleModification] {
        var modifications: [ObstacleModification] = []

        // Generate based on player skill and preferences
        switch profile.skillLevel {
        case .beginner:
            modifications.append(ObstacleModification(
                type: .spacingIncrease,
                value: 1.5,
                reason: "Increase spacing for beginners"
            ))
        case .expert, .master:
            modifications.append(ObstacleModification(
                type: .complexityIncrease,
                value: 1.3,
                reason: "Add complexity for expert players"
            ))
        default:
            break
        }

        // Adjust based on risk tolerance
        if profile.behaviorPatterns.riskTolerance == "high_risk" {
            modifications.append(ObstacleModification(
                type: .speedIncrease,
                value: 1.2,
                reason: "Increase speed for risk-tolerant players"
            ))
        }

        return modifications
    }

    private func generatePowerUpAdjustments(for profile: PlayerProfile) -> [PowerUpAdjustment] {
        var adjustments: [PowerUpAdjustment] = []

        // Adjust power-up frequency based on player preferences
        let frequency = profile.personalizationSettings.powerup_frequency

        if frequency > 0.7 {
            adjustments.append(PowerUpAdjustment(
                type: .frequencyIncrease,
                value: frequency,
                reason: "Increase power-up frequency for preferred player type"
            ))
        } else if frequency < 0.3 {
            adjustments.append(PowerUpAdjustment(
                type: .frequencyDecrease,
                value: frequency,
                reason: "Decrease power-up frequency for strategic players"
            ))
        }

        return adjustments
    }

    private func generateVisualEnhancements(for profile: PlayerProfile) -> [VisualEnhancement] {
        var enhancements: [VisualEnhancement] = []

        let visualPreference = profile.personalizationSettings.visual_effects

        if visualPreference > 0.7 {
            enhancements.append(VisualEnhancement(
                type: .particleIncrease,
                intensity: visualPreference,
                reason: "Enhance visual effects for visually-oriented players"
            ))
        }

        return enhancements
    }

    private func generateAudioAdjustments(for profile: PlayerProfile) -> [AudioAdjustment] {
        var adjustments: [AudioAdjustment] = []

        let audioPreference = profile.personalizationSettings.audio_intensity

        if audioPreference > 0.7 {
            adjustments.append(AudioAdjustment(
                type: .intensityIncrease,
                value: audioPreference,
                reason: "Increase audio intensity for audio-preferring players"
            ))
        }

        return adjustments
    }

    func reset() {
        generatedContent.removeAll()
    }
}

/// Emotion recognition system
@MainActor
class EmotionRecognitionSystem {
    private let emotionPatterns = EmotionPatterns()

    func analyzeEmotion(from behaviorData: BehaviorData) async -> EmotionAnalysisResult {
        // Analyze behavior patterns to detect emotions
        let frustrationLevel = analyzeFrustration(behaviorData)
        let excitementLevel = analyzeExcitement(behaviorData)
        let boredomLevel = analyzeBoredom(behaviorData)

        // Determine primary emotion
        let primaryEmotion: PlayerEmotion
        let intensity: Double

        if frustrationLevel > excitementLevel && frustrationLevel > boredomLevel {
            primaryEmotion = .frustrated
            intensity = frustrationLevel
        } else if excitementLevel > boredomLevel {
            primaryEmotion = .excited
            intensity = excitementLevel
        } else {
            primaryEmotion = .bored
            intensity = boredomLevel
        }

        // Generate suggested actions based on emotion
        let suggestedActions = generateSuggestedActions(for: primaryEmotion, intensity: intensity)

        return EmotionAnalysisResult(
            primaryEmotion: primaryEmotion,
            intensity: intensity,
            confidence: calculateConfidence(behaviorData),
            suggestedActions: suggestedActions
        )
    }

    private func analyzeFrustration(_ data: BehaviorData) -> Double {
        let collisionRate = 1.0 - data.successRate
        let avgReactionTime = data.reactionTimes.average

        // High collision rate and slow reactions indicate frustration
        return min((collisionRate * 0.6) + (avgReactionTime / 3.0 * 0.4), 1.0)
    }

    private func analyzeExcitement(_ data: BehaviorData) -> Double {
        let successRate = data.successRate
        let actionFrequency = Double(data.recentActions.count) / max(data.sessionDuration, 1.0)

        // High success rate and frequent actions indicate excitement
        return min((successRate * 0.7) + (actionFrequency / 5.0 * 0.3), 1.0)
    }

    private func analyzeBoredom(_ data: BehaviorData) -> Double {
        let actionFrequency = Double(data.recentActions.count) / max(data.sessionDuration, 1.0)
        let successRate = data.successRate

        // Low action frequency and moderate success indicate boredom
        let lowActivity = max(0, 1.0 - actionFrequency / 2.0)
        return min(lowActivity * 0.6 + (1.0 - successRate) * 0.4, 1.0)
    }

    private func generateSuggestedActions(for emotion: PlayerEmotion, intensity: Double) -> [String] {
        switch emotion {
        case .frustrated:
            if intensity > 0.7 {
                return ["Reduce difficulty immediately", "Increase power-up frequency", "Add tutorial hints"]
            } else {
                return ["Slightly reduce obstacle speed", "Add encouraging feedback"]
            }
        case .excited:
            if intensity > 0.7 {
                return ["Maintain current challenge", "Add bonus multipliers", "Introduce new power-ups"]
            } else {
                return ["Gradually increase difficulty", "Add achievement unlocks"]
            }
        case .bored:
            if intensity > 0.7 {
                return ["Significantly increase difficulty", "Add new obstacle types", "Introduce time challenges"]
            } else {
                return ["Add variety to obstacle patterns", "Introduce mini-games"]
            }
        }
    }

    private func calculateConfidence(_ data: BehaviorData) -> Double {
        // Confidence based on data quality
        let actionCount = Double(data.recentActions.count)
        let dataQuality = min(actionCount / 20.0, 1.0) // Max confidence with 20+ actions

        return dataQuality * 0.8 // Slightly reduce for emotion analysis uncertainty
    }
}

/// Reinforcement learning agent
@MainActor
class ReinforcementLearningAgent {
    private var qTable: [String: [String: Double]] = [:]
    private var learningRate = 0.1
    private var discountFactor = 0.9
    private var explorationRate = 0.1

    func learn(from interaction: PlayerInteraction) {
        let state = stateRepresentation(for: interaction.context)
        let action = actionRepresentation(for: interaction.action)
        let reward = calculateReward(for: interaction.outcome)

        // Q-learning update
        let currentQ = qTable[state]?[action] ?? 0.0
        let maxNextQ = getMaxQValue(for: state) // Simplified, would need next state

        let newQ = currentQ + learningRate * (reward + discountFactor * maxNextQ - currentQ)

        if qTable[state] == nil {
            qTable[state] = [:]
        }
        qTable[state]?[action] = newQ
    }

    func getInsights() -> ReinforcementInsights {
        // Analyze learned patterns
        let topActions = getTopActions()
        let behavioralAdaptations = generateBehavioralAdaptations(from: topActions)

        return ReinforcementInsights(
            learnedPatterns: topActions,
            behavioralAdaptations: behavioralAdaptations,
            confidence: calculateLearningConfidence()
        )
    }

    private func stateRepresentation(for context: GameContext) -> String {
        // Create a simplified state representation
        let scoreLevel = context.currentScore / 100
        let difficultyLevel = context.difficultyLevel
        let obstacleCount = context.obstacles.count

        return "score:\(scoreLevel)_diff:\(difficultyLevel)_obs:\(obstacleCount)"
    }

    private func actionRepresentation(for action: PlayerAction) -> String {
        switch action {
        case .moveLeft: return "move_left"
        case .moveRight: return "move_right"
        case .dodge: return "dodge"
        case .powerUpCollected: return "powerup"
        default: return "other"
        }
    }

    private func calculateReward(for outcome: InteractionOutcome) -> Double {
        switch outcome {
        case .success: return 1.0
        case .collision: return -1.0
        case .powerUp: return 0.5
        case .neutral: return 0.0
        }
    }

    private func getMaxQValue(for state: String) -> Double {
        return qTable[state]?.values.max() ?? 0.0
    }

    private func getTopActions() -> [LearnedAction] {
        var actionValues: [String: Double] = [:]

        // Aggregate Q-values across all states
        for (_, actions) in qTable {
            for (action, value) in actions {
                actionValues[action] = (actionValues[action] ?? 0) + value
            }
        }

        // Return top 5 actions
        return actionValues.sorted { $0.value > $1.value }
            .prefix(5)
            .map { LearnedAction(action: $0.key, value: $0.value) }
    }

    private func generateBehavioralAdaptations(from actions: [LearnedAction]) -> [BehavioralAdaptation] {
        var adaptations: [BehavioralAdaptation] = []

        for learnedAction in actions {
            if learnedAction.value > 0.5 {
                adaptations.append(BehavioralAdaptation(
                    type: .encourageAction,
                    action: learnedAction.action,
                    strength: learnedAction.value,
                    reason: "Learned that \(learnedAction.action) leads to positive outcomes"
                ))
            }
        }

        return adaptations
    }

    private func calculateLearningConfidence() -> Double {
        let totalStates = Double(qTable.count)
        let avgActionsPerState = qTable.values.map { Double($0.count) }.average

        return min((totalStates * avgActionsPerState) / 50.0, 1.0)
    }

    func reset() {
        qTable.removeAll()
    }
}

/// Multi-modal AI coordinator
@MainActor
class MultimodalAICoordinator {
    private weak var predictiveAnalyzer: PredictiveGameStateAnalyzer?
    private weak var contentGenerator: DynamicContentGenerator?
    private weak var emotionAnalyzer: EmotionRecognitionSystem?
    private weak var reinforcementLearner: ReinforcementLearningAgent?

    func connectSystems(predictive: PredictiveGameStateAnalyzer,
                       content: DynamicContentGenerator,
                       emotion: EmotionRecognitionSystem,
                       reinforcement: ReinforcementLearningAgent) {
        self.predictiveAnalyzer = predictive
        self.contentGenerator = content
        self.emotionAnalyzer = emotion
        self.reinforcementLearner = reinforcement
    }

    func updateContext(_ context: GameContext) {
        // Coordinate context updates across all AI systems
        // This would trigger coordinated analysis and adaptation
    }
}

// MARK: - Data Structures

struct GameStateSnapshot {
    let score: Int
    let difficultyLevel: Int
    let obstacleCount: Int
    let collisionCount: Int
    let sessionTime: TimeInterval
    let timestamp: Date

    init(from context: GameContext, timestamp: Date) {
        self.score = context.currentScore
        self.difficultyLevel = context.difficultyLevel
        self.obstacleCount = context.obstacles.count
        self.collisionCount = 0 // Would be calculated from context
        self.sessionTime = context.sessionTime
        self.timestamp = timestamp
    }
}

struct PredictiveAnalysisData {
    let difficultyAdjustments: [DifficultyAdjustment]
    let contentSuggestions: [ContentSuggestion]
    let performanceOptimizations: [String]
}

struct PatternAnalysis {
    let scoreTrend: Double
    let difficultyTrend: Double
    let obstacleTrend: Double
    let riskPatterns: RiskPattern
    let engagementPatterns: EngagementPattern

    static let empty = PatternAnalysis(
        scoreTrend: 0.0,
        difficultyTrend: 0.0,
        obstacleTrend: 0.0,
        riskPatterns: RiskPattern(collisionRate: 0.0, riskLevel: .conservative),
        engagementPatterns: EngagementPattern(averageSessionTime: 0.0, engagementLevel: .low)
    )
}

struct RiskPattern {
    let collisionRate: Double
    let riskLevel: RiskLevel
}

struct EngagementPattern {
    let averageSessionTime: TimeInterval
    let engagementLevel: EngagementLevel
}

struct ContentSuggestion {
    let type: SuggestionType
    let priority: Priority
    let reason: String

    var description: String {
        "\(priority.rawValue) priority: \(type.rawValue) - \(reason)"
    }

    enum SuggestionType: String {
        case powerUpIncrease, obstacleVariety, visualEnhancement
    }

    enum Priority: String {
        case low, medium, high
    }
}

struct PerformanceOptimization {
    let type: String
    let target: String
    let expectedImprovement: Double
}

struct ObstacleModification {
    let type: ModificationType
    let value: Double
    let reason: String

    var description: String {
        "\(type.rawValue): \(String(format: "%.1f", value))x - \(reason)"
    }

    enum ModificationType: String {
        case spacingIncrease, complexityIncrease, speedIncrease
    }
}

struct PowerUpAdjustment {
    let type: AdjustmentType
    let value: Double
    let reason: String

    var description: String {
        "\(type.rawValue): \(String(format: "%.1f", value)) - \(reason)"
    }

    enum AdjustmentType: String {
        case frequencyIncrease, frequencyDecrease
    }
}

struct VisualEnhancement {
    let type: EnhancementType
    let intensity: Double
    let reason: String

    var description: String {
        "\(type.rawValue): \(String(format: "%.1f", intensity)) - \(reason)"
    }

    enum EnhancementType: String {
        case particleIncrease, effectIntensity
    }
}

struct AudioAdjustment {
    let type: AdjustmentType
    let value: Double
    let reason: String

    var description: String {
        "\(type.rawValue): \(String(format: "%.1f", value)) - \(reason)"
    }

    enum AdjustmentType: String {
        case intensityIncrease, intensityDecrease
    }
}

enum PlayerEmotion {
    case frustrated, excited, bored
}

struct BehavioralAdaptation {
    let type: AdaptationType
    let action: String
    let strength: Double
    let reason: String

    enum AdaptationType {
        case encourageAction, discourageAction
    }
}

struct LearnedAction {
    let action: String
    let value: Double
}

struct ReinforcementInsights {
    let learnedPatterns: [LearnedAction]
    let behavioralAdaptations: [BehavioralAdaptation]
    let confidence: Double
}

struct GeneratedContent {
    let package: DynamicContentPackage
    let profile: PlayerProfile
    let timestamp: Date
}

struct EmotionPatterns {
    // Would contain emotion detection patterns
}

enum InteractionOutcome {
    case success, collision, powerUp, neutral
}

struct ObstacleData {
    let position: CGPoint
    let type: String
    let speed: Double
}

struct PowerUpData {
    let position: CGPoint
    let type: PowerUpType
    let duration: TimeInterval
}

struct ContentTemplates {
    // Would contain templates for dynamic content generation
}