//
//  GameScene.swift
//  AvoidObstaclesGame
//
//  The main SpriteKit scene that coordinates all game services and systems.
//

import Combine
import GameplayKit
import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

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

    /// AI adaptive difficulty management
    private let aiAdaptiveDifficultyManager = AIAdaptiveDifficultyManager()

    /// Power-up management
    private let powerUpManager: PowerUpManager

    /// Audio management (shared)
    private let audioManager = AudioManager.shared

    /// Achievement management (shared)
    private let achievementManager = AchievementManager.shared

    /// Haptic feedback manager (shared)
    private let hapticManager = HapticManager.shared

    /// Gesture manager for advanced touch controls
    private let gestureManager = GestureManager()

    /// Multiplayer management
    private let multiplayerManager: MultiplayerManager

    /// Game mode manager for different game modes
    private let gameModeManager: GameModeManager

    /// Boss battle manager for epic encounters
    private let bossManager: BossManager

    /// Replay manager for recording and replaying gameplay
    private let replayManager: ReplayManager

    /// Performance management (shared)
    private let performanceManager = PerformanceManager.shared

    /// Analytics dashboard management (shared)
    private let analyticsDashboard = AnalyticsDashboardManager.shared

    /// Tutorial management
    private let tutorialManager: TutorialManager

    /// Level editor manager for user-generated content creation
    private let levelEditorManager: LevelEditorManager

    /// Combine cancellables for reactive subscriptions
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Properties

    /// Last update time for game loop
    private var lastUpdateTime: TimeInterval = 0

    /// Game statistics for achievements
    private var currentGameStats = GameStats()

    /// Whether multiplayer mode is active
    private var isMultiplayerMode = false

    // MARK: - Initialization

    override init(size: CGSize) {
        // Initialize all service managers with empty scenes initially
        // They will be properly configured in didMove(to:)
        self.playerManager = PlayerManager(scene: SKScene(), gameStateManager: self.gameStateManager)
        self.obstacleManager = ObstacleManager(scene: SKScene())
        self.uiManager = GameHUDManager(scene: SKScene())
        self.physicsManager = PhysicsManager(scene: SKScene())
        self.effectsManager = EffectsManager(scene: SKScene())
        self.powerUpManager = PowerUpManager(scene: SKScene(), aiDifficultyManager: self.aiAdaptiveDifficultyManager)
        self.multiplayerManager = MultiplayerManager(scene: SKScene())
        self.gameModeManager = GameModeManager(scene: SKScene())
        self.bossManager = BossManager(scene: SKScene())
        self.replayManager = ReplayManager(scene: SKScene())
        self.levelEditorManager = LevelEditorManager(scene: SKScene())
        self.tutorialManager = TutorialManager(scene: SKScene())

        super.init(size: size)

        // Setup service relationships
        self.setupServiceDelegates()
    }

    required init?(coder aDecoder: NSCoder) {
        // Initialize all service managers with empty scenes initially
        // They will be properly configured in didMove(to:)
        self.playerManager = PlayerManager(scene: SKScene(), gameStateManager: self.gameStateManager)
        self.obstacleManager = ObstacleManager(scene: SKScene())
        self.uiManager = GameHUDManager(scene: SKScene())
        self.physicsManager = PhysicsManager(scene: SKScene())
        self.effectsManager = EffectsManager(scene: SKScene())
        self.powerUpManager = PowerUpManager(scene: SKScene(), aiDifficultyManager: self.aiAdaptiveDifficultyManager)
        self.multiplayerManager = MultiplayerManager(scene: SKScene())
        self.gameModeManager = GameModeManager(scene: SKScene())
        self.bossManager = BossManager(scene: SKScene())
        self.replayManager = ReplayManager(scene: SKScene())
        self.levelEditorManager = LevelEditorManager(scene: SKScene())
        self.tutorialManager = TutorialManager(scene: SKScene())

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

        // Analytics dashboard setup
        self.setupAnalyticsDashboard()

        // Multiplayer manager delegates
        self.multiplayerManager.delegate = self

        // Game mode manager delegates
        self.gameModeManager.delegate = self

        // Boss manager delegates
        self.bossManager.delegate = self

        // Power-up manager delegates
        self.powerUpManager.delegate = self

        // Replay manager delegates
        self.replayManager.delegate = self

        // Level editor manager delegates
        self.levelEditorManager.delegate = self

        // Tutorial manager delegates
        self.tutorialManager.delegate = self

        // Setup boss manager subscriptions
        self.setupBossManagerSubscriptions()
    }

    /// Sets up reactive subscriptions for boss manager events
    private func setupBossManagerSubscriptions() {
        // Subscribe to boss spawned events
        self.bossManager.bossSpawnedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] boss in
                Task {
                    await self?.bossBattleStarted(boss: boss)
                }
            }
            .store(in: &cancellables)

        // Subscribe to boss defeated events
        self.bossManager.bossDefeatedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bossType in
                Task {
                    await self?.bossBattleEnded(bossType: bossType, defeated: true)
                }
            }
            .store(in: &cancellables)

        // Subscribe to boss health changes
        self.bossManager.bossHealthChangedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] current, max in
                Task {
                    await self?.bossHealthChanged(current: current, max: max)
                }
            }
            .store(in: &cancellables)
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
        self.powerUpManager.updateScene(self)
        // MultiplayerManager already has scene reference from init
        self.gameModeManager.updateScene(self)
        self.bossManager.updateScene(self)
        self.replayManager.updateScene(self)
        self.levelEditorManager.updateScene(self)
        self.tutorialManager.updateScene(self)

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

        // Setup gesture manager
        self.setupGestureManager()
    }

    /// Sets up the animated background
    private func setupBackground() {
        // Create gradient background
        let backgroundNode = SKSpriteNode(color: .cyan, size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -100
        addChild(backgroundNode)

        // Add animated clouds
        for _ in 0 ..< 5 {
            let cloud = SKSpriteNode(color: SKColor.white.withAlphaComponent(0.3), size: CGSize(width: 60, height: 30))
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

    /// Sets up the gesture manager for advanced touch controls
    private func setupGestureManager() {
        self.gestureManager.delegate = self
        #if os(iOS) || os(tvOS)
            if let skView = self.view {
                self.gestureManager.setupForView(skView)
            }
        #endif
    }

    /// Sets up the analytics dashboard
    private func setupAnalyticsDashboard() {
        // Initialize analytics dashboard with default settings
        // This would typically configure metrics tracking and display
    }

    /// Starts periodic updates of analytics metrics
    private func startAnalyticsUpdates() {
        // Update metrics every 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateAnalyticsMetrics()
        }
    }

    /// Updates analytics metrics from all AI managers
    private func updateAnalyticsMetrics() {
        // AI Performance metrics (simulated for now - would come from actual AI analysis)
        let predictionAccuracy = 0.85 // Would be calculated from AI manager
        let adaptationRate = 0.92 // Would be calculated from recent adjustments
        let learningProgress = 0.78 // Would be calculated from behavior analysis

        self.analyticsDashboard.updateAIPerformance(
            predictionAccuracy: predictionAccuracy,
            adaptationRate: adaptationRate,
            learningProgress: learningProgress
        )

        // Obstacle metrics
        let spawnRate = 1.0 / self.gameStateManager.getCurrentDifficulty().spawnInterval
        let dynamicPatternUsage = 0.65 // Would be calculated from pattern distribution

        self.analyticsDashboard.updateObstacleMetrics(
            spawnRate: spawnRate,
            dynamicPatternUsage: dynamicPatternUsage
        )

        // Power-up metrics
        let effectiveness = 0.73 // Would be calculated from collection rates
        let adaptivePlacementSuccess = 0.81 // Would be calculated from strategic placement

        self.analyticsDashboard.updatePowerUpMetrics(
            effectiveness: effectiveness,
            adaptivePlacementSuccess: adaptivePlacementSuccess
        )
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

        // Start analytics session
        AnalyticsManager.shared.startSession()

        // Start tutorial for new players
        if !self.tutorialManager.hasCompletedTutorial() {
            self.tutorialManager.startTutorial()
        }

        // Start multiplayer if enabled
        if self.isMultiplayerMode {
            self.startMultiplayerGame()
        }

        // Set game mode in state manager
        self.gameStateManager.setGameMode(self.gameModeManager.currentMode)

        // Initialize environmental effects based on game mode
        self.setupEnvironmentalEffects()

        // Start recording gameplay
        self.replayManager.startRecording()

        // Track level start event
        AnalyticsManager.shared.trackEvent(.levelStart, parameters: [
            "game_mode": self.gameModeManager.currentMode.displayName,
            "difficulty": String(self.gameStateManager.getCurrentDifficultyLevel())
        ])
    }

    /// Starts multiplayer game mode
    private func startMultiplayerGame() {
        // Create AI opponents for local multiplayer
        self.multiplayerManager.startMultiplayerGame(mode: .localSplitScreen)

        // Create additional player entities for opponents
        self.createMultiplayerPlayers()
    }

    /// Creates player entities for multiplayer opponents
    private func createMultiplayerPlayers() {
        // For now, create AI-controlled players
        // In a full implementation, this would handle multiple human players
        let opponentPositions = [
            CGPoint(x: size.width * 0.25, y: 100), // Left player
            CGPoint(x: size.width * 0.75, y: 100), // Right player
        ]

        for (index, position) in opponentPositions.enumerated() {
            if index > 0 { // Skip first position (human player)
                // Create AI player representation
                let aiPlayer = SKSpriteNode(color: .red, size: CGSize(width: 30, height: 30))
                aiPlayer.position = position
                aiPlayer.name = "aiPlayer_\(index)"
                aiPlayer.zPosition = 10
                addChild(aiPlayer)

                // Add physics body for AI player
                aiPlayer.physicsBody = SKPhysicsBody(rectangleOf: aiPlayer.size)
                aiPlayer.physicsBody?.categoryBitMask = PhysicsCategory.player
                aiPlayer.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.powerUp
                aiPlayer.physicsBody?.collisionBitMask = PhysicsCategory.obstacle
                aiPlayer.physicsBody?.isDynamic = true
                aiPlayer.physicsBody?.allowsRotation = false
            }
        }
    }

    /// Sets up environmental effects based on game mode and difficulty
    private func setupEnvironmentalEffects() {
        let gameMode = self.gameStateManager.getCurrentGameMode()
        let difficulty = self.gameStateManager.getCurrentDifficultyLevel()

        // Stop any existing environmental effects
        self.effectsManager.stopEnvironmentalEffects()

        // Configure environmental effects based on game mode
        switch gameMode {
        case .classic:
            // Mild environmental effects for classic mode
            if difficulty > 3 {
                self.effectsManager.setWeather(.rain, intensity: 0.3)
            }
        case .timeTrial:
            // Fast-paced weather changes
            self.effectsManager.startWeatherCycle(interval: 15.0)
            self.effectsManager.startLightingCycle(cycleDuration: 60.0)
        case .survival:
            // Harsh environmental conditions
            self.effectsManager.setWeather(.storm, intensity: 0.7)
            self.effectsManager.startEnvironmentalHazards(interval: 30.0)
        case .puzzle:
            // Calm, foggy conditions for focus
            self.effectsManager.setWeather(.fog, intensity: 0.5)
            self.effectsManager.setLighting(.dusk, intensity: 0.6)
        case .challenge:
            // Dynamic weather with hazards
            self.effectsManager.startWeatherCycle(interval: 20.0)
            self.effectsManager.startEnvironmentalHazards(interval: 25.0)
        case .custom:
            // Custom environmental setup (could be configured by player)
            self.effectsManager.setWeather(.clear)
            self.effectsManager.setLighting(.day)
        }

        // Add difficulty-based environmental intensity
        let hazardInterval = self.calculateHazardInterval(for: difficulty)
        let weatherIntensity = self.calculateWeatherIntensity(for: difficulty)

        if difficulty > 3 {
            // Start environmental hazards based on difficulty
            self.effectsManager.startEnvironmentalHazards(interval: hazardInterval)

            // Scale existing weather effects
            if gameMode == .classic && difficulty > 3 {
                self.effectsManager.setWeather(.rain, intensity: weatherIntensity)
            }
            if gameMode == .survival {
                self.effectsManager.setWeather(.storm, intensity: weatherIntensity)
            }
            if case .challenge = gameMode {
                // Increase hazard frequency for challenge mode
                self.effectsManager.startEnvironmentalHazards(interval: hazardInterval * 0.8)
            }
        }

        // Add extreme difficulty effects
        if difficulty > 8 {
            // Multiple hazard types at extreme difficulties
            self.effectsManager.startEnvironmentalHazards(interval: hazardInterval * 0.5)
            // Random weather changes
            self.effectsManager.startWeatherCycle(interval: max(10.0, 30.0 - Double(difficulty)))
        }
    }

    // MARK: - Performance Handling

    /// Handles performance warnings and adjusts game parameters accordingly
    private func handlePerformanceWarning(_ warning: PerformanceWarning) {
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

    /// Called when the frame rate drops below a certain threshold
    private func handleFrameRateDrop(below targetFPS: Int) {
        // Handle frame rate drops
        print("Frame rate dropped below \(targetFPS) FPS")
    }

    /// Enables multiplayer mode for the next game
    public func enableMultiplayerMode() {
        self.isMultiplayerMode = true
    }

    /// Disables multiplayer mode
    public func disableMultiplayerMode() {
        self.isMultiplayerMode = false
        // End multiplayer game if active
        if self.multiplayerManager.gameIsActive {
            let results = MultiplayerGameResults(
                winner: nil,
                rankings: [],
                duration: 0,
                gameMode: "localSplitScreen"
            )
            self.multiplayerManager.endGame(with: results)
        }
    }

    /// Shows the game mode selection menu
    public func showGameModeSelection() {
        self.gameModeManager.showModeSelectionMenu()
    }

    /// Shows the replay selection menu
    public func showReplaySelection() {
        self.replayManager.showReplaySelectionUI()
    }

    /// Starts the level editor
    public func startLevelEditor() {
        self.levelEditorManager.startEditing()
    }

    /// Stops the level editor
    public func stopLevelEditor() {
        self.levelEditorManager.stopEditing()
    }

    /// Creates a new level in the editor
    public func createNewLevel(name: String) {
        self.levelEditorManager.createNewLevel(name: name)
    }

    /// Gets the current game mode
    func getCurrentGameMode() -> GameMode {
        self.gameModeManager.currentMode
    }

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
            // Update player and obstacles
            self.playerManager.update(deltaTime)
            self.obstacleManager.update(deltaTime)
            self.powerUpManager.update(deltaTime)
            self.bossManager.update(deltaTime: deltaTime)
            self.replayManager.update(deltaTime: deltaTime)
            self.levelEditorManager.update(deltaTime)
        }

        // Update obstacle manager
        self.obstacleManager.updateObstacles()

        // Update effects
        self.effectsManager.update(deltaTime: deltaTime)

        // Update multiplayer if active
        if self.isMultiplayerMode {
            // Multiplayer updates handled by individual managers
        }
    }

    /// Handles input beginning at a location
    func handleInputBegan(at location: CGPoint) {
        // Convert screen location to game coordinates
        let gameLocation = convertPoint(fromView: location)

        // Check if tutorial is active and handle tutorial touches first
        if self.tutorialManager.handleTouch(at: gameLocation) {
            return // Tutorial handled the touch
        }

        // Handle player movement based on touch location
        self.playerManager.handleTouch(at: gameLocation)
    }

    /// Handles input movement to a location
    func handleInputMoved(at location: CGPoint) {
        // Convert screen location to game coordinates
        let gameLocation = convertPoint(fromView: location)

        // Handle player movement based on touch location
        self.playerManager.handleTouch(at: gameLocation)
    }

    /// Handles input ending at a location
    func handleInputEnded(at location: CGPoint) {
        // Convert screen location to game coordinates
        let gameLocation = convertPoint(fromView: location)

        // Handle touch release if needed
        self.playerManager.handleTouchRelease(at: gameLocation)
    }

    /// Handles movement direction input
    func handleMovement(direction: MovementDirection, isActive: Bool) {
        switch direction {
        case .left:
            self.playerManager.setMovementDirection(.left, active: isActive)
        case .right:
            self.playerManager.setMovementDirection(.right, active: isActive)
        case .up:
            self.playerManager.setMovementDirection(.up, active: isActive)
        case .down:
            self.playerManager.setMovementDirection(.down, active: isActive)
        }
    }

    /// Handles game action input
    func handleAction(_ action: GameAction) {
        switch action {
        case .jump:
            // For now, jump could be implemented as a quick upward movement
            // This could be extended to include jumping mechanics
            self.playerManager.setMovementDirection(.up, active: true)
            // Reset after a short delay to simulate jump
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playerManager.setMovementDirection(.up, active: false)
            }
        case .pause:
            if self.gameStateManager.isGameActive() {
                self.gameStateManager.pauseGame()
                self.uiManager.showPauseMenu()
            } else {
                self.gameStateManager.resumeGame()
                self.uiManager.hidePauseMenu()
            }
        case .menu:
            // Show main menu or settings
            self.uiManager.showMainMenu()
        }
    }

    /// Handles game over state
    private func handleGameOver() {
        // Stop spawning obstacles
        self.obstacleManager.stopSpawning()

        // Stop environmental effects
        self.effectsManager.stopEnvironmentalEffects()

        // Stop recording and save the session
        let finalScore = self.gameStateManager.getCurrentScore()
        let difficultyLevel = self.gameStateManager.getCurrentDifficultyLevel()
        let gameMode = self.gameStateManager.getCurrentGameMode().displayName
        self.replayManager.stopRecording(finalScore: finalScore, difficultyLevel: difficultyLevel, gameMode: gameMode)

        // Track player death event
        AnalyticsManager.shared.trackEvent(.playerDeath, parameters: [
            "final_score": String(finalScore),
            "difficulty_level": String(difficultyLevel),
            "game_mode": gameMode,
            "survival_time": String(self.currentGameStats.survivalTime)
        ])

        // End analytics session
        AnalyticsManager.shared.endSession()

        // Show game over screen
        self.uiManager.showGameOverScreen(
            finalScore: self.gameStateManager.getCurrentScore(),
            isNewHighScore: self.gameStateManager.getCurrentScore() > HighScoreManager.shared.getHighestScore()
        )
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

@MainActor
extension GameScene: PerformanceDelegate {
    func performanceWarningTriggered(_ warning: PerformanceWarning) async {
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

    func frameRateDropped(below targetFPS: Int) async {
        // Handle frame rate drops
        print("Frame rate dropped below \(targetFPS) FPS")
    }
}

@MainActor
extension GameScene: MultiplayerDelegate {
    func playerJoined(_ player: MultiplayerPlayer) async {
        // Handle player joining the game
        print("Player joined: \(player.displayName)")
        // Could show notification or update UI
    }

    func playerLeft(_ player: MultiplayerPlayer) async {
        // Handle player leaving the game
        print("Player left: \(player.displayName)")
        // Could show notification or update UI
    }

    func gameStarted(with players: [MultiplayerPlayer]) async {
        // Handle game starting
        print("Multiplayer game started with \(players.count) players")
        // Could initialize multiplayer UI elements
    }

    func gameEnded(with results: MultiplayerGameResults) async {
        // Handle game ending
        print("Multiplayer game ended")
        if let winner = results.winner {
            print("Winner: \(winner.displayName)")
        }
        // Could show results screen
    }

    func receivedMove(from player: MultiplayerPlayer, move: PlayerMove) async {
        // Handle receiving a move from another player
        print("Received move from \(player.displayName): \(move.action)")
        // Could update game state based on the move
    }
}

@MainActor
extension GameScene: GameModeManagerDelegate {
    func gameModeDidChange(to mode: GameMode) async {
        print("Game mode changed to: \(mode.displayName)")
        // Update UI to reflect new game mode
        self.uiManager.updateGameModeDisplay(mode)
    }

    func gameModeWinConditionMet(result: GameResult) async {
        print("Game mode win condition met: \(result.completed ? "Success" : "Failed")")
        // Show completion screen
        self.gameModeManager.showModeCompleteScreen(result: result)
    }

    func showGameModeStartScreen(for mode: GameMode) async {
        // Start the game with the selected mode
        self.startGame()
    }

    func showGameModeCompleteScreen(result: GameResult) async {
        // Completion screen is handled by GameModeManager
        // Could add additional effects or sounds here
        if result.completed {
            self.effectsManager.createLevelUpCelebration()
            self.audioManager.playLevelUpSound()
        }
    }
}

@MainActor
extension GameScene: PlayerDelegate {
    func playerDidMove(to position: CGPoint) {
        // Handle player movement updates
        print("Player moved to: \(position)")

        // Notify tutorial manager of player movement
        self.tutorialManager.playerDidMove()

        // Record player movement for replay
        self.replayManager.recordPlayerAction(position: position, action: .move)

        // Track player movement for analytics (sample every few movements to avoid spam)
        if Int.random(in: 0...10) == 0 { // Track ~10% of movements
            AnalyticsManager.shared.updateHeatMapData(position: position, action: .move)
        }
    }

    func playerDidCollide(with obstacle: SKNode) {
        // Handle player collision with obstacle
        self.gameStateManager.endGame()

        // Notify tutorial manager of obstacle collision
        self.tutorialManager.playerDidHitObstacle()

        // Play collision haptic feedback
        self.hapticManager.playCollisionHaptic()

        // Record collision for replay
        if let playerNode = self.playerManager.player {
            self.replayManager.recordPlayerAction(position: playerNode.position, action: .collision)
        }

        // Track collision for analytics
        if let playerNode = self.playerManager.player {
            AnalyticsManager.shared.updateHeatMapData(position: playerNode.position, action: .collide)
        }
    }
}

@MainActor
extension GameScene: ObstacleDelegate {
    func obstacleDidSpawn(_ obstacle: Obstacle) {
        // Handle obstacle spawning
        print("Obstacle spawned")

        // Record obstacle spawn for replay
        self.replayManager.recordObstacleSnapshot(
            id: "\(ObjectIdentifier(obstacle))",
            type: "\(obstacle.obstacleType)",
            position: obstacle.node.position,
            isActive: true
        )
    }

    func obstacleDidRecycle(_ obstacle: Obstacle) {
        // Handle obstacle recycling
        print("Obstacle recycled")

        // Record obstacle deactivation for replay
        self.replayManager.recordObstacleSnapshot(
            id: "\(ObjectIdentifier(obstacle))",
            type: "\(obstacle.obstacleType)",
            position: obstacle.node.position,
            isActive: false
        )
    }

    func obstacleDidAvoid(_ obstacle: Obstacle) {
        // Handle obstacle avoidance
        self.currentGameStats.obstaclesAvoided += 1
        print("Obstacle avoided")
    }
}

@MainActor
extension GameScene: GameHUDManagerDelegate {
    func restartButtonTapped() {
        // Handle restart button tap
        self.startGame()
    }

    func settingsDidChange(_ settings: SettingsData) {
        // Handle settings changes that affect the game scene
        // This method is called when settings are changed via the settings UI
        print("Settings changed: \(settings)")
        // Could apply settings changes to game behavior, audio, etc.
    }

    func themeDidChange(to theme: Theme) {
        // Handle theme changes that affect the game scene
        print("Theme changed to: \(theme.name)")
        // Could apply theme changes to game visuals, effects, etc.
    }
}

@MainActor
extension GameScene: PhysicsManagerDelegate {
    func playerDidCollideWithObstacle(_ player: SKNode, obstacle: SKNode) {
        // Handle physics collision between player and obstacle
        self.gameStateManager.endGame()
    }

    func playerDidCollideWithPowerUp(_ player: SKNode, powerUp: SKNode) {
        // Handle physics collision between player and power-up
        // Find the PowerUp object from the SKNode
        if let powerUpObj = self.powerUpManager.getPowerUp(for: powerUp) {
            // Create a Player object for the powerUpCollected method
            let playerEntity = Player()
            playerEntity.position = player.position
            self.powerUpManager.powerUpCollected(powerUpObj, by: playerEntity)
        }
    }
}

@MainActor
extension GameScene: GameStateDelegate {
    func gameStateDidChange(from oldState: GameState, to newState: GameState) async {
        print("Game state changed from \(oldState) to \(newState)")
    }

    func scoreDidChange(to newScore: Int) async {
        self.uiManager.updateScore(newScore)

        // Play score increase haptic feedback
        self.hapticManager.playScoreIncreaseHaptic()

        // Track score update for analytics
        AnalyticsManager.shared.trackEvent(.scoreUpdate, parameters: [
            "score": String(newScore),
            "game_mode": self.gameStateManager.getCurrentGameMode().displayName,
            "difficulty": String(self.gameStateManager.getCurrentDifficultyLevel())
        ])
    }

    func difficultyDidIncrease(to level: Int) async {
        print("Difficulty increased to level \(level)")

        // Play level up haptic feedback
        self.hapticManager.playLevelUpHaptic()

        // Update environmental effects based on new difficulty
        self.updateEnvironmentalEffectsForDifficulty(level)

        // Update maximum difficulty reached stat
        self.currentGameStats.maxDifficultyReached = max(self.currentGameStats.maxDifficultyReached, level)

        // Track level progression for analytics
        AnalyticsManager.shared.trackEvent(.levelComplete, parameters: [
            "level": String(level),
            "game_mode": self.gameStateManager.getCurrentGameMode().displayName,
            "score": String(self.gameStateManager.getCurrentScore())
        ])
    }

    func gameDidEnd(withScore finalScore: Int, survivalTime: TimeInterval) async {
        self.currentGameStats.finalScore = finalScore
        self.currentGameStats.survivalTime = survivalTime
        self.handleGameOver()
    }

    func winConditionMet(result: GameResult) async {
        print("Win condition met: \(result)")
    }
}

@MainActor
extension GameScene: AchievementDelegate {
    public func achievementUnlocked(_ achievement: Achievement) async {
        print("Achievement unlocked: \(achievement.title)")
        self.uiManager.showAchievementNotification(achievement)

        // Play achievement haptic feedback
        self.hapticManager.playAchievementHaptic()

        // Track achievement unlock for analytics
        AnalyticsManager.shared.trackEvent(.achievementUnlocked, parameters: [
            "achievement_id": achievement.id,
            "achievement_title": achievement.title,
            "achievement_description": achievement.description,
            "points": String(achievement.points)
        ])
    }

    public func achievementProgressUpdated(_ achievement: Achievement, progress: Float) async {
        print("Achievement progress updated: \(achievement.title) - \(progress)")
    }
}

/// Boss battle delegate protocol
@MainActor
protocol BossManagerDelegate: AnyObject {
    func bossBattleStarted(boss: Boss) async
    func bossBattleEnded(bossType: Boss.BossType, defeated: Bool) async
    func bossHealthChanged(current: CGFloat, max: CGFloat) async
    func bossAttackPerformed(attack: BossAttack) async
}

@MainActor
extension GameScene: BossManagerDelegate {
    func bossBattleStarted(boss: Boss) async {
        print("Boss battle started: \(boss.bossType.displayName)")
        // Pause normal obstacle spawning
        self.obstacleManager.stopSpawning()

        // Play boss battle start haptic feedback
        self.hapticManager.playBossBattleStartHaptic()

        // Create dramatic environmental effects for boss battle
        self.effectsManager.setWeather(.storm, intensity: 0.8)
        self.effectsManager.setLighting(.stormy, intensity: 0.9)
        self.effectsManager.createScreenFlash(color: .red, duration: 0.3)

        // Show boss battle UI
        // self.uiManager.showBossBattleUI(for: boss)
        // Play boss battle music
        // self.audioManager.playBossBattleMusic()
    }

    func bossBattleEnded(bossType: Boss.BossType, defeated: Bool) async {
        print("Boss battle ended: \(bossType.displayName) - \(defeated ? "Defeated" : "Escaped")")
        // Resume normal obstacle spawning
        self.obstacleManager.startSpawning(with: self.gameStateManager.getCurrentDifficulty())

        // Play victory or defeat haptic feedback
        if defeated {
            self.hapticManager.playVictoryPattern()
        }

        // Restore normal environmental conditions
        self.setupEnvironmentalEffects()

        // Create victory/defeat effects
        if defeated {
            self.effectsManager.createLevelUpCelebration()
            self.effectsManager.createScreenFlash(color: .yellow, duration: 0.5)
        } else {
            self.effectsManager.createScreenFlash(color: .gray, duration: 0.3)
        }

        // Hide boss battle UI
        // self.uiManager.hideBossBattleUI()
        // Play appropriate music
        if defeated {
            // self.audioManager.playVictoryMusic()
            // Award bonus points
            self.gameStateManager.addScore(1000)
        } else {
            // self.audioManager.playNormalMusic()
        }
    }

    func bossHealthChanged(current: CGFloat, max: CGFloat) async {
        // Update boss health UI
        // self.uiManager.updateBossHealth(current: current, max: max)
    }

    func bossAttackPerformed(attack: BossAttack) async {
        print("Boss performed attack: \(attack)")

        // Add environmental effects based on attack type
        switch attack {
        case .laserBeam:
            // Screen shake for laser beam attacks
            self.createScreenShake(intensity: 0.3, duration: 0.2)
        case .spikeWave:
            // Ground shake for spike wave attacks
            self.createScreenShake(intensity: 0.4, duration: 0.3)
        case .projectileBarrage:
            // Multiple flashes for projectile barrage
            self.effectsManager.createScreenFlash(color: .orange, duration: 0.1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.effectsManager.createScreenFlash(color: .orange, duration: 0.1)
            }
        case .shockwave:
            // Strong shake and flash for shockwave
            self.createScreenShake(intensity: 0.6, duration: 0.4)
            self.effectsManager.createScreenFlash(color: .cyan, duration: 0.2)
        case .minionSpawn:
            // Fog effect for minion spawn
            self.effectsManager.setWeather(.fog, intensity: 0.4)
        case .teleportStrike:
            // Purple flash for teleport strike
            self.effectsManager.createScreenFlash(color: .purple, duration: 0.3)
        case .ultimateAttack:
            // Dramatic storm effect for ultimate attacks
            self.effectsManager.setWeather(.storm, intensity: 1.0)
            self.effectsManager.createScreenFlash(color: .red, duration: 0.4)
            self.createScreenShake(intensity: 0.8, duration: 0.5)
        }
    }

    /// Creates a screen shake effect
    /// - Parameters:
    ///   - intensity: How intense the shake should be (0.0 to 1.0)
    ///   - duration: How long the shake lasts
    private func createScreenShake(intensity: CGFloat, duration: TimeInterval) {
        guard let scene else { return }

        let shakeAction = SKAction.sequence([
            SKAction.moveBy(x: intensity * 5, y: 0, duration: duration / 8),
            SKAction.moveBy(x: -intensity * 10, y: 0, duration: duration / 8),
            SKAction.moveBy(x: intensity * 5, y: 0, duration: duration / 8),
            SKAction.moveBy(x: 0, y: intensity * 5, duration: duration / 8),
            SKAction.moveBy(x: 0, y: -intensity * 10, duration: duration / 8),
            SKAction.moveBy(x: 0, y: intensity * 5, duration: duration / 8),
        ])

        scene.run(shakeAction)
    }

    /// Calculates the environmental hazard interval based on difficulty
    /// - Parameter difficulty: Current game difficulty level
    /// - Returns: Time interval between hazards in seconds
    private func calculateHazardInterval(for difficulty: Int) -> TimeInterval {
        // Base interval decreases as difficulty increases
        let baseInterval: TimeInterval = 45.0
        let difficultyReduction = Double(difficulty) * 2.0
        return max(8.0, baseInterval - difficultyReduction)
    }

    /// Calculates weather intensity based on difficulty
    /// - Parameter difficulty: Current game difficulty level
    /// - Returns: Weather intensity from 0.0 to 1.0
    private func calculateWeatherIntensity(for difficulty: Int) -> Float {
        // Weather gets more intense at higher difficulties
        let baseIntensity: Float = 0.3
        let difficultyIncrease = Float(difficulty) * 0.05
        return min(1.0, baseIntensity + difficultyIncrease)
    }

    /// Updates environmental effects when difficulty increases during gameplay
    /// - Parameter difficulty: New difficulty level
    private func updateEnvironmentalEffectsForDifficulty(_ difficulty: Int) {
        // Only update if we're not in a boss battle (boss battles have their own effects)
        guard !bossManager.isActive else { return }

        let hazardInterval = calculateHazardInterval(for: difficulty)
        let weatherIntensity = calculateWeatherIntensity(for: difficulty)

        // Stop current hazards and restart with new interval
        effectsManager.stopEnvironmentalEffects()

        // Restart environmental effects with updated parameters
        let gameMode = gameStateManager.getCurrentGameMode()
        switch gameMode {
        case .classic:
            if difficulty > 3 {
                effectsManager.setWeather(.rain, intensity: weatherIntensity)
            }
            if difficulty > 5 {
                effectsManager.startEnvironmentalHazards(interval: hazardInterval)
            }
        case .timeTrial:
            effectsManager.startWeatherCycle(interval: max(10.0, 20.0 - Double(difficulty)))
            effectsManager.startLightingCycle(cycleDuration: max(30.0, 60.0 - Double(difficulty) * 2.0))
        case .survival:
            effectsManager.setWeather(.storm, intensity: weatherIntensity)
            effectsManager.startEnvironmentalHazards(interval: hazardInterval)
        case .puzzle:
            // Keep puzzle mode calm, but add subtle difficulty effects
            if difficulty > 6 {
                effectsManager.setWeather(.fog, intensity: min(weatherIntensity, 0.6))
            }
        case .challenge:
            effectsManager.startWeatherCycle(interval: max(15.0, 25.0 - Double(difficulty)))
            effectsManager.startEnvironmentalHazards(interval: hazardInterval)
        case .custom:
            // Custom mode doesn't change with difficulty
            break
        }

        // Add extreme difficulty effects
        if difficulty > 8 {
            effectsManager.startEnvironmentalHazards(interval: hazardInterval * 0.7)
        }
    }
}

extension GameScene: PowerUpDelegate {
    func powerUpDidSpawn(_ powerUp: PowerUp) {
        // Handle power-up spawning
        print("Power-up spawned: \(powerUp.type.rawValue)")

        // Record power-up spawn for replay
        self.replayManager.recordPowerUpSnapshot(
            id: "\(ObjectIdentifier(powerUp))",
            type: "\(powerUp.type)",
            position: powerUp.node.position,
            isCollected: false
        )
    }

    func powerUpDidCollect(_ powerUp: PowerUp, by player: Player) {
        // Handle power-up collection with environmental effects
        print("Power-up collected: \(powerUp.type.rawValue)")

        // Notify tutorial manager of power-up collection
        self.tutorialManager.playerDidCollectPowerUp()

        // Play power-up collection haptic feedback
        self.hapticManager.playPowerUpHaptic()

        // Record power-up collection for replay
        self.replayManager.recordPlayerAction(position: powerUp.node.position, action: .powerUpCollected)
        self.replayManager.recordPowerUpSnapshot(
            id: "\(ObjectIdentifier(powerUp))",
            type: "\(powerUp.type)",
            position: powerUp.node.position,
            isCollected: true
        )

        // Track power-up collection for analytics
        AnalyticsManager.shared.trackEvent(.powerUpUsed, parameters: [
            "powerup_type": powerUp.type.rawValue,
            "position_x": String(describing: powerUp.node.position.x),
            "position_y": String(describing: powerUp.node.position.y)
        ])
        AnalyticsManager.shared.updateHeatMapData(position: powerUp.node.position, action: .usePowerUp)

        // Add environmental effects based on power-up type
        switch powerUp.type {
        case .shield:
            // Protective shield activation effect
            self.effectsManager.createShieldActivationEffect(at: powerUp.node.position)
            self.effectsManager.createSparkleBurst(at: powerUp.node.position)
        case .speed:
            // Speed boost effect
            self.effectsManager.createSparkleBurst(at: powerUp.node.position)
            self.effectsManager.createScreenFlash(color: .cyan, duration: 0.2)
        case .magnet:
            // Magnetic attraction effect
            self.effectsManager.createSparkleBurst(at: powerUp.node.position)
            self.effectsManager.createScreenFlash(color: .magenta, duration: 0.2)
        case .slowMotion:
            // Time dilation effect
            self.effectsManager.createSparkleBurst(at: powerUp.node.position)
            self.effectsManager.createScreenFlash(color: .blue, duration: 0.3)
        case .multiBall:
            // Multiplicative effect
            self.effectsManager.createLevelUpCelebration()
            self.effectsManager.createScreenFlash(color: .green, duration: 0.4)
        case .laser:
            // Destructive power effect
            self.effectsManager.createExplosion(at: powerUp.node.position)
            self.effectsManager.createScreenFlash(color: .red, duration: 0.3)
        case .freeze:
            // Freezing effect
            self.effectsManager.createSparkleBurst(at: powerUp.node.position)
            self.effectsManager.createScreenFlash(color: .white, duration: 0.3)
        case .teleport:
            // Spatial distortion effect
            self.effectsManager.createExplosion(at: powerUp.node.position)
            self.effectsManager.createScreenFlash(color: .purple, duration: 0.4)
        case .scoreMultiplier, .timeBonus:
            // Valuable reward effect
            self.effectsManager.createLevelUpCelebration()
            self.effectsManager.createScreenFlash(color: .yellow, duration: 0.5)
        }

        // Update game stats
        self.currentGameStats.powerUpsCollected += 1
    }

    func powerUpDidExpire(_ powerUp: PowerUp) {
        // Handle power-up expiration
        print("Power-up expired: \(powerUp.type.rawValue)")

        // Optional: Add subtle expiration effect
        self.effectsManager.createSparkleBurst(at: powerUp.node.position)
    }
}

@MainActor
extension GameScene: ReplayManagerDelegate {
    func replayDidStart(recording: GameRecording) async {
        print("🎬 Replay started: \(recording.sessionId)")
        // Pause normal game systems during replay
        self.gameStateManager.pauseGame()
        // Could show replay UI overlay
    }

    func replayDidFinish(recording: GameRecording) async {
        print("🎬 Replay finished: \(recording.sessionId)")
        // Resume normal game systems
        self.gameStateManager.resumeGame()
        // Could hide replay UI overlay
    }

    func replayPlayerAction(_ action: GameRecording.PlayerAction) async {
        // Simulate player actions during replay
        switch action.action {
        case .move:
            // Move player to recorded position
            self.playerManager.moveTo(action.position)
        case .jump:
            // Handle jump action if implemented
            break
        case .powerUpCollected:
            // Handle power-up collection
            break
        case .collision:
            // Handle collision
            break
        case .gameOver:
            // Handle game over
            break
        }
    }

    func replayObstacleSnapshot(_ snapshot: GameRecording.ObstacleSnapshot) async {
        // Update obstacle positions during replay
        // This would need to be coordinated with the obstacle manager
        // For now, just log the snapshot
        print("Obstacle snapshot: \(snapshot.id) at \(snapshot.position)")
    }

    func replayPowerUpSnapshot(_ snapshot: GameRecording.PowerUpSnapshot) async {
        // Update power-up positions during replay
        // This would need to be coordinated with the power-up manager
        // For now, just log the snapshot
        print("Power-up snapshot: \(snapshot.id) at \(snapshot.position)")
    }
}

@MainActor
extension GameScene: LevelEditorDelegate {
    func levelEditorDidSaveLevel(_ level: CustomLevel) {
        print("🎨 Level saved: \(level.name)")
        // Could show save confirmation UI
    }

    func levelEditorDidLoadLevel(_ level: CustomLevel) {
        print("🎨 Level loaded: \(level.name)")
        // Could update UI to show loaded level
    }

    func levelEditorDidCreateNewLevel() {
        print("🎨 New level created")
        // Could show level creation UI
    }

    func levelEditorDidDeleteLevel(named name: String) {
        print("🎨 Level deleted: \(name)")
        // Could show deletion confirmation
    }
}

@MainActor
extension GameScene: GestureDelegate {
    public func gestureRecognized(_ gesture: GestureType, at location: CGPoint) {
        // Convert screen location to game coordinates
        let gameLocation = convertPoint(fromView: location)

        switch gesture {
        case .tap:
            // Handle tap for player movement
            self.playerManager.handleTouch(at: gameLocation)
            self.hapticManager.playButtonTapHaptic()

        case .doubleTap:
            // Handle double tap for special actions (e.g., jump or dash)
            self.handleDoubleTap(at: gameLocation)

        case let .multiTap(count):
            // Handle multi-tap gestures for advanced actions
            self.handleMultiTap(count: count, at: gameLocation)

        case let .swipe(direction):
            // Handle swipe gestures for directional movement
            self.handleSwipe(direction, at: gameLocation)

        case let .diagonalSwipe(direction):
            // Handle diagonal swipe gestures for precise diagonal movement
            self.handleDiagonalSwipe(direction, at: gameLocation)

        case let .multiFingerSwipe(directions):
            // Handle multi-finger swipe gestures for complex movements
            self.handleMultiFingerSwipe(directions, at: gameLocation)

        case let .forceTouch(pressure):
            // Handle force touch for pressure-sensitive actions
            self.handleForceTouch(pressure: pressure, at: gameLocation)

        case let .circularGesture(clockwise, radius):
            // Handle circular gestures for special abilities
            self.handleCircularGesture(clockwise: clockwise, radius: radius, at: gameLocation)

        case let .gestureCombo(primary, secondary):
            // Handle gesture combinations for advanced actions
            self.handleGestureCombo(primary: primary, secondary: secondary, at: gameLocation)

        case .longPress:
            // Handle long press for special actions
            self.handleLongPress(at: gameLocation)

        default:
            break
        }
    }

    public func gestureBegan(_ gesture: GestureType, at location: CGPoint) {
        // Handle gesture begin events
        let gameLocation = convertPoint(fromView: location)

        switch gesture {
        case .pan:
            // Start pan gesture for continuous movement
            self.handlePanBegan(at: gameLocation)
        case .pinch:
            // Start pinch gesture for zooming or special effects
            self.handlePinchBegan(at: gameLocation)
        default:
            break
        }
    }

    public func gestureChanged(_ gesture: GestureType, at location: CGPoint) {
        // Handle gesture change events
        let gameLocation = convertPoint(fromView: location)

        switch gesture {
        case let .pan(velocity):
            // Handle pan gesture changes for smooth movement
            self.handlePanChanged(at: gameLocation, velocity: velocity)
        case let .pinch(scale):
            // Handle pinch gesture changes
            self.handlePinchChanged(scale: scale, at: gameLocation)
        case let .rotation(angle):
            // Handle rotation gesture changes
            self.handleRotationChanged(angle: angle, at: gameLocation)
        default:
            break
        }
    }

    public func gestureEnded(_ gesture: GestureType, at location: CGPoint) {
        // Handle gesture end events
        let gameLocation = convertPoint(fromView: location)

        switch gesture {
        case .pan:
            // End pan gesture
            self.handlePanEnded(at: gameLocation)
        case .pinch:
            // End pinch gesture
            self.handlePinchEnded(at: gameLocation)
        case .rotation:
            // End rotation gesture
            self.handleRotationEnded(at: gameLocation)
        default:
            break
        }
    }
}

// MARK: - Gesture Handling Methods

extension GameScene {
    /// Handles double tap gestures
    private func handleDoubleTap(at location: CGPoint) {
        // Double tap could trigger a jump or special ability
        self.playerManager.setMovementDirection(.up, active: true)
        // Reset after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.playerManager.setMovementDirection(.up, active: false)
        }
        self.hapticManager.playButtonTapHaptic()
    }

    /// Handles multi-tap gestures
    private func handleMultiTap(count: Int, at location: CGPoint) {
        switch count {
        case 2:
            // Two-finger tap - quick dash in current direction
            self.playerManager.activateDash()
            self.hapticManager.playScoreIncreaseHaptic()
        case 3:
            // Three-finger tap - shield activation
            self.playerManager.activateShield()
            self.hapticManager.playSelectionChangeHaptic()
        case 4:
            // Four-finger tap - emergency pause
            if self.gameStateManager.isGameActive() {
                self.gameStateManager.pauseGame()
                self.uiManager.showPauseMenu()
            }
            self.hapticManager.playButtonTapHaptic()
        default:
            break
        }
    }

    /// Handles swipe gestures
    private func handleSwipe(_ direction: SwipeDirection, at location: CGPoint) {
        switch direction {
        case .up:
            // Quick upward movement
            self.playerManager.setMovementDirection(.up, active: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playerManager.setMovementDirection(.up, active: false)
            }
        case .down:
            // Quick downward movement (if applicable)
            self.playerManager.setMovementDirection(.down, active: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playerManager.setMovementDirection(.down, active: false)
            }
        case .left:
            // Quick left movement
            self.playerManager.setMovementDirection(.left, active: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playerManager.setMovementDirection(.left, active: false)
            }
        case .right:
            // Quick right movement
            self.playerManager.setMovementDirection(.right, active: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playerManager.setMovementDirection(.right, active: false)
            }
        }
        self.hapticManager.playSelectionChangeHaptic()
    }

    /// Handles diagonal swipe gestures
    private func handleDiagonalSwipe(_ direction: DiagonalDirection, at location: CGPoint) {
        switch direction {
        case .upLeft:
            // Diagonal movement up-left
            self.playerManager.setDiagonalMovement(.up, .left, active: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playerManager.setDiagonalMovement(.up, .left, active: false)
            }
        case .upRight:
            // Diagonal movement up-right
            self.playerManager.setDiagonalMovement(.up, .right, active: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playerManager.setDiagonalMovement(.up, .right, active: false)
            }
        case .downLeft:
            // Diagonal movement down-left
            self.playerManager.setDiagonalMovement(.down, .left, active: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playerManager.setDiagonalMovement(.down, .left, active: false)
            }
        case .downRight:
            // Diagonal movement down-right
            self.playerManager.setDiagonalMovement(.down, .right, active: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playerManager.setDiagonalMovement(.down, .right, active: false)
            }
        }
        self.hapticManager.playSelectionChangeHaptic()
    }

    /// Handles multi-finger swipe gestures
    private func handleMultiFingerSwipe(_ directions: [SwipeDirection], at location: CGPoint) {
        // Multi-finger swipes could trigger special abilities or complex movements
        if directions.count == 2 && directions.allSatisfy({ $0 == .up }) {
            // Two-finger up swipe - super jump
            self.playerManager.activateSuperJump()
            self.effectsManager.createExplosionBurst(at: self.playerManager.playerPosition)
        } else if directions.count == 2 && directions.contains(.left) && directions.contains(.right) {
            // Left and right swipe - spin attack
            self.playerManager.activateSpinAttack()
            self.hapticManager.playScoreIncreaseHaptic()
        }
    }

    /// Handles force touch gestures
    private func handleForceTouch(pressure: CGFloat, at location: CGPoint) {
        // Force touch for pressure-sensitive actions
        if pressure > 0.7 {
            // Hard press - powerful attack
            self.playerManager.activatePowerfulAttack()
            self.effectsManager.createShockwave(at: location)
        } else if pressure > 0.4 {
            // Medium press - normal attack
            self.playerManager.activateNormalAttack()
            self.hapticManager.playButtonTapHaptic()
        } else {
            // Light press - quick tap
            self.playerManager.handleTouch(at: location)
        }
    }

    /// Handles circular gestures
    private func handleCircularGesture(clockwise: Bool, radius: CGFloat, at location: CGPoint) {
        if clockwise {
            // Clockwise circle - defensive ability
            self.playerManager.activateDefensiveAbility()
            self.effectsManager.createShieldEffect(at: self.playerManager.playerPosition)
        } else {
            // Counter-clockwise circle - offensive ability
            self.playerManager.activateOffensiveAbility()
            self.effectsManager.createEnergyWave(at: location)
        }
        self.hapticManager.playSelectionChangeHaptic()
    }

    /// Handles gesture combinations
    private func handleGestureCombo(primary: GestureType, secondary: GestureType, at location: CGPoint) {
        // Handle complex gesture combinations
        if case .tap = primary, case let .swipe(direction) = secondary {
            // Tap + Swipe = quick directional dash
            self.playerManager.activateDirectionalDash(direction)
            self.effectsManager.createTrailBurst(at: self.playerManager.playerPosition)
        } else if case .doubleTap = primary, case .longPress = secondary {
            // Double tap + Long press = ultimate ability
            self.playerManager.activateUltimateAbility()
            self.effectsManager.createUltimateEffect(at: location)
        }
        self.hapticManager.playScoreIncreaseHaptic()
    }

    /// Handles long press gestures
    private func handleLongPress(at location: CGPoint) {
        // Long press could pause the game or show special menu
        if self.gameStateManager.isGameActive() {
            self.gameStateManager.pauseGame()
            self.uiManager.showPauseMenu()
        }
        self.hapticManager.playButtonTapHaptic()
    }

    /// Handles pan gesture begin
    private func handlePanBegan(at location: CGPoint) {
        // Start continuous movement towards pan location
        self.playerManager.handleTouch(at: location)
    }

    /// Handles pan gesture changes
    private func handlePanChanged(at location: CGPoint, velocity: CGPoint) {
        // Update player position based on pan velocity
        let speedMultiplier = min(2.0, hypot(velocity.x, velocity.y) / 500.0)
        self.playerManager.handleTouch(at: location)
        // Could use velocity for additional effects
    }

    /// Handles pan gesture end
    private func handlePanEnded(at location: CGPoint) {
        // Stop continuous movement
        self.playerManager.handleTouchRelease(at: location)
    }

    /// Handles pinch gesture begin
    private func handlePinchBegan(at location: CGPoint) {
        // Could start zoom or special effect
        self.hapticManager.playSelectionChangeHaptic()
    }

    /// Handles pinch gesture changes
    private func handlePinchChanged(scale: CGFloat, at location: CGPoint) {
        // Handle zoom or scale effects
        if scale > 1.5 {
            // Pinch out - could zoom in or activate special ability
            self.effectsManager.createSparkleBurst(at: location)
        } else if scale < 0.7 {
            // Pinch in - could zoom out or different effect
            // Implementation depends on game requirements
        }
    }

    /// Handles pinch gesture end
    private func handlePinchEnded(at location: CGPoint) {
        // End pinch effects
    }

    /// Handles rotation gesture changes
    private func handleRotationChanged(angle: CGFloat, at location: CGPoint) {
        // Could rotate player or create rotation effects
        // For now, just provide haptic feedback
        self.hapticManager.playSelectionChangeHaptic()
    }

    /// Handles rotation gesture end
    private func handleRotationEnded(at location: CGPoint) {
        // End rotation effects
    }
}

@MainActor
extension GameScene: TutorialManagerDelegate {
    func tutorialDidComplete() {
        print("Tutorial completed!")
        // Could unlock achievements or show completion celebration
        self.effectsManager.createLevelUpCelebration()
        self.audioManager.playLevelUpSound()

        // Track tutorial completion for analytics
        AnalyticsManager.shared.trackEvent(.tutorialCompleted, parameters: [
            "completion_time": String(Date().timeIntervalSince1970),
            "game_mode": self.gameModeManager.currentMode.displayName
        ])
    }

    func tutorialStepCompleted(_ step: TutorialStep) {
        print("Tutorial step completed: \(step.title)")
        // Could provide positive feedback
        self.hapticManager.playScoreIncreaseHaptic()
    }

    func tutorialSkipped() {
        print("Tutorial skipped by user")
        // Could show a message or update preferences
    }
}
