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

    /// Accessibility overlay for VoiceOver support
    private var accessibilityOverlay: UIView?
    private var restartButton: UIButton?
    private var gameStateAnnouncement: String = ""

    /// Performance monitoring timer
    private var performanceUpdateTimer: Timer?

    /// Whether performance monitoring is visible
    private var performanceMonitoringEnabled = false

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene

        // Pre-create reusable actions
        self.pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5),
        ])

        self.fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        self.fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
    }

    /// Updates the scene reference (called when scene is properly initialized)
    func updateScene(_ scene: SKScene) {
        self.scene = scene
        self.setupAccessibilityOverlay()
    }

    // MARK: - Setup

    /// Sets up all initial UI elements
    func setupUI() {
        self.setupScoreLabel()
        self.setupHighScoreLabel()
        self.setupDifficultyLabel()
        self.updateAccessibilityState()
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

    // MARK: - Accessibility Support

    /// Sets up accessibility overlay for VoiceOver support
    private func setupAccessibilityOverlay() {
        guard let scene else { return }

        // Create accessibility overlay view
        let overlay = UIView(frame: scene.view?.bounds ?? .zero)
        overlay.isAccessibilityElement = false
        overlay.accessibilityLabel = "Avoid Obstacles Game"
        overlay.accessibilityHint = "Tap to control the player character"

        // Create restart button for accessibility
        let button = UIButton(type: .system)
        button.setTitle("Restart Game", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isHidden = true // Initially hidden, shown during game over
        button.addTarget(self, action: #selector(restartButtonTapped), for: .touchUpInside)

        // Set accessibility properties
        button.accessibilityLabel = "Restart Game"
        button.accessibilityHint = "Double tap to start a new game"
        button.accessibilityTraits = .button

        // Position button (will be updated when game over screen is shown)
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 50)

        overlay.addSubview(button)
        scene.view?.addSubview(overlay)

        self.accessibilityOverlay = overlay
        self.restartButton = button

        // Announce initial game state
        self.announceGameState("Game started. Tap screen to control player.")
    }

    /// Updates accessibility state based on current game state
    private func updateAccessibilityState() {
        let score = self.scoreLabel?.text ?? "Score: 0"
        let level = self.difficultyLabel?.text ?? "Level: 1"
        let highScore = self.highScoreLabel?.text ?? "Best: 0"

        self.gameStateAnnouncement = "\(score). \(level). \(highScore). Tap to move player."

        // Update overlay accessibility
        self.accessibilityOverlay?.accessibilityLabel = "Avoid Obstacles Game - \(self.gameStateAnnouncement)"
    }

    /// Announces game state changes to VoiceOver
    /// - Parameter message: The message to announce
    private func announceGameState(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    /// Handles restart button tap for accessibility
    @objc private func restartButtonTapped() {
        self.delegate?.restartButtonTapped()
    }

    /// Shows the accessibility restart button
    private func showAccessibilityRestartButton() {
        guard let scene, let restartButton else { return }

        // Position button near the visual restart label
        let buttonWidth: CGFloat = 150
        let buttonHeight: CGFloat = 50
        let centerX = scene.size.width / 2
        let centerY = scene.size.height / 2 - 40

        restartButton.frame = CGRect(
            x: centerX - buttonWidth / 2,
            y: centerY - buttonHeight / 2,
            width: buttonWidth,
            height: buttonHeight
        )

        restartButton.isHidden = false
        restartButton.becomeFirstResponder()
    }

    /// Hides the accessibility restart button
    private func hideAccessibilityRestartButton() {
        self.restartButton?.isHidden = true
    }

    // MARK: - Updates

    /// Updates the score display
    /// - Parameter score: New score value
    func updateScore(_ score: Int) {
        self.scoreLabel?.text = "Score: \(score)"
        self.updateAccessibilityState()
    }

    /// Updates the high score display
    /// - Parameter highScore: New high score value
    func updateHighScore(_ highScore: Int) {
        self.highScoreLabel?.text = "Best: \(highScore)"
        self.updateAccessibilityState()
    }

    /// Updates the difficulty level display
    /// - Parameter level: New difficulty level
    func updateDifficultyLevel(_ level: Int) {
        self.difficultyLabel?.text = "Level: \(level)"
        self.updateAccessibilityState()
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

        // Show accessibility restart button
        self.showAccessibilityRestartButton()

        // Announce game over state
        let announcement = isNewHighScore ?
            "Game over. Final score: \(finalScore). New high score achieved! Tap restart button to play again." :
            "Game over. Final score: \(finalScore). Tap restart button to play again."
        self.announceGameState(announcement)
    }

    /// Hides the game over screen
    func hideGameOverScreen() {
        let labels = [gameOverLabel, restartLabel, highScoreAchievedLabel, finalScoreLabel]
        for label in labels {
            label?.run(SKAction.sequence([self.fadeOutAction, SKAction.removeFromParent()]))
        }

        self.gameOverLabel = nil
        self.restartLabel = nil
        self.highScoreAchievedLabel = nil
        self.finalScoreLabel = nil

        // Hide accessibility restart button
        self.hideAccessibilityRestartButton()

        // Announce game restart
        self.announceGameState("Game restarted. Tap screen to control player.")
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
                self.fadeOutAction,
                SKAction.removeFromParent(),
            ])

            levelUpLabel.run(animation) { [weak self] in
                self?.levelUpLabel = nil
            }
        }

        // Announce level up to VoiceOver
        self.announceGameState("Level up! Difficulty increased.")
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

        // Announce score increase to VoiceOver (only for significant scores to avoid spam)
        if score >= 10 {
            self.announceGameState("Score increased by \(score) points")
        }
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
        ] + self.statisticsLabels

        for label in allLabels {
            label?.removeFromParent()
        }

        // Clean up performance monitoring
        self.stopPerformanceUpdates()
        self.performanceOverlay?.removeFromParent()

        // Clean up accessibility overlay
        self.accessibilityOverlay?.removeFromSuperview()

        self.scoreLabel = nil
        self.highScoreLabel = nil
        self.difficultyLabel = nil
        self.gameOverLabel = nil
        self.restartLabel = nil
        self.highScoreAchievedLabel = nil
        self.finalScoreLabel = nil
        self.levelUpLabel = nil
        self.performanceOverlay = nil
        self.fpsLabel = nil
        self.memoryLabel = nil
        self.qualityLabel = nil
        self.accessibilityOverlay = nil
        self.restartButton = nil
        self.statisticsLabels.removeAll()
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
        if self.objectPool.count < self.maxPoolSize {
            self.objectPool.append(object)
        }
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
