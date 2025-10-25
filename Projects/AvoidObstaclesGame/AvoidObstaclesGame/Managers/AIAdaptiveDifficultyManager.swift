//
// AIAdaptiveDifficultyManager.swift
// AvoidObstaclesGame
//
// AI-powered adaptive difficulty system that analyzes player behavior
// and adjusts game difficulty in real-time using machine learning.
//

import Combine
import CoreML
import Foundation

/// Protocol for AI adaptive difficulty events
protocol AIAdaptiveDifficultyDelegate: AnyObject {
    func difficultyDidAdjust(to newDifficulty: AIAdaptiveDifficulty, reason: DifficultyAdjustmentReason) async
    func playerSkillAssessed(skillLevel: PlayerSkillLevel, confidence: Double) async
}

/// AI-powered adaptive difficulty management system
class AIAdaptiveDifficultyManager: @unchecked Sendable {
    // MARK: - Properties

    /// Delegate for difficulty adjustment events
    weak var delegate: AIAdaptiveDifficultyDelegate?

    /// Current adaptive difficulty settings
    private(set) var currentDifficulty: AIAdaptiveDifficulty

    /// Player behavior analyzer
    private let behaviorAnalyzer: PlayerBehaviorAnalyzer

    /// Difficulty adjustment engine
    private let adjustmentEngine: DifficultyAdjustmentEngine

    /// Performance monitor
    private let performanceMonitor: AIDifficultyPerformanceMonitor

    /// Ollama integration for advanced AI analysis
    private let ollamaManager: OllamaIntegrationManager

    /// Current game session data
    var sessionData: GameSessionData

    /// Timer for periodic analysis
    private var analysisTimer: Timer?

    /// Analysis interval in seconds
    private let analysisInterval: TimeInterval = 2.0

    /// Minimum confidence threshold for adjustments
    private let minConfidenceThreshold: Double = 0.7

    /// Publisher for AI performance metrics
    let aiPerformancePublisher = PassthroughSubject<AIPerformanceData, Never>()

    // MARK: - Initialization

    init(ollamaManager: OllamaIntegrationManager? = nil) {
        if let ollamaManager {
            self.ollamaManager = ollamaManager
        } else {
            self.ollamaManager = OllamaIntegrationManager()
        }
        self.behaviorAnalyzer = PlayerBehaviorAnalyzer()
        self.adjustmentEngine = DifficultyAdjustmentEngine()
        self.performanceMonitor = AIDifficultyPerformanceMonitor()
        self.sessionData = GameSessionData()

        // Start with balanced difficulty
        self.currentDifficulty = AIAdaptiveDifficulty.balanced

        setupPeriodicAnalysis()
    }

    // MARK: - Public Interface

    /// Records a player action for analysis
    /// - Parameters:
    ///   - action: The player action performed
    ///   - timestamp: When the action occurred
    ///   - context: Additional context about the action
    func recordPlayerAction(_ action: PlayerAction, timestamp: Date = Date(), context: ActionContext? = nil) {
        let actionData = PlayerActionData(action: action, timestamp: timestamp, context: context)
        sessionData.actions.append(actionData)

        // Real-time analysis for immediate adjustments
        analyzeAndAdjustIfNeeded()
    }

    /// Records game state changes
    /// - Parameter state: The new game state
    func recordGameState(_ state: GameState) {
        sessionData.currentState = state
        sessionData.stateHistory.append((state, Date()))
    }

    /// Records obstacle interaction
    /// - Parameters:
    ///   - obstacleType: Type of obstacle encountered
    ///   - success: Whether the player successfully avoided it
    ///   - reactionTime: How long it took to react
    func recordObstacleInteraction(obstacleType: Obstacle.ObstacleType, success: Bool, reactionTime: TimeInterval) {
        let interaction = ObstacleInteraction(
            obstacleType: obstacleType,
            success: success,
            reactionTime: reactionTime,
            timestamp: Date()
        )
        sessionData.obstacleInteractions.append(interaction)
    }

    /// Gets the current difficulty settings as GameDifficulty
    /// - Returns: GameDifficulty compatible settings
    func getCurrentGameDifficulty() -> GameDifficulty {
        currentDifficulty.toGameDifficulty()
    }

    /// Manually triggers difficulty analysis and adjustment
    func forceDifficultyAnalysis() {
        analyzeAndAdjustIfNeeded()
    }

    /// Resets the session data and difficulty
    func resetSession() {
        sessionData = GameSessionData()
        currentDifficulty = .balanced
        behaviorAnalyzer.reset()
        adjustmentEngine.reset()
    }

