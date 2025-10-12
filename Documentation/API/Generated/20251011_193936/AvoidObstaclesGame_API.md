# AvoidObstaclesGame API Documentation

**Generated:** Sat Oct 11 19:39:36 CDT 2025
**Version:** 1.0.0

## Overview

This document provides comprehensive API reference for AvoidObstaclesGame.

---

## GameCoordinator.swift

**Path:** `AvoidObstaclesGame/Coordinator/GameCoordinator.swift`

### Description

Protocol for objects that can be coordinated

### Protocols

#### `Coordinatable`

Protocol for objects that can be coordinated

- `func coordinatorDidStart()`
- `func coordinatorDidStop()`
- `func coordinatorDidTransition(to state: GameState)`

#### `GameCoordinatorDelegate`

Protocol for game coordinator delegate

- `func coordinatorDidTransition(to state: GameState)`
- `func coordinatorDidRequestSceneChange(to sceneType: SceneType)`

### Classes

#### `GameCoordinator`

Types of scenes the coordinator can manage
Main game coordinator responsible for managing game state and coordinating managers


### Enums

#### `GameState`

Game state enumeration


#### `SceneType`

Protocol for game coordinator delegate
Types of scenes the coordinator can manage


#### `UserAction`

User actions that can trigger state transitions


---

## GameStateManager.swift

**Path:** `AvoidObstaclesGame/Core/GameStateManager.swift`

### Description

Protocol for game state change notifications

### Protocols

#### `GameStateDelegate`

Protocol for game state change notifications

- `func gameStateDidChange(from oldState: GameState, to newState: GameState)`
- `func scoreDidChange(to newScore: Int)`
- `func difficultyDidIncrease(to level: Int)`
- `func gameDidEnd(withScore finalScore: Int, survivalTime: TimeInterval)`

### Classes

#### `GameStateManager`

Represents the current state of the game
Manages the core game state and logic


### Enums

#### `GameState`

Protocol for game state change notifications
Represents the current state of the game


---

## GameScene.swift

**Path:** `AvoidObstaclesGame/Core/GameScene.swift`

### Description

The main SpriteKit scene for AvoidObstaclesGame.
Coordinates all game services and manages the high-level game flow.

### Structs

#### `GameStats`

Game statistics for achievements and analytics


---

## GameDifficulty.swift

**Path:** `AvoidObstaclesGame/Core/GameDifficulty.swift`

### Description

Represents the difficulty settings for the AvoidObstaclesGame.
Adjusts obstacle spawn rate, speed, and score multiplier based on the player's score.

### Structs

#### `GameDifficulty`

Represents the difficulty settings for the AvoidObstaclesGame.
Adjusts obstacle spawn rate, speed, and score multiplier based on the player's score.


---

## GameObjectPool.swift

**Path:** `AvoidObstaclesGame/Managers/GameObjectPool.swift`

### Description

Protocol that all poolable game objects must conform to

### Protocols

#### `Poolable`

Protocol that all poolable game objects must conform to

- `var poolIdentifier: String `
- `var isActive: Bool `
- `func reset()`
- `func prepareForActivation(parameters: [String: Any]?)`
- `func memoryFootprint() -> Int`

#### `GameObjectPoolDelegate`

Protocol for object pool events

- `func objectDidSpawn<T: Poolable>(_ object: T)`
- `func objectDidRecycle<T: Poolable>(_ object: T)`

### Classes

#### `GameObjectPool`

Protocol for object pool events
Generic object pool for efficient reuse of game objects


---

## StatisticsDisplayManager.swift

**Path:** `AvoidObstaclesGame/Managers/StatisticsDisplayManager.swift`

### Description

Manages the statistics display overlay

### Classes

#### `StatisticsDisplayManager`

Manages the statistics display overlay


---

## PhysicsManager.swift

**Path:** `AvoidObstaclesGame/Managers/PhysicsManager.swift`

### Description

Protocol for physics-related events

### Protocols

#### `PhysicsManagerDelegate`

Protocol for physics-related events

- `func playerDidCollideWithObstacle(_ player: SKNode, obstacle: SKNode)`
- `func playerDidCollideWithPowerUp(_ player: SKNode, powerUp: SKNode)`

### Enums

#### `PhysicsQuality`

Physics simulation quality levels


---

