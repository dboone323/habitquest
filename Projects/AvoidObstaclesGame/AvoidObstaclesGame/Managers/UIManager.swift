//
// UIManager.swift
// AvoidObstaclesGame
//
// Manages all user interface elements including labels, game over screens,
// level up effects, and HUD updates.
//

import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Protocol for UI-related events
protocol UIManagerDelegate: AnyObject {
    func restartButtonTapped()
}

// MARK: - Accessibility Manager Delegate

@MainActor
extension UIManager: AccessibilityManagerDelegate {
    func accessibilitySettingsDidChange(from oldSettings: AccessibilitySettings, to newSettings: AccessibilitySettings) {
        // Update all UI elements with new accessibility settings
        self.updateAllUIFontSizes()
        self.updateAllUIColors()
    }
}

/// Manages all UI elements and visual feedback
@MainActor
class UIManager {
    // MARK: - Properties

    /// Delegate for UI events
    weak var delegate: UIManagerDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Accessibility manager for dynamic text and high contrast support
    private let accessibilityManager: AccessibilityManager

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

    #if os(iOS) || os(tvOS)
        /// Accessibility overlay for VoiceOver support
        private var accessibilityOverlay: UIView?
        private var restartButton: UIButton?
    #endif

    /// Performance monitoring timer
    private var performanceUpdateTimer: Timer?
    private var performanceMonitoringEnabled: Bool = false

    // MARK: - Initialization