    // MARK: - Private Methods

    private func setupPeriodicAnalysis() {
        analysisTimer = Timer.scheduledTimer(withTimeInterval: analysisInterval, repeats: true) { [weak self] _ in
            self?.analyzeAndAdjustIfNeeded()
        }
    }

    private func analyzeAndAdjustIfNeeded() {
        Task {
            do {
                // Analyze player behavior
                let analysis = try await behaviorAnalyzer.analyzeBehavior(sessionData: sessionData)

                // Get AI insights from Ollama
                let aiInsights = try await getAIInsights(for: analysis)

                // Calculate optimal difficulty
                let optimalDifficulty = adjustmentEngine.calculateOptimalDifficulty(
                    analysis: analysis,
                    aiInsights: aiInsights,
                    currentDifficulty: currentDifficulty
                )

                // Check if adjustment is needed
                if shouldAdjustDifficulty(from: currentDifficulty, to: optimalDifficulty) {
                    await applyDifficultyAdjustment(to: optimalDifficulty, reason: analysis.primaryReason)
                }

                // Update performance metrics
                performanceMonitor.recordAnalysis(success: true, duration: Date().timeIntervalSince(analysis.startTime))

            } catch {
                print("AI Difficulty Analysis Error: \(error.localizedDescription)")
                performanceMonitor.recordAnalysis(success: false, duration: 0)
            }
        }
    }

    private func getAIInsights(for analysis: PlayerBehaviorAnalysis) async throws -> AIInsights {
        let prompt = """
        Analyze this player behavior data and provide insights for game difficulty adjustment:

        Player Statistics:
        - Success Rate: \(String(format: "%.2f", analysis.successRate))%
        - Average Reaction Time: \(String(format: "%.2f", analysis.averageReactionTime))s
        - Risk Taking: \(analysis.riskTakingLevel.description)
        - Consistency: \(analysis.consistencyLevel.description)
        - Fatigue Indicators: \(analysis.fatigueIndicators.count)

        Recent Actions: \(analysis.recentActions.map(\.action.description).joined(separator: ", "))

        Provide a JSON response with:
        {
            "recommended_difficulty": "easy|normal|hard|expert",
            "confidence": 0.0-1.0,
            "reasoning": "brief explanation",
            "adjustments": ["specific suggestions"]
        }
        """

        let response = try await ollamaManager.generateText(
            prompt: prompt,
            maxTokens: 300,
            temperature: 0.3
        )

        return try parseAIInsights(from: response)
    }

    private func parseAIInsights(from response: String) throws -> AIInsights {
        // Simple JSON parsing - in production, use proper JSON parsing
        let recommendedDifficulty = extractValue(from: response, key: "recommended_difficulty") ?? "normal"
        let confidenceString = extractValue(from: response, key: "confidence") ?? "0.5"
        let confidence = Double(confidenceString) ?? 0.5
        let reasoning = extractValue(from: response, key: "reasoning") ?? "AI analysis"

        return AIInsights(
            recommendedDifficulty: AIAdaptiveDifficulty.fromString(recommendedDifficulty),
            confidence: confidence,
            reasoning: reasoning,
            adjustments: []
        )
    }

    private func extractValue(from jsonString: String, key: String) -> String? {
        let pattern = "\"\(key)\"\\s*:\\s*\"([^\"]+)\""
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: jsonString.utf16.count)
        if let match = regex?.firstMatch(in: jsonString, options: [], range: range) {
            if let valueRange = Range(match.range(at: 1), in: jsonString) {
                return String(jsonString[valueRange])
            }
        }
        return nil
    }

    private func shouldAdjustDifficulty(from current: AIAdaptiveDifficulty, to optimal: AIAdaptiveDifficulty) -> Bool {
        // Only adjust if confidence is high enough and difficulty levels are different
        guard current != optimal else { return false }

        let confidence = adjustmentEngine.getLastAdjustmentConfidence()
        return confidence >= minConfidenceThreshold
    }

    private func applyDifficultyAdjustment(to newDifficulty: AIAdaptiveDifficulty, reason: DifficultyAdjustmentReason) async {
        let oldDifficulty = currentDifficulty
        currentDifficulty = newDifficulty

        // Notify delegate
        Task { @MainActor in
            await delegate?.difficultyDidAdjust(to: newDifficulty, reason: reason)
        }

        // Log the adjustment
        print("AI Difficulty Adjusted: \(oldDifficulty.description) → \(newDifficulty.description) (Reason: \(reason.description))")
    }

    /// Stops the periodic analysis timer (for testing)
    func stopPeriodicAnalysis() {
        analysisTimer?.invalidate()
        analysisTimer = nil
    }
}

