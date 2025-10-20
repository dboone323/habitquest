//
//  AnalyticsDashboardManager.swift
//  AvoidObstaclesGame
//
//  Created by Developer on 2024
//
//  Analytics dashboard for real-time AI performance monitoring and player behavior insights
//

import Combine
import SpriteKit

// Import AI types

/// Manages the analytics dashboard for AI performance monitoring
@MainActor
final class AnalyticsDashboardManager {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = AnalyticsDashboardManager()

    /// Dashboard visibility state
    private var isDashboardVisible = false

    /// Dashboard root node
    private var dashboardNode: SKNode?

    /// Analytics panels
    private var analyticsPanels: [AnalyticsPanel] = []

    /// Touch tracking for triple tap detection
    private var touchTimestamps: [TimeInterval] = []

    /// AI performance metrics
    private var aiPerformanceMetrics = AIPerformanceMetrics()

    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    /// Weak references to managers for metrics
    private weak var aiManager: AIAdaptiveDifficultyManager?
    private weak var obstacleManager: ObstacleManager?
    private weak var powerUpManager: PowerUpManager?

    // MARK: - Initialization

    private init() {
        self.setupDashboard()
    }

    // MARK: - Dashboard Setup

    /// Sets up the analytics dashboard
    private func setupDashboard() {
        self.dashboardNode = SKNode()
        self.dashboardNode?.zPosition = 1000
        self.dashboardNode?.isHidden = true

        // Create background overlay
        let background = SKShapeNode(rectOf: CGSize(width: 300, height: 400))
        background.fillColor = SKColor.black.withAlphaComponent(0.8)
        background.strokeColor = SKColor.white
        background.lineWidth = 2
        background.position = CGPoint(x: 150, y: 200)
        self.dashboardNode?.addChild(background)

        // Create analytics panels
        self.createAnalyticsPanels()
    }

    /// Creates the analytics panels
    private func createAnalyticsPanels() {
        // AI Performance Panel
        let aiPanel = AnalyticsPanel(
            title: "AI Performance",
            position: CGPoint(x: 150, y: 350),
            size: CGSize(width: 280, height: 80)
        )
        self.analyticsPanels.append(aiPanel)
        self.dashboardNode?.addChild(aiPanel.node)

        // Player Behavior Panel
        let behaviorPanel = AnalyticsPanel(
            title: "Player Behavior",
            position: CGPoint(x: 150, y: 250),
            size: CGSize(width: 280, height: 80)
        )
        self.analyticsPanels.append(behaviorPanel)
        self.dashboardNode?.addChild(behaviorPanel.node)

        // Performance Metrics Panel
        let performancePanel = AnalyticsPanel(
            title: "Performance",
            position: CGPoint(x: 150, y: 150),
            size: CGSize(width: 280, height: 80)
        )
        self.analyticsPanels.append(performancePanel)
        self.dashboardNode?.addChild(performancePanel.node)

        // Analytics Insights Panel
        let insightsPanel = AnalyticsPanel(
            title: "Insights",
            position: CGPoint(x: 150, y: 50),
            size: CGSize(width: 280, height: 80)
        )
        self.analyticsPanels.append(insightsPanel)
        self.dashboardNode?.addChild(insightsPanel.node)
    }

    // MARK: - Dashboard Management

    /// Adds the dashboard to the scene
    func addDashboardToScene(_ scene: SKScene) {
        guard let dashboardNode = self.dashboardNode else { return }
        scene.addChild(dashboardNode)
    }

    /// Toggles dashboard visibility
    func toggleDashboard() {
        self.isDashboardVisible.toggle()
        self.dashboardNode?.isHidden = !self.isDashboardVisible

        if self.isDashboardVisible {
            self.updateDashboardMetrics()
        }
    }

    /// Handles triple tap detection for dashboard toggle
    func handleTripleTap(at location: CGPoint) -> Bool {
        let currentTime = CACurrentMediaTime()
        self.touchTimestamps.append(currentTime)

        // Keep only recent touches (within 0.5 seconds)
        self.touchTimestamps = self.touchTimestamps.filter { currentTime - $0 < 0.5 }

        // Check for triple tap
        if self.touchTimestamps.count >= 3 {
            self.toggleDashboard()
            self.touchTimestamps.removeAll()
            return true
        }

        return false
    }

    // MARK: - AI Metrics Wiring

