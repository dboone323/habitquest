//
// StatisticsDisplayManager.swift
// AvoidObstaclesGame
//
// Manages the statistics display overlay and formatting.
// Component extracted from UIManager.swift
//

import SpriteKit

/// Manages the statistics display overlay
class StatisticsDisplayManager {
    // MARK: - Properties

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Statistics display elements
    private var statisticsLabels: [SKNode] = []

    /// Animation actions for reuse
    private let fadeOutAction: SKAction = .fadeOut(withDuration: 0.3)

    // MARK: - Initialization

    /// Initializes the statistics display manager with a scene reference
    /// - Parameter scene: The game scene to add statistics to
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

    /// Removes all statistics display elements from the scene
    func removeAllStatistics() {
        self.hideStatistics()
    }
}