// MARK: - Supporting Types

/// AI-powered adaptive difficulty levels
enum AIAdaptiveDifficulty: String, Codable {
    case veryEasy = "very_easy"
    case easy
    case balanced
    case challenging
    case hard
    case veryHard = "very_hard"
    case expert
    case nightmare

    var description: String {
        switch self {
        case .veryEasy: return "Very Easy"
        case .easy: return "Easy"
        case .balanced: return "Balanced"
        case .challenging: return "Challenging"
        case .hard: return "Hard"
        case .veryHard: return "Very Hard"
        case .expert: return "Expert"
        case .nightmare: return "Nightmare"
        }
    }

    static func fromString(_ string: String) -> AIAdaptiveDifficulty {
        switch string.lowercased() {
        case "very_easy", "very easy": return .veryEasy
        case "easy": return .easy
        case "balanced", "normal": return .balanced
        case "challenging": return .challenging
        case "hard": return .hard
        case "very_hard", "very hard": return .veryHard
        case "expert": return .expert
        case "nightmare": return .nightmare
        default: return .balanced
        }
    }

    func toGameDifficulty() -> GameDifficulty {
        switch self {
        case .veryEasy:
            return GameDifficulty(spawnInterval: 1.5, obstacleSpeed: 2.0, scoreMultiplier: 0.8, powerUpSpawnChance: 0.1)
        case .easy:
            return GameDifficulty(spawnInterval: 1.3, obstacleSpeed: 2.5, scoreMultiplier: 0.9, powerUpSpawnChance: 0.08)
        case .balanced:
            return GameDifficulty(spawnInterval: 1.0, obstacleSpeed: 3.0, scoreMultiplier: 1.0, powerUpSpawnChance: 0.05)
        case .challenging:
            return GameDifficulty(spawnInterval: 0.8, obstacleSpeed: 3.5, scoreMultiplier: 1.3, powerUpSpawnChance: 0.04)
        case .hard:
            return GameDifficulty(spawnInterval: 0.6, obstacleSpeed: 4.0, scoreMultiplier: 1.6, powerUpSpawnChance: 0.03)
        case .veryHard:
            return GameDifficulty(spawnInterval: 0.5, obstacleSpeed: 4.5, scoreMultiplier: 2.0, powerUpSpawnChance: 0.02)
        case .expert:
            return GameDifficulty(spawnInterval: 0.4, obstacleSpeed: 5.0, scoreMultiplier: 2.5, powerUpSpawnChance: 0.01)
        case .nightmare:
            return GameDifficulty(spawnInterval: 0.3, obstacleSpeed: 6.0, scoreMultiplier: 3.0, powerUpSpawnChance: 0.005)
        }
    }
}

/// Reasons for difficulty adjustments
enum DifficultyAdjustmentReason {
    case playerStruggling
    case playerExcelling
    case fatigueDetected
    case learningNewPatterns
    case riskTakingAdjustment
    case consistencyImprovement
    case aiRecommendation

    var description: String {
        switch self {
        case .playerStruggling: return "Player struggling with current difficulty"
        case .playerExcelling: return "Player performing exceptionally well"
        case .fatigueDetected: return "Player fatigue detected"
        case .learningNewPatterns: return "Player learning new movement patterns"
        case .riskTakingAdjustment: return "Adjusting for risk-taking behavior"
        case .consistencyImprovement: return "Improving consistency in performance"
        case .aiRecommendation: return "AI analysis recommendation"
        }
    }
}

/// Player skill assessment levels
public enum PlayerSkillLevel: String, Codable, Sendable {
    case beginner
    case novice
    case intermediate
    case advanced
    case expert
    case master

    var description: String {
        switch self {
        case .beginner: return "Beginner"
        case .novice: return "Novice"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        case .master: return "Master"
        }
    }

    var level: Int {
        switch self {
        case .beginner: return 0
        case .novice: return 1
        case .intermediate: return 2
        case .advanced: return 3
        case .expert: return 4
        case .master: return 5
        }
    }

    static func < (lhs: PlayerSkillLevel, rhs: PlayerSkillLevel) -> Bool {
        lhs.level < rhs.level
    }
}

// MARK: - Supporting Classes

/// Analyzes player behavior patterns
class PlayerBehaviorAnalyzer {
    private var analysisHistory: [PlayerBehaviorAnalysis] = []
    private let behaviorPredictor: PlayerBehaviorPredictor

    init() {
        self.behaviorPredictor = PlayerBehaviorPredictor()
    }

