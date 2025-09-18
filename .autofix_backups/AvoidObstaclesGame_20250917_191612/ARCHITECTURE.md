# AvoidObstaclesGame Architecture Documentation

## Overview

AvoidObstaclesGame is a fast-paced iOS arcade game built with SpriteKit that challenges players to navigate through falling obstacles while achieving high scores. The game features progressive difficulty scaling, physics-based collision detection, persistent high score tracking, and smooth performance optimization for engaging gameplay.

## System Architecture

### Core Components

```
AvoidObstaclesGame/
├── AvoidObstaclesGame/                 # Main game bundle
│   ├── AppDelegate.swift              # App lifecycle management
│   ├── GameViewController.swift       # Game view controller
│   ├── GameScene.swift               # Core game logic and physics
│   ├── GameScene.sks                 # Visual scene editor file
│   ├── GameDifficulty.swift          # Difficulty progression system
│   ├── HighScoreManager.swift        # Score persistence manager
│   ├── Actions.sks                   # SpriteKit actions library
│   ├── Assets.xcassets/              # Game assets and sprites
│   └── Base.lproj/                   # Localization resources
├── AvoidObstaclesGameTests/           # Unit test suite
├── AvoidObstaclesGameUITests/         # UI automation tests
├── Tools/                            # Development utilities
└── test_game.sh                      # Automated testing script
```

## Game Architecture Patterns

### MVC Pattern Implementation

```swift
// Model: Game state and data management
struct GameState {
    var score: Int = 0
    var isGameOver: Bool = false
    var difficultyLevel: Int = 1
    var playerPosition: CGPoint = .zero
    var obstacles: [ObstacleNode] = []
}

// View: SpriteKit scene rendering
class GameScene: SKScene {
    // Visual representation and user interface
    private var player: SKSpriteNode?
    private var scoreLabel: SKLabelNode?
    private var gameOverLabel: SKLabelNode?

    // Scene lifecycle and rendering
    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupUI()
        startGame()
    }
}

// Controller: Game logic coordination
class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure SpriteKit view
        if let view = self.view as? SKView {
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)

            // Performance optimization
            view.ignoresSiblingOrder = true
        }
    }
}
```

### Physics System Architecture

#### Collision Detection Framework
```swift
// Physics categories for collision detection
enum PhysicsCategory {
    static let none: UInt32 = 0         // No collision
    static let player: UInt32 = 0b1     // Player character (1)
    static let obstacle: UInt32 = 0b10  // Falling obstacles (2)
    static let boundary: UInt32 = 0b100 // Screen boundaries (4)
    static let powerUp: UInt32 = 0b1000 // Future power-ups (8)
}

// Physics world configuration
class PhysicsWorldManager {
    func setupPhysicsWorld(_ scene: SKScene) {
        // Configure physics world properties
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        scene.physicsWorld.contactDelegate = scene as? SKPhysicsContactDelegate

        // Create invisible boundaries
        let boundary = SKPhysicsBody(edgeLoopFrom: scene.frame)
        boundary.categoryBitMask = PhysicsCategory.boundary
        scene.physicsBody = boundary
    }

    func createPlayerPhysics() -> SKPhysicsBody {
        let physics = SKPhysicsBody(circleOfRadius: 20)
        physics.categoryBitMask = PhysicsCategory.player
        physics.contactTestBitMask = PhysicsCategory.obstacle
        physics.collisionBitMask = PhysicsCategory.boundary
        physics.isDynamic = true
        physics.affectedByGravity = false
        physics.allowsRotation = false
        return physics
    }

    func createObstaclePhysics(size: CGSize) -> SKPhysicsBody {
        let physics = SKPhysicsBody(rectangleOf: size)
        physics.categoryBitMask = PhysicsCategory.obstacle
        physics.contactTestBitMask = PhysicsCategory.player
        physics.collisionBitMask = PhysicsCategory.none
        physics.isDynamic = true
        physics.affectedByGravity = true
        return physics
    }
}
```

#### Collision Response System
```swift
// Contact delegate implementation in GameScene
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch collision {
        case PhysicsCategory.player | PhysicsCategory.obstacle:
            handlePlayerObstacleCollision(contact)

        case PhysicsCategory.player | PhysicsCategory.powerUp:
            handlePlayerPowerUpCollision(contact)

        default:
            break
        }
    }

    private func handlePlayerObstacleCollision(_ contact: SKPhysicsContact) {
        // Game over logic
        endGame()

        // Visual feedback
        createExplosionEffect(at: player?.position ?? .zero)

        // Audio feedback
        playCollisionSound()

        // Haptic feedback
        triggerHapticFeedback()
    }
}
```

