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
    private let uiManager: GameHUDManager

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
        // Initialize all service managers with empty scenes initially
        // They will be properly configured in didMove(to:)
        self.playerManager = PlayerManager(scene: SKScene())
        self.obstacleManager = ObstacleManager(scene: SKScene())
        self.uiManager = GameHUDManager(scene: SKScene())
        self.physicsManager = PhysicsManager(scene: SKScene())
        self.effectsManager = EffectsManager(scene: SKScene())

        super.init(size: size)

        // Setup service relationships
        self.setupServiceDelegates()
    }

    required init?(coder aDecoder: NSCoder) {
        // Initialize all service managers with empty scenes initially
        // They will be properly configured in didMove(to:)
        self.playerManager = PlayerManager(scene: SKScene())
        self.obstacleManager = ObstacleManager(scene: SKScene())
        self.uiManager = GameHUDManager(scene: SKScene())
        self.physicsManager = PhysicsManager(scene: SKScene())
        self.effectsManager = EffectsManager(scene: SKScene())

        super.init(coder: aDecoder)

        // Setup service relationships
        self.setupServiceDelegates()
    }

    /// Sets up delegates between services
    private func setupServiceDelegates() {
        // Game state delegates
        self.gameStateManager.delegate = self

        // Player manager delegates
        self.playerManager.delegate = self

        // Obstacle manager delegates
        self.obstacleManager.delegate = self

        // UI manager delegates
        self.uiManager.delegate = self

        // Physics manager delegates
        self.physicsManager.delegate = self

        // Achievement manager delegates
        self.achievementManager.delegate = self

        // Performance manager delegates
        self.performanceManager.delegate = self
    }

    // MARK: - Scene Lifecycle

    /// Called when the scene is first presented by the view.
    override public func didMove(to _: SKView) {
        // Configure managers with the actual scene
        self.playerManager.updateScene(self)
        self.obstacleManager.updateScene(self)
        self.uiManager.updateScene(self)
        self.physicsManager.updateScene(self)
        self.effectsManager.updateScene(self)

        // Setup the scene
        self.setupScene()

        // Start background music
        self.audioManager.startBackgroundMusic()

        // Start the game
        self.startGame()
    }

    /// Sets up the basic scene configuration
    private func setupScene() {
        // Configure physics world
        physicsWorld.contactDelegate = self

        // Setup background
        self.setupBackground()

        // Setup UI
        self.uiManager.setupUI()

        // Setup player
        self.playerManager.createPlayer(at: CGPoint(x: size.width / 2, y: 100))

        // Enable tilt controls if available
        self.enableTiltControlsIfAvailable()

        // Setup effects
        self.effectsManager.createExplosion(at: .zero) // Preload explosion effect
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
            self.playerManager.enableTiltControls(sensitivity: 0.7)
        }
    }

    /// Starts a new game
    private func startGame() {
        self.gameStateManager.startGame()
        self.currentGameStats = GameStats()
    }

    // MARK: - Game Flow

    /// Handles game over
    private func handleGameOver() {
        self.gameStateManager.endGame()

        // Update achievements
        self.achievementManager.updateProgress(for: .gameCompleted, value: Int(self.gameStateManager.survivalTime))

        // Show game over screen
        let isNewHighScore = HighScoreManager.shared.addScore(self.gameStateManager.score)
        self.uiManager.showGameOverScreen(finalScore: self.gameStateManager.score, isNewHighScore: isNewHighScore)

        // Stop spawning obstacles
        self.obstacleManager.stopSpawning()

        // Play game over sound
        self.audioManager.playGameOverSound()
    }

    /// Restarts the game
    private func restartGame() {
        // Hide game over screen
        self.uiManager.hideGameOverScreen()

        // Reset player
        self.playerManager.reset()
        self.playerManager.setPosition(CGPoint(x: size.width / 2, y: 100))

        // Clear obstacles
        self.obstacleManager.removeAllObstacles()

        // Start new game
        self.startGame()
    }

    // MARK: - Touch Handling

    /// Handles touch input
    override public func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if self.gameStateManager.isGameOver() {
            // Handle restart
            self.uiManager.handleTouch(at: location)
        } else {
            // Handle player movement
            self.playerManager.moveTo(location)
        }
    }

    /// Handles touch movement for player control
    override public func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard !self.gameStateManager.isGameOver(), let touch = touches.first else { return }
        let location = touch.location(in: self)
        self.playerManager.moveTo(location)
    }

    // MARK: - Physics Contact Delegate

    /// Handles physics collisions
    public func didBegin(_ contact: SKPhysicsContact) {
        self.physicsManager.didBegin(contact)
    }

    // MARK: - Update Loop

    /// Main game update loop
    override public func update(_ currentTime: TimeInterval) {
        // Initialize last update time
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }

        let deltaTime = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime

        // Update game state if playing
        if self.gameStateManager.isGameActive() {
            self.updateGameplay(deltaTime)
        }

        // Update obstacle manager
        self.obstacleManager.updateObstacles()

        // Update effects
        self.effectsManager.updateBackgroundEffects(for: self.gameStateManager.getCurrentDifficulty())
    }

    /// Updates gameplay logic
    private func updateGameplay(_ deltaTime: TimeInterval) {
        // Update score based on time
        let scoreIncrement = Int(deltaTime * Double(self.gameStateManager.getCurrentDifficulty().scoreMultiplier))
        if scoreIncrement > 0 {
            self.gameStateManager.addScore(scoreIncrement)
        }

        // Update survival time
        self.currentGameStats.survivalTime += deltaTime
    }
}