    func analyzeBehavior(sessionData: GameSessionData) async throws -> PlayerBehaviorAnalysis {
        let startTime = Date()

        // Calculate success rate
        let totalInteractions = sessionData.obstacleInteractions.count
        let successfulInteractions = sessionData.obstacleInteractions.filter(\.success).count
        let successRate = totalInteractions > 0 ? Double(successfulInteractions) / Double(totalInteractions) : 0.0

        // Calculate average reaction time
        let reactionTimes = sessionData.obstacleInteractions.map(\.reactionTime)
        let averageReactionTime = reactionTimes.isEmpty ? 0.0 : reactionTimes.reduce(0, +) / Double(reactionTimes.count)

        // Analyze risk taking
        let riskTakingLevel = analyzeRiskTaking(sessionData: sessionData)

        // Analyze consistency
        let consistencyLevel = analyzeConsistency(sessionData: sessionData)

        // Detect fatigue indicators
        let fatigueIndicators = detectFatigue(sessionData: sessionData)

        // Get recent actions
        let recentActions = sessionData.actions.suffix(10)

        // Generate behavior predictions
        let predictions = try await behaviorPredictor.predictNextActions(
            sessionData: sessionData,
            recentActions: Array(recentActions)
        )

        // Determine primary adjustment reason
        let primaryReason = determineAdjustmentReason(
            successRate: successRate,
            averageReactionTime: averageReactionTime,
            riskTakingLevel: riskTakingLevel,
            consistencyLevel: consistencyLevel,
            fatigueIndicators: fatigueIndicators,
            predictions: predictions
        )

        let analysis = PlayerBehaviorAnalysis(
            successRate: successRate,
            averageReactionTime: averageReactionTime,
            riskTakingLevel: riskTakingLevel,
            consistencyLevel: consistencyLevel,
            fatigueIndicators: fatigueIndicators,
            recentActions: Array(recentActions),
            predictions: predictions,
            primaryReason: primaryReason,
            startTime: startTime
        )

        analysisHistory.append(analysis)
        return analysis
    }

    private func analyzeRiskTaking(sessionData: GameSessionData) -> RiskLevel {
        // Analyze how often player takes risks (close calls, etc.)
        let riskyActions = sessionData.actions.filter { action in
            switch action.action {
            case .nearMiss, .lastSecondDodge: return true
            default: return false
            }
        }

        let riskRatio = Double(riskyActions.count) / Double(max(sessionData.actions.count, 1))

        switch riskRatio {
        case 0.0 ..< 0.1: return .conservative
        case 0.1 ..< 0.3: return .moderate
        case 0.3 ..< 0.6: return .adventurous
        default: return .reckless
        }
    }

    private func analyzeConsistency(sessionData: GameSessionData) -> ConsistencyLevel {
        // Analyze performance consistency over time
        let recentInteractions = sessionData.obstacleInteractions.suffix(20)
        if recentInteractions.count < 5 { return .unknown }

        let successRates = stride(from: 0, to: recentInteractions.count, by: 4).map { startIndex in
            let endIndex = min(startIndex + 4, recentInteractions.count)
            let slice = recentInteractions[startIndex ..< endIndex]
            let successCount = slice.filter(\.success).count
            return Double(successCount) / Double(slice.count)
        }

        if successRates.isEmpty { return .unknown }

        let variance = successRates.map { pow($0 - successRates.average, 2) }.average
        let standardDeviation = sqrt(variance)

        switch standardDeviation {
        case 0.0 ..< 0.1: return .veryConsistent
        case 0.1 ..< 0.2: return .consistent
        case 0.2 ..< 0.3: return .moderate
        case 0.3 ..< 0.4: return .inconsistent
        default: return .veryInconsistent
        }
    }

    private func detectFatigue(sessionData: GameSessionData) -> [FatigueIndicator] {
        var indicators: [FatigueIndicator] = []

        // Check for declining performance
        let recentInteractions = Array(sessionData.obstacleInteractions.suffix(10))
        if recentInteractions.count >= 5 {
            let firstHalf = recentInteractions.prefix(recentInteractions.count / 2)
            let secondHalf = recentInteractions.suffix(recentInteractions.count / 2)

            let firstHalfSuccess = Double(firstHalf.filter(\.success).count) / Double(firstHalf.count)
            let secondHalfSuccess = Double(secondHalf.filter(\.success).count) / Double(secondHalf.count)

            if secondHalfSuccess < firstHalfSuccess - 0.2 {
                indicators.append(.decliningPerformance)
            }
        }

        // Check for slower reaction times
        let reactionTimes = sessionData.obstacleInteractions.map(\.reactionTime)
        if reactionTimes.count >= 10 {
            let recent = reactionTimes.suffix(5).average
            let earlier = Array(reactionTimes.prefix(5)).average

            if recent > earlier + 0.2 {
                indicators.append(.slowerReactions)
            }
        }

        return indicators
    }

