//
//  AnalyticsManager.swift
//  AvoidObstaclesGame
//
//  Created by Daniel on 2025-01-19.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation
import SpriteKit

/// Advanced analytics manager for comprehensive player behavior tracking and performance metrics
@MainActor
final class AnalyticsManager: NSObject, Sendable {
    // MARK: - Singleton

    static let shared = AnalyticsManager()

    // MARK: - Properties

    private var sessionStartTime: Date?
    private var currentSessionData: SessionAnalytics = .empty
    private var playerBehaviorPatterns: [AnalyticsBehaviorPattern] = []
    private var performanceMetrics: AnalyticsPerformanceMetrics = .empty
    private var gameEvents: [TrackedEvent] = []
    private var heatMapData: HeatMapData = .empty

    // Analytics configuration
    private let maxStoredSessions = 100
    private let analyticsUpdateInterval: TimeInterval = 5.0 // 5 seconds
    private var analyticsTimer: Timer?

    // MARK: - Initialization

    override private init() {
        super.init()
        setupAnalytics()
    }

    @MainActor
    deinit {
        analyticsTimer?.invalidate()
    }

    // MARK: - Setup

    private func setupAnalytics() {
        loadStoredAnalytics()
        startAnalyticsTimer()
    }

    private func startAnalyticsTimer() {
        analyticsTimer = Timer.scheduledTimer(withTimeInterval: analyticsUpdateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateAnalytics()
            }
        }
    }

    // MARK: - Session Management

    func startSession() {
        sessionStartTime = Date()
        currentSessionData = SessionAnalytics(
            sessionId: UUID().uuidString,
            startTime: Date(),
            playerId: getPlayerId(),
            deviceInfo: getDeviceInfo(),
            gameVersion: getGameVersion()
        )

        // Track session start event
        trackEvent(.sessionStart, parameters: ["session_id": currentSessionData.sessionId])
    }

    func endSession() {
        guard let startTime = sessionStartTime else { return }

        currentSessionData.endTime = Date()
        currentSessionData.duration = Date().timeIntervalSince(startTime)
        currentSessionData.totalScore = 0 // Placeholder - would get from GameStateManager
        currentSessionData.levelsCompleted = 0 // Placeholder - would get from GameStateManager
        currentSessionData.powerUpsUsed = 0 // Placeholder - would get from GameStateManager
        currentSessionData.deaths = 0 // Placeholder - would get from GameStateManager

        // Calculate engagement metrics
        currentSessionData.engagementScore = calculateEngagementScore()
        currentSessionData.skillProgression = calculateSkillProgression()

        // Track session end event
        trackEvent(.sessionEnd, parameters: [
            "duration": String(currentSessionData.duration),
            "score": String(currentSessionData.totalScore),
            "levels_completed": String(currentSessionData.levelsCompleted),
        ])

        // Store session data
        storeSessionData(currentSessionData)

        // Reset for next session
        sessionStartTime = nil
        currentSessionData = .empty
    }

    // MARK: - Event Tracking

    func trackEvent(_ event: AnalyticsEvent, parameters: [String: String] = [:]) {
        let gameEvent = TrackedEvent(
            eventId: UUID().uuidString,
            eventType: event,
            timestamp: Date(),
            parameters: parameters,
            sessionId: currentSessionData.sessionId,
            playerPosition: getCurrentPlayerPosition(),
            gameState: getCurrentGameState()
        )

        gameEvents.append(gameEvent)

        // Process event for real-time analytics
        processEvent(gameEvent)

        // Limit stored events to prevent memory issues
        if gameEvents.count > 1000 {
            gameEvents.removeFirst(100)
        }
    }

    // MARK: - Player Behavior Analysis

    func analyzePlayerBehavior() -> AnalyticsBehaviorAnalysis {
        let recentEvents = gameEvents.suffix(100)
        let sessionHistory = getStoredSessions().suffix(10)

        return AnalyticsBehaviorAnalysis(
            behaviorPatterns: analyzeBehaviorPatterns(recentEvents),
            skillLevel: assessPlayerSkill(recentEvents),
            engagementLevel: calculateEngagementLevel(sessionHistory),
            preferredGameModes: identifyPreferredGameModes(recentEvents),
            difficultyPreference: determineDifficultyPreference(sessionHistory),
            playStyle: classifyPlayStyle(recentEvents),
            retentionRisk: calculateRetentionRisk(sessionHistory),
            recommendations: generatePersonalizedRecommendations(recentEvents, sessionHistory)
        )
    }

    // MARK: - Performance Metrics

    func getPerformanceMetrics() -> AnalyticsPerformanceMetrics {
        AnalyticsPerformanceMetrics(
            averageFrameRate: calculateAverageFrameRate(),
            memoryUsage: getCurrentMemoryUsage(),
            batteryImpact: calculateBatteryImpact(),
            loadTimes: measureLoadTimes(),
            crashRate: calculateCrashRate(),
            sessionStability: calculateSessionStability()
        )
    }

    // MARK: - Heat Map Data

    func updateHeatMapData(position: CGPoint, action: AnalyticsPlayerAction) {
        heatMapData.updatePosition(position, action: action)
    }

    func getHeatMapData() -> HeatMapData {
        heatMapData
    }

    // MARK: - Real-time Analytics

    private func updateAnalytics() {
        // Update performance metrics
        performanceMetrics = getPerformanceMetrics()

        // Analyze current behavior patterns
        let analysis = analyzePlayerBehavior()

        // Generate insights
        _ = generateInsights(analysis, performanceMetrics)

        // Send to AI system for adaptive adjustments
        // TODO: Integrate with AIAdaptiveDifficultyManager when available

        // Store periodic analytics data
        storePeriodicAnalytics(analysis, performanceMetrics)
    }

    // MARK: - Data Persistence

    private func storeSessionData(_ session: SessionAnalytics) {
        var sessions = getStoredSessions()
        sessions.append(session)

        // Keep only recent sessions
        if sessions.count > maxStoredSessions {
            sessions.removeFirst(sessions.count - maxStoredSessions)
        }

        saveSessions(sessions)
    }

    private func storePeriodicAnalytics(_ analysis: AnalyticsBehaviorAnalysis, _ metrics: AnalyticsPerformanceMetrics) {
        let analyticsData = PeriodicAnalytics(
            timestamp: Date(),
            behaviorAnalysis: analysis,
            performanceMetrics: metrics,
            sessionId: currentSessionData.sessionId
        )

        var storedAnalytics = getStoredPeriodicAnalytics()
        storedAnalytics.append(analyticsData)

        // Keep only recent analytics (last 24 hours worth)
        let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        storedAnalytics = storedAnalytics.filter { $0.timestamp > oneDayAgo }

        savePeriodicAnalytics(storedAnalytics)
    }

    // MARK: - Helper Methods

    private func calculateEngagementScore() -> Double {
        let duration = currentSessionData.duration
        let score = Double(currentSessionData.totalScore)
        let levels = Double(currentSessionData.levelsCompleted)

        // Engagement score based on time spent, score achieved, and progress
        let timeScore = min(duration / 1800.0, 1.0) * 0.4 // Max 30 minutes = 40%
        let scoreScore = min(score / 10000.0, 1.0) * 0.4 // Max 10k score = 40%
        let levelScore = min(levels / 10.0, 1.0) * 0.2 // Max 10 levels = 20%

        return timeScore + scoreScore + levelScore
    }

    private func calculateSkillProgression() -> Double {
        // Calculate improvement over session
        let initialSkill = 0.5 // Base skill level
        let currentSkill = assessPlayerSkill(gameEvents.suffix(50))

        return max(0, currentSkill - initialSkill)
    }

    private func getPlayerId() -> String {
        if let playerId = UserDefaults.standard.string(forKey: "player_id") {
            return playerId
        } else {
            let newPlayerId = UUID().uuidString
            UserDefaults.standard.set(newPlayerId, forKey: "player_id")
            return newPlayerId
        }
    }

    private func getDeviceInfo() -> DeviceInfo {
        DeviceInfo(
            model: "iOS Device", // Placeholder - would use UIDevice in iOS app
            systemVersion: "iOS 17.0", // Placeholder - would use UIDevice in iOS app
            screenSize: CGSize(width: 375, height: 812) // Placeholder - would use UIScreen in iOS app
        )
    }

    private func getGameVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private func getCurrentPlayerPosition() -> CGPoint? {
        // Get player position from GameCoordinator
        return GameCoordinator.shared.getCurrentPlayerPosition()
    }

    private func getCurrentGameState() -> String {
        // Get game state from GameCoordinator
        return GameCoordinator.shared.getCurrentGameState()
    }

    // MARK: - Data Storage Keys

    private let sessionsKey = "stored_sessions"
    private let periodicAnalyticsKey = "periodic_analytics"
    private let behaviorPatternsKey = "behavior_patterns"

    private func getStoredSessions() -> [SessionAnalytics] {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey),
              let sessions = try? JSONDecoder().decode([SessionAnalytics].self, from: data)
        else {
            return []
        }
        return sessions
    }

    private func saveSessions(_ sessions: [SessionAnalytics]) {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
    }

    private func getStoredPeriodicAnalytics() -> [PeriodicAnalytics] {
        // Placeholder - would implement persistent storage
        []
    }

    private func savePeriodicAnalytics(_ analytics: [PeriodicAnalytics]) {
        // Placeholder - would implement persistent storage
    }

    private func loadStoredAnalytics() {
        // Load any previously stored analytics data
        _ = getStoredSessions()
        _ = getStoredPeriodicAnalytics()
    }

    // MARK: - Analysis Methods (Implementation)

    private func analyzeBehaviorPatterns(_ events: ArraySlice<TrackedEvent>) -> [AnalyticsBehaviorPattern] {
        var patterns: [AnalyticsBehaviorPattern] = []

        // Analyze movement patterns
        let movementEvents = events.filter { $0.eventType == .playerDeath || $0.eventType == .scoreUpdate }
        if !movementEvents.isEmpty {
            let movementPattern = AnalyticsBehaviorPattern(
                patternId: "movement_frequency",
                patternType: "movement",
                frequency: Double(movementEvents.count) / Double(max(1, events.count)),
                confidence: 0.8,
                description: "Player movement frequency analysis"
            )
            patterns.append(movementPattern)
        }

        // Analyze collision patterns
        let collisionEvents = events.filter { $0.eventType == .playerDeath }
        if !collisionEvents.isEmpty {
            let collisionPattern = AnalyticsBehaviorPattern(
                patternId: "collision_rate",
                patternType: "collision",
                frequency: Double(collisionEvents.count) / Double(max(1, events.count)),
                confidence: 0.9,
                description: "Player collision frequency analysis"
            )
            patterns.append(collisionPattern)
        }

        // Analyze power-up usage patterns
        let powerUpEvents = events.filter { $0.eventType == .powerUpUsed }
        if !powerUpEvents.isEmpty {
            let powerUpPattern = AnalyticsBehaviorPattern(
                patternId: "powerup_usage",
                patternType: "powerup",
                frequency: Double(powerUpEvents.count) / Double(max(1, events.count)),
                confidence: 0.7,
                description: "Power-up collection and usage patterns"
            )
            patterns.append(powerUpPattern)
        }

        return patterns
    }

    private func assessPlayerSkill(_ events: ArraySlice<TrackedEvent>) -> Double {
        let totalEvents = Double(events.count)
        if totalEvents == 0 { return 0.5 }

        // Calculate skill based on survival patterns and score progression
        let deathEvents = events.filter { $0.eventType == .playerDeath }
        let scoreEvents = events.filter { $0.eventType == .scoreUpdate }

        let deathRate = Double(deathEvents.count) / totalEvents
        let scoreRate = Double(scoreEvents.count) / totalEvents

        // Higher skill = lower death rate + higher score rate
        let skillScore = (1.0 - deathRate) * 0.6 + scoreRate * 0.4

        return max(0.0, min(1.0, skillScore))
    }

    private func calculateEngagementLevel(_ sessions: ArraySlice<SessionAnalytics>) -> EngagementLevel {
        if sessions.isEmpty { return .low }

        let avgDuration = sessions.map { $0.duration }.reduce(0, +) / Double(sessions.count)
        let avgScore = sessions.map { Double($0.totalScore) }.reduce(0, +) / Double(sessions.count)

        // Engagement based on session duration and score
        let durationScore = min(avgDuration / 600.0, 1.0) // Max 10 minutes = high engagement
        let scoreScore = min(avgScore / 5000.0, 1.0) // Max 5000 score = high engagement

        let engagementScore = (durationScore + scoreScore) / 2.0

        if engagementScore >= 0.7 { return .veryHigh }
        else if engagementScore >= 0.5 { return .high }
        else if engagementScore >= 0.3 { return .medium }
        else { return .low }
    }

    private func identifyPreferredGameModes(_ events: ArraySlice<TrackedEvent>) -> [AnalyticsGameMode] {
        // Analyze event patterns to determine preferred game modes
        // For now, return classic as default with some analysis
        var modes: [AnalyticsGameMode] = [.classic]

        let deathEvents = events.filter { $0.eventType == .playerDeath }.count
        let scoreEvents = events.filter { $0.eventType == .scoreUpdate }.count

        // If high score events relative to deaths, might prefer challenge modes
        if Double(scoreEvents) / Double(max(1, deathEvents)) > 2.0 {
            modes.append(.challenge)
        }

        return modes
    }

    private func determineDifficultyPreference(_ sessions: ArraySlice<SessionAnalytics>) -> String {
        if sessions.isEmpty { return "balanced" }

        let avgDeaths = sessions.map { Double($0.deaths) }.reduce(0, +) / Double(sessions.count)
        let avgScore = sessions.map { Double($0.totalScore) }.reduce(0, +) / Double(sessions.count)

        // Analyze death rate vs score to determine difficulty preference
        let performanceRatio = avgScore / max(1.0, avgDeaths * 1000.0)

        if performanceRatio > 2.0 { return "hard" }
        else if performanceRatio > 1.0 { return "medium" }
        else { return "easy" }
    }

    private func classifyPlayStyle(_ events: ArraySlice<TrackedEvent>) -> PlayStyle {
        let totalEvents = Double(events.count)
        if totalEvents == 0 { return .balanced }

        let powerUpEvents = Double(events.filter { $0.eventType == .powerUpUsed }.count)
        let deathEvents = Double(events.filter { $0.eventType == .playerDeath }.count)

        let powerUpRatio = powerUpEvents / totalEvents
        let deathRatio = deathEvents / totalEvents

        // Classify based on behavior patterns
        if powerUpRatio > 0.3 { return .completionist } // Collects many power-ups
        else if deathRatio < 0.1 { return .speedRunner } // Few deaths, fast progression
        else if deathRatio > 0.3 { return .aggressive } // High risk-taking
        else { return .balanced }
    }

    private func calculateRetentionRisk(_ sessions: ArraySlice<SessionAnalytics>) -> Double {
        if sessions.count < 2 { return 0.5 }

        // Analyze session frequency and duration trends
        let recentSessions = sessions.suffix(3)
        let olderSessions = sessions.prefix(max(1, sessions.count - 3))

        let recentAvgDuration = recentSessions.map { $0.duration }.reduce(0, +) / Double(recentSessions.count)
        let olderAvgDuration = olderSessions.map { $0.duration }.reduce(0, +) / Double(olderSessions.count)

        // If recent sessions are significantly shorter, higher retention risk
        let durationChange = recentAvgDuration / max(1.0, olderAvgDuration)

        // Retention risk is inverse of duration change (shorter sessions = higher risk)
        return max(0.0, min(1.0, 1.0 - durationChange))
    }

    private func generatePersonalizedRecommendations(_ events: ArraySlice<TrackedEvent>, _ sessions: ArraySlice<SessionAnalytics>) -> [String] {
        var recommendations: [String] = []

        let skillLevel = assessPlayerSkill(events)
        let engagementLevel = calculateEngagementLevel(sessions)
        let playStyle = classifyPlayStyle(events)

        // Generate recommendations based on analysis
        if skillLevel < 0.3 {
            recommendations.append("Try easier difficulty levels to build confidence")
        } else if skillLevel > 0.8 {
            recommendations.append("Challenge yourself with harder difficulty levels")
        }

        if engagementLevel == .low {
            recommendations.append("Try shorter sessions with specific goals")
        }

        if playStyle == .aggressive && events.filter({ $0.eventType == .playerDeath }).count > events.count / 3 {
            recommendations.append("Consider a more cautious approach to improve survival")
        }

        if recommendations.isEmpty {
            recommendations.append("Keep up the great performance!")
        }

        return recommendations
    }

    private func calculateAverageFrameRate() -> Double {
        // Get current FPS from PerformanceManager if available
        // For now, return a reasonable estimate based on system performance
        return 60.0 // Default to 60 FPS
    }

    private func getCurrentMemoryUsage() -> UInt64 {
        // Use the same memory calculation as PerformanceManager
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return kerr == KERN_SUCCESS ? info.resident_size : 50 * 1024 * 1024 // 50MB fallback
    }

    private func calculateBatteryImpact() -> Double {
        // Estimate battery impact based on current activity
        // This is a simplified calculation - in a real app, you'd use system APIs
        let memoryUsage = Double(getCurrentMemoryUsage()) / (1024 * 1024 * 1024) // GB
        let frameRate = calculateAverageFrameRate()

        // Higher memory usage and frame rate = higher battery impact
        return min(1.0, (memoryUsage * 0.3) + (frameRate / 120.0 * 0.7))
    }

    private func measureLoadTimes() -> [String: TimeInterval] {
        // Measure various load times
        var loadTimes: [String: TimeInterval] = [:]

        let startTime = Date()

        // Measure scene loading time (simplified)
        loadTimes["scene_load"] = Date().timeIntervalSince(startTime)

        // Measure asset loading time (simplified)
        loadTimes["asset_load"] = 0.1 // Placeholder

        // Measure AI initialization time (simplified)
        loadTimes["ai_init"] = 0.05 // Placeholder

        return loadTimes
    }

    private func calculateCrashRate() -> Double {
        // Calculate crash rate based on session data
        let sessions = getStoredSessions()
        if sessions.isEmpty { return 0.0 }

        // Count sessions that ended abruptly (very short duration with no score progression)
        let crashSessions = sessions.filter { session in
            session.duration < 10.0 && session.totalScore < 100
        }

        return Double(crashSessions.count) / Double(sessions.count)
    }

    private func calculateSessionStability() -> Double {
        // Calculate session stability based on consistent performance
        let sessions = getStoredSessions()
        if sessions.count < 2 { return 1.0 }

        // Calculate variance in session durations and scores
        let durations = sessions.map { $0.duration }
        let scores = sessions.map { Double($0.totalScore) }

        let avgDuration = durations.reduce(0, +) / Double(durations.count)
        let avgScore = scores.reduce(0, +) / Double(scores.count)

        // Calculate coefficient of variation (lower = more stable)
        let durationVariance = durations.map { pow($0 - avgDuration, 2) }.reduce(0, +) / Double(durations.count)
        let scoreVariance = scores.map { pow($0 - avgScore, 2) }.reduce(0, +) / Double(scores.count)

        let durationCV = sqrt(durationVariance) / max(1.0, avgDuration)
        let scoreCV = sqrt(scoreVariance) / max(1.0, avgScore)

        // Stability is inverse of average coefficient of variation
        let avgCV = (durationCV + scoreCV) / 2.0
        return max(0.0, 1.0 - avgCV)
    }

    private func processEvent(_ event: TrackedEvent) {
        // Process individual events for real-time analytics
        switch event.eventType {
        case .playerDeath:
            currentSessionData.deaths += 1
            // Update heat map for death location
            if let position = event.playerPosition {
                updateHeatMapData(position: position, action: .death)
            }
        case .levelComplete:
            currentSessionData.levelsCompleted += 1
        case .powerUpUsed:
            currentSessionData.powerUpsUsed += 1
            // Update heat map for power-up usage location
            if let position = event.playerPosition {
                updateHeatMapData(position: position, action: .usePowerUp)
            }
        case .scoreUpdate:
            if let scoreStr = event.parameters["score"], let score = Int(scoreStr) {
                currentSessionData.totalScore = max(currentSessionData.totalScore, score)
            }
        case .levelStart:
            // Track level progression
            break
        case .sessionStart:
            // Session already handled
            break
        case .sessionEnd:
            // Session already handled
            break
        default:
            // Track other events for heat map
            if let position = event.playerPosition {
                updateHeatMapData(position: position, action: .move)
            }
            break
        }
    }

    private func generateInsights(_ analysis: AnalyticsBehaviorAnalysis, _ metrics: AnalyticsPerformanceMetrics) -> [AnalyticsInsight] {
        var insights: [AnalyticsInsight] = []

        // Performance insights
        if metrics.averageFrameRate < 50.0 {
            insights.append(AnalyticsInsight(
                insightId: "performance_fps",
                type: .performance,
                title: "Frame Rate Performance",
                description: "Average frame rate is below optimal levels",
                confidence: 0.9,
                recommendations: ["Consider reducing visual effects", "Check device performance settings"]
            ))
        }

        if metrics.memoryUsage > 200 * 1024 * 1024 { // 200MB
            insights.append(AnalyticsInsight(
                insightId: "performance_memory",
                type: .performance,
                title: "Memory Usage High",
                description: "App is using significant memory resources",
                confidence: 0.8,
                recommendations: ["Consider clearing cache", "Reduce texture quality if possible"]
            ))
        }

        // Behavior insights
        if analysis.skillLevel < 0.3 {
            insights.append(AnalyticsInsight(
                insightId: "behavior_skill",
                type: .behavior,
                title: "Learning Opportunity",
                description: "Player may benefit from tutorial or easier difficulty",
                confidence: 0.7,
                recommendations: ["Enable tutorial mode", "Start with easier difficulty"]
            ))
        }

        if analysis.engagementLevel == .low {
            insights.append(AnalyticsInsight(
                insightId: "behavior_engagement",
                type: .engagement,
                title: "Engagement Opportunity",
                description: "Player sessions are shorter than optimal",
                confidence: 0.6,
                recommendations: ["Add more varied gameplay elements", "Introduce achievement rewards"]
            ))
        }

        if analysis.retentionRisk > 0.7 {
            insights.append(AnalyticsInsight(
                insightId: "behavior_retention",
                type: .engagement,
                title: "Retention Risk",
                description: "Player may be at risk of disengaging",
                confidence: 0.8,
                recommendations: ["Send re-engagement notifications", "Offer special challenges or rewards"]
            ))
        }

        // Technical insights
        if metrics.crashRate > 0.01 { // 1%
            insights.append(AnalyticsInsight(
                insightId: "technical_crashes",
                type: .technical,
                title: "Stability Issues",
                description: "App has experienced crashes during sessions",
                confidence: 0.9,
                recommendations: ["Check error logs", "Update to latest version", "Report technical issues"]
            ))
        }

        if metrics.sessionStability < 0.5 {
            insights.append(AnalyticsInsight(
                insightId: "technical_stability",
                type: .technical,
                title: "Session Instability",
                description: "Session performance varies significantly",
                confidence: 0.7,
                recommendations: ["Monitor system resources", "Check for background processes"]
            ))
        }

        return insights
    }
}

