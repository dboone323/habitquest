//
// GameHUDManager.swift
// AvoidObstaclesGame
//
// Consolidated HUD manager combining HUD display, statistics overlay, and performance monitoring.
// Implements AI-recommended manager consolidation for improved code organization.
//

import Foundation
import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Protocol for GameHUDManager events
@MainActor
protocol GameHUDManagerDelegate: AnyObject {
    func restartButtonTapped()
    func settingsDidChange(_ settings: SettingsData)
    func themeDidChange(to theme: Theme)
}

/// Consolidated HUD manager for all game interface elements
@MainActor
class GameHUDManager: ThemeDelegate {
    // MARK: - Properties

    /// Delegate for HUD events
    weak var delegate: GameHUDManagerDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Theme manager for dynamic theming
    private let themeManager = ThemeManager.shared

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

    /// Multiplayer UI Elements
    private var multiplayerStatusLabel: SKLabelNode?
    private var playerScoreLabels: [String: SKLabelNode] = [:]
    private var turnIndicatorLabel: SKLabelNode?
    private var multiplayerWinnerLabel: SKLabelNode?

    /// Game Mode UI Elements
    private var gameModeLabel: SKLabelNode?
    private var objectiveLabels: [SKLabelNode] = []

    /// Theme Toggle Button
    private var themeToggleButton: SKLabelNode?

    /// Settings Button
    private var settingsButton: SKLabelNode?

    /// Settings Manager
    private var settingsManager: SettingsManager?

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
        self.settingsManager = SettingsManager(scene: scene)
        self.settingsManager?.delegate = self
        self.setupHUD()
        self.themeManager.delegate = self
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

        // Theme Toggle Button
        themeToggleButton = SKLabelNode(fontNamed: "Chalkduster")
        themeToggleButton?.text = themeManager.currentTheme.mode == .dark ? "☀️" : "🌙"
        themeToggleButton?.fontSize = 20
        themeToggleButton?.fontColor = .systemBlue
        themeToggleButton?.position = CGPoint(x: scene.size.width - 20, y: scene.size.height - 70)
        themeToggleButton?.zPosition = 100
        themeToggleButton?.name = "themeToggle"

        // Settings Button
        settingsButton = SKLabelNode(fontNamed: "Chalkduster")
        settingsButton?.text = "⚙️"
        settingsButton?.fontSize = 20
        settingsButton?.fontColor = .systemBlue
        settingsButton?.position = CGPoint(x: scene.size.width - 60, y: scene.size.height - 70)
        settingsButton?.zPosition = 100
        settingsButton?.name = "settingsButton"