    private func determineAdjustmentReason(
        successRate: Double,
        averageReactionTime: TimeInterval,
        riskTakingLevel: RiskLevel,
        consistencyLevel: ConsistencyLevel,
        fatigueIndicators: [FatigueIndicator],
        predictions: PlayerBehaviorPredictions
    ) -> DifficultyAdjustmentReason {
        // Fatigue takes priority
        if !fatigueIndicators.isEmpty {
            return .fatigueDetected
        }

        // Consider predictions for proactive adjustments
        if predictions.confidence > 0.7 {
            // If predicting risky behavior, adjust for safety
            if predictions.riskAssessment == .reckless && successRate < 0.6 {
                return .riskTakingAdjustment
            }

            // If predicting methodical play, allow for learning
            if predictions.patternRecognition.contains(.methodical) && consistencyLevel == .veryConsistent {
                return .learningNewPatterns
            }
        }

        // Struggling player
        if successRate < 0.3 {
            return .playerStruggling
        }

        // Excelling player
        if successRate > 0.9 && averageReactionTime < 0.5 {
            return .playerExcelling
        }

        // Risk adjustment
        if riskTakingLevel == .reckless && successRate < 0.5 {
            return .riskTakingAdjustment
        }

        // Consistency improvement
        if consistencyLevel == .veryInconsistent {
            return .consistencyImprovement
        }

        return .aiRecommendation
    }

    func reset() {
        analysisHistory.removeAll()
    }
}

/// Calculates optimal difficulty adjustments
class DifficultyAdjustmentEngine {
    private var lastAdjustmentConfidence: Double = 0.0

    func calculateOptimalDifficulty(
        analysis: PlayerBehaviorAnalysis,
        aiInsights: AIInsights,
        currentDifficulty: AIAdaptiveDifficulty
    ) -> AIAdaptiveDifficulty {
        // Weight different factors
        let successWeight = 0.3
        let reactionWeight = 0.25
        let predictionWeight = 0.25
        let aiWeight = 0.2

        // Calculate difficulty score based on performance
        var difficultyScore = 0.0

        // Success rate contribution (lower success = easier difficulty)
        difficultyScore += (1.0 - analysis.successRate) * successWeight

        // Reaction time contribution (slower reactions = easier difficulty)
        let normalizedReactionTime = min(analysis.averageReactionTime / 2.0, 1.0) // Cap at 2 seconds
        difficultyScore += normalizedReactionTime * reactionWeight

        // Prediction-based adjustments
        let predictionAdjustment = calculatePredictionAdjustment(predictions: analysis.predictions)
        difficultyScore += predictionAdjustment * predictionWeight

        // AI insights contribution
        let aiDifficultyScore = difficultyScoreFromAI(aiInsights.recommendedDifficulty)
        difficultyScore += aiDifficultyScore * aiWeight

        // Calculate confidence
        lastAdjustmentConfidence = calculateConfidence(analysis: analysis, aiInsights: aiInsights)

        // Convert score to difficulty level
        return difficultyFromScore(difficultyScore)
    }

    private func calculatePredictionAdjustment(predictions: PlayerBehaviorPredictions) -> Double {
        var adjustment = 0.0

        // Adjust based on predicted risk level
        switch predictions.riskAssessment {
        case .conservative:
            adjustment += 0.2 // Make slightly easier for conservative players
        case .moderate:
            adjustment += 0.0 // No adjustment
        case .adventurous:
            adjustment -= 0.1 // Make slightly harder for adventurous players
        case .reckless:
            adjustment -= 0.2 // Make significantly harder for reckless players
        }

        // Adjust based on pattern recognition
        for pattern in predictions.patternRecognition {
            switch pattern {
            case .hesitant:
                adjustment += 0.15 // Easier for hesitant players
            case .aggressive:
                adjustment -= 0.1 // Harder for aggressive players
            case .methodical:
                adjustment += 0.05 // Slightly easier for methodical players
            case .chaotic:
                adjustment -= 0.05 // Slightly harder for chaotic players
            }
        }

        // Scale by confidence
        return adjustment * predictions.confidence
    }