// MARK: - Supporting Types

enum AnalyticsEvent: String, Codable, Sendable {
    case sessionStart
    case sessionEnd
    case levelStart
    case levelComplete
    case playerDeath
    case powerUpUsed
    case scoreUpdate
    case achievementUnlocked
    case tutorialCompleted
    case settingsChanged
    case purchaseMade
    case socialInteraction
}

enum AnalyticsPlayerAction: String, Codable, Sendable {
    case move
    case jump
    case usePowerUp
    case collide
    case death
    case levelComplete
}

enum AnalyticsGameMode: String, Codable, Sendable {
    case classic
    case timeTrial = "time_trial"
    case survival
    case puzzle
    case challenge
}

enum EngagementLevel: String, Codable, Sendable {
    case low
    case medium
    case high
    case veryHigh = "very_high"
}

enum PlayStyle: String, Codable, Sendable {
    case aggressive
    case defensive
    case balanced
    case speedRunner = "speed_runner"
    case completionist
}

struct SessionAnalytics: Codable, Sendable {
    let sessionId: String
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval = 0
    let playerId: String
    let deviceInfo: DeviceInfo
    let gameVersion: String
    var totalScore: Int = 0
    var levelsCompleted: Int = 0
    var powerUpsUsed: Int = 0
    var deaths: Int = 0
    var engagementScore: Double = 0
    var skillProgression: Double = 0

