# AvoidObstaclesGame API Reference

**Generated:** Sun Oct 12 09:52:57 CDT 2025
**Type:** Manual Documentation

## Public API Overview

### Public Classes

- `public class OllamaClient: ObservableObject `
- `public class GameScene: SKScene, SKPhysicsContactDelegate `
- `public class HuggingFaceClient `
- `public class PhysicsManager: NSObject, SKPhysicsContactDelegate `
- `public class GameViewController: UIViewController `
- `public class AudioManager: NSObject `
- `public class PerformanceManager `
- `public class AppDelegate: UIResponder, UIApplicationDelegate `
- `public class PlayerAnalyticsAI `
- `public class AdaptiveDifficultyAI `
- `public class AchievementDataManager: @unchecked Sendable `
- `public class OllamaIntegrationManager: AITextGenerationService, AICodeAnalysisService, AICodeGenerationService, AICachingService, AIPerformanceMonitoring, @unchecked Sendable `

### Public Structs

- `public struct OllamaConfig: Sendable `
- `public struct OllamaMessage: Codable, Sendable `
- `public struct OllamaGenerateResponse: Codable, Sendable `
- `public struct OllamaServerStatus: Codable, Sendable `
- `public struct DocumentationResult: Codable, Sendable `
- `public struct TestGenerationResult: Codable, Sendable `
- `public struct AutomationTask: Codable, Sendable `
- `public struct TaskResult: Sendable `
- `public struct Dependencies `
- `public struct SecurityIncident `
- `public struct Vulnerability `
- `public struct Achievement: Codable, Identifiable, Sendable `
- `public struct ServiceHealth: Codable, Sendable `
- `public struct CodeAnalysisResult: Codable, Sendable `
- `public struct CodeIssue: Codable, Sendable `
- `public struct CodeGenerationResult: Codable, Sendable `
- `public struct CacheStats: Codable, Sendable `
- `public struct PerformanceMetrics: Codable, Sendable `
- `public struct AIServiceInfo: Codable, Sendable `
- `public struct AIOperation: Codable, Sendable `
- `public struct AIOperationResult: Codable, Sendable `
- `public struct ServiceHealthOverview: Codable, Sendable `
- `public struct AIServiceConfiguration: Codable, Sendable `
- `public struct RateLimit: Codable, Sendable `
- `public struct AnyCodable: Codable, Sendable `
- `public struct ActionContext `
- `public struct TimestampedAction `
- `public struct PersonalizationRecommendations `
- `public struct BehavioralInsights `
- `public struct PersonalizationSettings: Codable `
- `public struct PlayerProfile: Codable `
- `public struct BehaviorPatterns: Codable `
- `public struct PowerUpPreference: Codable `
- `public struct CollisionPattern: Codable `
- `public struct GameSession `
- `public struct DifficultyAnalysis `
- `public struct GameSession `
- `public struct PlayerProfile `
- `public struct PlayerMetrics `
- `public struct GameMetrics `
- `public struct CollisionPattern `
- `public struct PowerUpUsage `
- `public struct DifficultyMilestone `
- `public struct MovementPatterns `
- `public struct BehaviorPatterns `
- `public struct Collision `

### Public Enums

- `public enum OllamaIntegration `
- `public enum HuggingFaceError: LocalizedError `
- `public enum TaskType `
- `public enum TaskType: String, Codable, Sendable `
- `public enum TaskPriority: String, Codable, Sendable `
- `public enum OllamaError: Error, LocalizedError `
- `public enum IntegrationError: Error, LocalizedError `
- `public enum PowerUpType: CaseIterable `
- `public enum SecurityFramework `
- `public enum Validation `
- `public enum DataSecurity `
- `public enum Crypto `
- `public enum Monitoring `
- `public enum VulnerabilityScanner `
- `public enum ValidationResult `
- `public enum ValidationError: Error, LocalizedError `
- `public enum SecurityError: Error, LocalizedError `
- `public enum SecurityEvent `
- `public enum LogLevel: String `
- `public enum IncidentSeverity: String `
- `public enum VulnerabilityType: String `
- `public enum AchievementType: String, Codable, Sendable `
- `public enum AchievementDefinitions `
- `public enum IssueSeverity: String, Codable, Sendable `
- `public enum AnalysisType: String, Codable, Sendable `
- `public enum CodeComplexity: String, Codable, Sendable `
- `public enum AIServiceType: String, Codable, Sendable `
- `public enum AICapability: String, Codable, Sendable `
- `public enum AIOperationType: String, Codable, Sendable `
- `public enum OperationPriority: String, Codable, Sendable `
- `public enum AIError: Error, LocalizedError `
- `public enum PlayerType: String, Codable `
- `public enum EngagementStyle: String, Codable `
- `public enum DifficultyPreference: String, Codable `
- `public enum PlayerAction `
- `public enum GameEvent `
- `public enum GameElementType `
- `public enum PlayerSkillLevel: String, Codable `
- `public enum DifficultyAdjustment: Equatable `

### Public Protocols

- `public protocol AchievementDelegate: AnyObject `
- `public protocol AITextGenerationService `
- `public protocol AICodeAnalysisService `
- `public protocol AICodeGenerationService `
- `public protocol AICachingService `
- `public protocol AIPerformanceMonitoring `
- `public protocol AIServiceCoordinator `
- `public protocol AIConfigurationService `


## Usage

For detailed usage examples, see the source files in:
`/Users/danielstevens/Desktop/Quantum-workspace/Projects/AvoidObstaclesGame/`

## Architecture Notes

This project follows the Quantum Workspace architecture patterns. See [ARCHITECTURE.md](../../ARCHITECTURE.md) for details.

---

*For full HTML documentation, run:*
```bash
jazzy --module AvoidObstaclesGame --output Documentation/API/AvoidObstaclesGame
```
