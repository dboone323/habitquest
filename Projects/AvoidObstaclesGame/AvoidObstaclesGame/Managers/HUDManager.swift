//
// HUDManager.swift
// AvoidObstaclesGame
//
// Manages Heads-Up Display elements including score, high score, and difficulty labels.
// Component extracted from UIManager.swift
//

import SpriteKit

/// Manages HUD (Heads-Up Display) elements
class HUDManager {
    // MARK: - Properties

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// HUD Elements
    private var scoreLabel: SKLabelNode?
    private var highScoreLabel: SKLabelNode?
    private var difficultyLabel: SKLabelNode?

    // MARK: - Initialization

    /// Initializes the HUD manager with a scene reference
    /// - Parameter scene: The game scene to add HUD elements to
    init(scene: SKScene) {
        self.scene = scene
        self.setupHUD()
    }

    // MARK: - Setup

    /// Sets up all HUD elements
    func setupHUD() {
        self.setupScoreLabel()
        self.setupHighScoreLabel()
        self.setupDifficultyLabel()
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

    // MARK: - Cleanup

    /// Removes all HUD elements from the scene
    func removeAllHUD() {
        let labels = [scoreLabel, highScoreLabel, difficultyLabel]
        for label in labels {
            label?.removeFromParent()
        }

        self.scoreLabel = nil
        self.highScoreLabel = nil
        self.difficultyLabel = nil
    }
}
