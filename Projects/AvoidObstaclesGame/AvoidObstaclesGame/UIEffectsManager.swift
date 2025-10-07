//
// UIEffectsManager.swift
// AvoidObstaclesGame
//
// Manages UI effects including level up animations and score popups.
// Component extracted from UIManager.swift
//

import SpriteKit

/// Manages UI effects and animations
class UIEffectsManager {
    // MARK: - Properties

    /// Reference to the game scene
    private weak var scene: SKScene?

    /// Active effect elements
    private var levelUpLabel: SKLabelNode?

    /// Animation actions for reuse
    private let fadeInAction: SKAction = .fadeIn(withDuration: 0.5)
    private let fadeOutAction: SKAction = .fadeOut(withDuration: 0.3)

    // MARK: - Initialization

    /// Initializes the UI effects manager with a scene reference
    /// - Parameter scene: The game scene to add effects to
    init(scene: SKScene) {
        self.scene = scene
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

    // MARK: - Cleanup

    /// Removes all active effect elements from the scene
    func removeAllEffects() {
        self.levelUpLabel?.removeFromParent()
        self.levelUpLabel = nil
    }
}