    static let empty = SessionAnalytics(
        sessionId: "",
        startTime: Date(),
        playerId: "",
        deviceInfo: DeviceInfo(model: "", systemVersion: "", screenSize: .zero),
        gameVersion: ""
    )
}

struct DeviceInfo: Codable, Sendable {
    let model: String
    let systemVersion: String
    let screenSize: CGSize
}

struct TrackedEvent: Sendable {
    let eventId: String
    let eventType: AnalyticsEvent
    let timestamp: Date
    let parameters: [String: String]
    let sessionId: String
    let playerPosition: CGPoint?
    let gameState: String
}

struct AnalyticsBehaviorAnalysis: Sendable {
    let behaviorPatterns: [AnalyticsBehaviorPattern]
    let skillLevel: Double
    let engagementLevel: EngagementLevel
    let preferredGameModes: [AnalyticsGameMode]
    let difficultyPreference: String
    let playStyle: PlayStyle
    let retentionRisk: Double
    let recommendations: [String]
}

struct AnalyticsBehaviorPattern: Codable, Sendable {
    let patternId: String
    let patternType: String
    let frequency: Double
    let confidence: Double
    let description: String
}

struct HeatMapData: Sendable {
    private var positionData: [String: Int] = [:]
    private var actionData: [AnalyticsPlayerAction: Int] = [:]

