//
// GameScene.swift
// AvoidObstaclesGame
//
// This file contains all the logic for the "Avoid the Obstacles" game.
//

import GameplayKit // For GKRandomSource, if needed for more complex randomness
import SpriteKit
import UIKit // For UITouch and UIEvent

// MARK: - Physics Categories

// Defines the categories for physics bodies to handle collisions.
// Using UInt32 for bitmasks allows up to 32 unique categories.
enum PhysicsCategory {
    static let none: UInt32 = 0 // 0
    static let player: UInt32 = 0b1 // Binary 1 (decimal 1)
    static let obstacle: UInt32 = 0b10 // Binary 2 (decimal 2)
    // Add more categories here if needed (e.g., powerUp: 0b100, ground: 0b1000)
}

/// The main SpriteKit scene for AvoidObstaclesGame.
/// Handles all game logic, rendering, physics, and user interaction.
class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties

    // Player Node: Represents the character controlled by the user.
    // It's an optional because it's initialized in setupPlayer().
    private var player: SKSpriteNode?

    // Score Label: Displays the current score.
    private var scoreLabel: SKLabelNode?
    // High Score Label: Displays the highest score
    private var highScoreLabel: SKLabelNode?
    // Difficulty Label: Shows current difficulty level
    private var difficultyLabel: SKLabelNode?

    // Score: Tracks the player's score.
    // The didSet property observer automatically updates the scoreLabel's text.
    private var score: Int = 0 {
        didSet {
            self.scoreLabel?.text = "Score: \(self.score)"
            self.updateDifficulty()
        }
    }

    // Game State: Manages whether the game is over.
    private var isGameOver: Bool = false
    // Game Over UI: Labels to display game over messages.
    private var gameOverLabel: SKLabelNode?
    private var restartLabel: SKLabelNode?
    private var highScoreAchievedLabel: SKLabelNode?
    private var finalScoreLabel: SKLabelNode?

    // Action Key for Spawning: Used to manage (start/stop) the obstacle spawning action.
    private let obstacleSpawnActionKey = "spawnObstacleAction"

    // Time tracking for score updates
    private var lastUpdateTime: TimeInterval = 0
    private var scoreUpdateTimer: TimeInterval = 0
    private let scoreInterval: TimeInterval = 1.0 // Score increases every 1 second the game is active.

    // Difficulty management
    private var currentDifficulty: GameDifficulty = .getDifficulty(for: 0)
    private var lastDifficultyLevel: Int = 1

    // Particle effects
    private var explosionParticles: SKEmitterNode?

    // MARK: - Scene Lifecycle

    /// Called when the scene is first presented by the view.
    /// Sets up the background, physics, UI, and starts the game.
    /// - Parameter view: The SKView presenting this scene.
    override func didMove(to view: SKView) {
        self.setupBackground()
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        self.setupParticleEffects()
        self.setupPlayer()
        self.setupUI()
        self.startGame()
    }

    private func setupBackground() {
        // Create an enhanced gradient background
        let backgroundNode = SKSpriteNode(color: .systemCyan, size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -100
        addChild(backgroundNode)

        // Add some subtle animated background elements
        for _ in 0 ..< 5 {
            let cloud = SKSpriteNode(color: .white, size: CGSize(width: 60, height: 30))
            cloud.alpha = 0.3
            cloud.position = CGPoint(
                x: CGFloat.random(in: 0 ... size.width),
                y: CGFloat.random(in: size.height * 0.7 ... size.height)
            )
            cloud.zPosition = -50

            // Animate clouds moving slowly
            let moveAction = SKAction.moveBy(
                x: -size.width - 60, y: 0, duration: TimeInterval.random(in: 10 ... 20)
            )
            let resetAction = SKAction.moveTo(x: size.width + 60, duration: 0)
            let sequence = SKAction.sequence([moveAction, resetAction])
            cloud.run(SKAction.repeatForever(sequence))

            addChild(cloud)
        }
    }

    private func setupParticleEffects() {
        // Create explosion particle effect
        self.explosionParticles = SKEmitterNode()
        guard let explosion = explosionParticles else { return }

        // Create a simple white texture for particles programmatically
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        let sparkImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 8, height: 8)))
        }

        // Configure explosion particles
        explosion.particleTexture = SKTexture(image: sparkImage)
        explosion.particleBirthRate = 300
        explosion.numParticlesToEmit = 100
        explosion.particleLifetime = 1.0
        explosion.particleLifetimeRange = 0.5

        // Particle appearance
        explosion.particleScale = 0.1
        explosion.particleScaleRange = 0.05
        explosion.particleScaleSpeed = -0.1
        explosion.particleAlpha = 1.0
        explosion.particleAlphaSpeed = -1.0
        explosion.particleColor = SKColor.orange
        explosion.particleColorBlendFactor = 1.0

        // Particle movement
        explosion.emissionAngle = 0
        explosion.emissionAngleRange = CGFloat.pi * 2
        explosion.particleSpeed = 200
        explosion.particleSpeedRange = 100
        explosion.xAcceleration = 0
        explosion.yAcceleration = -100

        // Set blend mode for better visual effect
        explosion.particleBlendMode = .add
        explosion.zPosition = 50
    }

    /// Starts or restarts the game, resetting all state and UI.
    func startGame() {
        // Reset game state
        self.isGameOver = false
        self.score = 0 // This will also update the label via didSet
        self.currentDifficulty = GameDifficulty.getDifficulty(for: 0)
        self.lastDifficultyLevel = 1

        // Remove game over messages if they exist
        self.gameOverLabel?.removeFromParent()
        self.restartLabel?.removeFromParent()
        self.highScoreAchievedLabel?.removeFromParent()
        self.finalScoreLabel?.removeFromParent()

        // Ensure player is in the correct starting position if restarting
        self.player?.position = CGPoint(x: size.width / 2, y: 100)
        self.player?.isHidden = false
        self.player?.removeAllActions()
        self.player?.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0.1))

        // Reset UI
        self.difficultyLabel?.text = "Level: 1"

        // Start spawning obstacles
        self.startSpawningObstacles()
    }

    // MARK: - Setup Methods

    /// Creates and configures the player node with enhanced visual design and physics.
    private func setupPlayer() {
        // Creates and configures the player node with enhanced visual design.

        // Create player sprite node with improved visual design
        player = SKSpriteNode(color: .systemBlue, size: CGSize(width: 50, height: 50))
        guard let player else { return } // Safety check for optional player.

        player.name = "player" // Assign a name for easier debugging or node searching.
        player.position = CGPoint(x: size.width / 2, y: 100) // Initial position: bottom-center.

        // Add a subtle glow effect to the player
        let glowEffect = SKEffectNode()
        glowEffect.shouldRasterize = true
        let glowFilter = CIFilter(name: "CIGaussianBlur")
        glowFilter?.setValue(3.0, forKey: kCIInputRadiusKey)
        glowEffect.filter = glowFilter
        glowEffect.addChild(SKSpriteNode(color: .cyan, size: CGSize(width: 55, height: 55)))
        glowEffect.zPosition = -1
        player.addChild(glowEffect)

        // Setup player's physics body for collision detection.
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size) // Shape matches the sprite.
        player.physicsBody?.categoryBitMask = PhysicsCategory.player // Assign to 'player' category.
        player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle // Notify on contact with 'obstacle'.
        player.physicsBody?.collisionBitMask = PhysicsCategory.none // No physical collision response (won't bounce off).
        player.physicsBody?.affectedByGravity = false // Player shouldn't be pulled down by gravity.
        player.physicsBody?.isDynamic = false // Player is not moved by physics simulation, only by code (touch input).

        addChild(player) // Add the player node to the scene.
    }

    /// Creates and configures all UI elements (score, high score, difficulty labels).
    private func setupUI() {
        // Creates and configures all UI elements.

        // Score Label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        guard let scoreLabel else { return }
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 20, y: size.height - 40)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)

        // High Score Label
        highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        guard let highScoreLabel else { return }
        let highestScore = HighScoreManager.shared.getHighestScore()
        highScoreLabel.text = "Best: \(highestScore)"
        highScoreLabel.fontSize = 20
        highScoreLabel.fontColor = SKColor.darkGray
        highScoreLabel.horizontalAlignmentMode = .left
        highScoreLabel.position = CGPoint(x: 20, y: size.height - 70)
        highScoreLabel.zPosition = 100
        addChild(highScoreLabel)

        // Difficulty Label
        difficultyLabel = SKLabelNode(fontNamed: "Chalkduster")
        guard let difficultyLabel else { return }
        difficultyLabel.text = "Level: 1"
        difficultyLabel.fontSize = 18
        difficultyLabel.fontColor = SKColor.blue
        difficultyLabel.horizontalAlignmentMode = .right
        difficultyLabel.position = CGPoint(x: size.width - 20, y: size.height - 40)
        difficultyLabel.zPosition = 100
        addChild(difficultyLabel)
    }

    // MARK: - Obstacle Spawning

    /// Sets up a repeating action to spawn obstacles at intervals based on difficulty.
    private func startSpawningObstacles() {
        // Sets up a repeating action to spawn obstacles at intervals based on difficulty.

        let spawnAction = SKAction.run(self.spawnObstacle)
        let waitAction = SKAction.wait(forDuration: self.currentDifficulty.spawnInterval, withRange: 0.2)
        let sequenceAction = SKAction.sequence([spawnAction, waitAction])
        let repeatForeverAction = SKAction.repeatForever(sequenceAction)

        run(repeatForeverAction, withKey: self.obstacleSpawnActionKey)
    }

    /// Stops the obstacle spawning action.
    private func stopSpawningObstacles() {
        // Stops the obstacle spawning action.
        removeAction(forKey: self.obstacleSpawnActionKey)
    }

    /// Creates a single obstacle with difficulty-based properties and enhanced visuals.
    private func spawnObstacle() {
        // Creates a single obstacle with difficulty-based properties and enhanced visuals.
        if self.isGameOver { return }

        let obstacleSize = CGSize(width: 30, height: 30)
        let obstacle = SKSpriteNode(color: .systemRed, size: obstacleSize)
        obstacle.name = "obstacle"

        // Add visual enhancement to obstacles
        let borderWidth: CGFloat = 2.0
        let borderColor = SKColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0) // Dark red color

        // Create border effect
        let topBorder = SKSpriteNode(
            color: borderColor, size: CGSize(width: obstacleSize.width, height: borderWidth)
        )
        topBorder.position = CGPoint(x: 0, y: obstacleSize.height / 2 - borderWidth / 2)
        obstacle.addChild(topBorder)

        let bottomBorder = SKSpriteNode(
            color: borderColor, size: CGSize(width: obstacleSize.width, height: borderWidth)
        )
        bottomBorder.position = CGPoint(x: 0, y: -obstacleSize.height / 2 + borderWidth / 2)
        obstacle.addChild(bottomBorder)

        let leftBorder = SKSpriteNode(
            color: borderColor, size: CGSize(width: borderWidth, height: obstacleSize.height)
        )
        leftBorder.position = CGPoint(x: -obstacleSize.width / 2 + borderWidth / 2, y: 0)
        obstacle.addChild(leftBorder)

        let rightBorder = SKSpriteNode(
            color: borderColor, size: CGSize(width: borderWidth, height: obstacleSize.height)
        )
        rightBorder.position = CGPoint(x: obstacleSize.width / 2 - borderWidth / 2, y: 0)
        obstacle.addChild(rightBorder)

        let randomX = CGFloat.random(
            in: obstacle.size.width / 2 ... size.width - obstacle.size.width / 2
        )
        obstacle.position = CGPoint(x: randomX, y: size.height + obstacle.size.height)

        // Setup physics body
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.player
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.none
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.isDynamic = true

        addChild(obstacle)

        // Use difficulty-based speed
        let moveAction = SKAction.moveTo(
            y: -obstacle.size.height, duration: self.currentDifficulty.obstacleSpeed
        )
        let removeAction = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveAction, removeAction]))
    }

    // MARK: - Difficulty Management

    /// Updates the game difficulty based on the current score and restarts obstacle spawning if needed.
    private func updateDifficulty() {
        let newDifficulty = GameDifficulty.getDifficulty(for: self.score)
        let newLevel = GameDifficulty.getDifficultyLevel(for: self.score)

        if newLevel > self.lastDifficultyLevel {
            // Difficulty increased, restart spawning with new parameters
            self.currentDifficulty = newDifficulty
            self.lastDifficultyLevel = newLevel

            // Update UI
            self.difficultyLabel?.text = "Level: \(newLevel)"

            // Restart spawning with new difficulty
            if !self.isGameOver {
                self.stopSpawningObstacles()
                self.startSpawningObstacles()

                // Visual feedback for level up
                self.showLevelUpEffect()
            }
        }
    }

    /// Displays a visual effect when the player levels up.
    private func showLevelUpEffect() {
        let levelUpLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelUpLabel.text = "LEVEL UP!"
        levelUpLabel.fontSize = 32
        levelUpLabel.fontColor = SKColor.yellow
        levelUpLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        levelUpLabel.zPosition = 200
        addChild(levelUpLabel)

        // Animate level up text
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        levelUpLabel.run(SKAction.sequence([scaleUp, scaleDown, fadeOut, remove]))
    }

    // MARK: - Touch Handling

    /// Handles player movement by dragging on the screen.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Called when a touch that began on the screen moves.
        if self.isGameOver { return } // Disable player movement if game is over.

        guard let touch = touches.first else { return } // Get the first touch.
        let touchLocation = touch.location(in: self) // Get touch location within the scene.

        // Update player's x-position based on touch, keeping it within screen bounds.
        var newXPosition = touchLocation.x
        let halfPlayerWidth = (player?.size.width ?? 0) / 2 // Use actual player width if available.

        // Clamp newXPosition to prevent player from moving off-screen.
        if newXPosition < halfPlayerWidth {
            newXPosition = halfPlayerWidth
        } else if newXPosition > size.width - halfPlayerWidth {
            newXPosition = size.width - halfPlayerWidth
        }

        self.player?.position.x = newXPosition // Apply the new x-position.
    }

    /// Handles tap to restart the game after game over.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Called when a new touch begins on the screen.
        if self.isGameOver {
            // If the game is over, any tap will restart the game.
            self.restartGame()
        }
        // If not game over, touchesBegan doesn't do anything for player movement in this setup.
        // Player movement is handled by touchesMoved for a dragging interaction.
    }

    // MARK: - Collision Detection (SKPhysicsContactDelegate)

    /// Called when two physics bodies begin contact. Handles player-obstacle collisions.
    /// - Parameter contact: The contact information between two physics bodies.
    func didBegin(_ contact: SKPhysicsContact) {
        // This delegate method is called when two physics bodies with matching contactTestBitMasks begin contact.
        if self.isGameOver { return } // Don't process new collisions if game is already over.

        // Identify the two bodies that collided.
        // It's good practice to order them (e.g., by categoryBitMask) to simplify checks.
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // Check if the collision is between the player and an obstacle.
        if firstBody.categoryBitMask == PhysicsCategory.player,
           secondBody.categoryBitMask == PhysicsCategory.obstacle {
            // Player contacted an obstacle.
            // Safely cast the nodes to SKSpriteNode before passing them to the handler.
            if let playerNode = firstBody.node as? SKSpriteNode,
               let obstacleNode = secondBody.node as? SKSpriteNode {
                self.playerHitObstacle(player: playerNode, obstacle: obstacleNode)
            }
        }
    }

    // MARK: - Game Logic Methods

    /// Handles the game logic when the player collides with an obstacle.
    /// - Parameters:
    ///   - player: The player node involved in the collision.
    ///   - obstacle: The obstacle node involved in the collision.
    private func playerHitObstacle(player: SKSpriteNode, obstacle: SKSpriteNode) {
        // Handles the game logic when the player collides with an obstacle.
        if self.isGameOver { return } // Ensure this logic runs only once per game over.

        self.isGameOver = true // Set the game over state.

        // Stop spawning new obstacles.
        self.stopSpawningObstacles()

        // Visual feedback for collision (e.g., player flashes or changes color, then disappears).
        let colorizeAction = SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 0.1)
        player.run(colorizeAction) {
            player.isHidden = true // Hide player after the effect.
        }
        obstacle.removeFromParent() // Remove the specific obstacle that was hit.

        // Remove all other on-screen obstacles to clear the play area.
        // This uses enumerateChildNodes to find all nodes named "obstacle".
        enumerateChildNodes(withName: "obstacle") { node, _ in
            node.removeFromParent()
        }

        // Display the Game Over message and restart prompt.
        self.showGameOverScreen()

        // Play explosion effect at the player's location
        if let explosion = explosionParticles {
            explosion.position = player.position
            addChild(explosion)

            // Remove the explosion effect after a short duration
            let removeAction = SKAction.removeFromParent()
            explosion.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), removeAction]))
        }
    }

    /// Displays the Game Over screen, final score, and high score notification.
    private func showGameOverScreen() {
        // Check if this is a high score and save it
        let isNewHighScore = HighScoreManager.shared.addScore(self.score)

        // Game Over title
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel?.text = "Game Over!"
        gameOverLabel?.fontSize = 40
        gameOverLabel?.fontColor = SKColor.red
        gameOverLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        gameOverLabel?.zPosition = 101
        if let gameOverLabel {
            addChild(gameOverLabel)
        }

        // Final score display
        finalScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        finalScoreLabel?.text = "Final Score: \(self.score)"
        finalScoreLabel?.fontSize = 28
        finalScoreLabel?.fontColor = SKColor.black
        finalScoreLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        finalScoreLabel?.zPosition = 101
        if let finalScoreLabel {
            addChild(finalScoreLabel)
        }

        // High score achievement notification
        if isNewHighScore {
            highScoreAchievedLabel = SKLabelNode(fontNamed: "Chalkduster")
            highScoreAchievedLabel?.text = "🎉 NEW HIGH SCORE! 🎉"
            highScoreAchievedLabel?.fontSize = 24
            highScoreAchievedLabel?.fontColor = SKColor.orange
            highScoreAchievedLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2 + 10)
            highScoreAchievedLabel?.zPosition = 101
            if let highScoreAchievedLabel {
                addChild(highScoreAchievedLabel)

                // Animate the high score text
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.1, duration: 0.5),
                    SKAction.scale(to: 1.0, duration: 0.5),
                ])
                highScoreAchievedLabel.run(SKAction.repeatForever(pulse))
            }
        }

        // Restart instruction
        restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel?.text = "Tap to Restart"
        restartLabel?.fontSize = 25
        restartLabel?.fontColor = SKColor.darkGray
        restartLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2 - 40)
        restartLabel?.zPosition = 101
        if let restartLabel {
            addChild(restartLabel)
        }

        // Update high score display
        let newHighest = HighScoreManager.shared.getHighestScore()
        self.highScoreLabel?.text = "Best: \(newHighest)"
    }

    /// Restarts the game after game over, resetting all state and UI.
    private func restartGame() {
        // Remove all game over UI elements
        self.gameOverLabel?.removeFromParent()
        self.restartLabel?.removeFromParent()
        self.highScoreAchievedLabel?.removeFromParent()
        self.finalScoreLabel?.removeFromParent()

        // Reset game state variables
        self.isGameOver = false
        self.score = 0 // This will update the score label via didSet
        self.currentDifficulty = GameDifficulty.getDifficulty(for: 0)
        self.lastDifficultyLevel = 1
        self.difficultyLabel?.text = "Level: 1"

        // Reset player
        self.player?.position = CGPoint(x: size.width / 2, y: 100)
        self.player?.isHidden = false
        self.player?.removeAllActions()
        self.player?.run(SKAction.colorize(withColorBlendFactor: 0, duration: 0.1))

        // Start spawning obstacles with initial difficulty
        self.startSpawningObstacles()
    }

    // MARK: - Update Loop

    /// Called before each frame is rendered. Updates score and game state.
    /// - Parameter currentTime: The current system time.
    override func update(_ currentTime: TimeInterval) {
        // This method is called automatically before each frame is rendered.

        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }

        let deltaTime = currentTime - self.lastUpdateTime

        // Update score based on time if the game is not over
        if !self.isGameOver {
            self.scoreUpdateTimer += deltaTime
            if self.scoreUpdateTimer >= self.scoreInterval {
                // Apply difficulty-based score multiplier
                let baseScore = 1
                let multipliedScore = Int(Double(baseScore) * self.currentDifficulty.scoreMultiplier)
                self.score += multipliedScore
                self.scoreUpdateTimer -= self.scoreInterval
            }
        }

        self.lastUpdateTime = currentTime
    }
}
