//
// GameCoordinator.swift
// AvoidObstaclesGame
//
// Coordinator pattern implementation for managing game state transitions
// and coordinating between different game systems and managers.
//

import Combine
import Foundation
import SpriteKit

/// Protocol for objects that can be coordinated
protocol Coordinatable: AnyObject {
    /// Called when the coordinator starts managing this object
    func coordinatorDidStart()

    /// Called when the coordinator stops managing this object
    func coordinatorDidStop()

    /// Called when the coordinator transitions to a new state
    func coordinatorDidTransition(to state: AppState)
}

/// App state enumeration
enum AppState {
    case menu
    case playing
    case paused
    case gameOver
    case settings
    case achievements
}

/// Protocol for game coordinator delegate
protocol GameCoordinatorDelegate: AnyObject {
    func coordinatorDidTransition(to state: AppState)
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
@MainActor
final class GameCoordinator {
    // MARK: - Singleton

    static let shared = GameCoordinator()

    /// Current app state
    private(set) var currentState: AppState = .menu {
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
    private let adaptiveDifficultyAI = AIAdaptiveDifficultyManager()

    /// AI-powered player analytics system
    private let playerAnalyticsAI = PlayerAnalyticsAI.shared

    /// Advanced AI system for predictive analysis and dynamic content
    private let advancedAI = AdvancedAIManager.shared

    /// Combine cancellables for subscriptions
    private var cancellables = Set<AnyCancellable>()

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
               effectsManager: EffectsManager)
    {

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

        // Initialize analytics and performance monitoring
        self.setupAnalyticsAndPerformance()

        // Setup AI system delegates
        self.setupAISystemDelegates()

        // Setup advanced AI system
        self.setupAdvancedAI()

        // Start in menu state
        self.transition(to: .menu)
    }

    /// Setup AI system delegates to coordinate through this coordinator
    private func setupAISystemDelegates() {
        self.adaptiveDifficultyAI.delegate = self
    }

