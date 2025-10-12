# HabitQuest API Reference

**Generated:** Sun Oct 12 09:52:58 CDT 2025
**Type:** Manual Documentation

## Public API Overview

### Public Classes

- `public class HabitViewModel: BaseViewModel `
- `public class OllamaClient: ObservableObject `
- `public class HuggingFaceClient `
- `public class OllamaIntegrationManager: AITextGenerationService, AICodeAnalysisService, AICodeGenerationService `
- `public class AIHealthMonitor `
- `public class QuestLogViewModel: ObservableObject `
- `public class DataManagementViewModel: ObservableObject `
- `public class ProfileViewModel: ObservableObject `
- `public class TodaysQuestsViewModel: ObservableObject `

### Public Structs

- `public struct Dependencies `
- `public struct State `
- `public struct State `
- `public struct AIHabitInsight: Identifiable `
- `public struct AIHabitPrediction: Identifiable `
- `public struct AIHabitSuggestion: Identifiable `
- `public struct AIHabit: Identifiable `
- `public struct AIHabitLog `
- `public struct OllamaConfig `
- `public struct OllamaMessage: Codable `
- `public struct OllamaGenerateResponse: Codable `
- `public struct OllamaServerStatus `
- `public struct DocumentationResult `
- `public struct TestGenerationResult `
- `public struct AutomationTask `
- `public struct TaskResult: Sendable `
- `public struct StreakMilestone: Identifiable, @unchecked Sendable `
- `public struct ErrorHandler: Sendable `
- `public struct SecurityIncident `
- `public struct Vulnerability `
- `public struct WeeklyPatternChartView: View `
- `public struct StreakDistributionChartView: View `
- `public struct AnalyticsCard: View `
- `public struct TopPerformerRow: View `
- `public struct HabitDetailSheet: View `
- `public struct AnalyticsExportView: View `
- `public struct ConsistencyInsightView: View `
- `public struct InsightCard: View `
- `public struct AIHabitInsightsView: View `
- `public struct JournalAnalysisView: View `
- `public struct HabitRecommendation `
- `public struct HabitSuggestion `
- `public struct StreakDayData: Identifiable `
- `public struct DataExportService: Sendable `
- `public struct HabitAnalytics `
- `public struct OverallStats `
- `public struct AnalyticsStreakData `
- `public struct CategoryStats `
- `public struct MoodCorrelation `
- `public struct MoodStats `
- `public struct TimePatterns `
- `public struct WeeklyProgress `
- `public struct MonthlyTrend `
- `public struct HabitPerformance `
- `public struct HabitTrendData `
- `public struct CategoryInsight `
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
- `public struct HealthStats `
- `public struct CurrentHealth `
- `public struct OllamaHealthStatus `
- `public struct AnalyticsHabit `
- `public struct AnalyticsHabitLog `
- `public struct ProductivityMetrics `
- `public struct ProductivityScore `
- `public struct ProductivityInsights `
- `public struct ProductivityTrends `
- `public struct ProductivityMilestone `
- `public struct SchedulingRecommendation `
- `public struct HabitPatterns `
- `public struct TimeFactors `
- `public struct StreakMomentum `
- `public struct BehavioralInsights `
- `public struct AnalyticsHabitSuggestion: Identifiable `
- `public struct UserProfile `
- `public struct CategoryPerformance `
- `public struct HabitPerformanceSummary `
- `public struct QuestLogView: View `
- `public struct StreakVisualizationView: View `
- `public struct StreakCelebrationView: View `
- `public struct HeatMapDay: View `
- `public struct StreakHeatMapView: View `
- `public struct MetricCard: View `
- `public struct PredictionCard: View `
- `public struct DataManagementView: View `
- `public struct AlertModifier: ViewModifier `
- `public struct FileHandlerModifier: ViewModifier `
- `public struct HabitQuestBackupDocument: FileDocument `
- `public struct CharacterAvatarSection: View `
- `public struct ProgressSection: View `
- `public struct ProfileView: View `
- `public struct AnalyticsTabView: View `
- `public struct TrendsView: View `
- `public struct PatternsView: View `
- `public struct InsightsView: View `
- `public struct AdvancedAnalyticsView: View `
- `public struct AnalyticsInsightsCard: View `
- `public struct InsightRow: View `
- `public struct PredictiveAnalyticsCard: View `
- `public struct PredictionRow: View `
- `public struct BehavioralPatternsCard: View `
- `public struct PatternRow: View `
- `public struct StatsSection: View `
- `public struct StatCard: View `
- `public struct AchievementsSection: View `
- `public struct AchievementBadge: View `
- `public struct AnalyticsTestView: View `
- `public struct TestResultsView: View `
- `public struct TestResultRow: View `
- `public struct StatItem: View `
- `public struct TodaysQuestsView: View `
- `public struct StreakAnalyticsView: View `
- `public struct StreakAnalyticsTopPerformersView: View `
- `public struct StreakAnalyticsOverviewView: View `
- `public struct StreakAnalyticsInsightsView: View `
- `public struct StreakAnalyticsWeeklyView: View `
- `public struct StreakAnalyticsDistributionView: View `
- `public struct AppMainView: View `
- `public struct ContentView: View `
- `public struct HeaderView: View `
- `public struct ItemListView: View `
- `public struct ItemRowView: View `
- `public struct ItemDetailView: View `
- `public struct DetailRow: View `
- `public struct FooterStatsView: View `
- `public struct DetailView: View `
- `public struct HabitQuestApp: App `

