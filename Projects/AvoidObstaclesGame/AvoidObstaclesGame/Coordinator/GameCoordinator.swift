//
// GameCoordinator.swift
// AvoidObstaclesGame
//
// Coordinator pattern implementation for managing game state transitions
// and coordinating between different game systems and managers.
//

import Foundation
import SpriteKit

/// Protocol for objects that can be coordinated
protocol Coordinatable: AnyObject {
    /// Called when the coordinator starts managing this object
    func coordinatorDidStart()

    /// Called when the coordinator stops managing this object
    func coordinatorDidStop()

    /// Called when the coordinator transitions to a new state
    func coordinatorDidTransition(to state: GameState)
}

/// Game state enumeration
enum GameState {
    case menu
    case playing
    case paused
    case gameOver
    case settings
    case achievements
}

/// Protocol for game coordinator delegate
protocol GameCoordinatorDelegate: AnyObject {
    func coordinatorDidTransition(to state: GameState)
    func coordinatorDidRequestSceneChange(to sceneType: SceneType)
}

/// Types of scenes the coordinator can manage
enum SceneType {
    case mainMenu
    case game
    case settings
    case achievements
}

/// Main game coordinator responsible for managing game state and coordinating managers
class GameCoordinator {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = GameCoordinator()

    /// Current game state
    private(set) var currentState: GameState = .menu {
        didSet {
            self.handleStateTransition(from: oldValue, to: self.currentState)
        }
    }

    /// Coordinator delegate
    weak var delegate: GameCoordinatorDelegate?

    /// Managed coordinators and coordinatables
    private var coordinatables: [Coordinatable] = []
    private var childCoordinators: [String: Any] = [:]

    /// Game scene reference
    private weak var gameScene: GameScene?

    /// Managers (weak references to prevent retain cycles)
    private weak var gameStateManager: GameStateManager?
    private weak var playerManager: PlayerManager?
    private weak var obstacleManager: ObstacleManager?
    private weak var uiManager: GameHUDManager?
    private weak var physicsManager: PhysicsManager?
    private weak var effectsManager: EffectsManager?
    private weak var audioManager: AudioManager?
    private weak var achievementManager: AchievementManager?
    private weak var performanceManager: PerformanceManager?
    private weak var progressionManager: ProgressionManager?

    /// AI-powered adaptive difficulty system
    private let adaptiveDifficultyAI = AdaptiveDifficultyAI.shared

    /// AI-powered player analytics system
    private let playerAnalyticsAI = PlayerAnalyticsAI.shared

    // MARK: - Initialization

    private init() {
        // Private init for singleton
    }

    /// Setup the coordinator with the game scene and managers
    func setup(with gameScene: GameScene,
               gameStateManager: GameStateManager,
               playerManager: PlayerManager,
               obstacleManager: ObstacleManager,
               uiManager: GameHUDManager,
               physicsManager: PhysicsManager,
               effectsManager: EffectsManager) {

        self.gameScene = gameScene
        self.gameStateManager = gameStateManager
        self.playerManager = playerManager
        self.obstacleManager = obstacleManager
        self.uiManager = uiManager
        self.physicsManager = physicsManager
        self.effectsManager = effectsManager

        // Shared managers
        self.audioManager = AudioManager.shared
        self.achievementManager = AchievementManager.shared
        self.performanceManager = PerformanceManager.shared
        self.progressionManager = ProgressionManager.shared

        // Setup manager delegates to point to coordinator
        self.setupManagerDelegates()

        // Start in menu state
        self.transition(to: .menu)
    }

    /// Setup manager delegates to coordinate through this coordinator
    private func setupManagerDelegates() {
        self.gameStateManager?.delegate = self
        self.playerManager?.delegate = self
        self.obstacleManager?.delegate = self
        self.uiManager?.delegate = self
        self.physicsManager?.delegate = self
        self.achievementManager?.delegate = self
        self.performanceManager?.delegate = self
        self.progressionManager?.delegate = self
    }

    // MARK: - State Management

    /// Transition to a new game state
    func transition(to state: GameState) {
        guard state != self.currentState else { return }

        let previousState = self.currentState
        self.currentState = state

        print("GameCoordinator: Transitioning from \(previousState) to \(state)")

        // Notify delegate
        self.delegate?.coordinatorDidTransition(to: state)

        // Notify all coordinatables
        for coordinatable in self.coordinatables {
            coordinatable.coordinatorDidTransition(to: state)
        }
    }

    /// Handle state transition logic
    private func handleStateTransition(from oldState: GameState, to newState: GameState) {
        switch (oldState, newState) {
        case (.menu, .playing):
            self.startGame()
        case (.playing, .paused):
            self.pauseGame()
        case (.paused, .playing):
            self.resumeGame()
        case (.playing, .gameOver):
            self.endGame()
        case (.gameOver, .menu):
            self.returnToMenu()
        case (.menu, .settings):
            self.showSettings()
        case (.menu, .achievements):
            self.showAchievements()
        case (.settings, .menu), (.achievements, .menu):
            self.returnToMenu()
        default:
            break
        }
    }