    private func difficultyScoreFromAI(_ difficulty: AIAdaptiveDifficulty) -> Double {
        switch difficulty {
        case .veryEasy: return 0.0
        case .easy: return 0.2
        case .balanced: return 0.5
        case .challenging: return 0.7
        case .hard: return 0.8
        case .veryHard: return 0.9
        case .expert: return 0.95
        case .nightmare: return 1.0
        }
    }

    private func calculateConfidence(analysis: PlayerBehaviorAnalysis, aiInsights: AIInsights) -> Double {
        // Base confidence from data quality
        var confidence = 0.5

        // More data = higher confidence
        if analysis.recentActions.count > 20 {
            confidence += 0.2
        } else if analysis.recentActions.count > 10 {
            confidence += 0.1
        }

        // AI confidence contribution
        confidence += aiInsights.confidence * 0.3

        return min(confidence, 1.0)
    }

    private func difficultyFromScore(_ score: Double) -> AIAdaptiveDifficulty {
        switch score {
        case 0.0 ..< 0.15: return .veryEasy
        case 0.15 ..< 0.3: return .easy
        case 0.3 ..< 0.45: return .balanced
        case 0.45 ..< 0.6: return .challenging
        case 0.6 ..< 0.75: return .hard
        case 0.75 ..< 0.85: return .veryHard
        case 0.85 ..< 0.95: return .expert
        default: return .nightmare
        }
    }

    func getLastAdjustmentConfidence() -> Double {
        lastAdjustmentConfidence
    }

    func calculateFallbackAdjustment(for skillLevel: PlayerSkillLevel) -> AIAdaptiveDifficulty {
        // Provide fallback difficulty based on skill level
        switch skillLevel {
        case .beginner, .novice:
            return .easy
        case .intermediate:
            return .balanced
        case .advanced:
            return .challenging
        case .expert:
            return .hard
        case .master:
            return .veryHard
        }
    }

    func reset() {
        lastAdjustmentConfidence = 0.0
    }
}

/// Performance monitoring for AI difficulty system
class AIDifficultyPerformanceMonitor {
    private var analysisCount = 0
    private var successfulAnalyses = 0
    private var totalAnalysisTime: TimeInterval = 0
    private var adjustmentCount = 0

    func recordAnalysis(success: Bool, duration: TimeInterval) {
        analysisCount += 1
        if success {
            successfulAnalyses += 1
        }
        totalAnalysisTime += duration
    }

    func recordAdjustment() {
        adjustmentCount += 1
    }

    func getMetrics() -> AIDifficultyMetrics {
        let successRate = analysisCount > 0 ? Double(successfulAnalyses) / Double(analysisCount) : 0.0
        let averageAnalysisTime = analysisCount > 0 ? totalAnalysisTime / Double(analysisCount) : 0.0

        return AIDifficultyMetrics(
            totalAnalyses: analysisCount,
            successRate: successRate,
            averageAnalysisTime: averageAnalysisTime,
            totalAdjustments: adjustmentCount
        )
    }
}

/// ML-based player behavior prediction system
class PlayerBehaviorPredictor {
    private var predictionModel: BehaviorPredictionModel
    private var historicalPatterns: [BehaviorPattern] = []
    private let maxPatterns = 100

    init() {
        self.predictionModel = BehaviorPredictionModel()
    }

    func predictNextActions(sessionData: GameSessionData, recentActions: [PlayerActionData]) async throws -> PlayerBehaviorPredictions {
        // Extract features from session data
        let features = extractFeatures(from: sessionData, recentActions: recentActions)

        // Update historical patterns
        updateHistoricalPatterns(with: features)

        // Generate predictions using ML model
        let predictions = try await predictionModel.predict(features: features)

        // Calculate confidence based on pattern matching
        let confidence = calculatePredictionConfidence(predictions: predictions, features: features)

        return PlayerBehaviorPredictions(
            predictedActions: predictions.nextActions,
            confidence: confidence,
            timeHorizon: predictions.timeHorizon,
            riskAssessment: predictions.riskAssessment,
            patternRecognition: identifyPatterns(in: features)
        )
    }