    init(scene: SKScene) {
        self.scene = scene
        self.accessibilityManager = AccessibilityManager()

        // Pre-create reusable actions
        self.pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5),
        ])

        self.fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        self.fadeOutAction = SKAction.fadeOut(withDuration: 0.3)

        // Set up accessibility delegate after initialization
        self.accessibilityManager.delegate = self
    }

    /// Updates the scene reference (called when scene is properly initialized)
    func updateScene(_ scene: SKScene) {
        self.scene = scene
        #if os(iOS) || os(tvOS)
            self.setupAccessibilityOverlay()
        #endif
    }

    // MARK: - Setup

    /// Sets up all initial UI elements
    func setupUI() {
        self.setupScoreLabel()
        self.setupHighScoreLabel()
        self.setupDifficultyLabel()
        #if os(iOS) || os(tvOS)
            self.updateAccessibilityState()
        #endif
    }

    /// Sets up the score label
    private func setupScoreLabel() {
        guard let scene else { return }

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        guard let scoreLabel else { return }

        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 24, style: .body)
        scoreLabel.fontColor = self.accessibilityManager.uiColors().textColor
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
        highScoreLabel.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 20, style: .caption)
        highScoreLabel.fontColor = self.accessibilityManager.uiColors().secondaryTextColor
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
        difficultyLabel.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 18, style: .caption)
        difficultyLabel.fontColor = self.accessibilityManager.uiColors().accentColor
        difficultyLabel.horizontalAlignmentMode = .right
        difficultyLabel.position = CGPoint(x: scene.size.width - 20, y: scene.size.height - 40)
        difficultyLabel.zPosition = 100

        scene.addChild(difficultyLabel)
    }

    // MARK: - Accessibility Support

    #if os(iOS) || os(tvOS)
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
            self.accessibilityManager.announce("Game started. Tap screen to control player.")
        }

        /// Updates accessibility state based on current game state
        private func updateAccessibilityState() {
            let score = self.scoreLabel?.text ?? "Score: 0"
            let level = self.difficultyLabel?.text ?? "Level: 1"
            let highScore = self.highScoreLabel?.text ?? "Best: 0"

            // Update overlay accessibility if it exists
            #if os(iOS) || os(tvOS)
                self.accessibilityOverlay?.accessibilityLabel = "Avoid Obstacles Game - \(score). \(level). \(highScore). Tap to move player."
            #endif
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
    #endif

    // MARK: - Updates

    /// Updates the score display
    /// - Parameter score: New score value
    func updateScore(_ score: Int) {
        self.scoreLabel?.text = "Score: \(score)"
        #if os(iOS) || os(tvOS)
            self.updateAccessibilityState()
        #endif
    }

    /// Updates the high score display
    /// - Parameter highScore: New high score value
    func updateHighScore(_ highScore: Int) {
        self.highScoreLabel?.text = "Best: \(highScore)"
        #if os(iOS) || os(tvOS)
            self.updateAccessibilityState()
        #endif
    }

    /// Updates the difficulty level display
    /// - Parameter level: New difficulty level
    func updateDifficultyLevel(_ level: Int) {
        self.difficultyLabel?.text = "Level: \(level)"
        #if os(iOS) || os(tvOS)
            self.updateAccessibilityState()
        #endif
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
        gameOverLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 40, style: .title)
        gameOverLabel?.fontColor = self.accessibilityManager.uiColors().textColor
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
        finalScoreLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 28, style: .headline)
        finalScoreLabel?.fontColor = self.accessibilityManager.uiColors().textColor
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
            highScoreAchievedLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 24, style: .headline)
            highScoreAchievedLabel?.fontColor = self.accessibilityManager.uiColors().accentColor
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
        restartLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 25, style: .body)
        restartLabel?.fontColor = self.accessibilityManager.uiColors().secondaryTextColor
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
        #if os(iOS) || os(tvOS)
            self.showAccessibilityRestartButton()
        #endif

        // Announce game over state
        #if os(iOS) || os(tvOS)
            let announcement = isNewHighScore ?
                "Game over. Final score: \(finalScore). New high score achieved! Tap restart button to play again." :
                "Game over. Final score: \(finalScore). Tap restart button to play again."
            self.accessibilityManager.announce(announcement)
        #endif
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
        #if os(iOS) || os(tvOS)
            self.hideAccessibilityRestartButton()

            // Announce game restart
            self.accessibilityManager.announce("Game restarted. Tap screen to control player.")
        #endif
    }

    // MARK: - Level Up Effects

    /// Shows a level up effect
    func showLevelUpEffect() {
        guard let scene else { return }

        levelUpLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelUpLabel?.text = "LEVEL UP!"
        levelUpLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 32, style: .title)
        levelUpLabel?.fontColor = self.accessibilityManager.uiColors().accentColor
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
        #if os(iOS) || os(tvOS)
            self.accessibilityManager.announce("Level up! Difficulty increased.")
        #endif
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
        scoreLabel.fontColor = self.accessibilityManager.uiColors().accentColor
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
        #if os(iOS) || os(tvOS)
            if score >= 10 {
                self.accessibilityManager.announce("Score increased by \(score) points")
            }
        #endif
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
            label.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 18, style: .body)
            label.fontColor = self.accessibilityManager.uiColors().textColor
            label.position = CGPoint(x: scene.size.width / 2, y: currentY)
            label.zPosition = 150

            // Add background for readability
            let background = SKShapeNode(rectOf: CGSize(width: 120, height: 70))
            background.fillColor = self.accessibilityManager.uiColors().backgroundColor.withAlphaComponent(0.7)
            background.strokeColor = self.accessibilityManager.uiColors().borderColor.withAlphaComponent(0.3)
            background.lineWidth = 1
            background.position = CGPoint(x: 60, y: scene.size.height - 50)
            background.zPosition = -1

            self.performanceOverlay?.addChild(background)
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
           restartLabel.contains(location)
        {
            self.delegate?.restartButtonTapped()
        }
    }

    // MARK: - Accessibility Updates

    /// Updates all UI elements with current accessibility font sizes
    private func updateAllUIFontSizes() {
        self.scoreLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 24, style: .body)
        self.highScoreLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 20, style: .caption)
        self.difficultyLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 18, style: .caption)
        self.gameOverLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 40, style: .title)
        self.finalScoreLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 28, style: .headline)
        self.restartLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 25, style: .body)
        self.highScoreAchievedLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 24, style: .headline)
        self.levelUpLabel?.fontSize = self.accessibilityManager.dynamicFontSize(baseSize: 32, style: .title)
    }

    /// Updates all UI elements with current accessibility colors
    private func updateAllUIColors() {
        let colors = self.accessibilityManager.uiColors()

        self.scoreLabel?.fontColor = colors.textColor
        self.highScoreLabel?.fontColor = colors.secondaryTextColor
        self.difficultyLabel?.fontColor = colors.accentColor
        self.gameOverLabel?.fontColor = colors.textColor
        self.finalScoreLabel?.fontColor = colors.textColor
        self.restartLabel?.fontColor = colors.secondaryTextColor
        self.highScoreAchievedLabel?.fontColor = colors.accentColor
        self.levelUpLabel?.fontColor = colors.accentColor

        // Update statistics labels (every other label is a background)
        for (index, label) in self.statisticsLabels.enumerated() {
            if index % 2 == 0 { // Text labels
                if let textLabel = label as? SKLabelNode {
                    textLabel.fontColor = colors.textColor
                }
            } else { // Background labels
                if let backgroundLabel = label as? SKShapeNode {
                    backgroundLabel.fillColor = colors.backgroundColor.withAlphaComponent(0.7)
                    backgroundLabel.strokeColor = colors.borderColor.withAlphaComponent(0.3)
                }
            }
        }

        // Update performance monitoring labels
        self.fpsLabel?.fontColor = colors.textColor
        self.memoryLabel?.fontColor = colors.textColor
        self.qualityLabel?.fontColor = colors.textColor

        // Update performance overlay background
        if let performanceOverlay = self.performanceOverlay {
            for child in performanceOverlay.children {
                if let background = child as? SKShapeNode {
                    background.fillColor = colors.backgroundColor.withAlphaComponent(0.7)
                    background.strokeColor = colors.borderColor.withAlphaComponent(0.3)
                }
            }
        }
    }

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
        #if os(iOS) || os(tvOS)
            self.accessibilityOverlay?.removeFromSuperview()
        #endif

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
        #if os(iOS) || os(tvOS)
            self.accessibilityOverlay = nil
            self.restartButton = nil
        #endif
        self.statisticsLabels.removeAll()
    }

    // MARK: - Object Pooling

    /// Object pool for performance optimization
    private nonisolated(unsafe) var objectPool: [Any] = []
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
        fpsLabel?.fontColor = self.accessibilityManager.uiColors().textColor
        fpsLabel?.horizontalAlignmentMode = .left
        fpsLabel?.position = CGPoint(x: 10, y: scene.size.height - 30)

        // Memory Label
        memoryLabel = SKLabelNode(fontNamed: "Menlo")
        memoryLabel?.text = "MEM: -- MB"
        memoryLabel?.fontSize = 14
        memoryLabel?.fontColor = self.accessibilityManager.uiColors().textColor
        memoryLabel?.horizontalAlignmentMode = .left
        memoryLabel?.position = CGPoint(x: 10, y: scene.size.height - 50)

        // Quality Label
        qualityLabel = SKLabelNode(fontNamed: "Menlo")
        qualityLabel?.text = "QUAL: HIGH"
        qualityLabel?.fontSize = 14
        qualityLabel?.fontColor = self.accessibilityManager.uiColors().textColor
        qualityLabel?.horizontalAlignmentMode = .left
        qualityLabel?.position = CGPoint(x: 10, y: scene.size.height - 70)

        // Add background for readability
        let background = SKShapeNode(rectOf: CGSize(width: 120, height: 70))
        background.fillColor = self.accessibilityManager.uiColors().backgroundColor.withAlphaComponent(0.7)
        background.strokeColor = self.accessibilityManager.uiColors().borderColor.withAlphaComponent(0.3)
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
            Task { [weak self] in
                await self?.updatePerformanceDisplay()
            }
        }
    }

    /// Stops performance updates
    private func stopPerformanceUpdates() {
        self.performanceUpdateTimer?.invalidate()
        self.performanceUpdateTimer = nil
    }

    /// Updates the performance display with current stats
    @MainActor
    private func updatePerformanceDisplay() {
        let stats = PerformanceManager.shared.getPerformanceStats()
        let colors = self.accessibilityManager.uiColors()

        // Update FPS
        self.fpsLabel?.text = String(format: "FPS: %.1f", stats.averageFPS)
        self.fpsLabel?.fontColor = stats.averageFPS >= 55 ? colors.accentColor : (stats.averageFPS >= 30 ? colors.secondaryTextColor : .red)

        // Update Memory
        let memoryMB = Double(stats.currentMemoryUsage) / (1024 * 1024)
        self.memoryLabel?.text = String(format: "MEM: %.1f MB", memoryMB)
        self.memoryLabel?.fontColor = memoryMB < 50 ? colors.accentColor : (memoryMB < 100 ? colors.secondaryTextColor : .red)

        // Update Quality
        switch stats.currentQualityLevel {
        case .high:
            self.qualityLabel?.text = "QUAL: HIGH"
            self.qualityLabel?.fontColor = colors.accentColor
        case .medium:
            self.qualityLabel?.text = "QUAL: MED"
            self.qualityLabel?.fontColor = colors.secondaryTextColor
        case .low:
            self.qualityLabel?.text = "QUAL: LOW"
            self.qualityLabel?.fontColor = .red
        }
    }

    // MARK: - Async UI Updates

    /// Updates the high score display asynchronously
    /// - Parameter highScore: New high score value
    func updateHighScoreAsync(_ highScore: Int) async {
        await MainActor.run {
            self.updateHighScore(highScore)
        }
    }

    /// Shows game statistics overlay asynchronously
    /// - Parameter statistics: Dictionary of statistics to display
    func showStatisticsAsync(_ statistics: [String: Any]) async {
        await MainActor.run {
            self.showStatistics(statistics)
        }
    }

    // MARK: - AI Notifications

    /// Shows a notification when difficulty changes
    /// - Parameters:
    ///   - newDifficulty: The new AI difficulty level
    ///   - reason: The reason for the difficulty adjustment
    func showDifficultyChangeNotification(_ newDifficulty: AIAdaptiveDifficulty, reason: DifficultyAdjustmentReason) {
        guard let scene else { return }

        // Create notification label
        let notificationLabel = SKLabelNode(fontNamed: "Chalkduster")
        notificationLabel.fontSize = 28
        notificationLabel.fontColor = self.accessibilityManager.uiColors().textColor
        notificationLabel.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 50)
        notificationLabel.zPosition = 300 // Above other UI elements

        // Set notification text based on difficulty change
        let difficultyText: String
        let color: SKColor

        switch newDifficulty {
        case .veryEasy:
            difficultyText = "Difficulty: Very Easy"
            color = self.accessibilityManager.uiColors().accentColor
        case .easy:
            difficultyText = "Difficulty: Easy"
            color = self.accessibilityManager.uiColors().accentColor
        case .balanced:
            difficultyText = "Difficulty: Balanced"
            color = self.accessibilityManager.uiColors().secondaryTextColor
        case .challenging:
            difficultyText = "Difficulty: Challenging"
            color = .orange
        case .hard:
            difficultyText = "Difficulty: Hard"
            color = .orange
        case .veryHard:
            difficultyText = "Difficulty: Very Hard"
            color = .red
        case .expert:
            difficultyText = "Difficulty: Expert"
            color = .red
        case .nightmare:
            difficultyText = "Difficulty: Nightmare"
            color = .purple
        }

        notificationLabel.text = difficultyText
        notificationLabel.fontColor = color

        // Add reason subtitle if available
        let reasonLabel = SKLabelNode(fontNamed: "Chalkduster")
        reasonLabel.text = reason.description
        reasonLabel.fontSize = 18
        reasonLabel.fontColor = self.accessibilityManager.uiColors().secondaryTextColor
        reasonLabel.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 10)
        reasonLabel.zPosition = 300

        // Add background for readability
        let background = SKShapeNode(rectOf: CGSize(width: scene.size.width * 0.6, height: 80))
        background.fillColor = self.accessibilityManager.uiColors().backgroundColor.withAlphaComponent(0.8)
        background.strokeColor = color.withAlphaComponent(0.5)
        background.lineWidth = 2
        background.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 30)
        background.zPosition = 299

        scene.addChild(background)
        scene.addChild(notificationLabel)
        scene.addChild(reasonLabel)

        // Animate notification
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        let notificationSequence = SKAction.sequence([fadeIn, wait, fadeOut, remove])

        background.run(notificationSequence)
        notificationLabel.run(notificationSequence)
        reasonLabel.run(notificationSequence)

        // Announce difficulty change to VoiceOver
        #if os(iOS) || os(tvOS)
            self.accessibilityManager.announce("Difficulty adjusted to \(difficultyText.lowercased()). \(reason.description)")
        #endif
    }

    /// Updates the display of player skill level
    /// - Parameters:
    ///   - skillLevel: The assessed player skill level
    ///   - confidence: Confidence score of the assessment (0.0 to 1.0)
    func updatePlayerSkillLevel(_ skillLevel: PlayerSkillLevel, confidence: Double) {
        guard scene != nil else { return }

        // Update difficulty label to show skill level
        let skillText: String
        let color: SKColor

        switch skillLevel {
        case .beginner:
            skillText = "Skill: Beginner"
            color = .green
        case .novice:
            skillText = "Skill: Novice"
            color = .green
        case .intermediate:
            skillText = "Skill: Intermediate"
            color = .yellow
        case .advanced:
            skillText = "Skill: Advanced"
            color = .orange
        case .expert:
            skillText = "Skill: Expert"
            color = .red
        case .master:
            skillText = "Skill: Master"
            color = .purple
        }

        // Create or update skill level label
        if let existingSkillLabel = self.difficultyLabel {
            // Temporarily show skill level instead of difficulty
            let originalText = existingSkillLabel.text
            existingSkillLabel.text = skillText
            existingSkillLabel.fontColor = color

            // Flash effect to draw attention
            let flashAction = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2),
                SKAction.wait(forDuration: 1.5),
            ])

            existingSkillLabel.run(flashAction) {
                // Restore original difficulty display
                existingSkillLabel.text = originalText
                existingSkillLabel.fontColor = .blue
            }
        }

        // Announce skill assessment to VoiceOver
        #if os(iOS) || os(tvOS)
            let confidencePercent = Int(confidence * 100)
            self.accessibilityManager.announce("Player skill assessed as \(skillText.lowercased()) with \(confidencePercent)% confidence")
        #endif
    }
}