    /// Wires up AI performance metrics from managers
    func wireAIPerformanceMetrics(
        from aiManager: AIAdaptiveDifficultyManager,
        obstacleManager: ObstacleManager,
        powerUpManager: PowerUpManager
    ) {
        // Store weak references
        self.aiManager = aiManager
        self.obstacleManager = obstacleManager
        self.powerUpManager = powerUpManager

        // Set up periodic updates from AnalyticsManager
        setupAnalyticsIntegration()

        // Analytics wiring is complete - metrics will be updated manually
        print("Analytics dashboard wired to AI managers")
    }

    /// Set up integration with AnalyticsManager for comprehensive metrics
    private func setupAnalyticsIntegration() {
        // Create a timer to periodically update dashboard with analytics data
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateFromAnalyticsManager()
            }
        }
    }

    /// Update dashboard metrics from AnalyticsManager
    private func updateFromAnalyticsManager() {
        let analytics = AnalyticsManager.shared
        let behaviorAnalysis = analytics.analyzePlayerBehavior()
        let performanceMetrics = analytics.getPerformanceMetrics()

        // Update AI performance metrics based on analytics
        let engagementValue: Double
        switch behaviorAnalysis.engagementLevel {
        case .low: engagementValue = 0.25
        case .medium: engagementValue = 0.5
        case .high: engagementValue = 0.75
        case .veryHigh: engagementValue = 1.0
        }

        updateAIPerformance(
            predictionAccuracy: behaviorAnalysis.skillLevel,
            adaptationRate: engagementValue,
            learningProgress: behaviorAnalysis.skillLevel
        )

        // Update obstacle metrics
        if let obstacleManager = self.obstacleManager {
            let activeObstacles = obstacleManager.getActiveObstacles().count
            let spawnRate = Double(activeObstacles) / 10.0 // Estimate spawn rate
            updateObstacleMetrics(spawnRate: spawnRate, dynamicPatternUsage: 0.5)
        }

        // Update power-up metrics
        if let powerUpManager = self.powerUpManager {
            // Estimate effectiveness and placement success
            updatePowerUpMetrics(effectiveness: 0.7, adaptivePlacementSuccess: 0.6)
        }
    }

    /// Manually update AI performance metrics
    func updateAIPerformance(predictionAccuracy: Double, adaptationRate: Double, learningProgress: Double) {
        let metrics = AIPerformanceData(
            predictionAccuracy: predictionAccuracy,
            adaptationRate: adaptationRate,
            learningProgress: learningProgress
        )
        updateAIPerformanceMetrics(metrics)
    }

    /// Manually update obstacle metrics
    func updateObstacleMetrics(spawnRate: Double, dynamicPatternUsage: Double) {
        let metrics = ObstacleMetrics(
            spawnRate: spawnRate,
            dynamicPatternUsage: dynamicPatternUsage
        )
        updateObstacleMetricsInternal(metrics)
    }

    /// Manually update power-up metrics
    func updatePowerUpMetrics(effectiveness: Double, adaptivePlacementSuccess: Double) {
        let metrics = PowerUpMetrics(
            effectiveness: effectiveness,
            adaptivePlacementSuccess: adaptivePlacementSuccess
        )
        updatePowerUpMetrics(metrics)
    }

    // MARK: - Metrics Updates

    /// Updates AI performance metrics
    private func updateAIPerformanceMetrics(_ metrics: AIPerformanceData) {
        self.aiPerformanceMetrics.predictionAccuracy = metrics.predictionAccuracy
        self.aiPerformanceMetrics.adaptationRate = metrics.adaptationRate
        self.aiPerformanceMetrics.learningProgress = metrics.learningProgress

        if self.isDashboardVisible {
            self.updateDashboardMetrics()
        }
    }

    /// Updates obstacle metrics
    private func updateObstacleMetricsInternal(_ metrics: ObstacleMetrics) {
        self.aiPerformanceMetrics.obstacleSpawnRate = metrics.spawnRate
        self.aiPerformanceMetrics.dynamicPatternUsage = metrics.dynamicPatternUsage

        if self.isDashboardVisible {
            self.updateDashboardMetrics()
        }
    }

    /// Updates power-up metrics
    private func updatePowerUpMetrics(_ metrics: PowerUpMetrics) {
        self.aiPerformanceMetrics.powerUpEffectiveness = metrics.effectiveness
        self.aiPerformanceMetrics.adaptivePlacementSuccess = metrics.adaptivePlacementSuccess

        if self.isDashboardVisible {
            self.updateDashboardMetrics()
        }
    }

    /// Updates dashboard display with current metrics
    private func updateDashboardMetrics() {
        guard self.analyticsPanels.count >= 4 else { return }

        // Update AI Performance Panel
        let aiMetrics = [
            "Prediction: \(String(format: "%.1f%%", self.aiPerformanceMetrics.predictionAccuracy * 100))",
            "Adaptation: \(String(format: "%.2f", self.aiPerformanceMetrics.adaptationRate))",
            "Learning: \(String(format: "%.1f%%", self.aiPerformanceMetrics.learningProgress * 100))",
        ]
        self.analyticsPanels[0].updateMetrics(aiMetrics)

        // Update Player Behavior Panel
        let analytics = AnalyticsManager.shared
        let behaviorAnalysis = analytics.analyzePlayerBehavior()
        let behaviorMetrics = [
            "Skill: \(String(format: "%.1f", behaviorAnalysis.skillLevel * 100))%",
            "Engagement: \(behaviorAnalysis.engagementLevel.rawValue)",
            "Style: \(behaviorAnalysis.playStyle.rawValue)",
        ]
        self.analyticsPanels[1].updateMetrics(behaviorMetrics)

        // Update Performance Metrics Panel
        let performanceMetrics = analytics.getPerformanceMetrics()
        let performanceDisplayMetrics = [
            "FPS: \(String(format: "%.0f", performanceMetrics.averageFrameRate))",
            "Memory: \(String(format: "%.1f", Double(performanceMetrics.memoryUsage) / (1024*1024)))MB",
            "Stability: \(String(format: "%.1f%%", performanceMetrics.sessionStability * 100))",
        ]
        self.analyticsPanels[2].updateMetrics(performanceDisplayMetrics)

        // Update Insights Panel
        let insights = analytics.analyzePlayerBehavior()
        let insightsDisplay = [
            "Retention: \(String(format: "%.1f%%", (1.0 - insights.retentionRisk) * 100))",
            "Patterns: \(insights.behaviorPatterns.count)",
            "Recommendations: \(insights.recommendations.count)",
        ]
        self.analyticsPanels[3].updateMetrics(insightsDisplay)
    }
}