    /// Setup advanced AI system integration
    private func setupAdvancedAI() {
        // Subscribe to advanced AI performance metrics
        self.advancedAI.aiPerformancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] metrics in
                // Handle advanced AI performance metrics
                self?.handleAdvancedAIPerformance(metrics)
            }
            .store(in: &self.cancellables)
    }

    /// Setup analytics and performance monitoring integration
    private func setupAnalyticsAndPerformance() {
        // Set up performance monitoring delegate
        self.performanceManager?.delegate = self

        // Start analytics session
        AnalyticsManager.shared.startSession()

        // Set up periodic analytics updates
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateAnalyticsAndPerformance()
            }
        }
    }

    /// Update analytics and performance metrics periodically
    private func updateAnalyticsAndPerformance() {
        // Get comprehensive performance report
        if let performanceReport = self.performanceManager?.getDetailedPerformanceReport() {
            // Log performance insights
            if !performanceReport.recommendations.isEmpty {
                print("Performance Recommendations: \(performanceReport.recommendations.joined(separator: ", "))")
            }

            if !performanceReport.bottlenecks.isEmpty {
                print("Performance Bottlenecks Detected: \(performanceReport.bottlenecks.map { String(describing: $0) }.joined(separator: ", "))")
            }
        }

        // Get analytics insights
        let analytics = AnalyticsManager.shared
        let behaviorAnalysis = analytics.analyzePlayerBehavior()
        let performanceMetrics = analytics.getPerformanceMetrics()

        // Generate and log insights
        let insights = analytics.analyzePlayerBehavior()
        if !insights.recommendations.isEmpty {
            print("Analytics Recommendations: \(insights.recommendations.joined(separator: ", "))")
        }
    }

    // MARK: - State Management

    /// Transition to a new game state
    func transition(to state: AppState) {
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
    private func handleStateTransition(from oldState: AppState, to newState: AppState) {
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

        // Reset AI session data
        self.adaptiveDifficultyAI.resetSession()
        self.advancedAI.resetAILearning()

        // Record game state change
        self.adaptiveDifficultyAI.recordGameState(.playing)

        // Initialize advanced AI with starting context
        self.updateAdvancedAIContext()

        // Reset game state
        self.gameStateManager?.restartGame()

        // Setup player
        self.playerManager?.reset()

        // Clear obstacles
        self.obstacleManager?.removeAllObstacles()

        // Reset UI
        self.uiManager?.setHUDVisible(true)

        // Physics is handled automatically by SpriteKit

        // Start audio
        self.audioManager?.startBackgroundMusic()

        // Get initial difficulty from AI system
        if self.gameStateManager != nil {
            _ = self.adaptiveDifficultyAI.getCurrentGameDifficulty()
            // difficulty.updateDifficulty(aiDifficulty) // Method doesn't exist on GameStateManager
        }

        // Start obstacle spawning with AI-determined difficulty
        if let obstacleManager = self.obstacleManager {
            let aiDifficulty = self.adaptiveDifficultyAI.getCurrentGameDifficulty()
            obstacleManager.startSpawning(with: aiDifficulty)
        }

        // Notify progression system
        self.progressionManager?.updateProgress(for: .gameCompleted)

        // Start periodic advanced AI context updates
        self.startAdvancedAIUpdates()
    }

    /// Update advanced AI with current game context
    private func updateAdvancedAIContext() {
        guard let gameStateManager = self.gameStateManager,
              let playerManager = self.playerManager,
              let obstacleManager = self.obstacleManager else { return }

        let context = GameContext(
            currentScore: gameStateManager.score,
            playerPosition: playerManager.player?.position ?? .zero,
            obstacles: obstacleManager.getActiveObstacles().compactMap { node in
                // Find the corresponding Obstacle object from the node
                if let obstacle = obstacleManager.getObstacleForNode(node) {
                    return ObstacleData(
                        position: obstacle.node.position,
                        type: String(describing: obstacle.obstacleType),
                        speed: 100.0 // Default speed since speed property is private
                    )
                }
                return nil
            },
            powerUps: [], // Would need to be populated from power-up manager
            gameState: gameStateManager.currentState,
            difficultyLevel: gameStateManager.currentDifficultyLevel,
            sessionTime: gameStateManager.survivalTime,
            playerHealth: 3.0 // Default health since PlayerManager doesn't track lives
        )

        self.advancedAI.updateGameContext(context)
    }

    /// Start periodic advanced AI context updates
    private func startAdvancedAIUpdates() {
        // Update context every 2 seconds during gameplay
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            // Stop updates if not playing
            if self.currentState != .playing {
                timer.invalidate()
                return
            }

            self.updateAdvancedAIContext()
        }
    }

    /// Pause the current game
    private func pauseGame() {
        print("GameCoordinator: Pausing game")

        // Record game state change
        self.adaptiveDifficultyAI.recordGameState(.paused)

        // Pause physics
        // Physics pausing is handled by the scene

        // Pause audio
        self.audioManager?.pauseBackgroundMusic()

        // Show pause UI
        self.uiManager?.setHUDVisible(false) // Hide HUD during pause
    }

    /// Resume the paused game
    private func resumeGame() {
        print("GameCoordinator: Resuming game")

        // Record game state change
        self.adaptiveDifficultyAI.recordGameState(.playing)

        // Resume physics
        // Physics resuming is handled by the scene

        // Resume audio
        self.audioManager?.resumeBackgroundMusic()

        // Hide pause UI
        self.uiManager?.setHUDVisible(true) // Show HUD after resume
    }

    /// End the current game
    private func endGame() {
        print("GameCoordinator: Ending game")

        // Record game state change
        self.adaptiveDifficultyAI.recordGameState(.gameOver)

        // Stop spawning obstacles
        self.obstacleManager?.stopSpawning()

        // Physics stopping is handled by the scene

        // Show game over UI
        if let finalScore = self.gameStateManager?.score {
            // Note: isNewHighScore method doesn't exist in ProgressionManager
            self.uiManager?.showGameOverScreen(finalScore: finalScore, isNewHighScore: false)
        }

        // Process final score
        if let finalScore = self.gameStateManager?.score {
            _ = self.progressionManager?.addScore(finalScore) // Ignore return value
        }

        // Achievement progress is automatically saved when updated
    }

    /// Return to main menu
    private func returnToMenu() {
        print("GameCoordinator: Returning to menu")

        // Reset all systems
        self.gameStateManager?.restartGame()
        self.playerManager?.reset()
        self.obstacleManager?.removeAllObstacles()
        // Main menu UI is handled by the view controller

        // Physics stopping is handled by the scene

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
        // Settings UI is handled by the view controller

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
        // Achievements UI is handled by the view controller

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
        self.childCoordinators[key]
    }

    // MARK: - Public Interface

    /// Handle user input for state transitions
    func handleUserAction(_ action: UserAction) async {
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
            await self.handleQuit()
        }
    }

    /// Handle application quit
    private func handleQuit() async {
        print("GameCoordinator: Handling quit")

        // Achievement progress is automatically saved when updated
        await self.progressionManager?.resetAllAchievementsAsync()

        // Cleanup
        self.coordinatables.forEach { $0.coordinatorDidStop() }
        self.coordinatables.removeAll()
        self.childCoordinators.removeAll()
    }

    /// Get current player position for analytics
    func getCurrentPlayerPosition() -> CGPoint? {
        self.playerManager?.player?.position
    }

    /// Get current game state for analytics
    func getCurrentGameState() -> String {
        switch self.currentState {
        case .menu:
            return "menu"
        case .playing:
            return "playing"
        case .paused:
            return "paused"
        case .gameOver:
            return "game_over"
        case .settings:
            return "settings"
        case .achievements:
            return "achievements"
        }
    }

    /// Helper method to get power-up type from node
    private func getPowerUpType(from node: SKNode) -> PowerUpType? {
        // This would need to be implemented based on how power-ups are stored
        // For now, return a random power-up type
        PowerUpType.allCases.randomElement()
    }

    /// Handle advanced AI performance metrics
    private func handleAdvancedAIPerformance(_ metrics: AdvancedAIPerformanceData) {
        // Log advanced AI performance
        let analysisTime = String(format: "%.2f", metrics.analysisTime)
        let predictionAccuracy = String(format: "%.2f", metrics.predictionAccuracy)
        let generationRate = String(format: "%.2f", metrics.contentGenerationRate)
        let adaptationEffectiveness = String(format: "%.2f", metrics.adaptationEffectiveness)
        print("Advanced AI Performance - Analysis: \(analysisTime)s, Prediction: \(predictionAccuracy), Generation: \(generationRate), Effectiveness: \(adaptationEffectiveness)")

        // Could trigger UI updates or performance optimizations based on metrics
        if metrics.adaptationEffectiveness < 0.5 {
            print("Advanced AI adaptation effectiveness low, considering fallback strategies")
        }
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
    func gameStateDidChange(from oldState: GameState, to newState: GameState) {
        // Handle game state changes
        switch (oldState, newState) {
        case (.waitingToStart, .playing):
            // Game started
            break
        case (.playing, .paused):
            self.transition(to: .paused)
        case (.paused, .playing):
            self.transition(to: .playing)
        case (.playing, .gameOver):
            self.transition(to: .gameOver)
        default:
            break
        }
    }

    func scoreDidChange(to score: Int) {
        // Update UI through coordinator
        self.uiManager?.updateScore(score)
    }

    func difficultyDidIncrease(to level: Int) {
        // Update UI with new difficulty level
        self.uiManager?.updateDifficultyLevel(level)
    }

    func gameDidEnd(withScore finalScore: Int, survivalTime: TimeInterval) {
        // Handle game end
        self.transition(to: .gameOver)
    }

    func gameModeDidChange(to mode: GameMode) {
        // Handle game mode change
        self.uiManager?.updateGameModeDisplay(mode)
    }

    func winConditionMet(result: GameResult) {
        // Handle win condition met
        // self.uiManager?.showWinScreen(result) // Method doesn't exist
    }
}