    // MARK: - Game Flow Methods

    /// Start a new game
    private func startGame() {
        print("GameCoordinator: Starting game")

        // Reset game state
        self.gameStateManager?.resetGame()

        // Setup player
        self.playerManager?.resetPlayer()

        // Clear obstacles
        self.obstacleManager?.clearAllObstacles()

        // Reset UI
        self.uiManager?.resetUI()

        // Start physics
        self.physicsManager?.startPhysics()

        // Start audio
        self.audioManager?.startBackgroundMusic()

        // Notify progression system
        self.progressionManager?.updateProgress(for: .gameCompleted)
    }

    /// Pause the current game
    private func pauseGame() {
        print("GameCoordinator: Pausing game")

        // Pause physics
        self.physicsManager?.pausePhysics()

        // Pause audio
        self.audioManager?.pauseBackgroundMusic()

        // Show pause UI
        self.uiManager?.showPauseMenu()
    }

    /// Resume the paused game
    private func resumeGame() {
        print("GameCoordinator: Resuming game")

        // Resume physics
        self.physicsManager?.resumePhysics()

        // Resume audio
        self.audioManager?.resumeBackgroundMusic()

        // Hide pause UI
        self.uiManager?.hidePauseMenu()
    }

    /// End the current game
    private func endGame() {
        print("GameCoordinator: Ending game")

        // Stop physics
        self.physicsManager?.stopPhysics()

        // Stop spawning obstacles
        self.obstacleManager?.stopSpawning()

        // Show game over UI
        self.uiManager?.showGameOverScreen()

        // Process final score
        if let finalScore = self.gameStateManager?.currentScore {
            self.progressionManager?.addScore(finalScore)
        }

        // Save achievements progress
        self.achievementManager?.saveProgress()
    }

    /// Return to main menu
    private func returnToMenu() {
        print("GameCoordinator: Returning to menu")

        // Reset all systems
        self.gameStateManager?.resetGame()
        self.playerManager?.resetPlayer()
        self.obstacleManager?.clearAllObstacles()
        self.uiManager?.showMainMenu()

        // Stop physics
        self.physicsManager?.stopPhysics()

        // Reset audio to menu music
        self.audioManager?.stopBackgroundMusic()
    }

    /// Show settings screen
    private func showSettings() {
        print("GameCoordinator: Showing settings")

        // Pause any active game
        if self.currentState == .playing {
            self.pauseGame()
        }

        // Show settings UI
        self.uiManager?.showSettingsMenu()

        // Request scene change if needed
        self.delegate?.coordinatorDidRequestSceneChange(to: .settings)
    }

    /// Show achievements screen
    private func showAchievements() {
        print("GameCoordinator: Showing achievements")

        // Pause any active game
        if self.currentState == .playing {
            self.pauseGame()
        }

        // Show achievements UI
        self.uiManager?.showAchievementsScreen()

        // Request scene change if needed
        self.delegate?.coordinatorDidRequestSceneChange(to: .achievements)
    }

    // MARK: - Coordinator Management

    /// Add a coordinatable object to be managed
    func addCoordinatable(_ coordinatable: Coordinatable) {
        guard !self.coordinatables.contains(where: { $0 === coordinatable }) else { return }

        self.coordinatables.append(coordinatable)
        coordinatable.coordinatorDidStart()
        coordinatable.coordinatorDidTransition(to: self.currentState)
    }

    /// Remove a coordinatable object
    func removeCoordinatable(_ coordinatable: Coordinatable) {
        guard let index = self.coordinatables.firstIndex(where: { $0 === coordinatable }) else { return }

        coordinatable.coordinatorDidStop()
        self.coordinatables.remove(at: index)
    }

    /// Add a child coordinator
    func addChildCoordinator(_ coordinator: Any, for key: String) {
        self.childCoordinators[key] = coordinator
    }

    /// Remove a child coordinator
    func removeChildCoordinator(for key: String) {
        self.childCoordinators.removeValue(forKey: key)
    }

    /// Get a child coordinator
    func childCoordinator(for key: String) -> Any? {
        return self.childCoordinators[key]
    }

    // MARK: - Public Interface

    /// Handle user input for state transitions
    func handleUserAction(_ action: UserAction) {
        switch action {
        case .startGame:
            if self.currentState == .menu || self.currentState == .gameOver {
                self.transition(to: .playing)
            }
        case .pauseGame:
            if self.currentState == .playing {
                self.transition(to: .paused)
            }
        case .resumeGame:
            if self.currentState == .paused {
                self.transition(to: .playing)
            }
        case .endGame:
            if self.currentState == .playing {
                self.transition(to: .gameOver)
            }
        case .returnToMenu:
            self.transition(to: .menu)
        case .showSettings:
            self.transition(to: .settings)
        case .showAchievements:
            self.transition(to: .achievements)
        case .quitGame:
            self.handleQuit()
        }
    }

    /// Handle application quit
    private func handleQuit() {
        print("GameCoordinator: Handling quit")

        // Save all progress
        self.achievementManager?.saveProgress()
        self.progressionManager?.resetAllAchievementsAsync()

        // Cleanup
        self.coordinatables.forEach { $0.coordinatorDidStop() }
        self.coordinatables.removeAll()
        self.childCoordinators.removeAll()
    }