## Game Systems

### Difficulty Progression System

```swift
struct GameDifficulty {
    let spawnInterval: Double    // Time between obstacle spawns
    let obstacleSpeed: Double   // Speed of falling obstacles
    let scoreMultiplier: Double // Score multiplier for this difficulty
    let obstacleCount: Int      // Number of simultaneous obstacles

    // Progressive difficulty scaling
    static func getDifficulty(for score: Int) -> GameDifficulty {
        switch score {
        case 0..<10:
            return GameDifficulty(
                spawnInterval: 1.2,
                obstacleSpeed: 3.5,
                scoreMultiplier: 1.0,
                obstacleCount: 1
            )

        case 10..<25:
            return GameDifficulty(
                spawnInterval: 1.0,
                obstacleSpeed: 3.0,
                scoreMultiplier: 1.2,
                obstacleCount: 2
            )

        case 25..<50:
            return GameDifficulty(
                spawnInterval: 0.8,
                obstacleSpeed: 2.5,
                scoreMultiplier: 1.5,
                obstacleCount: 3
            )

        case 50..<100:
            return GameDifficulty(
                spawnInterval: 0.6,
                obstacleSpeed: 2.0,
                scoreMultiplier: 2.0,
                obstacleCount: 4
            )

        case 100..<200:
            return GameDifficulty(
                spawnInterval: 0.5,
                obstacleSpeed: 1.5,
                scoreMultiplier: 2.5,
                obstacleCount: 5
            )

        default: // 200+
            return GameDifficulty(
                spawnInterval: 0.4,
                obstacleSpeed: 1.2,
                scoreMultiplier: 3.0,
                obstacleCount: 6
            )
        }
    }

    // Dynamic difficulty adjustment
    func adjustForPlayerSkill(averageReactionTime: TimeInterval) -> GameDifficulty {
        let skillFactor = min(max(averageReactionTime / 0.5, 0.7), 1.3)

        return GameDifficulty(
            spawnInterval: spawnInterval * skillFactor,
            obstacleSpeed: obstacleSpeed / skillFactor,
            scoreMultiplier: scoreMultiplier,
            obstacleCount: obstacleCount
        )
    }
}
```

### Obstacle Management System

```swift
class ObstacleManager {
    private var activeObstacles: [SKSpriteNode] = []
    private var obstaclePool: [SKSpriteNode] = []
    private let maxPoolSize = 20

    // Object pooling for performance
    func getObstacle() -> SKSpriteNode {
        if let recycledObstacle = obstaclePool.popLast() {
            resetObstacle(recycledObstacle)
            return recycledObstacle
        } else {
            return createNewObstacle()
        }
    }

    func recycleObstacle(_ obstacle: SKSpriteNode) {
        obstacle.removeFromParent()
        obstacle.removeAllActions()

        if obstaclePool.count < maxPoolSize {
            obstaclePool.append(obstacle)
        }

        activeObstacles.removeAll { $0 === obstacle }
    }

    private func createNewObstacle() -> SKSpriteNode {
        let obstacle = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        obstacle.name = "obstacle"

        // Configure physics
        obstacle.physicsBody = PhysicsWorldManager().createObstaclePhysics(size: obstacle.size)

        return obstacle
    }

    // Spawning logic with difficulty adjustment
    func spawnObstacle(in scene: SKScene, difficulty: GameDifficulty) {
        let obstacle = getObstacle()

        // Random horizontal position
        let randomX = CGFloat.random(
            in: obstacle.size.width/2...(scene.size.width - obstacle.size.width/2)
        )

        obstacle.position = CGPoint(x: randomX, y: scene.size.height + obstacle.size.height)

        scene.addChild(obstacle)
        activeObstacles.append(obstacle)

        // Animate falling with difficulty-based speed
        let fallAction = SKAction.moveBy(
            x: 0,
            y: -(scene.size.height + obstacle.size.height * 2),
            duration: TimeInterval(scene.size.height / (difficulty.obstacleSpeed * 100))
        )

        let removeAction = SKAction.run { [weak self] in
            self?.recycleObstacle(obstacle)
        }

        obstacle.run(SKAction.sequence([fallAction, removeAction]))
    }
}
```

## Score and Progression System

### High Score Management