## ObstacleManager.swift

**Path:** `AvoidObstaclesGame/Managers/ObstacleManager.swift`

### Description

Protocol for obstacle-related events

### Protocols

#### `ObstacleDelegate`

Protocol for obstacle-related events

- `func obstacleDidSpawn(_ obstacle: Obstacle)`
- `func obstacleDidRecycle(_ obstacle: Obstacle)`

### Classes

#### `ObstacleManager`

Protocol for obstacle-related events
Manages obstacles with object pooling for performance


### Structs

#### `ObstacleConfiguration`

Configuration for obstacle types


### Enums

#### `ObstacleType`

Types of obstacles available


---

## EffectsManager.swift

**Path:** `AvoidObstaclesGame/Managers/EffectsManager.swift`

### Description

Manages visual effects and animations

### Classes

#### `EffectsManager`

Manages visual effects and animations


---

## AudioManager.swift

**Path:** `AvoidObstaclesGame/Managers/AudioManager.swift`

### Description

Manages all audio-related functionality

### Enums

#### `HapticStyle`

Haptic feedback styles


---

## ObstaclePool.swift

**Path:** `AvoidObstaclesGame/Managers/ObstaclePool.swift`

### Description

Protocol for obstacle pool events

### Protocols

#### `ObstaclePoolDelegate`

Protocol for obstacle pool events

- `func obstacleDidSpawn(_ obstacle: Obstacle)`
- `func obstacleDidRecycle(_ obstacle: Obstacle)`

### Classes

#### `ObstaclePool`

Protocol for obstacle pool events
Manages a pool of Obstacle objects for efficient reuse


---

## PerformanceOverlayManager.swift

**Path:** `AvoidObstaclesGame/Managers/PerformanceOverlayManager.swift`

### Description

Manages the performance monitoring overlay

### Classes

#### `PerformanceOverlayManager`

Manages the performance monitoring overlay


---

## PlayerManager.swift

**Path:** `AvoidObstaclesGame/Managers/PlayerManager.swift`

### Description

Protocol for player-related events

### Protocols

#### `PlayerDelegate`

Protocol for player-related events

- `func playerDidMove(to position: CGPoint)`
- `func playerDidCollide(with obstacle: SKNode)`

### Classes

#### `PlayerManager`

Protocol for player-related events
Manages the player character and its interactions


---

## GameOverScreenManager.swift

**Path:** `AvoidObstaclesGame/Managers/GameOverScreenManager.swift`

### Description

Protocol for game over screen events

### Protocols

#### `GameOverScreenDelegate`

Protocol for game over screen events

- `func restartButtonTapped()`

### Classes

#### `GameOverScreenManager`

Protocol for game over screen events
Manages the game over screen display and interactions


---

## UIDisplayManager.swift

**Path:** `AvoidObstaclesGame/Managers/UIDisplayManager.swift`

### Description

Types of display overlays that can be shown

### Classes

#### `UIDisplayManager`

Types of display overlays that can be shown
Manages all UI display overlays including statistics and performance monitoring


### Enums

#### `DisplayOverlayType`

Types of display overlays that can be shown


---

## HUDManager.swift

**Path:** `AvoidObstaclesGame/Managers/HUDManager.swift`

### Description

Manages HUD (Heads-Up Display) elements

### Classes

#### `HUDManager`

Manages HUD (Heads-Up Display) elements


---

## UIManager.swift

**Path:** `AvoidObstaclesGame/Managers/UIManager.swift`

### Description

Protocol for UI-related events

### Protocols

#### `UIManagerDelegate`

Protocol for UI-related events

- `func restartButtonTapped()`

### Classes

#### `UIManager`

Protocol for UI-related events
Manages all UI elements and visual feedback


---

## UIEffectsManager.swift

**Path:** `AvoidObstaclesGame/Managers/UIEffectsManager.swift`

### Description

Manages UI effects and animations

### Classes

#### `UIEffectsManager`

Manages UI effects and animations


---

## GameHUDManager.swift

**Path:** `AvoidObstaclesGame/Managers/GameHUDManager.swift`

### Description

Protocol for GameHUDManager events

### Protocols

#### `GameHUDManagerDelegate`

Protocol for GameHUDManager events

- `func restartButtonTapped()`

### Classes

#### `GameHUDManager`