extension GameCoordinator: PlayerDelegate {
    func playerDidMove(to position: CGPoint) {
        // Handle player movement effects
        // Create a temporary node for trail effect
        let tempNode = SKNode()
        tempNode.position = position
        _ = self.effectsManager?.createTrail(for: tempNode)

        // Record movement for AI analysis - removed as method doesn't exist
    }

    func playerDidCollide(with obstacle: SKNode) {
        // Handle collision effects
        self.effectsManager?.createExplosion(at: obstacle.position)
        self.audioManager?.playCollisionSound()

        // Collision handling is done by PlayerManager

        // Record collision for AI analysis - removed as method doesn't exist
    }

    func playerDidCollectPowerUp(_ powerUp: PowerUp) {
        // Handle power-up effects
        self.effectsManager?.createSparkleBurst(at: powerUp.node.position)
        self.audioManager?.playPowerUpSound()

        // Update progression
        self.progressionManager?.updateProgress(for: .powerUpCollected)

        // Record power-up collection for AI analysis - removed as method doesn't exist
    }
}

extension GameCoordinator: ObstacleDelegate {
    func obstacleDidSpawn(_ obstacle: Obstacle) {
        // Add obstacle to physics
        // self.physicsManager?.addObstacle(obstacle) // Method doesn't exist

        // Obstacle spawning doesn't directly affect AI analysis
        // Player interactions with obstacles are recorded in PlayerDelegate
    }

    func obstacleDidRecycle(_ obstacle: Obstacle) {
        // Remove obstacle from physics
        // self.physicsManager?.removeObstacle(obstacle) // Method doesn't exist

        // Obstacle removal doesn't directly affect AI analysis
        // Player interactions with obstacles are recorded in PlayerDelegate
    }

    func obstacleDidAvoid(_ obstacle: Obstacle) {
        // Record successful obstacle avoidance for AI analysis - removed as method doesn't exist
    }
}

extension GameCoordinator: GameHUDManagerDelegate {
    func uiDidRequestPause() {
        // self.handleUserAction(.pauseGame) // Async call in sync context
        if self.currentState == .playing {
            self.transition(to: .paused)
        }
    }

    func uiDidRequestResume() {
        // self.handleUserAction(.resumeGame) // Async call in sync context
        if self.currentState == .paused {
            self.transition(to: .playing)
        }
    }