// MARK: - Analytics Panel

/// Individual analytics panel for displaying metrics
final class AnalyticsPanel {
    /// Panel node
    let node: SKNode

    /// Panel title
    private let titleLabel: SKLabelNode

    /// Metric labels
    private var metricLabels: [SKLabelNode] = []

    /// Panel background
    private let background: SKShapeNode

    /// Initializes a new analytics panel
    init(title: String, position: CGPoint, size: CGSize) {
        self.node = SKNode()
        self.node.position = position

        // Create background
        self.background = SKShapeNode(rectOf: size)
        self.background.fillColor = SKColor.gray.withAlphaComponent(0.5)
        self.background.strokeColor = SKColor.white
        self.background.lineWidth = 1
        self.node.addChild(self.background)

        // Create title label
        self.titleLabel = SKLabelNode(text: title)
        self.titleLabel.fontSize = 14
        self.titleLabel.fontColor = SKColor.white
        self.titleLabel.position = CGPoint(x: 0, y: size.height / 2 - 20)
        self.node.addChild(self.titleLabel)

        // Create metric labels
        for i in 0 ..< 3 {
            let label = SKLabelNode(text: "")
            label.fontSize = 10
            label.fontColor = SKColor.cyan
            label.position = CGPoint(x: -size.width / 2 + 10, y: size.height / 2 - 40 - CGFloat(i) * 15)
            label.horizontalAlignmentMode = .left
            self.metricLabels.append(label)
            self.node.addChild(label)
        }
    }

    /// Updates the metrics displayed in the panel
    @MainActor
    func updateMetrics(_ metrics: [String]) {
        for (index, metric) in metrics.enumerated() where index < self.metricLabels.count {
            self.metricLabels[index].text = metric
        }
    }
}

// MARK: - AI Performance Metrics

/// AI performance metrics data structure
struct AIPerformanceMetrics {
    var predictionAccuracy: Double = 0.0
    var adaptationRate: Double = 0.0
    var learningProgress: Double = 0.0
    var obstacleSpawnRate: Double = 0.0
    var dynamicPatternUsage: Double = 0.0
    var powerUpEffectiveness: Double = 0.0
    var adaptivePlacementSuccess: Double = 0.0
}

// MARK: - Metrics Data Structures

/// Power-up metrics from power-up manager
struct PowerUpMetrics {
    let effectiveness: Double
    let adaptivePlacementSuccess: Double
}