```swift
class HighScoreManager {
    static let shared = HighScoreManager()
    private let highScoresKey = "AvoidObstaclesHighScores"
    private let maxScores = 10

    private init() {}

    // Persistent score storage
    func getHighScores() -> [HighScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: highScoresKey),
              let scores = try? JSONDecoder().decode([HighScoreEntry].self, from: data) else {
            return []
        }
        return scores.sorted { $0.score > $1.score }
    }

    func addScore(_ score: Int, playerName: String = "Player") -> ScoreResult {
        var scores = getHighScores()
        let newEntry = HighScoreEntry(
            score: score,
            playerName: playerName,
            date: Date(),
            difficultyReached: GameDifficulty.getDifficultyLevel(for: score)
        )

        scores.append(newEntry)
        scores.sort { $0.score > $1.score }

        // Keep only top scores
        if scores.count > maxScores {
            scores = Array(scores.prefix(maxScores))
        }

        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(data, forKey: highScoresKey)
            UserDefaults.standard.synchronize()
        }

        // Determine result type
        let rank = scores.firstIndex { $0.id == newEntry.id } ?? maxScores

        return ScoreResult(
            rank: rank + 1,
            isNewHighScore: rank < maxScores,
            isPersonalBest: score > getPersonalBest(),
            totalScores: scores.count
        )
    }

    // Analytics and statistics
    func getScoreStatistics() -> ScoreStatistics {
        let scores = getHighScores().map { $0.score }

        return ScoreStatistics(
            averageScore: scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count,
            medianScore: calculateMedian(scores),
            totalGamesPlayed: UserDefaults.standard.integer(forKey: "totalGamesPlayed"),
            bestStreak: UserDefaults.standard.integer(forKey: "bestStreak")
        )
    }
}

struct HighScoreEntry: Codable, Identifiable {
    let id = UUID()
    let score: Int
    let playerName: String
    let date: Date
    let difficultyReached: Int
}

struct ScoreResult {
    let rank: Int
    let isNewHighScore: Bool
    let isPersonalBest: Bool
    let totalScores: Int
}
```

### Achievement System

```swift
enum Achievement: String, CaseIterable {
    case firstGame = "first_game"
    case score100 = "score_100"
    case score500 = "score_500"
    case score1000 = "score_1000"
    case survivor = "survivor_60s"
    case speedster = "speedster"
    case perfectStart = "perfect_start"

    var title: String {
        switch self {
        case .firstGame: "First Steps"
        case .score100: "Century"
        case .score500: "High Flyer"
        case .score1000: "Legend"
        case .survivor: "Survivor"
        case .speedster: "Speed Demon"
        case .perfectStart: "Perfect Start"
        }
    }

    var description: String {
        switch self {
        case .firstGame: "Complete your first game"
        case .score100: "Reach a score of 100"
        case .score500: "Reach a score of 500"
        case .score1000: "Reach a score of 1000"
        case .survivor: "Survive for 60 seconds"
        case .speedster: "Reach level 5 difficulty"
        case .perfectStart: "Score 50 without getting hit"
        }
    }
}

class AchievementManager {
    static let shared = AchievementManager()
    private let achievementsKey = "unlockedAchievements"

    func checkAchievements(gameStats: GameStats) {
        var newAchievements: [Achievement] = []

        // Check score-based achievements
        if gameStats.finalScore >= 100 && !isUnlocked(.score100) {
            newAchievements.append(.score100)
        }

        if gameStats.finalScore >= 500 && !isUnlocked(.score500) {
            newAchievements.append(.score500)
        }

        if gameStats.finalScore >= 1000 && !isUnlocked(.score1000) {
            newAchievements.append(.score1000)
        }

        // Check time-based achievements
        if gameStats.survivalTime >= 60 && !isUnlocked(.survivor) {
            newAchievements.append(.survivor)
        }

        // Check performance achievements
        if gameStats.maxDifficultyReached >= 5 && !isUnlocked(.speedster) {
            newAchievements.append(.speedster)
        }

        // Unlock new achievements
        for achievement in newAchievements {
            unlockAchievement(achievement)
        }
    }

    private func unlockAchievement(_ achievement: Achievement) {
        var unlockedAchievements = getUnlockedAchievements()
        unlockedAchievements.insert(achievement.rawValue)

        UserDefaults.standard.set(Array(unlockedAchievements), forKey: achievementsKey)

        // Show achievement notification
        showAchievementNotification(achievement)
    }
}
```

## Performance Optimization

### Memory Management

