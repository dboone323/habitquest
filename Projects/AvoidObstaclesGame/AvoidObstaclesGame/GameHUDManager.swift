//
// GameHUDManager.swift
// AvoidObstaclesGame
//
// Consolidated HUD manager combining HUD display, statistics overlay, and performance monitoring.
// Implements AI-recommended manager consolidation for improved code organization.
//

import SpriteKit
import Foundation
import UIKit

/// Protocol for GameHUDManager events
protocol GameHUDManagerDelegate: AnyObject {
    func restartButtonTapped()
}

/// Consolidated HUD manager for all game interface elements
class GameHUDManager {
    // MARK: - Properties

    /// Delegate for HUD events
    weak var delegate: GameHUDManagerDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// HUD Elements (from HUDManager)
    private var scoreLabel: SKLabelNode?
    private var highScoreLabel: SKLabelNode?
    private var difficultyLabel: SKLabelNode?

    /// Statistics Display Elements (from StatisticsDisplayManager)
    private var statisticsLabels: [SKNode] = []
    private let fadeOutAction: SKAction = .fadeOut(withDuration: 0.3)

    /// Performance Monitoring Elements (from PerformanceOverlayManager)
    private var performanceOverlay: SKNode?
    private var fpsLabel: SKLabelNode?
    private var memoryLabel: SKLabelNode?
    private var qualityLabel: SKLabelNode?
    private var performanceUpdateTimer: Timer?

    /// Performance monitoring state
    private var performanceMonitoringEnabled = false

    /// HUD visibility state
    private var hudVisible = true

    /// Game Over Screen Elements
    private var gameOverLabel: SKLabelNode?
    private var restartLabel: SKLabelNode?
    private var highScoreAchievedLabel: SKLabelNode?
    private var finalScoreLabel: SKLabelNode?
    private var levelUpLabel: SKLabelNode?

    /// Animation actions for reuse
    private let pulseAction: SKAction
    private let fadeInAction: SKAction

    // MARK: - Initialization

