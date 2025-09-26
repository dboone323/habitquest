//
// UIManager.swift
// AvoidObstaclesGame
//
// Manages all user interface elements including labels, game over screens,
// level up effects, and HUD updates.
//

import SpriteKit
import UIKit

/// Protocol for UI-related events
protocol UIManagerDelegate: AnyObject {
    func restartButtonTapped()
}

/// Manages all UI elements and visual feedback
class UIManager {
    // MARK: - Properties

    /// Delegate for UI events
    weak var delegate: UIManagerDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// UI Elements
    private var scoreLabel: SKLabelNode?
    private var highScoreLabel: SKLabelNode?
    private var difficultyLabel: SKLabelNode?
    private var gameOverLabel: SKLabelNode?
    private var restartLabel: SKLabelNode?
    private var highScoreAchievedLabel: SKLabelNode?
    private var finalScoreLabel: SKLabelNode?
    private var levelUpLabel: SKLabelNode?

    /// Statistics labels
    private var statisticsLabels: [SKNode] = []

    /// Animation actions for reuse
    private let pulseAction: SKAction
    private let fadeInAction: SKAction
    private let fadeOutAction: SKAction

    /// Performance monitoring overlay
    private var performanceOverlay: SKNode?
    private var fpsLabel: SKLabelNode?
    private var memoryLabel: SKLabelNode?
    private var qualityLabel: SKLabelNode?
    private var performanceUpdateTimer: Timer?

    /// Whether performance monitoring is visible
    private var performanceMonitoringEnabled = false

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene

