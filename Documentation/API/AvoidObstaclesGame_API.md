# AvoidObstaclesGame API Documentation

Generated: Wed Sep 24 09:04:03 CDT 2025
Project: AvoidObstaclesGame
Location: /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame

## Overview

This document contains the public API reference for AvoidObstaclesGame.

## Classes and Structs

### PerformanceManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/PerformanceManager.swift`

#### Public Types

- **public class PerformanceManager {** (line 10)

#### Public Functions

- `recordFrame() {` (line 19)
- `getCurrentFPS() -> Double {` (line 29)
- `getMemoryUsage() -> Double {` (line 44)
- `isPerformanceDegraded() -> Bool {` (line 62)

### PerformanceManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/PerformanceManager.swift`

### PhysicsManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/PhysicsManager.swift`

#### Public Types

- **public class PhysicsManager: NSObject, SKPhysicsContactDelegate {** (line 18)

#### Public Functions

- `didBegin(_ contact: SKPhysicsContact) {` (line 109)

### ObstacleManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/ObstacleManager.swift`

### GameViewController

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/GameViewController.swift`

#### Public Types

- **public class GameViewController: UIViewController {** (line 14)

### EffectsManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/EffectsManager.swift`

### GameStateManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/GameStateManager.swift`

### AudioManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/AudioManager.swift`

#### Public Types

- **public class AudioManager: NSObject {** (line 12)

#### Public Functions

- `audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {` (line 360)

### PhysicsCategory

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/PhysicsCategory.swift`

### HighScoreManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/HighScoreManager.swift`

### PlayerManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/PlayerManager.swift`

#### Public Types

- **public enum PowerUpType: CaseIterable {** (line 391)

### AchievementManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/AchievementManager.swift`

#### Public Types

- **public struct Achievement: Codable, Identifiable {** (line 17)

#### Public Properties

- `let id: String` (line 18)

### AppDelegate

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/AppDelegate.swift`

#### Public Types

- **public class AppDelegate: UIResponder, UIApplicationDelegate {** (line 11)

#### Public Functions

- `application(` (line 14)
- `applicationWillResignActive(_: UIApplication) {` (line 22)
- `applicationDidEnterBackground(_: UIApplication) {` (line 31)
- `applicationWillEnterForeground(_: UIApplication) {` (line 37)
- `applicationDidBecomeActive(_: UIApplication) {` (line 42)

#### Public Properties

- `var window: UIWindow?` (line 12)

### GameScene

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/GameScene.swift`

#### Public Types

- **public class GameScene: SKScene, SKPhysicsContactDelegate {** (line 14)

#### Public Functions

- `didBegin(_ contact: SKPhysicsContact) {` (line 245)

### GameDifficulty

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/GameDifficulty.swift`

### UIManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/UIManager.swift`

### Dependencies

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Dependencies.swift`

#### Public Types

- **public struct Dependencies {** (line 9)
- **public class Logger {** (line 26)
- **public enum LogLevel: String {** (line 49)

#### Public Functions

- `log(_ message: String, level: LogLevel = .info) {` (line 31)
- `error(_ message: String) {` (line 36)
- `warning(_ message: String) {` (line 40)
- `info(_ message: String) {` (line 44)

#### Public Properties

- `let performanceManager: PerformanceManager` (line 10)
- `let logger: Logger` (line 11)

### AppDelegateTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/AppDelegateTests.swift`

### DependenciesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/DependenciesTests.swift`

### AppDelegateTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/AppDelegateTestsTests.swift`

### GameSceneTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/GameSceneTests.swift`

### PerformanceManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/PerformanceManagerTests.swift`

#### Public Types

- **public class MockPerformanceDelegate: PerformanceDelegate {** (line 11)
- **public class PerformanceManagerTests: XCTestCase {** (line 31)

### GameViewControllerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/GameViewControllerTests.swift`

#### Public Types

- **public class GameViewControllerTests: XCTestCase {** (line 13)
- **public class MockSKView: SKView {** (line 219)
- **public class GameViewControllerDeviceTests: XCTestCase {** (line 270)
- **public class GameViewControllerIntegrationTests: XCTestCase {** (line 304)

### EffectsManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/EffectsManagerTests.swift`

#### Public Types

- **public class MockSKScene: SKScene {** (line 14)
- **public class MockSKEmitterNode: SKEmitterNode {** (line 38)
- **public class EffectsManagerTests: XCTestCase {** (line 54)

### AchievementManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/AchievementManagerTests.swift`

### AvoidObstaclesGameTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/AvoidObstaclesGameTestsTests.swift`

### ObstacleManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/ObstacleManagerTests.swift`

#### Public Types

- **public class ObstacleManagerTests: XCTestCase {** (line 12)
- **public class MockObstacleDelegate: ObstacleDelegate {** (line 368)
- **public enum PowerUpType: CaseIterable {** (line 396)

### GameSceneTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/GameSceneTestsTests.swift`

### GameModelTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/GameModelTestsTests.swift`

### PhysicsCategoryTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/PhysicsCategoryTests.swift`

### UIManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/UIManagerTests.swift`

### AudioManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/AudioManagerTests.swift`

### PlayerManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/PlayerManagerTests.swift`

### DataExportServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/DataExportServiceTestsTests.swift`

### HighScoreManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/HighScoreManagerTests.swift`

### AvoidObstaclesGameUITestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/AvoidObstaclesGameUITestsTests.swift`

### AvoidObstaclesGameUITestsLaunchTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/AvoidObstaclesGameUITestsLaunchTestsTests.swift`

### GameDifficultyTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/GameDifficultyTestsTests.swift`

### HighScoreManagerTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/HighScoreManagerTestsTests.swift`

### GameViewControllerTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/GameViewControllerTestsTests.swift`

### PhysicsManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/PhysicsManagerTests.swift`

#### Public Types

- **public class MockPhysicsManagerDelegate: PhysicsManagerDelegate {** (line 14)
- **public class PhysicsManagerTests: XCTestCase {** (line 40)
- **public class PhysicsManagerPerformanceTests: XCTestCase {** (line 379)

### GameStateManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/GameStateManagerTests.swift`

### GameDifficultyTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Tests/GameDifficultyTests.swift`

### AppDelegateTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/AppDelegateTests.swift`

#### Public Types

- **public class AppDelegateTests: XCTestCase {** (line 5)

### GameSceneTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameSceneTests.swift`

#### Public Types

- **public class GameSceneTests: XCTestCase {** (line 6)

### GameViewControllerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameViewControllerTests.swift`

#### Public Types

- **public class GameViewControllerTests: XCTestCase {** (line 5)

### GameModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameModelTests.swift`

### DataExportServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/DataExportServiceTests.swift`

### AvoidObstaclesGameTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/AvoidObstaclesGameTests.swift`

### HighScoreManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/HighScoreManagerTests.swift`

#### Public Types

- **public class HighScoreManagerTests: XCTestCase {** (line 5)

### GameDifficultyTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameDifficultyTests.swift`

#### Public Types

- **public class GameDifficultyTests: XCTestCase {** (line 5)

### AvoidObstaclesGameUITestsLaunchTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameUITests/AvoidObstaclesGameUITestsLaunchTests.swift`

### AvoidObstaclesGameUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameUITests/AvoidObstaclesGameUITests.swift`

### GeneratedAssetSymbols

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/build/AvoidObstaclesGame.build/Debug-iphoneos/AvoidObstaclesGame.build/DerivedSources/GeneratedAssetSymbols.swift`

## Dependencies
