//
// GameOverScreenManager.swift
// AvoidObstaclesGame
//
// Manages the game over screen display and restart functionality.
// Component extracted from UIManager.swift
//

import SpriteKit

/// Protocol for game over screen events
protocol GameOverScreenDelegate: AnyObject {
    func restartButtonTapped()
}

/// Manages the game over screen display and interactions
class GameOverScreenManager {
    // MARK: - Properties

    /// Delegate for game over screen events
    weak var delegate: GameOverScreenDelegate?

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Game Over Screen Elements
    private var gameOverLabel: SKLabelNode?
    private var restartLabel: SKLabelNode?
    private var highScoreAchievedLabel: SKLabelNode?
    private var finalScoreLabel: SKLabelNode?

    /// Animation actions for reuse
    private let fadeInAction: SKAction = .fadeIn(withDuration: 0.5)
    private let fadeOutAction: SKAction = .fadeOut(withDuration: 0.3)

    // MARK: - Initialization

    /// Initializes the game over screen manager with a scene reference
    /// - Parameter scene: The game scene to add game over elements to
    init(scene: SKScene) {
        self.scene = scene
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
                    SKAction.repeatForever(SKAction.sequence([
                        SKAction.scale(to: 1.1, duration: 0.5),
                        SKAction.scale(to: 1.0, duration: 0.5),
                    ])),
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
            label?.run(SKAction.sequence([self.fadeOutAction, SKAction.removeFromParent()]))
        }

        self.gameOverLabel = nil
        self.restartLabel = nil
        self.highScoreAchievedLabel = nil
        self.finalScoreLabel = nil
    }

    // MARK: - Touch Handling

    /// Handles touch events for game over screen interactions
    /// - Parameter location: Touch location in scene coordinates
    /// - Returns: True if the touch was handled by the game over screen
    func handleTouch(at location: CGPoint) -> Bool {
        // Check if restart label was tapped
        if let restartLabel,
           restartLabel.contains(location) {
            self.delegate?.restartButtonTapped()
            return true
        }
        return false
    }

    // MARK: - Cleanup

    /// Removes all game over screen elements from the scene
    func removeAllGameOverElements() {
        self.hideGameOverScreen()
    }
}