    private func extractFeatures(from sessionData: GameSessionData, recentActions: [PlayerActionData]) -> BehaviorFeatures {
        // Movement patterns
        let movementFrequency = calculateMovementFrequency(actions: recentActions)
        let directionalBias = calculateDirectionalBias(actions: recentActions)

        // Reaction patterns
        let averageReactionTime = sessionData.obstacleInteractions.map(\.reactionTime).average
        let successRate = Double(sessionData.obstacleInteractions.filter(\.success).count) / Double(max(sessionData.obstacleInteractions.count, 1))

        // Risk patterns
        let riskActions = recentActions.filter { action in
            switch action.action {
            case .nearMiss, .lastSecondDodge: return true
            default: return false
            }
        }
        let riskRatio = Double(riskActions.count) / Double(max(recentActions.count, 1))

        // Timing patterns
        let actionIntervals = calculateActionIntervals(actions: recentActions)
        let rhythmConsistency = calculateRhythmConsistency(intervals: actionIntervals)

        return BehaviorFeatures(
            movementFrequency: movementFrequency,
            directionalBias: directionalBias,
            averageReactionTime: averageReactionTime,
            successRate: successRate,
            riskRatio: riskRatio,
            actionIntervals: actionIntervals,
            rhythmConsistency: rhythmConsistency,
            sessionDuration: Date().timeIntervalSince(sessionData.startTime)
        )
    }

    private func calculateMovementFrequency(actions: [PlayerActionData]) -> Double {
        let timeSpan = actions.last?.timestamp.timeIntervalSince(actions.first?.timestamp ?? Date()) ?? 1.0
        return Double(actions.count) / max(timeSpan, 1.0)
    }

    private func calculateDirectionalBias(actions: [PlayerActionData]) -> Double {
        let leftMoves = actions.filter { $0.action == .moveLeft }.count
        let rightMoves = actions.filter { $0.action == .moveRight }.count
        let totalMoves = leftMoves + rightMoves
        return totalMoves > 0 ? Double(rightMoves - leftMoves) / Double(totalMoves) : 0.0
    }

    private func calculateActionIntervals(actions: [PlayerActionData]) -> [TimeInterval] {
        guard actions.count > 1 else { return [] }
        var intervals: [TimeInterval] = []
        for i in 1 ..< actions.count {
            let interval = actions[i].timestamp.timeIntervalSince(actions[i - 1].timestamp)
            intervals.append(interval)
        }
        return intervals
    }

    private func calculateRhythmConsistency(intervals: [TimeInterval]) -> Double {
        guard intervals.count > 1 else { return 0.0 }
        let mean = intervals.average
        let variance = intervals.map { pow($0 - mean, 2) }.average
        let standardDeviation = sqrt(variance)
        return 1.0 / (1.0 + standardDeviation) // Higher consistency = lower variance
    }

    private func updateHistoricalPatterns(with features: BehaviorFeatures) {
        let pattern = BehaviorPattern(
            features: features,
            timestamp: Date(),
            sessionContext: SessionContext()
        )

        historicalPatterns.append(pattern)
        if historicalPatterns.count > maxPatterns {
            historicalPatterns.removeFirst()
        }
    }

    private func calculatePredictionConfidence(predictions: MLActionPredictions, features: BehaviorFeatures) -> Double {
        var confidence = predictions.confidence

        // Boost confidence based on pattern matching
        let similarPatterns = historicalPatterns.filter { pattern in
            pattern.features.similarity(to: features) > 0.8
        }

        if !similarPatterns.isEmpty {
            confidence += 0.2
        }

        // Reduce confidence for very new players
        if features.sessionDuration < 30.0 {
            confidence *= 0.7
        }

        return min(confidence, 1.0)
    }

    private func identifyPatterns(in features: BehaviorFeatures) -> [BehaviorPatternType] {
        var patterns: [BehaviorPatternType] = []

        // Hesitant player pattern
        if features.movementFrequency < 0.5 && features.averageReactionTime > 1.0 {
            patterns.append(.hesitant)
        }

        // Aggressive player pattern
        if features.riskRatio > 0.3 && features.movementFrequency > 2.0 {
            patterns.append(.aggressive)
        }

        // Methodical player pattern
        if features.rhythmConsistency > 0.8 && features.successRate > 0.8 {
            patterns.append(.methodical)
        }

        // Chaotic player pattern
        if features.rhythmConsistency < 0.3 && features.riskRatio > 0.4 {
            patterns.append(.chaotic)
        }

        return patterns
    }
}

/// Core ML model wrapper for behavior prediction
class BehaviorPredictionModel {
    func predict(features: BehaviorFeatures) async throws -> MLActionPredictions {
        // Simplified ML prediction logic (in production, this would use Core ML)
        // For now, implement basic pattern-based prediction

        let predictedActions = predictActionsBasedOnPatterns(features: features)
        let confidence = calculatePredictionConfidence(features: features)
        let timeHorizon = 2.0 // Predict 2 seconds ahead
        let riskAssessment = assessRiskLevel(features: features)

        return MLActionPredictions(
            nextActions: predictedActions,
            confidence: confidence,
            timeHorizon: timeHorizon,
            riskAssessment: riskAssessment
        )
    }