        // Pre-create reusable actions
        pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5),
        ])

        fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
    }

    // MARK: - Setup

    /// Sets up all initial UI elements
    func setupUI() {
        setupScoreLabel()
        setupHighScoreLabel()
        setupDifficultyLabel()
    }

    /// Sets up the score label
    private func setupScoreLabel() {
        guard let scene else { return }

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        guard let scoreLabel else { return }

        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 20, y: scene.size.height - 40)
        scoreLabel.zPosition = 100

        scene.addChild(scoreLabel)
    }

    /// Sets up the high score label
    private func setupHighScoreLabel() {
        guard let scene else { return }

        highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        guard let highScoreLabel else { return }

        let highestScore = HighScoreManager.shared.getHighestScore()
        highScoreLabel.text = "Best: \(highestScore)"
        highScoreLabel.fontSize = 20
        highScoreLabel.fontColor = .darkGray
        highScoreLabel.horizontalAlignmentMode = .left
        highScoreLabel.position = CGPoint(x: 20, y: scene.size.height - 70)
        highScoreLabel.zPosition = 100

        scene.addChild(highScoreLabel)
    }

    /// Sets up the difficulty label
    private func setupDifficultyLabel() {
        guard let scene else { return }

        difficultyLabel = SKLabelNode(fontNamed: "Chalkduster")
        guard let difficultyLabel else { return }

        difficultyLabel.text = "Level: 1"
        difficultyLabel.fontSize = 18
        difficultyLabel.fontColor = .blue
        difficultyLabel.horizontalAlignmentMode = .right
        difficultyLabel.position = CGPoint(x: scene.size.width - 20, y: scene.size.height - 40)
        difficultyLabel.zPosition = 100

        scene.addChild(difficultyLabel)
    }

    // MARK: - Updates

    /// Updates the score display
    /// - Parameter score: New score value
    func updateScore(_ score: Int) {
        scoreLabel?.text = "Score: \(score)"
    }

    /// Updates the high score display
    /// - Parameter highScore: New high score value
    func updateHighScore(_ highScore: Int) {
        highScoreLabel?.text = "Best: \(highScore)"
    }

    /// Updates the difficulty level display
    /// - Parameter level: New difficulty level
    func updateDifficultyLevel(_ level: Int) {
        difficultyLabel?.text = "Level: \(level)"
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
            gameOverLabel.run(fadeInAction)
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
                fadeInAction,
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
                    fadeInAction,
                    SKAction.repeatForever(pulseAction),
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
                fadeInAction,
            ]))
        }
    }

    /// Hides the game over screen
    func hideGameOverScreen() {
        let labels = [gameOverLabel, restartLabel, highScoreAchievedLabel, finalScoreLabel]
        for label in labels {
            label?.run(SKAction.sequence([fadeOutAction, SKAction.removeFromParent()]))
        }

        gameOverLabel = nil
        restartLabel = nil
        highScoreAchievedLabel = nil
        finalScoreLabel = nil
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
                fadeInAction,
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3),
                SKAction.wait(forDuration: 0.5),
                fadeOutAction,
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

    // MARK: - Statistics Display

    /// Shows game statistics overlay
    /// - Parameter statistics: Dictionary of statistics to display
    func showStatistics(_ statistics: [String: Any]) {
        guard let scene else { return }

        hideStatistics() // Clear any existing statistics

        let startY = scene.size.height * 0.7
        let spacing: CGFloat = 30
        var currentY = startY

        for (key, value) in statistics {
            let label = SKLabelNode(fontNamed: "Chalkduster")
            label.text = "\(formatStatisticKey(key)): \(formatStatisticValue(value))"
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

            statisticsLabels.append(label)
            statisticsLabels.append(background)

            currentY -= spacing
        }
    }

    /// Hides the statistics display
    func hideStatistics() {
        for label in statisticsLabels {
            label.run(SKAction.sequence([fadeOutAction, SKAction.removeFromParent()]))
        }
        statisticsLabels.removeAll()
    }

    // MARK: - Touch Handling

    /// Handles touch events for UI interactions
    /// - Parameter location: Touch location in scene coordinates
    func handleTouch(at location: CGPoint) {
        // Check if restart label was tapped
        if let restartLabel,
           restartLabel.contains(location)
        {
            delegate?.restartButtonTapped()
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

    /// Removes all UI elements from the scene
    func removeAllUI() {
        let allLabels = [
            scoreLabel,
            highScoreLabel,
            difficultyLabel,
            gameOverLabel,
            restartLabel,
            highScoreAchievedLabel,
            finalScoreLabel,
            levelUpLabel,
            fpsLabel,
            memoryLabel,
            qualityLabel,
        ] + statisticsLabels

        for label in allLabels {
            label?.removeFromParent()
        }

        // Clean up performance monitoring
        stopPerformanceUpdates()
        performanceOverlay?.removeFromParent()

        scoreLabel = nil
        highScoreLabel = nil
        difficultyLabel = nil
        gameOverLabel = nil
        restartLabel = nil
        highScoreAchievedLabel = nil
        finalScoreLabel = nil
        levelUpLabel = nil
        performanceOverlay = nil
        fpsLabel = nil
        memoryLabel = nil
        qualityLabel = nil
        statisticsLabels.removeAll()
    }

    // MARK: - Object Pooling

    /// Object pool for performance optimization
    private var objectPool: [Any] = []
    private let maxPoolSize = 50

    /// Get an object from the pool or create new one
    private func getPooledObject<T>() -> T? {
        if let pooled = objectPool.popLast() as? T {
            return pooled
        }
        return nil
    }

    /// Return an object to the pool
    private func returnToPool(_ object: Any) {
        if objectPool.count < maxPoolSize {
            objectPool.append(object)
        }
    }

    // MARK: - Performance Monitoring

    /// Enables or disables performance monitoring overlay
    /// - Parameter enabled: Whether to show performance stats
    func setPerformanceMonitoring(enabled: Bool) {
        performanceMonitoringEnabled = enabled

        if enabled {
            setupPerformanceOverlay()
            startPerformanceUpdates()
        } else {
            hidePerformanceOverlay()
            stopPerformanceUpdates()
        }
    }

    /// Toggles performance monitoring overlay
    func togglePerformanceMonitoring() {
        setPerformanceMonitoring(enabled: !performanceMonitoringEnabled)
    }

    /// Sets up the performance monitoring overlay
    private func setupPerformanceOverlay() {
        guard let scene else { return }

        // Create overlay container
        performanceOverlay = SKNode()
        performanceOverlay?.zPosition = 200 // Above everything else

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

        performanceOverlay?.addChild(background)
        if let fpsLabel { performanceOverlay?.addChild(fpsLabel) }
        if let memoryLabel { performanceOverlay?.addChild(memoryLabel) }
        if let qualityLabel { performanceOverlay?.addChild(qualityLabel) }

        scene.addChild(performanceOverlay!)
    }

    /// Hides the performance monitoring overlay
    private func hidePerformanceOverlay() {
        performanceOverlay?.removeFromParent()
        performanceOverlay = nil
        fpsLabel = nil
        memoryLabel = nil
        qualityLabel = nil
    }

    /// Starts periodic performance updates
    private func startPerformanceUpdates() {
        performanceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updatePerformanceDisplay()
        }
    }

    /// Stops performance updates
    private func stopPerformanceUpdates() {
        performanceUpdateTimer?.invalidate()
        performanceUpdateTimer = nil
    }

    /// Updates the performance display with current stats
    private func updatePerformanceDisplay() {
        let stats = PerformanceManager.shared.getPerformanceStats()

        // Update FPS
        fpsLabel?.text = String(format: "FPS: %.1f", stats.averageFPS)
        fpsLabel?.fontColor = stats.averageFPS >= 55 ? .green : (stats.averageFPS >= 30 ? .yellow : .red)

        // Update Memory
        let memoryMB = Double(stats.currentMemoryUsage) / (1024 * 1024)
        memoryLabel?.text = String(format: "MEM: %.1f MB", memoryMB)
        memoryLabel?.fontColor = memoryMB < 50 ? .cyan : (memoryMB < 100 ? .yellow : .red)

        // Update Quality
        switch stats.currentQualityLevel {
        case .high:
            qualityLabel?.text = "QUAL: HIGH"
            qualityLabel?.fontColor = .green
        case .medium:
            qualityLabel?.text = "QUAL: MED"
            qualityLabel?.fontColor = .yellow
        case .low:
            qualityLabel?.text = "QUAL: LOW"
            qualityLabel?.fontColor = .red
        }
    }

    // MARK: - Async UI Updates

    /// Updates the high score display asynchronously
    /// - Parameter highScore: New high score value
    func updateHighScoreAsync(_ highScore: Int) async {
        await Task.detached {
            self.updateHighScore(highScore)
        }.value
    }

    /// Shows game statistics overlay asynchronously
    /// - Parameter statistics: Dictionary of statistics to display
    func showStatisticsAsync(_ statistics: [String: Any]) async {
        await Task.detached {
            self.showStatistics(statistics)
        }.value
    }
}