    /// Initializes the consolidated HUD manager with a scene reference
    /// - Parameter scene: The game scene to add HUD elements to
    init(scene: SKScene) {
        // Pre-create reusable actions
        self.pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5),
        ])

        self.fadeInAction = SKAction.fadeIn(withDuration: 0.3)

        self.scene = scene
        self.setupHUD()
    }

    /// Updates the scene reference (called when scene is properly initialized)
    func updateScene(_ scene: SKScene) {
        self.scene = scene
        self.setupHUD()
    }

    // MARK: - Setup

    /// Sets up all HUD elements
    func setupHUD() {
        self.setupScoreElements()
        self.setupPerformanceOverlay()
    }

    /// Sets up all UI elements (alias for setupHUD for compatibility)
    func setupUI() {
        self.setupHUD()
    }

    /// Sets up score-related HUD elements
    private func setupScoreElements() {
        guard let scene else { return }

        // Score Label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel?.text = "Score: 0"
        scoreLabel?.fontSize = 24
        scoreLabel?.fontColor = .black
        scoreLabel?.horizontalAlignmentMode = .left
        scoreLabel?.position = CGPoint(x: 20, y: scene.size.height - 40)
        scoreLabel?.zPosition = 100

        // High Score Label
        highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        let highestScore = HighScoreManager.shared.getHighestScore()
        highScoreLabel?.text = "Best: \(highestScore)"
        highScoreLabel?.fontSize = 20
        highScoreLabel?.fontColor = .darkGray
        highScoreLabel?.horizontalAlignmentMode = .left
        highScoreLabel?.position = CGPoint(x: 20, y: scene.size.height - 70)
        highScoreLabel?.zPosition = 100

        // Difficulty Label
        difficultyLabel = SKLabelNode(fontNamed: "Chalkduster")
        difficultyLabel?.text = "Level: 1"
        difficultyLabel?.fontSize = 18
        difficultyLabel?.fontColor = .blue
        difficultyLabel?.horizontalAlignmentMode = .right
        difficultyLabel?.position = CGPoint(x: scene.size.width - 20, y: scene.size.height - 40)
        difficultyLabel?.zPosition = 100

        // Add to scene
        if let scoreLabel { scene.addChild(scoreLabel) }
        if let highScoreLabel { scene.addChild(highScoreLabel) }
        if let difficultyLabel { scene.addChild(difficultyLabel) }
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

        // Only add to scene if performance monitoring is enabled
        if performanceMonitoringEnabled {
            scene.addChild(self.performanceOverlay!)
        }
    }

    // MARK: - HUD Updates

    /// Updates the score display
    /// - Parameter score: New score value
    func updateScore(_ score: Int) {
        self.scoreLabel?.text = "Score: \(score)"
    }

    /// Updates the high score display
    /// - Parameter highScore: New high score value
    func updateHighScore(_ highScore: Int) {
        self.highScoreLabel?.text = "Best: \(highScore)"
    }

    /// Updates the difficulty level display
    /// - Parameter level: New difficulty level
    func updateDifficultyLevel(_ level: Int) {
        self.difficultyLabel?.text = "Level: \(level)"
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
            if self.performanceOverlay == nil {
                self.setupPerformanceOverlay()
            }
            self.startPerformanceUpdates()
            self.scene?.addChild(self.performanceOverlay!)
        } else {
            self.hidePerformanceOverlay()
            self.stopPerformanceUpdates()
        }
    }

    /// Toggles performance monitoring overlay
    func togglePerformanceMonitoring() {
        self.setPerformanceMonitoring(enabled: !self.performanceMonitoringEnabled)
    }

    /// Hides the performance monitoring overlay
    private func hidePerformanceOverlay() {
        self.performanceOverlay?.removeFromParent()
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
        let stats = PerformanceManager.shared.getPerformanceStats()

        // Update FPS
        self.fpsLabel?.text = String(format: "FPS: %.1f", stats.averageFPS)
        self.fpsLabel?.fontColor = stats.averageFPS >= 55 ? .green : (stats.averageFPS >= 30 ? .yellow : .red)

        // Update Memory
        let memoryMB = Double(stats.currentMemoryUsage) / (1024 * 1024)
        self.memoryLabel?.text = String(format: "MEM: %.1f MB", memoryMB)
        self.memoryLabel?.fontColor = memoryMB < 50 ? .cyan : (memoryMB < 100 ? .yellow : .red)

        // Update Quality
        switch stats.currentQualityLevel {
        case .high:
            self.qualityLabel?.text = "QUAL: HIGH"
            self.qualityLabel?.fontColor = .green
        case .medium:
            self.qualityLabel?.text = "QUAL: MED"
            self.qualityLabel?.fontColor = .yellow
        case .low:
            self.qualityLabel?.text = "QUAL: LOW"
            self.qualityLabel?.fontColor = .red
        }
    }

    // MARK: - HUD Visibility

    /// Sets HUD visibility
    /// - Parameter visible: Whether HUD should be visible
    func setHUDVisible(_ visible: Bool) {
        self.hudVisible = visible

        let alpha: CGFloat = visible ? 1.0 : 0.0
        let action = SKAction.fadeAlpha(to: alpha, duration: 0.3)

        self.scoreLabel?.run(action)
        self.highScoreLabel?.run(action)
        self.difficultyLabel?.run(action)
    }

    /// Toggles HUD visibility
    func toggleHUDVisibility() {
        self.setHUDVisible(!self.hudVisible)
    }

    // MARK: - Game Over Screen

    /// Shows the game over screen
    /// - Parameters:
    ///   - finalScore: The player's final score
    ///   - isNewHighScore: Whether this is a new high score
    func showGameOverScreen(finalScore: Int, isNewHighScore: Bool) {
        guard let scene else { return }

        // Game Over title
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel?.text = "Game Over!"
        gameOverLabel?.fontSize = 40
        gameOverLabel?.fontColor = .red
        gameOverLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 100)
        gameOverLabel?.zPosition = 101

        if let gameOverLabel {
            gameOverLabel.alpha = 0
            scene.addChild(gameOverLabel)
            gameOverLabel.run(self.fadeInAction)
        }

        // Final score display
        finalScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        finalScoreLabel?.text = "Final Score: \(finalScore)"
        finalScoreLabel?.fontSize = 28
        finalScoreLabel?.fontColor = .black
        finalScoreLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 50)
        finalScoreLabel?.zPosition = 101

        if let finalScoreLabel {
            finalScoreLabel.alpha = 0
            scene.addChild(finalScoreLabel)
            finalScoreLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                self.fadeInAction,
            ]))
        }

        // High score achievement notification
        if isNewHighScore {
            highScoreAchievedLabel = SKLabelNode(fontNamed: "Chalkduster")
            highScoreAchievedLabel?.text = "🎉 NEW HIGH SCORE! 🎉"
            highScoreAchievedLabel?.fontSize = 24
            highScoreAchievedLabel?.fontColor = .orange
            highScoreAchievedLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 10)
            highScoreAchievedLabel?.zPosition = 101

            if let highScoreAchievedLabel {
                highScoreAchievedLabel.alpha = 0
                scene.addChild(highScoreAchievedLabel)
                highScoreAchievedLabel.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.4),
                    self.fadeInAction,
                    SKAction.repeatForever(self.pulseAction),
                ]))
            }
        }

        // Restart instruction
        restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel?.text = "Tap to Restart"
        restartLabel?.fontSize = 25
        restartLabel?.fontColor = .darkGray
        restartLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 - 40)
        restartLabel?.zPosition = 101

        if let restartLabel {
            restartLabel.alpha = 0
            scene.addChild(restartLabel)
            restartLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.6),
                self.fadeInAction,
            ]))
        }
    }

    /// Hides the game over screen
    func hideGameOverScreen() {
        let labels = [gameOverLabel, restartLabel, highScoreAchievedLabel, finalScoreLabel]
        for label in labels {
            label?.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()]))
        }

        self.gameOverLabel = nil
        self.restartLabel = nil
        self.highScoreAchievedLabel = nil
        self.finalScoreLabel = nil
    }

    // MARK: - Level Up Effects

    /// Shows a level up effect
    func showLevelUpEffect() {
        guard let scene else { return }

        levelUpLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelUpLabel?.text = "LEVEL UP!"
        levelUpLabel?.fontSize = 32
        levelUpLabel?.fontColor = .yellow
        levelUpLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        levelUpLabel?.zPosition = 200

        if let levelUpLabel {
            levelUpLabel.alpha = 0
            scene.addChild(levelUpLabel)

            let animation = SKAction.sequence([
                self.fadeInAction,
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3),
                SKAction.wait(forDuration: 0.5),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent(),
            ])

            levelUpLabel.run(animation) { [weak self] in
                self?.levelUpLabel = nil
            }
        }
    }

    // MARK: - Score Popups

    /// Shows a score popup at the specified position
    /// - Parameters:
    ///   - score: The score value to display
    ///   - position: Where to show the popup
    func showScorePopup(score: Int, at position: CGPoint) {
        guard let scene else { return }

        let scoreLabel = SKLabelNode(fontNamed: "Arial-Bold")
        scoreLabel.text = "+\(score)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .yellow
        scoreLabel.position = position
        scoreLabel.zPosition = 50

        scene.addChild(scoreLabel)

        // Animate popup
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        let animation = SKAction.group([moveUp, fadeOut])
        let sequence = SKAction.sequence([animation, remove])

        scoreLabel.run(sequence)
    }

    // MARK: - Touch Handling

    /// Handles touch events for UI interactions
    /// - Parameter location: Touch location in scene coordinates
    func handleTouch(at location: CGPoint) {
        // Check if restart label was tapped
        if let restartLabel,
           restartLabel.contains(location) {
            self.delegate?.restartButtonTapped()
        }
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

    /// Removes all HUD elements from the scene
    func removeAllHUD() {
        // Remove HUD elements
        let labels = [scoreLabel, highScoreLabel, difficultyLabel]
        for label in labels {
            label?.removeFromParent()
        }

        self.scoreLabel = nil
        self.highScoreLabel = nil
        self.difficultyLabel = nil

        // Remove statistics
        self.hideStatistics()

        // Remove performance overlay
        self.hidePerformanceOverlay()
        self.stopPerformanceUpdates()
    }
}
