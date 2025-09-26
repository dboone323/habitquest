//
// GameScene.swift
// AvoidObstaclesGame
//
// The main SpriteKit scene that coordinates all game services and systems.
//

import GameplayKit
import SpriteKit
import UIKit

/// The main SpriteKit scene for AvoidObstaclesGame.
/// Coordinates all game services and manages the high-level game flow.
public class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Service Managers

    /// Game state management
    private let gameStateManager = GameStateManager()

    /// Player management
    private let playerManager: PlayerManager

    /// Obstacle management
    private let obstacleManager: ObstacleManager

    /// UI management
    private let uiManager: UIManager

    /// Physics management
    private let physicsManager: PhysicsManager

    /// Effects management
    private let effectsManager: EffectsManager

    /// Audio management (shared)
    private let audioManager = AudioManager.shared

    /// Achievement management (shared)
    private let achievementManager = AchievementManager.shared

    /// Performance management (shared)
    private let performanceManager = PerformanceManager.shared

    // MARK: - Properties

    /// Last update time for game loop
    private var lastUpdateTime: TimeInterval = 0

    /// Game statistics for achievements
    private var currentGameStats = GameStats()

    // MARK: - Initialization

    override init(size: CGSize) {
        // Initialize all service managers
        playerManager = PlayerManager(scene: SKScene())
        obstacleManager = ObstacleManager(scene: SKScene())
        uiManager = UIManager(scene: SKScene())
        physicsManager = PhysicsManager(scene: SKScene())
        effectsManager = EffectsManager(scene: SKScene())

        super.init(size: size)

        // Setup service relationships
        setupServiceDelegates()
    }

    required init?(coder aDecoder: NSCoder) {
        // Initialize all service managers
        playerManager = PlayerManager(scene: SKScene())
        obstacleManager = ObstacleManager(scene: SKScene())
        uiManager = UIManager(scene: SKScene())
        physicsManager = PhysicsManager(scene: SKScene())
        effectsManager = EffectsManager(scene: SKScene())

        super.init(coder: aDecoder)

        // Setup service relationships
        setupServiceDelegates()
    }

    /// Sets up delegates between services
    private func setupServiceDelegates() {
        // Game state delegates
        gameStateManager.delegate = self

        // Player manager delegates
        playerManager.delegate = self

        // Obstacle manager delegates
        obstacleManager.delegate = self

        // UI manager delegates
        uiManager.delegate = self

        // Physics manager delegates
        physicsManager.delegate = self

        // Achievement manager delegates
        achievementManager.delegate = self

        // Performance manager delegates
        performanceManager.delegate = self
    }

    // MARK: - Scene Lifecycle

    /// Called when the scene is first presented by the view.
    override public func didMove(to _: SKView) {
        // Setup the scene
        setupScene()

        // Start background music
        audioManager.startBackgroundMusic()

        // Start the game
        startGame()
    }

    /// Sets up the basic scene configuration
    private func setupScene() {
        // Configure physics world
        physicsWorld.contactDelegate = self

        // Setup background
        setupBackground()

        // Setup UI
        uiManager.setupUI()

        // Setup player
        playerManager.createPlayer(at: CGPoint(x: size.width / 2, y: 100))

        // Enable tilt controls if available
        enableTiltControlsIfAvailable()

        // Setup effects
        effectsManager.createExplosion(at: .zero) // Preload explosion effect
    }

    /// Sets up the animated background
    private func setupBackground() {
        // Create gradient background
        let backgroundNode = SKSpriteNode(color: .systemCyan, size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -100
        addChild(backgroundNode)

        // Add animated clouds
        for _ in 0 ..< 5 {
            let cloud = SKSpriteNode(color: .white.withAlphaComponent(0.3), size: CGSize(width: 60, height: 30))
            cloud.position = CGPoint(
                x: CGFloat.random(in: 0 ... size.width),
                y: CGFloat.random(in: size.height * 0.7 ... size.height)
            )
            cloud.zPosition = -50

            // Animate clouds
            let moveAction = SKAction.moveBy(x: -size.width - 60, y: 0, duration: TimeInterval.random(in: 10 ... 20))
            let resetAction = SKAction.moveTo(x: size.width + 60, duration: 0)
            let sequence = SKAction.sequence([moveAction, resetAction])
            cloud.run(SKAction.repeatForever(sequence))

            addChild(cloud)
        }
    }

    /// Enables tilt controls if the device supports motion and user has enabled it
    private func enableTiltControlsIfAvailable() {
        // Check if tilt controls should be enabled (could be from user settings)
        let tiltEnabled = UserDefaults.standard.bool(forKey: "tiltControlsEnabled")
        if tiltEnabled {
            playerManager.enableTiltControls(sensitivity: 0.7)
        }
    }

    /// Starts a new game
    private func startGame() {
        gameStateManager.startGame()
        currentGameStats = GameStats()
    }

    // MARK: - Game Flow

    /// Handles game over
    private func handleGameOver() {
        gameStateManager.endGame()

        // Update achievements
        achievementManager.updateProgress(for: .gameCompleted, value: Int(gameStateManager.survivalTime))

        // Show game over screen
        let isNewHighScore = HighScoreManager.shared.addScore(gameStateManager.score)
        uiManager.showGameOverScreen(finalScore: gameStateManager.score, isNewHighScore: isNewHighScore)

        // Stop spawning obstacles
        obstacleManager.stopSpawning()

        // Play game over sound
        audioManager.playGameOverSound()
    }

    /// Restarts the game
    private func restartGame() {
        // Hide game over screen
        uiManager.hideGameOverScreen()

        // Reset player
        playerManager.reset()
        playerManager.setPosition(CGPoint(x: size.width / 2, y: 100))

        // Clear obstacles
        obstacleManager.removeAllObstacles()

        // Start new game
        startGame()
    }

    // MARK: - Touch Handling

    /// Handles touch input
    override public func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if gameStateManager.isGameOver() {
            // Handle restart
            uiManager.handleTouch(at: location)
        } else {
            // Handle player movement
            playerManager.moveTo(location)
        }
    }

    /// Handles touch movement for player control
    override public func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard !gameStateManager.isGameOver(), let touch = touches.first else { return }
        let location = touch.location(in: self)
        playerManager.moveTo(location)
    }

    // MARK: - Physics Contact Delegate

    /// Handles physics collisions
    public func didBegin(_ contact: SKPhysicsContact) {
        physicsManager.didBegin(contact)
    }

    // MARK: - Update Loop

    /// Main game update loop
    override public func update(_ currentTime: TimeInterval) {
        // Initialize last update time
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update game state if playing
        if gameStateManager.isGameActive() {
            updateGameplay(deltaTime)
        }

        // Update obstacle manager
        obstacleManager.updateObstacles()

        // Update effects
        effectsManager.updateBackgroundEffects(for: gameStateManager.getCurrentDifficulty())
    }

    /// Updates gameplay logic
    private func updateGameplay(_ deltaTime: TimeInterval) {
        // Update score based on time
        let scoreIncrement = Int(deltaTime * Double(gameStateManager.getCurrentDifficulty().scoreMultiplier))
        if scoreIncrement > 0 {
            gameStateManager.addScore(scoreIncrement)
        }

        // Update survival time
        currentGameStats.survivalTime += deltaTime
    }
}