        // Add to scene
        if let scoreLabel { scene.addChild(scoreLabel) }
        if let highScoreLabel { scene.addChild(highScoreLabel) }
        if let difficultyLabel { scene.addChild(difficultyLabel) }
        if let themeToggleButton { scene.addChild(themeToggleButton) }
        if let settingsButton { scene.addChild(settingsButton) }
    }

    /// Sets up the performance monitoring overlay
    @MainActor
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
    @MainActor
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
    @MainActor
    func hideStatistics() {
        for label in self.statisticsLabels {
            label.run(SKAction.sequence([self.fadeOutAction, SKAction.removeFromParent()]))
        }
        self.statisticsLabels.removeAll()
    }

    /// Formats a statistic key for display
    /// - Parameter key: The raw statistic key
    /// - Returns: Formatted key string
    private func formatStatisticKey(_ key: String) -> String {
        // Convert camelCase to Title Case with spaces
        let words = key.components(separatedBy: CharacterSet.uppercaseLetters)
            .filter { !$0.isEmpty }
            .map(\.capitalized)
        return words.joined(separator: " ")
    }

    /// Formats a statistic value for display
    /// - Parameter value: The raw statistic value
    /// - Returns: Formatted value string
    private func formatStatisticValue(_ value: Any) -> String {
        if let intValue = value as? Int {
            return "\(intValue)"
        } else if let doubleValue = value as? Double {
            return String(format: "%.2f", doubleValue)
        } else if let stringValue = value as? String {
            return stringValue
        } else {
            return "\(value)"
        }
    }

    // MARK: - Performance Monitoring

    /// Enables or disables performance monitoring overlay
    /// - Parameter enabled: Whether to show performance stats
    @MainActor
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
    @MainActor
    private func hidePerformanceOverlay() {
        self.performanceOverlay?.removeFromParent()
    }

    /// Starts periodic performance updates
    @MainActor
    private func startPerformanceUpdates() {
        self.performanceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updatePerformanceDisplay()
            }
        }
    }

    /// Stops performance updates
    @MainActor
    private func stopPerformanceUpdates() {
        self.performanceUpdateTimer?.invalidate()
        self.performanceUpdateTimer = nil
    }

    /// Updates the performance display with current stats
    @MainActor
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
    @MainActor
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
    @MainActor
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
    @MainActor
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
    @MainActor
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

    /// Shows an achievement notification
    /// - Parameter achievement: The achievement that was unlocked
    @MainActor
    func showAchievementNotification(_ achievement: Achievement) {
        guard let scene else { return }

        let achievementLabel = SKLabelNode(fontNamed: "Chalkduster")
        achievementLabel.text = "🏆 \(achievement.title) 🏆"
        achievementLabel.fontSize = 28
        achievementLabel.fontColor = .yellow
        achievementLabel.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 50)
        achievementLabel.zPosition = 200

        let descriptionLabel = SKLabelNode(fontNamed: "Chalkduster")
        descriptionLabel.text = achievement.description
        descriptionLabel.fontSize = 18
        descriptionLabel.fontColor = .white
        descriptionLabel.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        descriptionLabel.zPosition = 200

        // Add background
        let background = SKShapeNode(rectOf: CGSize(width: scene.size.width * 0.8, height: 80))
        background.fillColor = .black.withAlphaComponent(0.8)
        background.strokeColor = .yellow
        background.lineWidth = 2
        background.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 25)
        background.zPosition = 199

        scene.addChild(background)
        scene.addChild(achievementLabel)
        scene.addChild(descriptionLabel)

        // Animate
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, remove])

        achievementLabel.alpha = 0
        descriptionLabel.alpha = 0
        background.alpha = 0

        achievementLabel.run(sequence)
        descriptionLabel.run(sequence)
        background.run(sequence)
    }

    // MARK: - Score Popups

    /// Shows a score popup at the specified position
    /// - Parameters:
    ///   - score: The score value to display
    ///   - position: Where to show the popup
    @MainActor
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

    /// Shows the settings overlay
    @MainActor
    private func showSettings() {
        settingsManager?.showSettings()
    }

    /// Checks if the system is in dark mode
    /// - Returns: True if system is in dark mode
    private func isSystemInDarkMode() -> Bool {
        return themeManager.isSystemInDarkMode()
    }

    /// Updates UI elements to match the current theme
    /// - Parameter theme: The theme to apply
    @MainActor
    private func updateUIForTheme(_ theme: Theme) {
        // Update HUD element colors
        scoreLabel?.fontColor = theme.colors.textPrimary
        highScoreLabel?.fontColor = theme.colors.textSecondary
        difficultyLabel?.fontColor = theme.colors.accentColor
        themeToggleButton?.fontColor = theme.colors.accentColor
        settingsButton?.fontColor = theme.colors.accentColor

        // Update game over screen colors
                        gameOverLabel?.fontColor = theme.colors.dangerColor
        finalScoreLabel?.fontColor = theme.colors.textPrimary
        restartLabel?.fontColor = theme.colors.textSecondary

        // Update multiplayer UI colors
        multiplayerStatusLabel?.fontColor = theme.colors.accentColor
        turnIndicatorLabel?.fontColor = theme.colors.accentColor

        // Update objective colors
        for label in objectiveLabels {
            label.fontColor = theme.colors.textPrimary
        }

        // Update game mode label color
        gameModeLabel?.fontColor = theme.colors.accentColor
    }

    /// Handles touch events for UI interactions
    /// - Parameter location: Touch location in scene coordinates
    @MainActor
    func handleTouch(at location: CGPoint) {
        // Check if theme selector is visible
        if let themeSelector = scene?.childNode(withName: "themeSelectorOverlay") {
            // Handle theme selector touches
            handleThemeSelectorTouch(at: location, in: themeSelector)
            return
        }

        // If settings overlay is visible, forward touch to settings manager
        if settingsManager?.isSettingsVisible() == true {
            settingsManager?.handleTouch(at: location)
            return
        }

        // Check if restart label was tapped
        if let restartLabel,
           restartLabel.contains(location)
        {
            self.delegate?.restartButtonTapped()
        }

        // Check if theme toggle button was tapped
        if let themeToggleButton,
           themeToggleButton.contains(location)
        {
            self.showThemeSelector()
        }

        // Check if settings button was tapped
        if let settingsButton,
           settingsButton.contains(location)
        {
            self.showSettings()
        }
    }
    /// Handles touches within the theme selector overlay
    /// - Parameters:
    ///   - location: Touch location
    ///   - overlay: Theme selector overlay node
    @MainActor
    private func handleThemeSelectorTouch(at location: CGPoint, in overlay: SKNode) {
        // Convert location to overlay coordinates
        let overlayLocation = overlay.convert(location, from: scene!)

        // Check if a theme button was tapped
        for child in overlay.children {
            if child.name?.hasPrefix("themeButton_") == true,
               child.contains(overlayLocation) {

                // Extract theme mode from button name
                if let name = child.name,
                   let modeString = name.components(separatedBy: "_").last,
                   let themeMode = ThemeMode(rawValue: modeString) {

                    // Apply the selected theme
                    themeManager.setThemeMode(themeMode)

                    // Close theme selector
                    overlay.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.removeFromParent()
                    ]))
                }
                return
            }
        }

        // If tapped outside buttons, close the selector
        overlay.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Multiplayer UI

    /// Shows multiplayer status with player count
    /// - Parameter playerCount: Number of players in the game
    @MainActor
    func showMultiplayerStatus(playerCount: Int) {
        guard let scene else { return }

        multiplayerStatusLabel = SKLabelNode(fontNamed: "Chalkduster")
        multiplayerStatusLabel?.text = "Multiplayer: \(playerCount) Players"
        multiplayerStatusLabel?.fontSize = 18
        multiplayerStatusLabel?.fontColor = .blue
        multiplayerStatusLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height - 40)
        multiplayerStatusLabel?.zPosition = 100

        if let multiplayerStatusLabel {
            multiplayerStatusLabel.alpha = 0
            scene.addChild(multiplayerStatusLabel)
            multiplayerStatusLabel.run(self.fadeInAction)
        }
    }

    /// Updates the score display for a specific multiplayer player
    /// - Parameters:
    ///   - playerId: The player's identifier
    ///   - score: The player's new score
    @MainActor
    func updateMultiplayerScore(for playerId: String, score: Int) {
        guard let scene else { return }

        let scoreLabel = playerScoreLabels[playerId] ?? {
            let label = SKLabelNode(fontNamed: "Chalkduster")
            label.fontSize = 16
            label.zPosition = 100
            playerScoreLabels[playerId] = label
            scene.addChild(label)
            return label
        }()

        scoreLabel.text = "Player \(playerId): \(score)"

        // Position labels vertically
        let playerIndex = Int(playerId) ?? 0
        scoreLabel.position = CGPoint(x: scene.size.width - 100, y: scene.size.height - 80 - CGFloat(playerIndex * 25))
    }

    /// Shows the winner of a multiplayer game
    /// - Parameter winner: The winning player's identifier
    @MainActor
    func showMultiplayerWinner(winner: String) {
        guard let scene else { return }

        multiplayerWinnerLabel = SKLabelNode(fontNamed: "Chalkduster")
        multiplayerWinnerLabel?.text = "🏆 Player \(winner) Wins! 🏆"
        multiplayerWinnerLabel?.fontSize = 32
        multiplayerWinnerLabel?.fontColor = .green
        multiplayerWinnerLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        multiplayerWinnerLabel?.zPosition = 150

        if let multiplayerWinnerLabel {
            multiplayerWinnerLabel.alpha = 0
            scene.addChild(multiplayerWinnerLabel)
            multiplayerWinnerLabel.run(SKAction.sequence([
                self.fadeInAction,
                SKAction.wait(forDuration: 2.0),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent(),
            ])) { [weak self] in
                self?.multiplayerWinnerLabel = nil
            }
        }
    }

    /// Shows that the multiplayer game ended in a draw
    @MainActor
    func showMultiplayerDraw() {
        guard let scene else { return }

        multiplayerWinnerLabel = SKLabelNode(fontNamed: "Chalkduster")
        multiplayerWinnerLabel?.text = "🤝 It's a Draw! 🤝"
        multiplayerWinnerLabel?.fontSize = 32
        multiplayerWinnerLabel?.fontColor = .orange
        multiplayerWinnerLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        multiplayerWinnerLabel?.zPosition = 150

        if let multiplayerWinnerLabel {
            multiplayerWinnerLabel.alpha = 0
            scene.addChild(multiplayerWinnerLabel)
            multiplayerWinnerLabel.run(SKAction.sequence([
                self.fadeInAction,
                SKAction.wait(forDuration: 2.0),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent(),
            ])) { [weak self] in
                self?.multiplayerWinnerLabel = nil
            }
        }
    }

    /// Shows turn indicator for turn-based multiplayer
    /// - Parameter currentPlayer: The current player's identifier
    @MainActor
    func showTurnIndicator(for currentPlayer: String) {
        guard let scene else { return }

        turnIndicatorLabel?.removeFromParent()

        turnIndicatorLabel = SKLabelNode(fontNamed: "Chalkduster")
        turnIndicatorLabel?.text = "Player \(currentPlayer)'s Turn"
        turnIndicatorLabel?.fontSize = 20
        turnIndicatorLabel?.fontColor = .cyan
        turnIndicatorLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height - 70)
        turnIndicatorLabel?.zPosition = 100

        if let turnIndicatorLabel {
            turnIndicatorLabel.alpha = 0
            scene.addChild(turnIndicatorLabel)
            turnIndicatorLabel.run(self.fadeInAction)
        }
    }

    /// Hides all multiplayer UI elements
    @MainActor
    func hideMultiplayerUI() {
        multiplayerStatusLabel?.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()]))
        turnIndicatorLabel?.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()]))

        for (_, label) in playerScoreLabels {
            label.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()]))
        }

        playerScoreLabels.removeAll()

        self.multiplayerStatusLabel = nil
        self.turnIndicatorLabel = nil
    }

    // MARK: - Game Mode UI

    /// Updates the game mode display
    /// - Parameter mode: The current game mode
    @MainActor
    func updateGameModeDisplay(_ mode: GameMode) {
        guard let scene = self.scene else { return }

        // Remove existing mode label
        self.gameModeLabel?.removeFromParent()

        // Create new mode label
        self.gameModeLabel = SKLabelNode(fontNamed: "Chalkduster")
        self.gameModeLabel?.text = mode.displayName
        self.gameModeLabel?.fontSize = 16
        self.gameModeLabel?.fontColor = .cyan
        self.gameModeLabel?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height - 50)
        self.gameModeLabel?.zPosition = 100

        if let gameModeLabel = self.gameModeLabel {
            gameModeLabel.alpha = 0
            scene.addChild(gameModeLabel)
            gameModeLabel.run(self.fadeInAction)
        }
    }

    /// Shows objectives for the current game mode
    /// - Parameter objectives: Array of game objectives to display
    @MainActor
    func showObjectives(_ objectives: [GameObjective]) {
        guard let scene = self.scene else { return }

        // Clear existing objectives
        self.hideObjectives()

        // Create objective labels
        for (index, objective) in objectives.enumerated() {
            let objectiveLabel = SKLabelNode(fontNamed: "Chalkduster")
            objectiveLabel.text = "\(objective.description): \(Int(objective.progress))/\(Int(objective.type.targetValue))"
            objectiveLabel.fontSize = 14
            objectiveLabel.fontColor = objective.isCompleted ? .green : .white
            objectiveLabel.position = CGPoint(x: 20, y: scene.size.height - 100 - CGFloat(index * 25))
            objectiveLabel.zPosition = 100
            objectiveLabel.horizontalAlignmentMode = .left

            objectiveLabel.alpha = 0
            scene.addChild(objectiveLabel)
            objectiveLabel.run(self.fadeInAction)

            self.objectiveLabels.append(objectiveLabel)
        }
    }

    /// Updates a specific objective's progress
    /// - Parameters:
    ///   - index: Index of the objective to update
    ///   - progress: New progress value
    @MainActor
    func updateObjective(at index: Int, progress: Double) {
        guard index < self.objectiveLabels.count else { return }
        let label = self.objectiveLabels[index]

        // This would need the objective data to format properly
        // For now, just update the progress number
        if let text = label.text,
           let colonIndex = text.firstIndex(of: ":")
        {
            let prefix = text[..<colonIndex]
            label.text = "\(prefix): \(Int(progress))"
        }
    }

    /// Hides all objective displays
    @MainActor
    func hideObjectives() {
        for label in self.objectiveLabels {
            label.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()]))
        }
        self.objectiveLabels.removeAll()
    }

    // MARK: - Menu Management

    /// Shows the pause menu
    @MainActor
    func showPauseMenu() {
        guard let scene else { return }

        // Create pause overlay
        let pauseOverlay = SKShapeNode(rectOf: scene.size)
        pauseOverlay.fillColor = .black.withAlphaComponent(0.5)
        pauseOverlay.strokeColor = .clear
        pauseOverlay.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        pauseOverlay.zPosition = 150
        pauseOverlay.name = "pauseOverlay"

        // Create pause label
        let pauseLabel = SKLabelNode(fontNamed: "Chalkduster")
        pauseLabel.text = "PAUSED"
        pauseLabel.fontSize = 40
        pauseLabel.fontColor = .white
        pauseLabel.position = CGPoint(x: 0, y: 50)
        pauseLabel.zPosition = 151

        // Create resume instruction
        let resumeLabel = SKLabelNode(fontNamed: "Chalkduster")
        resumeLabel.text = "Tap to Resume"
        resumeLabel.fontSize = 24
        resumeLabel.fontColor = .lightGray
        resumeLabel.position = CGPoint(x: 0, y: -20)
        resumeLabel.zPosition = 151

        pauseOverlay.addChild(pauseLabel)
        pauseOverlay.addChild(resumeLabel)
        scene.addChild(pauseOverlay)
    }

    /// Hides the pause menu
    @MainActor
    func hidePauseMenu() {
        scene?.childNode(withName: "pauseOverlay")?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent(),
        ]))
    }

    /// Shows the main menu
    @MainActor
    func showMainMenu() {
        guard let scene else { return }

        // Create menu overlay
        let menuOverlay = SKShapeNode(rectOf: scene.size)
        menuOverlay.fillColor = .black.withAlphaComponent(0.7)
        menuOverlay.strokeColor = .clear
        menuOverlay.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        menuOverlay.zPosition = 150
        menuOverlay.name = "mainMenuOverlay"

        // Create title
        let titleLabel = SKLabelNode(fontNamed: "Chalkduster")
        titleLabel.text = "Avoid Obstacles"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 100)
        titleLabel.zPosition = 151

        // Create start instruction
        let startLabel = SKLabelNode(fontNamed: "Chalkduster")
        startLabel.text = "Tap to Start"
        startLabel.fontSize = 24
        startLabel.fontColor = .yellow
        startLabel.position = CGPoint(x: 0, y: 20)
        startLabel.zPosition = 151

        menuOverlay.addChild(titleLabel)
        menuOverlay.addChild(startLabel)
        scene.addChild(menuOverlay)
    }

    // MARK: - Cleanup

    /// Removes all HUD elements from the scene
    @MainActor
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

        // Remove multiplayer UI
        self.hideMultiplayerUI()

        // Remove game mode UI
        self.gameModeLabel?.removeFromParent()
        self.gameModeLabel = nil
        self.hideObjectives()
    }

    /// Toggles between light and dark theme
    @MainActor
    private func toggleTheme() {
        let nextTheme = themeManager.getNextTheme()
        themeManager.setThemeMode(nextTheme.mode)
    }

    /// Shows theme selection menu
    @MainActor
    private func showThemeSelector() {
        guard let scene else { return }

        // Create theme selector overlay
        let overlay = SKShapeNode(rectOf: scene.size)
        overlay.fillColor = .black.withAlphaComponent(0.7)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        overlay.zPosition = 200
        overlay.name = "themeSelectorOverlay"

        // Create title
        let titleLabel = SKLabelNode(fontNamed: "Chalkduster")
        titleLabel.text = "Choose Theme"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: scene.size.height / 2 - 100)
        titleLabel.zPosition = 201

        overlay.addChild(titleLabel)

        // Create theme buttons
        let themes = themeManager.getAvailableThemes()
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 60
        let spacing: CGFloat = 20
        let totalWidth = CGFloat(themes.count) * (buttonWidth + spacing) - spacing
        let startX = -totalWidth / 2 + buttonWidth / 2

        for (index, theme) in themes.enumerated() {
            let buttonX = startX + CGFloat(index) * (buttonWidth + spacing)

            // Create button background
            let buttonBg = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 8)
            buttonBg.fillColor = theme.colors.backgroundPrimary
            buttonBg.strokeColor = theme.colors.borderColor
            buttonBg.lineWidth = 2
            buttonBg.position = CGPoint(x: buttonX, y: 20)
            buttonBg.zPosition = 201
            buttonBg.name = "themeButton_\(theme.mode.rawValue)"

            // Create theme name label
            let themeLabel = SKLabelNode(fontNamed: "Chalkduster")
            themeLabel.text = theme.name
            themeLabel.fontSize = 16
            themeLabel.fontColor = theme.colors.textPrimary
            themeLabel.position = CGPoint(x: 0, y: 5)
            themeLabel.zPosition = 202

            // Create color preview circles
            let previewColors = themeManager.getThemePreviewColors(for: theme)
            for (colorIndex, color) in previewColors.enumerated() {
                let circle = SKShapeNode(circleOfRadius: 6)
                circle.fillColor = color
                circle.strokeColor = .white
                circle.lineWidth = 1
                circle.position = CGPoint(x: -30 + CGFloat(colorIndex * 15), y: -15)
                circle.zPosition = 202
                buttonBg.addChild(circle)
            }

            buttonBg.addChild(themeLabel)
            overlay.addChild(buttonBg)
        }

        // Create close instruction
        let closeLabel = SKLabelNode(fontNamed: "Chalkduster")
        closeLabel.text = "Tap outside to close"
        closeLabel.fontSize = 16
        closeLabel.fontColor = .lightGray
        closeLabel.position = CGPoint(x: 0, y: -scene.size.height / 2 + 50)
        closeLabel.zPosition = 201

        overlay.addChild(closeLabel)
        scene.addChild(overlay)
    }

    /// Called when the theme changes
    /// - Parameter theme: The new theme
    @MainActor
    func themeDidChange(to theme: Theme) {
        // Update theme toggle button icon based on theme mode
        switch theme.mode {
        case .light:
            themeToggleButton?.text = "☀️"
        case .dark:
            themeToggleButton?.text = "🌙"
        case .blue:
            themeToggleButton?.text = "🔵"
        case .purple:
            themeToggleButton?.text = "🟣"
        case .green:
            themeToggleButton?.text = "🟢"
        case .highContrast:
            themeToggleButton?.text = "⚪"
        case .system:
            themeToggleButton?.text = themeManager.isSystemInDarkMode() ? "🌙" : "☀️"
        case .custom:
            themeToggleButton?.text = "🎨"
        }

        // Update UI colors based on new theme
        updateUIForTheme(theme)

        // Notify delegate (GameScene) about theme change
        delegate?.themeDidChange(to: theme)
    }
}

// MARK: - SettingsManagerDelegate

extension GameHUDManager: SettingsManagerDelegate {
    /// Called when settings are changed
    /// - Parameter settings: The updated settings
    @MainActor
    func settingsDidChange(_ settings: SettingsData) {
        // Handle settings changes that affect the HUD
        // For example, update HUD visibility based on settings
        if settings.gameplay.showHUD {
            setHUDVisible(settings.gameplay.showHUD)
        }

        // Update performance monitoring based on settings
        if settings.advanced.showPerformanceStats {
            setPerformanceMonitoring(enabled: settings.advanced.showPerformanceStats)
        }

        // Notify delegate of settings changes
        delegate?.settingsDidChange(settings)
    }

    /// Called when settings overlay is closed
    @MainActor
    func settingsDidClose() {
        // Handle any cleanup when settings are closed
        // Could resume game if it was paused, etc.
    }
}