```swift
class PerformanceManager {
    // Object pooling for frequently created objects
    private var nodePool: [String: [SKNode]] = [:]
    private let maxPoolSize = 50

    func getPooledNode(type: String, creator: () -> SKNode) -> SKNode {
        if var pool = nodePool[type], !pool.isEmpty {
            let node = pool.removeLast()
            nodePool[type] = pool
            return node
        } else {
            return creator()
        }
    }

    func returnToPool(_ node: SKNode, type: String) {
        // Reset node state
        node.removeFromParent()
        node.removeAllActions()
        node.alpha = 1.0
        node.isHidden = false

        // Add to pool if not full
        if var pool = nodePool[type], pool.count < maxPoolSize {
            pool.append(node)
            nodePool[type] = pool
        } else if nodePool[type] == nil {
            nodePool[type] = [node]
        }
    }

    // Memory pressure handling
    func handleMemoryWarning() {
        // Clear pools
        nodePool.removeAll()

        // Reduce active obstacles
        reduceActiveObstacles()

        // Lower graphics quality temporarily
        adjustGraphicsQuality(level: .low)
    }
}
```

### Frame Rate Optimization

```swift
extension GameScene {
    // Optimize rendering for consistent 60fps
    private func optimizePerformance() {
        // Batch node updates
        enumerateChildNodes(withName: "obstacle") { node, _ in
            if node.position.y < -100 {
                // Remove off-screen obstacles immediately
                self.recycleObstacle(node as! SKSpriteNode)
            }
        }

        // Limit concurrent obstacles based on device capability
        let deviceCapability = getDeviceCapability()
        let maxObstacles = deviceCapability.maxObstacles

        if activeObstacleCount > maxObstacles {
            removeExcessObstacles(count: activeObstacleCount - maxObstacles)
        }
    }

    private func getDeviceCapability() -> DeviceCapability {
        let device = UIDevice.current

        // Detect device performance tier
        switch device.userInterfaceIdiom {
        case .phone:
            if ProcessInfo.processInfo.processorCount >= 6 {
                return DeviceCapability.high
            } else {
                return DeviceCapability.medium
            }
        case .pad:
            return DeviceCapability.high
        default:
            return DeviceCapability.medium
        }
    }
}

struct DeviceCapability {
    let maxObstacles: Int
    let particleLimit: Int
    let textureQuality: TextureQuality

    static let high = DeviceCapability(maxObstacles: 15, particleLimit: 100, textureQuality: .high)
    static let medium = DeviceCapability(maxObstacles: 10, particleLimit: 50, textureQuality: .medium)
    static let low = DeviceCapability(maxObstacles: 6, particleLimit: 25, textureQuality: .low)
}
```

## Audio and Visual Effects

### Sound Management System

```swift
class AudioManager {
    static let shared = AudioManager()

    private var soundEffects: [String: SKAction] = [:]
    private var backgroundMusic: SKAudioNode?
    private var isAudioEnabled: Bool {
        UserDefaults.standard.bool(forKey: "audioEnabled")
    }

    func preloadSounds() {
        soundEffects["collision"] = SKAction.playSoundFileNamed("collision.wav", waitForCompletion: false)
        soundEffects["score"] = SKAction.playSoundFileNamed("score.wav", waitForCompletion: false)
        soundEffects["gameOver"] = SKAction.playSoundFileNamed("gameOver.wav", waitForCompletion: false)
    }

    func playSound(_ soundName: String, on node: SKNode) {
        guard isAudioEnabled,
              let soundAction = soundEffects[soundName] else { return }

        node.run(soundAction)
    }

    func startBackgroundMusic(in scene: SKScene) {
        guard isAudioEnabled else { return }

        stopBackgroundMusic()

        backgroundMusic = SKAudioNode(fileNamed: "background_music.mp3")
        backgroundMusic?.autoplayLooped = true

        if let music = backgroundMusic {
            scene.addChild(music)
        }
    }
}
```

### Particle Effects System

```swift
class EffectsManager {
    static let shared = EffectsManager()

    func createExplosionEffect(at position: CGPoint, in scene: SKScene) {
        guard let explosion = SKEmitterNode(fileNamed: "Explosion.sks") else { return }

        explosion.position = position
        explosion.zPosition = 100

        scene.addChild(explosion)

        // Auto-remove after animation
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ])

        explosion.run(removeAction)
    }

    func createScorePopup(score: Int, at position: CGPoint, in scene: SKScene) {
        let scoreLabel = SKLabelNode(fontNamed: "Arial-Bold")
        scoreLabel.text = "+\\(score)"
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
}
```

## Input and Controls

### Touch Input System