// MARK: - Service Delegates

extension GameScene: GameStateDelegate {
    func gameStateDidChange(from _: GameState, to newState: GameState) {
        switch newState {
        case .playing:
            obstacleManager.startSpawning(with: gameStateManager.getCurrentDifficulty())
        case .gameOver:
            handleGameOver()
        default:
            break
        }
    }

    func scoreDidChange(to newScore: Int) {
        uiManager.updateScore(newScore)
        currentGameStats.finalScore = newScore
        achievementManager.updateProgress(for: .scoreReached(score: newScore))
    }

    func difficultyDidIncrease(to level: Int) {
        uiManager.updateDifficultyLevel(level)
        uiManager.showLevelUpEffect()
        effectsManager.createLevelUpCelebration()
        audioManager.playLevelUpSound()
        achievementManager.updateProgress(for: .difficultyReached(level: level))
    }

    func gameDidEnd(withScore finalScore: Int, survivalTime: TimeInterval) {
        currentGameStats.finalScore = finalScore
        currentGameStats.survivalTime = survivalTime
        currentGameStats.maxDifficultyReached = gameStateManager.getCurrentDifficultyLevel()
    }
}

extension GameScene: PlayerDelegate {
    func playerDidMove(to _: CGPoint) {
        // Handle player movement feedback if needed
    }

    func playerDidCollide(with _: SKNode) {
        // Handle collision through physics manager
        handleGameOver()
        effectsManager.createExplosion(at: playerManager.position)
        audioManager.playCollisionSound()
    }
}

extension GameScene: ObstacleDelegate {
    func obstacleDidSpawn(_: SKSpriteNode) {
        // Obstacle spawned successfully
    }

    func obstacleDidRecycle(_: SKSpriteNode) {
        // Obstacle recycled
    }
}

extension GameScene: UIManagerDelegate {
    func restartButtonTapped() {
        restartGame()
    }
}

extension GameScene: PhysicsManagerDelegate {
    func playerDidCollideWithObstacle(_: SKNode, obstacle: SKNode) {
        playerManager.handleCollision(with: obstacle)
    }

    func playerDidCollideWithPowerUp(_: SKNode, powerUp: SKNode) {
        // Handle power-up collection
        powerUp.removeFromParent()
        effectsManager.createPowerUpCollectionEffect(at: powerUp.position)
        audioManager.playPowerUpSound()

        // Determine power-up type from color (this is a simple approach)
        let powerUpType: PowerUpType = if let sprite = powerUp as? SKSpriteNode {
            if sprite.color == .blue {
                .shield
            } else if sprite.color == .green {
                .speed
            } else {
                .magnet
            }
        } else {
            .shield // Default fallback
        }

        playerManager.applyPowerUpEffect(powerUpType)

        achievementManager.updateProgress(for: .powerUpCollected)
    }
}

extension GameScene: AchievementDelegate {
    func achievementUnlocked(_ achievement: Achievement) {
        // Show achievement notification
        uiManager.showScorePopup(score: achievement.points, at: CGPoint(x: size.width / 2, y: size.height / 2))
    }

    func achievementProgressUpdated(_: Achievement, progress _: Float) {
        // Could show progress indicator
    }
}

extension GameScene: PerformanceDelegate {
    func performanceWarningTriggered(_ warning: PerformanceWarning) {
        switch warning {
        case .highMemoryUsage, .memoryPressure:
            // Reduce obstacle count or effects
            obstacleManager.removeAllObstacles()
        case .lowFrameRate:
            // Reduce visual effects
            effectsManager.cleanupUnusedEffects()
        default:
            break
        }
    }

    func frameRateDropped(below targetFPS: Int) {
        // Handle frame rate drops
        print("Frame rate dropped below \(targetFPS) FPS")
    }
}

/// Game statistics for achievements and analytics
struct GameStats {
    var finalScore: Int = 0
    var survivalTime: TimeInterval = 0
    var maxDifficultyReached: Int = 1
    var powerUpsCollected: Int = 0
    var obstaclesAvoided: Int = 0
}