// MARK: - Service Delegates

extension GameScene: GameStateDelegate {
    func gameStateDidChange(from _: GameState, to newState: GameState) {
        switch newState {
        case .playing:
            self.obstacleManager.startSpawning(with: self.gameStateManager.getCurrentDifficulty())
        case .gameOver:
            self.handleGameOver()
        default:
            break
        }
    }

    func scoreDidChange(to newScore: Int) {
        self.uiManager.updateScore(newScore)
        self.currentGameStats.finalScore = newScore
        self.achievementManager.updateProgress(for: .scoreReached(score: newScore))
    }

    func difficultyDidIncrease(to level: Int) {
        self.uiManager.updateDifficultyLevel(level)
        self.uiManager.showLevelUpEffect()
        self.effectsManager.createLevelUpCelebration()
        self.audioManager.playLevelUpSound()
        self.achievementManager.updateProgress(for: .difficultyReached(level: level))
    }

    func gameDidEnd(withScore finalScore: Int, survivalTime: TimeInterval) {
        self.currentGameStats.finalScore = finalScore
        self.currentGameStats.survivalTime = survivalTime
        self.currentGameStats.maxDifficultyReached = self.gameStateManager.getCurrentDifficultyLevel()
    }
}

extension GameScene: PlayerDelegate {
    func playerDidMove(to _: CGPoint) {
        // Handle player movement feedback if needed
    }

    func playerDidCollide(with _: SKNode) {
        // Handle collision through physics manager
        self.handleGameOver()
        self.effectsManager.createExplosion(at: self.playerManager.position)
        self.audioManager.playCollisionSound()
    }
}

extension GameScene: ObstacleDelegate {
    func obstacleDidSpawn(_: Obstacle) {
        // Obstacle spawned successfully
    }

    func obstacleDidRecycle(_: Obstacle) {
        // Obstacle recycled
    }
}

extension GameScene: GameHUDManagerDelegate {
    func restartButtonTapped() {
        self.restartGame()
    }
}

extension GameScene: PhysicsManagerDelegate {
    func playerDidCollideWithObstacle(_: SKNode, obstacle: SKNode) {
        self.playerManager.handleCollision(with: obstacle)
    }

    func playerDidCollideWithPowerUp(_: SKNode, powerUp: SKNode) {
        // Handle power-up collection
        powerUp.removeFromParent()
        self.effectsManager.createPowerUpCollectionEffect(at: powerUp.position)
        self.audioManager.playPowerUpSound()

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

        self.playerManager.applyPowerUpEffect(powerUpType)

        self.achievementManager.updateProgress(for: .powerUpCollected)
    }
}

extension GameScene: AchievementDelegate {
    public func achievementUnlocked(_ achievement: Achievement) {
        // Show achievement notification
        self.uiManager.showScorePopup(score: achievement.points, at: CGPoint(x: size.width / 2, y: size.height / 2))
    }

    public func achievementProgressUpdated(_: Achievement, progress _: Float) {
        // Could show progress indicator
    }
}

extension GameScene: PerformanceDelegate {
    func performanceWarningTriggered(_ warning: PerformanceWarning) {
        switch warning {
        case .highMemoryUsage, .memoryPressure:
            // Reduce obstacle count or effects
            self.obstacleManager.removeAllObstacles()
        case .lowFrameRate:
            // Reduce visual effects
            self.effectsManager.cleanupUnusedEffects()
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