    mutating func updatePosition(_ position: CGPoint, action: AnalyticsPlayerAction) {
        let key = "\(Int(position.x))_\(Int(position.y))"
        positionData[key, default: 0] += 1
        actionData[action, default: 0] += 1
    }

    func getActionDistribution() -> [AnalyticsPlayerAction: Int] {
        actionData
    }

    static let empty = HeatMapData()
}

struct PeriodicAnalytics: Sendable {
    let timestamp: Date
    let behaviorAnalysis: AnalyticsBehaviorAnalysis
    let performanceMetrics: AnalyticsPerformanceMetrics
    let sessionId: String
}

struct AnalyticsInsight: Sendable {
    let insightId: String
    let type: InsightType
    let title: String
    let description: String
    let confidence: Double
    let recommendations: [String]
}

enum InsightType: String, Sendable {
    case performance
    case behavior
    case engagement
    case monetization
    case technical
}

/// Game performance metrics for analytics
struct AnalyticsPerformanceMetrics: Sendable {
    let averageFrameRate: Double
    let memoryUsage: UInt64
    let batteryImpact: Double
    let loadTimes: [String: TimeInterval]
    let crashRate: Double
    let sessionStability: Double

    static let empty = AnalyticsPerformanceMetrics(
        averageFrameRate: 0.0,
        memoryUsage: 0,
        batteryImpact: 0.0,
        loadTimes: [:],
        crashRate: 0.0,
        sessionStability: 0.0
    )
}