```swift
extension GameScene {
    // Multi-touch support for advanced controls
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else {
            handleGameOverTouches(touches)
            return
        }

        for touch in touches {
            let location = touch.location(in: self)
            handlePlayerMovement(to: location)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }

        for touch in touches {
            let location = touch.location(in: self)
            smoothPlayerMovement(to: location)
        }
    }

    private func handlePlayerMovement(to location: CGPoint) {
        guard let player = self.player else { return }

        // Constrain player movement to screen bounds
        let constrainedX = max(player.size.width/2,
                              min(location.x, size.width - player.size.width/2))

        // Smooth movement with physics
        let targetPosition = CGPoint(x: constrainedX, y: player.position.y)
        let moveAction = SKAction.move(to: targetPosition, duration: 0.1)
        moveAction.timingMode = .easeOut

        player.run(moveAction, withKey: "playerMovement")
    }

    // Alternative control schemes
    private func handleTiltControls() {
        // Accelerometer-based movement
        if let accelerometerData = motionManager.accelerometerData {
            let acceleration = accelerometerData.acceleration.x
            let newX = player?.position.x ?? 0 + CGFloat(acceleration * 20)

            // Apply movement with bounds checking
            updatePlayerPosition(x: newX)
        }
    }
}
```

## Testing Architecture

### Unit Testing Strategy

```swift
class GameLogicTests: XCTestCase {
    var gameScene: GameScene!

    override func setUp() {
        super.setUp()
        gameScene = GameScene(size: CGSize(width: 375, height: 667))
    }

    func testDifficultyProgression() {
        // Test difficulty scaling
        let level1 = GameDifficulty.getDifficulty(for: 5)
        let level2 = GameDifficulty.getDifficulty(for: 15)

        XCTAssertGreaterThan(level1.spawnInterval, level2.spawnInterval)
        XCTAssertLessThan(level1.obstacleSpeed, level2.obstacleSpeed)
        XCTAssertLessThan(level1.scoreMultiplier, level2.scoreMultiplier)
    }

    func testScoreCalculation() {
        // Test score system
        let initialScore = 0
        let expectedScore = 10

        gameScene.addScore(10)
        XCTAssertEqual(gameScene.currentScore, expectedScore)
    }

    func testHighScoreManager() {
        // Test high score persistence
        let manager = HighScoreManager.shared
        manager.clearHighScores() // Reset for test

        let testScore = 150
        let result = manager.addScore(testScore)

        XCTAssertTrue(result.isNewHighScore)
        XCTAssertEqual(manager.getHighestScore(), testScore)
    }

    func testObstaclePooling() {
        // Test object pooling performance
        let manager = ObstacleManager()

        let obstacle1 = manager.getObstacle()
        let obstacle2 = manager.getObstacle()

        XCTAssertNotEqual(obstacle1, obstacle2)

        manager.recycleObstacle(obstacle1)
        let obstacle3 = manager.getObstacle()

        XCTAssertEqual(obstacle1, obstacle3) // Should reuse pooled object
    }
}
```

### Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testFrameRateStability() {
        let gameScene = GameScene(size: CGSize(width: 375, height: 667))

        // Simulate heavy load
        for _ in 0..<20 {
            gameScene.spawnObstacle()
        }

        measure {
            // Measure update cycle performance
            gameScene.update(0.016) // 60fps = ~16ms per frame
        }
    }

    func testMemoryUsage() {
        let gameScene = GameScene(size: CGSize(width: 375, height: 667))

        measure(metrics: [XCTMemoryMetric()]) {
            // Test memory usage during obstacle spawning
            for _ in 0..<100 {
                gameScene.spawnObstacle()
                gameScene.update(0.1)
            }
        }
    }
}
```

## Future Architecture Plans

### Roadmap

1. **Multiplayer Integration**
   - Real-time competitive gameplay
   - Leaderboards and tournaments
   - Social sharing features

2. **Power-ups and Special Items**
   - Shield protection system
   - Speed boosts and time dilation
   - Magnet for score collection

3. **Advanced Graphics**
   - Particle system enhancements
   - Dynamic lighting effects
   - 3D obstacle models

4. **AI and Machine Learning**
   - Adaptive difficulty based on player skill
   - Personalized obstacle patterns
   - Predictive player assistance

### Scalability Considerations

- **Modular Game Systems**: Pluggable game mechanics and features
- **Cloud Save Integration**: GameCenter and iCloud synchronization
- **Analytics Integration**: Player behavior tracking and optimization
- **Monetization Architecture**: In-app purchases and reward systems

---

*Architecture Documentation Last Updated: September 12, 2025*
*AvoidObstaclesGame Version: 1.0*
*Platform: iOS 13.0+, SpriteKit Framework*