### Public Enums

- `public enum LogLevel: String `
- `public enum Action `
- `public enum Action `
- `public enum AIProcessingStatus `
- `public enum AIMotivationLevel `
- `public enum AIInsightCategory `
- `public enum AIPriority `
- `public enum AISuggestionCategory `
- `public enum AIHabitFrequency `
- `public enum AIHabitCategory `
- `public enum AIHabitDifficulty `
- `public enum MoodRating: String, CaseIterable, Codable `
- `public enum OllamaError: LocalizedError `
- `public enum TaskType `
- `public enum IntegrationError: Error `
- `public enum AchievementCategory: String, CaseIterable, Codable `
- `public enum AchievementRequirement: @preconcurrency Codable, @unchecked Sendable `
- `public enum HabitFrequency: String, CaseIterable, Codable `
- `public enum HabitCategory: String, CaseIterable, Codable `
- `public enum HabitDifficulty: String, CaseIterable, Codable `
- `public enum AppError: LocalizedError `
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
- `public enum LogLevel `
- `public enum IncidentSeverity: String `
- `public enum VulnerabilityType: String `
- `public enum RecommendationCategory `
- `public enum HuggingFaceError: LocalizedError `
- `public enum TaskType `
- `public enum DataExportError: LocalizedError, @unchecked Sendable `
- `public enum HabitTrend: String, Codable `
- `public enum IssueSeverity: String, Codable, Sendable `
- `public enum AnalysisType: String, Codable, Sendable `
- `public enum CodeComplexity: String, Codable, Sendable `
- `public enum AIServiceType: String, Codable, Sendable `
- `public enum AICapability: String, Codable, Sendable `
- `public enum AIOperationType: String, Codable, Sendable `
- `public enum OperationPriority: String, Codable, Sendable `
- `public enum AIError: Error, LocalizedError `
- `public enum AnalyticsHabitCategory: String, CaseIterable, Codable `
- `public enum AnalyticsHabitDifficulty: String, CaseIterable, Codable `
- `public enum TimePeriod `
- `public enum ProductivityTrend `
- `public enum ProductivityArea `
- `public enum MilestoneType `
- `public enum CategoryTrend `

### Public Protocols

- `public protocol BaseViewModel: ObservableObject `
- `public protocol AITextGenerationService `
- `public protocol AICodeAnalysisService `
- `public protocol AICodeGenerationService `
- `public protocol AICachingService `
- `public protocol AIPerformanceMonitoring `
- `public protocol AIServiceCoordinator `
- `public protocol AIConfigurationService `


## Usage

For detailed usage examples, see the source files in:
`/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/`

## Architecture Notes

This project follows the Quantum Workspace architecture patterns. See [ARCHITECTURE.md](../../ARCHITECTURE.md) for details.

---

*For full HTML documentation, run:*
```bash
jazzy --module HabitQuest --output Documentation/API/HabitQuest
```