    /// Get current game statistics
    func getGameStatistics() -> [String: Any] {
        return [
            "currentState": self.currentState,
            "coordinatablesCount": self.coordinatables.count,
            "childCoordinatorsCount": self.childCoordinators.count,
            "gameScore": self.gameStateManager?.currentScore ?? 0,
            "gameTime": self.gameStateManager?.gameTime ?? 0,
            "playerLives": self.playerManager?.lives ?? 0
        ]
    }
}

/// User actions that can trigger state transitions
enum UserAction {
    case startGame
    case pauseGame
    case resumeGame
    case endGame
    case returnToMenu
    case showSettings
    case showAchievements
    case quitGame
}

// MARK: - Manager Delegate Extensions

extension GameCoordinator: GameStateDelegate {
    func gameDidStart() {
        // Handled by state transition
    }

    func gameDidEnd() {
        self.transition(to: .gameOver)
    }

    func gameDidPause() {
        self.transition(to: .paused)
    }

    func gameDidResume() {
        self.transition(to: .playing)
    }

    func scoreDidChange(to score: Int) {
        // Update UI through coordinator
        self.uiManager?.updateScore(score)
    }

    func livesDidChange(to lives: Int) {
        // Update UI through coordinator
        self.uiManager?.updateLives(lives)

        // Check for game over
        if lives <= 0 {
            self.transition(to: .gameOver)
        }
    }
}

extension GameCoordinator: PlayerDelegate {
    func playerDidMove(to position: CGPoint) {
        // Handle player movement effects
        self.effectsManager?.createTrailEffect(at: position)
    }

    func playerDidCollide(with obstacle: Obstacle) {
        // Handle collision effects
        self.effectsManager?.createExplosion(at: obstacle.position)
        self.audioManager?.playCollisionSound()

        // Update game state
        self.gameStateManager?.playerDidCollide()
    }

    func playerDidCollectPowerUp(_ powerUp: PowerUp) {
        // Handle power-up effects
        self.effectsManager?.createSparkleEffect(at: powerUp.position)
        self.audioManager?.playPowerUpSound()

        // Update progression
        self.progressionManager?.updateProgress(for: .powerUpCollected)
    }
}

extension GameCoordinator: ObstacleDelegate {
    func obstacleDidSpawn(_ obstacle: Obstacle) {
        // Add obstacle to physics
        self.physicsManager?.addObstacle(obstacle)
    }

    func obstacleDidRemove(_ obstacle: Obstacle) {
        // Remove obstacle from physics
        self.physicsManager?.removeObstacle(obstacle)
    }
}

extension GameCoordinator: GameHUDManagerDelegate {
    func uiDidRequestPause() {
        self.handleUserAction(.pauseGame)
    }

    func uiDidRequestResume() {
        self.handleUserAction(.resumeGame)
    }

    func uiDidRequestRestart() {
        self.handleUserAction(.startGame)
    }

    func uiDidRequestMenu() {
        self.handleUserAction(.returnToMenu)
    }

    func uiDidRequestSettings() {
        self.handleUserAction(.showSettings)
    }

    func uiDidRequestAchievements() {
        self.handleUserAction(.showAchievements)
    }
}

extension GameCoordinator: PhysicsManagerDelegate {
    func physicsDidDetectCollision(between nodeA: SKNode, and nodeB: SKNode) {
        // Handle collision logic
        self.gameScene?.handleCollision(between: nodeA, and: nodeB)
    }
}

extension GameCoordinator: AchievementDelegate {
    func achievementUnlocked(_ achievement: Achievement) {
        // Show achievement notification
        self.uiManager?.showAchievementNotification(achievement)

        // Play achievement effects
        self.audioManager?.playLevelUpSound()
        self.effectsManager?.createLevelUpEffect()
    }

    func achievementProgressUpdated(_ achievement: Achievement, progress: Float) {
        // Update achievement UI if visible
        self.uiManager?.updateAchievementProgress(achievement, progress: progress)
    }
}

extension GameCoordinator: PerformanceDelegate {
    func performanceMetricsDidUpdate(_ metrics: [String: Any]) {
        // Update performance UI
        self.uiManager?.updatePerformanceMetrics(metrics)
    }
}

extension GameCoordinator: ProgressionDelegate {
    func achievementUnlocked(_ achievement: Achievement) {
        // Forward to achievement delegate
        self.achievementManager?.delegate?.achievementUnlocked(achievement)
    }

    func achievementProgressUpdated(_ achievement: Achievement, progress: Double) {
        // Forward to achievement delegate
        self.achievementManager?.delegate?.achievementProgressUpdated(achievement, progress: Float(progress))
    }

    func highScoreAchieved(_ score: Int, rank: Int) {
        // Show high score notification
        self.uiManager?.showHighScoreNotification(score: score, rank: rank)

        // Play high score effects
        self.audioManager?.playLevelUpSound()
        self.effectsManager?.createHighScoreEffect()
    }
}