    func uiDidRequestRestart() {
        // self.handleUserAction(.startGame) // Async call in sync context
        if self.currentState == .menu || self.currentState == .gameOver {
            self.transition(to: .playing)
        }
    }

    func uiDidRequestMenu() {
        // self.handleUserAction(.returnToMenu) // Async call in sync context
        self.transition(to: .menu)
    }

    func uiDidRequestSettings() {
        // self.handleUserAction(.showSettings) // Async call in sync context
        self.transition(to: .settings)
    }

    func uiDidRequestAchievements() {
        // self.handleUserAction(.showAchievements) // Async call in sync context
        self.transition(to: .achievements)
    }

    func restartButtonTapped() {
        // self.handleUserAction(.startGame) // Async call in sync context
        if self.currentState == .menu || self.currentState == .gameOver {
            self.transition(to: .playing)
        }
    }

    func settingsDidChange(_ settings: SettingsData) {
        // Handle settings changes that affect the game coordinator
        // This method is called when settings are changed via the settings UI
        print("Settings changed in coordinator: \(settings)")
        // Could apply settings changes to game behavior, audio, etc.
    }

    func themeDidChange(to theme: Theme) {
        // Handle theme changes in the game coordinator
        print("Theme changed to: \(theme.name)")
        // Apply theme changes to game elements if needed
        // Theme changes are handled by individual managers that conform to ThemeDelegate
    }
}

extension GameCoordinator: PhysicsManagerDelegate {
    func physicsDidDetectCollision(between nodeA: SKNode, and nodeB: SKNode) {
        // Handle collision logic
        // self.gameScene?.handleCollision(between: nodeA, and: nodeB) // Method doesn't exist
    }

    func playerDidCollideWithObstacle(_ player: SKNode, obstacle: SKNode) {
        // Handle player-obstacle collision
        self.playerManager?.handleCollision(with: obstacle)
    }

    func playerDidCollideWithPowerUp(_ player: SKNode, powerUp: SKNode) {
        // Handle player-powerup collision
        if let powerUpType = self.getPowerUpType(from: powerUp) {
            self.playerManager?.applyPowerUpEffect(powerUpType)
            self.progressionManager?.updateProgress(for: .powerUpCollected)
        }
    }
}

@MainActor
extension GameCoordinator: AchievementDelegate {
    func achievementUnlocked(_ achievement: Achievement) async {
        // Show achievement notification
        // self.uiManager?.showAchievementNotification(achievement) // Method doesn't exist

        // Play achievement effects
        self.audioManager?.playLevelUpSound()
        self.effectsManager?.createLevelUpCelebration()
    }

    func achievementProgressUpdated(_ achievement: Achievement, progress: Float) async {
        // Update achievement UI if visible
        // self.uiManager?.updateAchievementProgress(achievement, progress: progress) // Method doesn't exist
    }
}

@MainActor
extension GameCoordinator: PerformanceDelegate {
    func performanceMetricsDidUpdate(_ metrics: [String: Any]) async {
        // Update performance UI
        // self.uiManager?.updatePerformanceMetrics(metrics) // Method doesn't exist
    }

    func performanceWarningTriggered(_ warning: PerformanceWarning) async {
        // Handle performance warning
        print("Performance warning: \(String(describing: warning))")
        // self.uiManager?.showPerformanceWarning(warning) // Method doesn't exist
    }

    func frameRateDropped(below targetFPS: Int) async {
        // Handle frame rate drop
        print("Frame rate dropped below \(targetFPS) FPS")
        // self.uiManager?.showFrameRateWarning(targetFPS) // Method doesn't exist
    }
}

@MainActor
extension GameCoordinator: AIAdaptiveDifficultyDelegate {
    func difficultyDidAdjust(to newDifficulty: AIAdaptiveDifficulty, reason: DifficultyAdjustmentReason) async {
        print("AI Difficulty Adjusted: \(newDifficulty.description) - Reason: \(reason.description)")

        // Update obstacle spawning with new difficulty
        if self.obstacleManager != nil {
            _ = newDifficulty.toGameDifficulty()
            // obstacleManager.updateDifficulty(gameDifficulty) // Method doesn't exist
        }

        // Show difficulty change notification to player
        // self.uiManager?.showDifficultyChangeNotification(newDifficulty, reason: reason) // Method doesn't exist

        // Play difficulty adjustment sound
        self.audioManager?.playSoundEffect("difficulty_adjust")
    }

    func playerSkillAssessed(skillLevel: PlayerSkillLevel, confidence: Double) async {
        print("Player Skill Assessed: \(skillLevel.description) (Confidence: \(String(format: "%.2f", confidence)))")

        // Update UI with skill level
        // self.uiManager?.updatePlayerSkillLevel(skillLevel, confidence: confidence) // Method doesn't exist

        // Update progression system - removed as method doesn't exist
    }
}
