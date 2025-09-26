# HabitQuest API Documentation

Generated: Wed Sep 24 09:04:05 CDT 2025
Project: HabitQuest
Location: /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest

## Overview

This document contains the public API reference for HabitQuest.

## Classes and Structs

### PerformanceManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/PerformanceManager.swift`

#### Public Types

- **public class PerformanceManager {** (line 10)

#### Public Functions

- `recordFrame() {` (line 19)
- `getCurrentFPS() -> Double {` (line 29)
- `getMemoryUsage() -> Double {` (line 44)
- `isPerformanceDegraded() -> Bool {` (line 62)

### HabitQuestUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestUITests/HabitQuestUITests.swift`

### Dependencies

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Dependencies.swift`

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

### ContentViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ContentViewTestsTests.swift`

### ContentGenerationServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ContentGenerationServiceTests.swift`

### DependenciesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/DependenciesTests.swift`

### AnalyticsAggregatorServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AnalyticsAggregatorServiceTests.swift`

### StreakAnalyticsOverviewViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakAnalyticsOverviewViewTests.swift`

### TrendAnalysisServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/TrendAnalysisServiceTests.swift`

### StreakAnalyticsViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakAnalyticsViewTestsTests.swift`

### ProfileViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ProfileViewTests.swift`

### SmartNotificationServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/SmartNotificationServiceTestsTests.swift`

### WeeklyPatternChartViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/WeeklyPatternChartViewTests.swift`

### StreakHeatMapViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakHeatMapViewTestsTests.swift`

### StreakAnalyticsViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakAnalyticsViewModelTests.swift`

### PerformanceManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/PerformanceManagerTests.swift`

### StreakAnalyticsDistributionViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakAnalyticsDistributionViewTests.swift`

### LoggerTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/LoggerTestsTests.swift`

### TodaysQuestsViewModelTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/TodaysQuestsViewModelTestsTests.swift`

### NotificationServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/NotificationServiceTestsTests.swift`

### BehavioralInsightsServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/BehavioralInsightsServiceTests.swift`

### AchievementTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AchievementTestsTests.swift`

### TodaysQuestsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/TodaysQuestsViewTests.swift`

### ConsistencyInsightViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ConsistencyInsightViewTests.swift`

### QuestLogViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/QuestLogViewTests.swift`

### StreakDistributionChartViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakDistributionChartViewTests.swift`

### SharedAnalyticsComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/SharedAnalyticsComponentsTests.swift`

### StreakVisualizationViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakVisualizationViewTestsTests.swift`

### ContentViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ContentViewTests.swift`

### DataManagementViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/DataManagementViewTests.swift`

### PatternAnalysisServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/PatternAnalysisServiceTests.swift`

### DataManagementViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/DataManagementViewTestsTests.swift`

### HabitLogTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/HabitLogTests.swift`

### HabitViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/HabitViewModelTests.swift`

#### Public Types

- **public enum MockHabitCategory: String, CaseIterable, Codable {** (line 7)
- **public enum MockHabitFrequency: String, CaseIterable, Codable {** (line 11)
- **public enum MockHabitDifficulty: String, CaseIterable, Codable {** (line 15)

### HabitQuestUITestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/HabitQuestUITestsTests.swift`

### AnalyticsTestViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AnalyticsTestViewTestsTests.swift`

### HabitQuestAppTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/HabitQuestAppTestsTests.swift`

### HabitSuggestionServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/HabitSuggestionServiceTests.swift`

### PredictionServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/PredictionServiceTests.swift`

### TopPerformerRowViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/TopPerformerRowViewTests.swift`

### SharedAnalyticsComponentsTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/SharedAnalyticsComponentsTestsTests.swift`

### SharedArchitectureTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/SharedArchitectureTestsTests.swift`

### StreakAnalyticsInsightsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakAnalyticsInsightsViewTests.swift`

### GameRulesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/GameRulesTests.swift`

### PlayerProfileTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/PlayerProfileTests.swift`

### DataManagementViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/DataManagementViewModelTests.swift`

### LoggerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/LoggerTests.swift`

### DataExportServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/DataExportServiceTests.swift`

### ProductivityMetricsServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ProductivityMetricsServiceTests.swift`

### ItemTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ItemTests.swift`

### TodaysQuestsViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/TodaysQuestsViewModelTests.swift`

### HabitTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/HabitTests.swift`

### QuestLogViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/QuestLogViewModelTests.swift`

### AnalyticsTestViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AnalyticsTestViewTests.swift`

### DataExportServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/DataExportServiceTestsTests.swift`

### ErrorHandlerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ErrorHandlerTests.swift`

### AnalyticsCardViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AnalyticsCardViewTests.swift`

### StreakMilestoneTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakMilestoneTestsTests.swift`

### AppMainViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AppMainViewTests.swift`

### TodaysQuestsViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/TodaysQuestsViewTestsTests.swift`

### NotificationSchedulerServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/NotificationSchedulerServiceTests.swift`

### AnalyticsTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AnalyticsTypesTests.swift`

### SmartNotificationServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/SmartNotificationServiceTests.swift`

### StreakAnalyticsWeeklyViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakAnalyticsWeeklyViewTests.swift`

### AnalyticsTypesTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AnalyticsTypesTestsTests.swift`

### StreakServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakServiceTests.swift`

### QuestLogViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/QuestLogViewTestsTests.swift`

### StreakAnalyticsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakAnalyticsViewTests.swift`

### ProfileViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ProfileViewTestsTests.swift`

### AppMainViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AppMainViewTestsTests.swift`

### StreakAnalyticsTopPerformersViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakAnalyticsTopPerformersViewTests.swift`

### StreakAnalyticsDataTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakAnalyticsDataTests.swift`

### AchievementTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AchievementTests.swift`

### SharedArchitectureTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/SharedArchitectureTests.swift`

### DataManagementViewModelTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/DataManagementViewModelTestsTests.swift`

### HabitQuestAppTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/HabitQuestAppTests.swift`

### AchievementServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AchievementServiceTests.swift`

### StreakHeatMapViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakHeatMapViewTests.swift`

### GameRulesTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/GameRulesTestsTests.swift`

### ContextAwarenessServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ContextAwarenessServiceTests.swift`

### ProfileViewModelTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ProfileViewModelTestsTests.swift`

### HabitQuestTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/HabitQuestTestsTests.swift`

### StreakServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakServiceTestsTests.swift`

### CategoryInsightsServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/CategoryInsightsServiceTests.swift`

### QuestLogViewModelTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/QuestLogViewModelTestsTests.swift`

### ProfileViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ProfileViewModelTests.swift`

### AchievementServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AchievementServiceTestsTests.swift`

### SupportingViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/SupportingViewsTests.swift`

### NotificationServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/NotificationServiceTests.swift`

### AnalyticsServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AnalyticsServiceTests.swift`

### AnalyticsServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AnalyticsServiceTestsTests.swift`

### StreakVisualizationViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakVisualizationViewTests.swift`

### ErrorHandlerTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/ErrorHandlerTestsTests.swift`

### HabitQuestBridgingTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/HabitQuestBridgingTests.swift`

### StreakMilestoneTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/StreakMilestoneTests.swift`

### AdvancedAnalyticsEngineTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/AdvancedAnalyticsEngineTests.swift`

### BehavioralAdaptationServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Tests/BehavioralAdaptationServiceTests.swift`

### HabitViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/ViewModels/HabitViewModel.swift`

#### Public Types

- **public class HabitViewModel: BaseViewModel {** (line 14)

#### Public Functions

- `handle(_ action: Action) {` (line 70)

#### Public Properties

- `var state = State()` (line 44)
- `var isLoading = false` (line 45)
- `var errorMessage: String?` (line 46)

### PlayerProfile

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Models/PlayerProfile.swift`

### HabitLog

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Models/HabitLog.swift`

#### Public Types

- **public enum MoodRating: String, CaseIterable, Codable {** (line 55)

#### Public Properties

- `var id: UUID` (line 9)
- `var completionDate: Date` (line 11)
- `var isCompleted: Bool` (line 13)
- `var notes: String?` (line 15)
- `var xpEarned: Int` (line 17)
- `var mood: MoodRating?` (line 19)
- `var completionTime: Date?` (line 21)

### StreakMilestone

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Models/StreakMilestone.swift`

#### Public Types

- **public struct StreakMilestone: Identifiable, @unchecked Sendable {** (line 4)

#### Public Properties

- `let id: UUID` (line 5)

### Achievement

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Models/Achievement.swift`

#### Public Types

- **public enum AchievementCategory: String, CaseIterable, Codable {** (line 102)
- **public enum AchievementRequirement: @preconcurrency Codable, @unchecked Sendable {** (line 131)

### Habit

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Models/Habit.swift`

#### Public Types

- **public enum HabitFrequency: String, CaseIterable, Codable {** (line 98)
- **public enum HabitCategory: String, CaseIterable, Codable {** (line 110)
- **public enum HabitDifficulty: String, CaseIterable, Codable {** (line 150)

#### Public Properties

- `var id: UUID` (line 8)
- `var name: String` (line 11)
- `var habitDescription: String` (line 14)
- `var frequency: HabitFrequency` (line 17)
- `var creationDate: Date` (line 20)
- `var xpValue: Int` (line 23)
- `var streak: Int` (line 26)
- `var isActive: Bool` (line 29)
- `var category: HabitCategory` (line 32)
- `var difficulty: HabitDifficulty` (line 35)
- `var logs: [HabitLog] = []` (line 39)

### SharedArchitecture

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Utilities/SharedArchitecture.swift`

#### Public Types

- **public enum AppError: LocalizedError {** (line 37)

#### Public Properties

- `var errorDescription: String? {` (line 43)

### Logger

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Utilities/Logger.swift`

### ErrorHandler

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Utilities/ErrorHandler.swift`

#### Public Types

- **public struct ErrorHandler: Sendable {** (line 8)

### SharedAnalyticsComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Views/SharedAnalyticsComponents.swift`

### WeeklyPatternChartView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Views/Components/WeeklyPatternChartView.swift`

#### Public Types

- **public struct WeeklyPatternChartView: View {** (line 6)

#### Public Properties

- `var body: some View {` (line 10)

### StreakDistributionChartView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Views/Components/StreakDistributionChartView.swift`

#### Public Types

- **public struct StreakDistributionChartView: View {** (line 6)

#### Public Properties

- `var body: some View {` (line 10)

### AnalyticsCardView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Views/Components/AnalyticsCardView.swift`

#### Public Types

- **public struct AnalyticsCard: View {** (line 6)

#### Public Properties

- `var body: some View {` (line 49)

### TopPerformerRowView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Views/Components/TopPerformerRowView.swift`

#### Public Types

- **public struct TopPerformerRow: View {** (line 6)

#### Public Properties

- `var body: some View {` (line 11)

### SupportingViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Views/Components/SupportingViews.swift`

#### Public Types

- **public struct HabitDetailSheet: View {** (line 5)
- **public struct AnalyticsExportView: View {** (line 28)

#### Public Properties

- `var body: some View {` (line 9)
- `var body: some View {` (line 31)

### ConsistencyInsightView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Views/Components/ConsistencyInsightView.swift`

#### Public Types

- **public struct ConsistencyInsightView: View {** (line 6)
- **public struct InsightCard: View {** (line 26)

#### Public Properties

- `var body: some View {` (line 10)
- `var body: some View {` (line 31)

### SmartNotificationService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/SmartNotificationService.swift`

### AnalyticsTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/AnalyticsTypes.swift`

### AdvancedAnalyticsEngine

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/AdvancedAnalyticsEngine.swift`

### StreakService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/StreakService.swift`

#### Public Types

- **public struct StreakDayData: Identifiable {** (line 231)

#### Public Properties

- `let id = UUID()` (line 232)

### GameRules

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/GameRules.swift`

### NotificationService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/NotificationService.swift`

### DataExportService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/DataExportService.swift`

#### Public Types

- **public struct DataExportService: Sendable {** (line 8)
- **public enum DataExportError: LocalizedError, @unchecked Sendable {** (line 282)

### AnalyticsService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/AnalyticsService.swift`

#### Public Types

- **public enum HabitTrend: String {** (line 240)

### AchievementService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/AchievementService.swift`

### BehavioralAdaptationService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Notifications/BehavioralAdaptationService.swift`

### ContentGenerationService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Notifications/ContentGenerationService.swift`

### ContextAwarenessService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Notifications/ContextAwarenessService.swift`

### NotificationSchedulerService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Notifications/NotificationSchedulerService.swift`

### TrendAnalysisService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Analytics/TrendAnalysisService.swift`

### HabitSuggestionService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Analytics/HabitSuggestionService.swift`

### CategoryInsightsService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Analytics/CategoryInsightsService.swift`

### AnalyticsAggregatorService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Analytics/AnalyticsAggregatorService.swift`

### BehavioralInsightsService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Analytics/BehavioralInsightsService.swift`

### PredictionService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Analytics/PredictionService.swift`

### ProductivityMetricsService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Analytics/ProductivityMetricsService.swift`

### PatternAnalysisService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/Analytics/PatternAnalysisService.swift`

### Item

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Item.swift`

### QuestLogView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/QuestLog/QuestLogView.swift`

#### Public Types

- **public struct QuestLogView: View {** (line 6)

#### Public Properties

- `var body: some View {` (line 10)
- `var body: some View {` (line 62)
- `var body: some View {` (line 87)
- `var body: some View {` (line 109)
- `var body: some View {` (line 166)
- `var body: some View {` (line 206)

### QuestLogViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/QuestLog/QuestLogViewModel.swift`

#### Public Types

- **public class QuestLogViewModel: ObservableObject {** (line 7)

### StreakVisualizationView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakVisualization/StreakVisualizationView.swift`

#### Public Types

- **public struct StreakVisualizationView: View {** (line 5)
- **public struct StreakCelebrationView: View {** (line 266)
- **public struct HeatMapDay: View {** (line 358)

#### Public Properties

- `var body: some View {` (line 20)
- `var body: some View {` (line 274)
- `var body: some View {` (line 365)

### StreakHeatMapView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakVisualization/StreakHeatMapView.swift`

#### Public Types

- **public struct StreakHeatMapView: View {** (line 5)
- **public struct MetricCard: View {** (line 296)
- **public struct PredictionCard: View {** (line 319)

#### Public Properties

- `var body: some View {` (line 38)
- `var body: some View {` (line 301)
- `var body: some View {` (line 322)

### DataManagementView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/DataManagement/DataManagementView.swift`

#### Public Types

- **public struct DataManagementView: View {** (line 7)
- **public struct AlertModifier: ViewModifier {** (line 70)
- **public struct FileHandlerModifier: ViewModifier {** (line 76)
- **public struct HabitQuestBackupDocument: FileDocument {** (line 98)

#### Public Functions

- `body(content: Content) -> some View {` (line 71)
- `body(content: Content) -> some View {` (line 77)

#### Public Properties

- `var body: some View {` (line 10)

### DataManagementViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/DataManagement/DataManagementViewModel.swift`

#### Public Types

- **public class DataManagementViewModel: ObservableObject {** (line 7)

### ProfileView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/CharacterProfile/ProfileView.swift`

#### Public Types

- **public struct ProfileView: View {** (line 3)
- **public struct CharacterAvatarSection: View {** (line 68)
- **public struct ProgressSection: View {** (line 123)
- **public struct StatsSection: View {** (line 165)
- **public struct StatCard: View {** (line 196)
- **public struct AchievementsSection: View {** (line 223)
- **public struct AchievementBadge: View {** (line 262)
- **public struct AnalyticsTabView: View {** (line 283)
- **public struct TrendsView: View {** (line 319)
- **public struct PatternsView: View {** (line 364)
- **public struct InsightsView: View {** (line 409)
- **public struct AdvancedAnalyticsView: View {** (line 445)
- **public struct AnalyticsInsightsCard: View {** (line 492)
- **public struct InsightRow: View {** (line 529)
- **public struct PredictiveAnalyticsCard: View {** (line 558)
- **public struct PredictionRow: View {** (line 591)
- **public struct BehavioralPatternsCard: View {** (line 616)
- **public struct PatternRow: View {** (line 659)

#### Public Properties

- `var body: some View {` (line 7)
- `var body: some View {` (line 74)
- `var body: some View {` (line 128)
- `var body: some View {` (line 173)
- `var body: some View {` (line 201)
- `var body: some View {` (line 226)
- `var body: some View {` (line 265)
- `var body: some View {` (line 286)
- `var body: some View {` (line 320)
- `var body: some View {` (line 365)
- `var body: some View {` (line 410)
- `var body: some View {` (line 448)
- `var body: some View {` (line 493)
- `var body: some View {` (line 535)
- `var body: some View {` (line 559)
- `var body: some View {` (line 596)
- `var body: some View {` (line 617)
- `var body: some View {` (line 665)

### ProfileViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/CharacterProfile/ProfileViewModel.swift`

#### Public Types

- **public class ProfileViewModel: ObservableObject {** (line 7)

### AnalyticsTestView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/AnalyticsTest/AnalyticsTestView.swift`

#### Public Types

- **public struct AnalyticsTestView: View {** (line 53)
- **public struct TestResultsView: View {** (line 237)
- **public struct TestResultRow: View {** (line 279)
- **public struct StatItem: View {** (line 316)

#### Public Properties

- `var body: some View {` (line 58)
- `var body: some View {` (line 240)
- `var body: some View {` (line 282)
- `var body: some View {` (line 321)

### TodaysQuestsViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/TodaysQuests/TodaysQuestsViewModel.swift`

#### Public Types

- **public class TodaysQuestsViewModel: ObservableObject {** (line 15)

### TodaysQuestsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/TodaysQuests/TodaysQuestsView.swift`

#### Public Types

- **public struct TodaysQuestsView: View {** (line 6)

#### Public Properties

- `var body: some View {` (line 12)
- `var body: some View {` (line 86)
- `var body: some View {` (line 111)
- `var body: some View {` (line 128)
- `var body: some View {` (line 197)

### StreakAnalyticsData

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakAnalytics/StreakAnalyticsData.swift`

### StreakAnalyticsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakAnalytics/StreakAnalyticsView.swift`

#### Public Types

- **public struct StreakAnalyticsView: View {** (line 5)

#### Public Properties

- `var body: some View {` (line 13)

### StreakAnalyticsViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakAnalytics/StreakAnalyticsViewModel.swift`

#### Public Properties

- `let objectWillChange = ObservableObjectPublisher()` (line 8)

### StreakAnalyticsTopPerformersView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakAnalytics/Views/StreakAnalyticsTopPerformersView.swift`

#### Public Types

- **public struct StreakAnalyticsTopPerformersView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 7)

### StreakAnalyticsOverviewView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakAnalytics/Views/StreakAnalyticsOverviewView.swift`

#### Public Types

- **public struct StreakAnalyticsOverviewView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 8)

### StreakAnalyticsInsightsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakAnalytics/Views/StreakAnalyticsInsightsView.swift`

#### Public Types

- **public struct StreakAnalyticsInsightsView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 7)

### StreakAnalyticsWeeklyView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakAnalytics/Views/StreakAnalyticsWeeklyView.swift`

#### Public Types

- **public struct StreakAnalyticsWeeklyView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 7)

### StreakAnalyticsDistributionView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakAnalytics/Views/StreakAnalyticsDistributionView.swift`

#### Public Types

- **public struct StreakAnalyticsDistributionView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 7)

### HabitQuestBridging

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/HabitQuestBridging.swift`

### AppMainView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Application/AppMainView.swift`

#### Public Types

- **public struct AppMainView: View {** (line 5)

#### Public Properties

- `var body: some View {` (line 6)

### ContentView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/ContentView.swift`

#### Public Types

- **public struct ContentView: View {** (line 12)
- **public struct HeaderView: View {** (line 59)
- **public struct ItemListView: View {** (line 86)
- **public struct ItemRowView: View {** (line 117)
- **public struct ItemDetailView: View {** (line 167)
- **public struct DetailRow: View {** (line 212)
- **public struct FooterStatsView: View {** (line 231)
- **public struct DetailView: View {** (line 262)

#### Public Properties

- `var body: some View {` (line 20)
- `var body: some View {` (line 60)
- `var body: some View {` (line 91)
- `var body: some View {` (line 120)
- `var body: some View {` (line 170)
- `var body: some View {` (line 216)
- `var body: some View {` (line 234)
- `var body: some View {` (line 263)

### HabitQuestApp

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/HabitQuestApp.swift`

#### Public Types

- **public struct HabitQuestApp: App {** (line 18)

#### Public Properties

- `var body: some Scene {` (line 49)

### ProfileViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/ProfileViewTests.swift`

#### Public Types

- **public class ProfileViewTests: XCTestCase {** (line 4)

### TodaysQuestsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/TodaysQuestsViewTests.swift`

#### Public Types

- **public class TodaysQuestsViewTests: XCTestCase {** (line 4)

### QuestLogViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/QuestLogViewTests.swift`

#### Public Types

- **public class QuestLogViewTests: XCTestCase {** (line 4)

### SharedAnalyticsComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/SharedAnalyticsComponentsTests.swift`

#### Public Types

- **public class SharedAnalyticsComponentsTests: XCTestCase {** (line 4)

### ContentViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/ContentViewTests.swift`

#### Public Types

- **public class ContentViewTests: XCTestCase {** (line 6)

### DataManagementViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/DataManagementViewTests.swift`

#### Public Types

- **public class DataManagementViewTests: XCTestCase {** (line 4)

### GameRulesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/GameRulesTests.swift`

#### Public Types

- **public class GameRulesTests: XCTestCase {** (line 4)

### DataManagementViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/DataManagementViewModelTests.swift`

#### Public Types

- **public class DataManagementViewModelTests: XCTestCase {** (line 5)

### LoggerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/LoggerTests.swift`

#### Public Types

- **public class LoggerTests: XCTestCase {** (line 4)

### DataExportServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/DataExportServiceTests.swift`

### TodaysQuestsViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/TodaysQuestsViewModelTests.swift`

#### Public Types

- **public class TodaysQuestsViewModelTests: XCTestCase {** (line 4)

### QuestLogViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/QuestLogViewModelTests.swift`

#### Public Types

- **public class QuestLogViewModelTests: XCTestCase {** (line 4)

### AnalyticsTestViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AnalyticsTestViewTests.swift`

#### Public Types

- **public class AnalyticsTestViewTests: XCTestCase {** (line 4)

### ErrorHandlerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/ErrorHandlerTests.swift`

#### Public Types

- **public class ErrorHandlerTests: XCTestCase {** (line 4)

### AppMainViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AppMainViewTests.swift`

#### Public Types

- **public class AppMainViewTests: XCTestCase {** (line 4)

### AnalyticsTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AnalyticsTypesTests.swift`

#### Public Types

- **public class AnalyticsTypesTests: XCTestCase {** (line 4)

### SmartNotificationServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/SmartNotificationServiceTests.swift`

#### Public Types

- **public class SmartNotificationServiceTests: XCTestCase {** (line 4)

### StreakServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakServiceTests.swift`

#### Public Types

- **public class StreakServiceTests: XCTestCase {** (line 4)

### StreakAnalyticsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakAnalyticsViewTests.swift`

#### Public Types

- **public class StreakAnalyticsViewTests: XCTestCase {** (line 4)

### AchievementTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AchievementTests.swift`

#### Public Types

- **public class AchievementTests: XCTestCase {** (line 5)

### SharedArchitectureTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/SharedArchitectureTests.swift`

#### Public Types

- **public class SharedArchitectureTests: XCTestCase {** (line 4)

### HabitQuestAppTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/HabitQuestAppTests.swift`

#### Public Types

- **public class HabitQuestAppTests: XCTestCase {** (line 4)

### AchievementServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AchievementServiceTests.swift`

#### Public Types

- **public class AchievementServiceTests: XCTestCase {** (line 4)

### StreakHeatMapViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakHeatMapViewTests.swift`

#### Public Types

- **public class StreakHeatMapViewTests: XCTestCase {** (line 4)

### ProfileViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/ProfileViewModelTests.swift`

#### Public Types

- **public class ProfileViewModelTests: XCTestCase {** (line 5)

### NotificationServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/NotificationServiceTests.swift`

#### Public Types

- **public class NotificationServiceTests: XCTestCase {** (line 4)

### AnalyticsServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AnalyticsServiceTests.swift`

#### Public Types

- **public class AnalyticsServiceTests: XCTestCase {** (line 4)

### StreakVisualizationViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakVisualizationViewTests.swift`

#### Public Types

- **public class StreakVisualizationViewTests: XCTestCase {** (line 4)

### HabitQuestTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/HabitQuestTests.swift`

### StreakMilestoneTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakMilestoneTests.swift`

#### Public Types

- **public class StreakMilestoneTests: XCTestCase {** (line 4)

## Dependencies
