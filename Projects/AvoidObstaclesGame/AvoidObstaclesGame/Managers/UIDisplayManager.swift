//
// UIDisplayManager.swift
// AvoidObstaclesGame
//
// Consolidated manager for all UI display overlays including statistics and performance monitoring.
// Merged from StatisticsDisplayManager and PerformanceOverlayManager for better cohesion.
//

import SpriteKit

/// Types of display overlays that can be shown
enum DisplayOverlayType {
    case statistics
    case performance
}

/// Manages all UI display overlays including statistics and performance monitoring
class UIDisplayManager {
    // MARK: - Properties

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Statistics display elements
    private var statisticsLabels: [SKNode] = []

    /// Performance monitoring overlay
    private var performanceOverlay: SKNode?
    private var fpsLabel: SKLabelNode?
    private var memoryLabel: SKLabelNode?
    private var qualityLabel: SKLabelNode?
    private var performanceUpdateTimer: Timer?

    /// Whether performance monitoring is enabled
    private var performanceMonitoringEnabled = false

    /// Animation actions for reuse
    private let fadeOutAction: SKAction = .fadeOut(withDuration: 0.3)

    // MARK: - Initialization

    /// Initializes the UI display manager with a scene reference
    /// - Parameter scene: The game scene to add overlays to
    init(scene: SKScene) {
        self.scene = scene
    }

    // MARK: - Statistics Display

    /// Shows game statistics overlay
    /// - Parameter statistics: Dictionary of statistics to display
    func showStatistics(_ statistics: [String: Any]) {
        guard let scene else { return }

        self.hideStatistics() // Clear any existing statistics

        let startY = scene.size.height * 0.7
        let spacing: CGFloat = 30
        var currentY = startY

        for (key, value) in statistics {
            let label = SKLabelNode(fontNamed: "Chalkduster")
            label.text = "\(self.formatStatisticKey(key)): \(self.formatStatisticValue(value))"
            label.fontSize = 18
            label.fontColor = .white
            label.position = CGPoint(x: scene.size.width / 2, y: currentY)
            label.zPosition = 150

            // Add background for readability
            let background = SKShapeNode(rectOf: CGSize(width: scene.size.width * 0.8, height: 25))
            background.fillColor = .black.withAlphaComponent(0.7)
            background.strokeColor = .clear
            background.position = label.position
            background.zPosition = 149

            scene.addChild(background)
            scene.addChild(label)

            self.statisticsLabels.append(label)
            self.statisticsLabels.append(background)

            currentY -= spacing
        }
    }

    /// Hides the statistics display
    func hideStatistics() {
        for label in self.statisticsLabels {
            label.run(SKAction.sequence([self.fadeOutAction, SKAction.removeFromParent()]))
        }
        self.statisticsLabels.removeAll()
    }

    // MARK: - Performance Monitoring

    /// Enables or disables performance monitoring overlay
    /// - Parameter enabled: Whether to show performance stats
    func setPerformanceMonitoring(enabled: Bool) {
        self.performanceMonitoringEnabled = enabled

        if enabled {
            self.setupPerformanceOverlay()
            self.startPerformanceUpdates()
        } else {
            self.hidePerformanceOverlay()
            self.stopPerformanceUpdates()
        }
    }

    /// Toggles performance monitoring overlay
    func togglePerformanceMonitoring() {
        self.setPerformanceMonitoring(enabled: !self.performanceMonitoringEnabled)
    }

    /// Sets up the performance monitoring overlay
    private func setupPerformanceOverlay() {
        guard let scene else { return }

        // Create overlay container
        self.performanceOverlay = SKNode()
        self.performanceOverlay?.zPosition = 200 // Above everything else

        // FPS Label
        fpsLabel = SKLabelNode(fontNamed: "Menlo")
        fpsLabel?.text = "FPS: --"
        fpsLabel?.fontSize = 14
        fpsLabel?.fontColor = .green
        fpsLabel?.horizontalAlignmentMode = .left
        fpsLabel?.position = CGPoint(x: 10, y: scene.size.height - 30)

        // Memory Label
        memoryLabel = SKLabelNode(fontNamed: "Menlo")
        memoryLabel?.text = "MEM: -- MB"
        memoryLabel?.fontSize = 14
        memoryLabel?.fontColor = .cyan
        memoryLabel?.horizontalAlignmentMode = .left
        memoryLabel?.position = CGPoint(x: 10, y: scene.size.height - 50)

        // Quality Label
        qualityLabel = SKLabelNode(fontNamed: "Menlo")
        qualityLabel?.text = "QUAL: HIGH"
        qualityLabel?.fontSize = 14
        qualityLabel?.fontColor = .yellow
        qualityLabel?.horizontalAlignmentMode = .left
        qualityLabel?.position = CGPoint(x: 10, y: scene.size.height - 70)

        // Add background for readability
        let background = SKShapeNode(rectOf: CGSize(width: 120, height: 70))
        background.fillColor = .black.withAlphaComponent(0.7)
        background.strokeColor = .white.withAlphaComponent(0.3)
        background.lineWidth = 1
        background.position = CGPoint(x: 60, y: scene.size.height - 50)
        background.zPosition = -1

        self.performanceOverlay?.addChild(background)
        if let fpsLabel { self.performanceOverlay?.addChild(fpsLabel) }
        if let memoryLabel { self.performanceOverlay?.addChild(memoryLabel) }
        if let qualityLabel { self.performanceOverlay?.addChild(qualityLabel) }

        scene.addChild(self.performanceOverlay!)
    }

    /// Hides the performance monitoring overlay
    private func hidePerformanceOverlay() {
        self.performanceOverlay?.removeFromParent()
        self.performanceOverlay = nil
        self.fpsLabel = nil
        self.memoryLabel = nil
        self.qualityLabel = nil
    }

    /// Starts periodic performance updates
    private func startPerformanceUpdates() {
        self.performanceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updatePerformanceDisplay()
        }
    }

    /// Stops performance updates
    private func stopPerformanceUpdates() {
        self.performanceUpdateTimer?.invalidate()
        self.performanceUpdateTimer = nil
    }

    /// Updates the performance display with current stats
    private func updatePerformanceDisplay() {
        // TODO: Integrate with PerformanceManager when available
        // For now, show placeholder values
        self.fpsLabel?.text = "FPS: 60.0"
        self.fpsLabel?.fontColor = .green

        self.memoryLabel?.text = "MEM: 25.0 MB"
        self.memoryLabel?.fontColor = .cyan

        self.qualityLabel?.text = "QUAL: HIGH"
        self.qualityLabel?.fontColor = .green
    }

    // MARK: - Helper Methods

    /// Formats statistic keys for display
    private func formatStatisticKey(_ key: String) -> String {
        switch key {
        case "gamesPlayed": "Games Played"
        case "totalScore": "Total Score"
        case "averageScore": "Average Score"
        case "bestSurvivalTime": "Best Survival Time"
        case "highestScore": "Highest Score"
        default: key.capitalized
        }
    }

    /// Formats statistic values for display
    private func formatStatisticValue(_ value: Any) -> String {
        if let doubleValue = value as? Double {
            if doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                String(Int(doubleValue))
            } else {
                String(format: "%.1f", doubleValue)
            }
        } else if let intValue = value as? Int {
            String(intValue)
        } else {
            String(describing: value)
        }
    }

    // MARK: - Cleanup

    /// Removes all display elements from the scene
    func removeAllDisplayElements() {
        self.hideStatistics()
        self.hidePerformanceOverlay()
        self.stopPerformanceUpdates()
    }
}
