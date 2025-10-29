# AvoidObstaclesGame API Documentation
**Generated:** Tue Oct 28 14:24:07 CDT 2025
**Framework:** AI-Powered Documentation

## Overview

This document provides comprehensive API documentation for the AvoidObstaclesGame application.
Documentation is automatically generated from code analysis and AI-enhanced descriptions.

## Table of Contents

- [Public API Reference](#public-api-reference)
- [Class Hierarchy](#class-hierarchy)
- [Protocols](#protocols)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)

## Public API Reference

### Manual API Documentation Required

AI generation failed. Please document the following manually:

#### Functions
```swift
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/OllamaClient.swift\n124:    public func generate(
186:    public func generateWithProgress(
206:    public func quantumChat(
278:    public func generateAdvanced(
311:    public func chat(
336:    public func listModels() async throws -> [String] {
342:    public func pullModel(_ modelName: String) async throws {
351:    public func checkModelAvailability(_ model: String) async -> Bool {
362:    public func isServerRunning() async -> Bool {
371:    public func getServerStatus() async -> OllamaServerStatus {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Core/GameScene.swift\n530:    public func enableMultiplayerMode() {
535:    public func disableMultiplayerMode() {
550:    public func showGameModeSelection() {
555:    public func showReplaySelection() {
560:    public func startLevelEditor() {
565:    public func stopLevelEditor() {
570:    public func createNewLevel(name: String) {
979:    public func achievementUnlocked(_ achievement: Achievement) async {
995:    public func achievementProgressUpdated(_ achievement: Achievement, progress: Float) async {
1361:    public func gestureRecognized(_ gesture: GestureType, at location: CGPoint) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/HuggingFaceClient.swift\n102:    public func generate(
207:    public func analyzeCode(
242:    public func generateDocumentation(
277:    public func generateWithFallback(
366:    public func getPerformanceMetrics() -> PerformanceMetrics {
377:    public func isAvailable() async -> Bool {
389:    public func getHealthStatus() async -> ServiceHealth {
410:    public func generateText(prompt: String, maxTokens: Int, temperature: Double) async throws -> String {
421:    public func analyzeCode(code: String, language: String, analysisType: AnalysisType) async throws -> CodeAnalysisResult {
467:    public func generateCode(description: String, language: String, context: String?) async throws -> CodeGenerationResult {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/GameViewController.swift\n194:        public func setMultiplayerMode(_ enabled: Bool) {
204:        public func isMultiplayerModeEnabled() -> Bool {
247:        public func setMultiplayerMode(_ enabled: Bool) {
257:        public func isMultiplayerModeEnabled() -> Bool {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/HapticManager.swift\n49:    public func setHapticEnabled(_ enabled: Bool) {
55:    public func setHapticIntensity(_ intensity: Float) {
61:    public func getHapticEnabled() -> Bool {
67:    public func getHapticIntensity() -> Float {
74:    public func playCollisionHaptic() {
83:    public func playPowerUpHaptic() {
92:    public func playScoreIncreaseHaptic() {
101:    public func playLevelUpHaptic() {
110:    public func playGameOverHaptic() {
119:    public func playAchievementHaptic() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/AudioManager.swift\n367:    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/ThemeManager.swift\n335:    public func setThemeMode(_ mode: ThemeMode) {
341:    public func isSystemInDarkMode() -> Bool {
359:    public func getAvailableThemes() -> [Theme] {
402:    public func applyThemeWithTransition(_ theme: Theme, duration: TimeInterval = 0.5) {
433:    public func createCustomTheme(name: String, baseTheme: Theme, customColors: [String: SKColor]) -> Theme {
487:    public func getNextTheme() -> Theme {
498:    public func cycleToNextTheme() {
506:    public func getThemePreviewColors(for theme: Theme) -> [SKColor] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/ControlManager.swift\n228:    public func setControlScheme(_ scheme: ControlScheme) {
244:    public func updateSensitivity(_ sensitivity: ControlSensitivity) {
252:    public func updateMapping(_ mapping: ControlMapping) {
259:    public func setControlsEnabled(_ enabled: Bool) {
266:    public func setShowHints(_ showHints: Bool) {
272:    public func getCurrentScheme() -> ControlScheme {
278:    public func getCurrentSensitivity() -> ControlSensitivity {
284:    public func getCurrentMapping() -> ControlMapping {
290:    public func getAvailableSchemes() -> [ControlScheme] {
295:    public func resetToDefaults() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/GestureManager.swift\n123:        public func setupForView(_ view: UIView) {
129:        public func setupForView(_ view: Any) {
146:    public func removeFromView() {
425:        public func processTouches(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) {
468:        public func processTouches(_ touches: Any, with event: Any?, in view: Any) {
620:    public func setEnabled(_ enabled: Bool) {
634:    public func configureSensitivity(swipeDistance: CGFloat? = nil,\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/AppDelegate.swift\n15:        public func application(
23:        public func applicationWillResignActive(_: UIApplication) {
32:        public func applicationDidEnterBackground(_: UIApplication) {
38:        public func applicationWillEnterForeground(_: UIApplication) {
43:        public func applicationDidBecomeActive(_: UIApplication) {
59:        public func applicationDidFinishLaunching(_ aNotification: Notification) {
81:        public func applicationWillTerminate(_ aNotification: Notification) {
85:        public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/AIServiceProtocols.swift\n531:    public func encode(to encoder: Encoder) throws {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Services/PlayerAnalyticsAI.swift\n149:    public func recordPlayerAction(_ action: PlayerAction, context: ActionContext? = nil) {
163:    public func recordGameEvent(_ event: GameEvent) {
172:    public func getPersonalizedRecommendations() async -> PersonalizationRecommendations {
187:    public func getCurrentPlayerProfile() -> PlayerProfile {
194:    public func predictPlayerPreference(for elementType: GameElementType) async -> Double {
201:    public func getBehavioralInsights() async -> BehavioralInsights {
207:    public func resetAnalytics() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Services/AdaptiveDifficultyAI.swift\n67:    public func recordGameSession(
83:    public func getDifficultyRecommendation() async -> DifficultyAdjustment {
98:    public func getPlayerSkillAssessment() -> PlayerSkillLevel {
103:    public func resetAnalysis() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Services/AIHealthMonitor.swift\n20:    public func recordHealth(for service: String, status: ServiceHealth) {
27:    public func getHealth(for service: String) -> ServiceHealth {
36:    public func getOverallHealth() -> ServiceHealth {
62:    public func resetHealth(for service: String) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Services/AchievementDataManager.swift\n31:    public func loadProgress(for achievements: [String: Achievement]) -> ([String: Achievement], Int) {
65:    public func saveProgress(for achievements: [String: Achievement]) {
97:    public func updateAchievement(_ id: String, in achievements: [String: Achievement], increment: Int = 1) -> [String: Achievement] {
118:    public func unlockAchievement(_ id: String, in achievements: [String: Achievement]) -> [String: Achievement] {
140:    public func resetAllAchievements(_ achievements: [String: Achievement]) -> [String: Achievement] {
161:    public func clearAllData() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/OllamaIntegrationManager.swift\n11:    public func generateText(prompt: String, maxTokens: Int, temperature: Double) async throws -> String {\n\n
```

#### Classes
```swift
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Platforms/macOS/ViewController-macOS.swift\n12:class ViewController: NSViewController {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Platforms/macOS/AppDelegate-macOS.swift\n13:class AppDelegate: NSObject, NSApplicationDelegate {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Platforms/tvOS/GameViewController-tvOS.swift\n12:class GameViewController: UIViewController {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/Platforms/tvOS/AppDelegate-tvOS.swift\n12:class AppDelegate: UIResponder, UIApplicationDelegate {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Core/GameStateManager.swift\n32:class GameStateManager {
542:class WinConditionChecker {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/GameObjectPool.swift\n38:class GameObjectPool<T: Poolable & Hashable> {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/LevelEditorManager.swift\n690:class LevelEditorOverlay: SKNode {
721:class LevelEditorToolbar: SKNode {
748:class LevelEditorButton: SKNode {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/StatisticsDisplayManager.swift\n12:class StatisticsDisplayManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/BossManager.swift\n13:class BossManager: GameComponent {
308:class BossAttackNode: GameComponent {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/InAppPurchaseManager.swift\n266:class PurchaseButton: SKNode {
318:class PurchaseUI {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/ObstacleManager.swift\n523:class DynamicObstacleGenerator {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/EffectsManager.swift\n41:class EffectsManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/GameModeManager.swift\n24:class GameModeManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/ObstaclePool.swift\n21:class ObstaclePool {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/AIAdaptiveDifficultyManager.swift\n20:class AIAdaptiveDifficultyManager: @unchecked Sendable {
380:class PlayerBehaviorAnalyzer {
575:class DifficultyAdjustmentEngine {
716:class AIDifficultyPerformanceMonitor {
748:class PlayerBehaviorPredictor {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/ModernUIManager.swift\n48:class ModernUICard: SKNode {
126:class ModernUIProgressBar: SKNode {
193:class ModernUIButton: SKNode {
257:class ModernUIManager: ThemeDelegate {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/PerformanceOverlayManager.swift\n12:class PerformanceOverlayManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/PlayerManager.swift\n24:class PlayerManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/SkillTreeManager.swift\n51:class SkillTreeManager: GameComponent {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/AdvancedAIManager.swift\n349:class PredictiveGameStateAnalyzer {
537:class DynamicContentGenerator {
660:class EmotionRecognitionSystem {
754:class ReinforcementLearningAgent {
868:class MultimodalAICoordinator {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/MultiplayerManager.swift\n75:class MultiplayerManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/GameOverScreenManager.swift\n17:class GameOverScreenManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/PowerUpManager.swift\n334:class AdaptiveSpawningConfig {
520:class PowerUp {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/UIDisplayManager.swift\n19:class UIDisplayManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/ReplayManager.swift\n63:class ReplayManager: GameComponent {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/HUDManager.swift\n13:class HUDManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/TutorialManager.swift\n123:class TutorialManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/UIManager.swift\n32:class UIManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/SettingsManager.swift\n94:class SettingsManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/AccessibilityManager.swift\n16:class AccessibilityManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/UIEffectsManager.swift\n13:class UIEffectsManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/GameHUDManager.swift\n25:class GameHUDManager: ThemeDelegate {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Models/GameEntities.swift\n59:class Player: GameComponent, Renderable, Collidable {
182:class Obstacle: GameComponent, Renderable, Collidable, Hashable {
436:class Boss: GameComponent, Renderable, Collidable, Hashable {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Services/HighScoreManager.swift\n12:class HighScoreManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Services/ProgressionManager.swift\n20:class ProgressionManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Services/AchievementManager.swift\n12:class AchievementManager: Sendable {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/SocialManagerTests.swift\n4:class SocialManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/TutorialManagerTests.swift\n4:class TutorialManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/SkillTreeManagerTests.swift\n4:class SkillTreeManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/InAppPurchaseManagerTests.swift\n4:class InAppPurchaseManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/StatisticsDisplayManagerTests.swift\n4:class StatisticsDisplayManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameCoordinatorTests.swift\n4:class GameCoordinatorTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/ObstaclePoolTests.swift\n4:class ObstaclePoolTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/ProgressionManagerTests.swift\n4:class ProgressionManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameEntitiesTests.swift\n4:class GameEntitiesTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/PerformanceManagerTests.swift\n4:class PerformanceManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/MultiplayerManagerTests.swift\n4:class MultiplayerManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/UIDisplayManagerTests.swift\n4:class UIDisplayManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/EffectsManagerTests.swift\n4:class EffectsManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/AIAdaptiveDifficultyManagerTests.swift\n307:class MockAIAdaptiveDifficultyDelegate: AIAdaptiveDifficultyDelegate {
328:class MockOllamaIntegrationManager: OllamaIntegrationManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/ReplayManagerTests.swift\n4:class ReplayManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/AchievementManagerTests.swift\n4:class AchievementManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/PerformanceOverlayManagerTests.swift\n4:class PerformanceOverlayManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameModeManagerTests.swift\n4:class GameModeManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameHUDManagerTests.swift\n4:class GameHUDManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/ObstacleManagerTests.swift\n4:class ObstacleManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/AnalyticsManagerTests.swift\n4:class AnalyticsManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/AIBehaviorModelsTests.swift\n4:class AIBehaviorModelsTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/SettingsManagerTests.swift\n4:class SettingsManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameModeTests.swift\n4:class GameModeTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameOverScreenManagerTests.swift\n4:class GameOverScreenManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/UIManagerTests.swift\n4:class UIManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/AudioManagerTests.swift\n4:class AudioManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/PlayerManagerTests.swift\n4:class PlayerManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/PlatformDetectorTests.swift\n4:class PlatformDetectorTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/BossManagerTests.swift\n4:class BossManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/AnalyticsDashboardManagerTests.swift\n4:class AnalyticsDashboardManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/AccessibilityManagerTests.swift\n4:class AccessibilityManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameObjectPoolTests.swift\n4:class GameObjectPoolTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/PowerUpManagerTests.swift\n4:class PowerUpManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/TestingManagerTests.swift\n4:class TestingManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/UIEffectsManagerTests.swift\n4:class UIEffectsManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/ModernUIManagerTests.swift\n4:class ModernUIManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/HUDManagerTests.swift\n4:class HUDManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/AdvancedAIManagerTests.swift\n4:class AdvancedAIManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/PhysicsManagerTests.swift\n4:class PhysicsManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameStateManagerTests.swift\n4:class GameStateManagerTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/GameCoordinatorAITests.swift\n228:class MockSKScene: SKScene {
238:class MockGameCoordinatorDelegate: GameCoordinatorDelegate {
265:class MockObstacle: Obstacle {
271:class MockPowerUp: PowerUp {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGameTests/LevelEditorManagerTests.swift\n4:class LevelEditorManagerTests: XCTestCase {\n\n
```

#### Protocols
```swift
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Coordinator/GameCoordinator.swift\n14:protocol Coordinatable: AnyObject {
36:protocol GameCoordinatorDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Core/GameStateManager.swift\n13:protocol GameStateDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Core/GameScene.swift\n1002:protocol BossManagerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/GameObjectPool.swift\n14:protocol Poolable: AnyObject {
32:protocol GameObjectPoolDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/LevelEditorManager.swift\n239:protocol LevelEditorDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/PhysicsManager.swift\n14:protocol PhysicsManagerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/ObstacleManager.swift\n17:protocol ObstacleDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/GameModeManager.swift\n15:protocol GameModeManagerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/ObstaclePool.swift\n15:protocol ObstaclePoolDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/AIAdaptiveDifficultyManager.swift\n14:protocol AIAdaptiveDifficultyDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/ModernUIManager.swift\n14:protocol ModernUIManagerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/PlayerManager.swift\n17:protocol PlayerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/MultiplayerManager.swift\n14:protocol MultiplayerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/GameOverScreenManager.swift\n12:protocol GameOverScreenDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/PowerUpManager.swift\n15:protocol PowerUpDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/ReplayManager.swift\n520:protocol ReplayManagerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/TutorialManager.swift\n17:protocol TutorialManagerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/UIManager.swift\n15:protocol UIManagerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/SettingsManager.swift\n87:protocol SettingsManagerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/AccessibilityManager.swift\n230:protocol AccessibilityManagerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Managers/GameHUDManager.swift\n17:protocol GameHUDManagerDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Utils/PerformanceManager.swift\n16:protocol PerformanceDelegate: AnyObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Models/GameEntities.swift\n36:protocol GameComponent: AnyObject {
43:protocol Renderable {
50:protocol Collidable {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/AvoidObstaclesGame/Services/ProgressionManager.swift\n12:protocol ProgressionDelegate: AnyObject {\n\n
```

---
*Generated by AI Documentation Agent*