Protocol for GameHUDManager events
Consolidated HUD manager for all game interface elements


---

## PerformanceManager.swift

**Path:** `AvoidObstaclesGame/Utils/PerformanceManager.swift`

### Description

Protocol for performance-related events

### Protocols

#### `PerformanceDelegate`

Protocol for performance-related events

- `func performanceWarningTriggered(_ warning: PerformanceWarning)`
- `func frameRateDropped(below targetFPS: Int)`

### Structs

#### `PoolSizes`

Quality level settings
Pool size recommendations


#### `PerformanceStats`

Pool size recommendations
Performance statistics tracking


### Enums

#### `PerformanceWarning`

Protocol for performance-related events
Performance warning types


#### `DeviceCapability`

Performance warning types
Device capability levels


#### `TextureQuality`

Texture quality levels


#### `QualityLevel`

Quality level settings


---

## GameEntities.swift

**Path:** `AvoidObstaclesGame/Models/GameEntities.swift`

### Description

Protocol for all game components that need updates

### Protocols

#### `GameComponent`

Protocol for all game components that need updates

- `func update(deltaTime: TimeInterval)`
- `func reset()`

#### `Renderable`

Protocol for all game components that need updates
Protocol for objects that can be rendered on screen

- `var node: SKNode `
- `var isVisible: Bool `

#### `Collidable`

Protocol for objects that can be rendered on screen
Protocol for objects that can collide

- `var physicsBody: SKPhysicsBody? `
- `func handleCollision(with other: Collidable)`

### Classes

#### `Player`

Protocol for objects that can collide
Represents the player character with enhanced UI feedback


#### `Obstacle`

Represents game obstacles with improved visual design


#### `PowerUp`

Represents power-ups with enhanced visual effects


---

## PhysicsCategory.swift

**Path:** `AvoidObstaclesGame/Models/PhysicsCategory.swift`

### Description

Defines the categories for physics bodies to handle collisions.
Using UInt32 for bitmasks allows up to 32 unique categories.

### Enums

#### `PhysicsCategory`

Defines the categories for physics bodies to handle collisions.
Using UInt32 for bitmasks allows up to 32 unique categories.


---

## HighScoreManager.swift

**Path:** `AvoidObstaclesGame/Services/HighScoreManager.swift`

### Description

Manages high scores with persistent storage using UserDefaults.
Provides methods to add, retrieve, and clear high scores for the AvoidObstaclesGame.

### Classes

#### `HighScoreManager`

Manages high scores with persistent storage using UserDefaults.
Provides methods to add, retrieve, and clear high scores for the AvoidObstaclesGame.


---

## ProgressionManager.swift

**Path:** `AvoidObstaclesGame/Services/ProgressionManager.swift`

### Description

Protocol for progression-related events

### Protocols

#### `ProgressionDelegate`

Protocol for progression-related events

- `func achievementUnlocked(_ achievement: Achievement)`
- `func achievementProgressUpdated(_ achievement: Achievement, progress: Double)`
- `func highScoreAchieved(_ score: Int, rank: Int)`

### Classes

#### `ProgressionManager`

Protocol for progression-related events
Manages all progression systems including achievements and high scores


### Enums

#### `AchievementEvent`

Events that can trigger achievement progress


---

## PlayerAnalyticsAI.swift

**Path:** `AvoidObstaclesGame/Services/PlayerAnalyticsAI.swift`

### Description

Simple power-up type enum for analytics
Player skill level assessment

### Enums

#### `PlayerSkillLevel`

Simple power-up type enum for analytics
Player skill level assessment


---

## AdaptiveDifficultyAI.swift

**Path:** `AvoidObstaclesGame/Services/AdaptiveDifficultyAI.swift`

### Description

Simple power-up type enum for AI analysis
AI-powered adaptive difficulty system
Analyzes player behavior patterns and performance metrics to provide
dynamic difficulty scaling for optimal game engagement.

### Enums

#### `AIError`

AI analysis result from Ollama
AI-related errors


---

## AchievementManager.swift

**Path:** `AvoidObstaclesGame/Services/AchievementManager.swift`

### Description

Manages achievements and their unlocking

### Classes

#### `AchievementManager`

Manages achievements and their unlocking


### Enums

#### `AchievementEvent`

Events that can trigger achievement progress


---