    private func predictActionsBasedOnPatterns(features: BehaviorFeatures) -> [PredictedAction] {
        var predictions: [PredictedAction] = []

        // Predict based on directional bias
        if abs(features.directionalBias) > 0.3 {
            let direction: PlayerAction = features.directionalBias > 0 ? .moveRight : .moveLeft
            predictions.append(PredictedAction(
                action: direction,
                probability: abs(features.directionalBias),
                timeOffset: 0.5
            ))
        }

        // Predict dodging behavior based on risk ratio
        if features.riskRatio > 0.2 {
            predictions.append(PredictedAction(
                action: .dodge,
                probability: features.riskRatio,
                timeOffset: 1.0
            ))
        }

        // Predict power-up collection based on success rate
        if features.successRate > 0.7 {
            predictions.append(PredictedAction(
                action: .powerUpCollected(type: .shield),
                probability: 0.3,
                timeOffset: 1.5
            ))
        }

        return predictions.sorted { $0.probability > $1.probability }
    }

    private func calculatePredictionConfidence(features: BehaviorFeatures) -> Double {
        // Base confidence on data quality and consistency
        var confidence = 0.5

        if features.sessionDuration > 60.0 {
            confidence += 0.2
        }

        if features.rhythmConsistency > 0.7 {
            confidence += 0.2
        }

        if features.successRate > 0.0 { // Has some interaction data
            confidence += 0.1
        }

        return min(confidence, 0.9)
    }

    private func assessRiskLevel(features: BehaviorFeatures) -> RiskLevel {
        let riskScore = features.riskRatio * 0.6 + (1.0 - features.successRate) * 0.4

        switch riskScore {
        case 0.0 ..< 0.2: return .conservative
        case 0.2 ..< 0.4: return .moderate
        case 0.4 ..< 0.7: return .adventurous
        default: return .reckless
        }
    }
}

struct AIDifficultyMetrics {
    let totalAnalyses: Int
    let successRate: Double
    let averageAnalysisTime: TimeInterval
    let totalAdjustments: Int
}

// MARK: - Prediction Data Structures

struct PlayerBehaviorPredictions {
    let predictedActions: [PredictedAction]
    let confidence: Double
    let timeHorizon: TimeInterval
    let riskAssessment: RiskLevel
    let patternRecognition: [BehaviorPatternType]
}

struct PredictedAction {
    let action: PlayerAction
    let probability: Double
    let timeOffset: TimeInterval
}

struct BehaviorFeatures {
    let movementFrequency: Double
    let directionalBias: Double
    let averageReactionTime: TimeInterval
    let successRate: Double
    let riskRatio: Double
    let actionIntervals: [TimeInterval]
    let rhythmConsistency: Double
    let sessionDuration: TimeInterval

    func similarity(to other: BehaviorFeatures) -> Double {
        // Calculate similarity score between two feature sets
        let movementDiff = abs(movementFrequency - other.movementFrequency) / max(movementFrequency, other.movementFrequency, 1.0)
        let biasDiff = abs(directionalBias - other.directionalBias)
        let reactionDiff = abs(averageReactionTime - other.averageReactionTime) / max(averageReactionTime, other.averageReactionTime, 1.0)
        let successDiff = abs(successRate - other.successRate)
        let riskDiff = abs(riskRatio - other.riskRatio)
        let rhythmDiff = abs(rhythmConsistency - other.rhythmConsistency)

        let totalDiff = movementDiff + biasDiff + reactionDiff + successDiff + riskDiff + rhythmDiff
        return 1.0 / (1.0 + totalDiff / 6.0) // Normalize to 0-1
    }
}

struct BehaviorPattern {
    let features: BehaviorFeatures
    let timestamp: Date
    let sessionContext: SessionContext
}

struct SessionContext {
    let gameState: GameState = .playing
    let currentScore: Int = 0
    let powerUpsActive: [PowerUpType] = []
}

struct MLActionPredictions {
    let nextActions: [PredictedAction]
    let confidence: Double
    let timeHorizon: TimeInterval
    let riskAssessment: RiskLevel
}

enum BehaviorPatternType {
    case hesitant
    case aggressive
    case methodical
    case chaotic

    var description: String {
        switch self {
        case .hesitant: return "Hesitant"
        case .aggressive: return "Aggressive"
        case .methodical: return "Methodical"
        case .chaotic: return "Chaotic"
        }
    }
}

/// AI performance data for analytics dashboard
struct AIPerformanceData {
    let predictionAccuracy: Double
    let adaptationRate: Double
    let learningProgress: Double
}
