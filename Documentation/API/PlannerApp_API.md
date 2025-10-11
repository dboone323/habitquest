# PlannerApp API Documentation

Generated: October 11, 2025
Project: PlannerApp
Location: /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp

## Overview

This document contains the public API reference for PlannerApp, including the AI-powered dashboard features and intelligent task management system.

## AI-Powered Features

### AITaskPrioritizationService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Services/AITaskPrioritizationService.swift`

AI-powered task prioritization service that provides intelligent task suggestions and productivity insights using pattern recognition, goal-based analysis, and time-based recommendations.

#### Public Types

- **public class AITaskPrioritizationService: ObservableObject {** (line 10)
  - Singleton service for AI-powered task analysis and suggestions
  - Thread-safe with @MainActor isolation
  - Provides real-time task suggestions and productivity insights

#### Public Properties

- `public static var shared: AITaskPrioritizationService` (line 12)
  - Singleton instance for accessing AI services throughout the app
- `@Published public var isProcessing = false` (line 18)
  - Indicates when AI analysis is in progress
- `@Published public var lastUpdate: Date?` (line 19)
  - Timestamp of the last AI analysis update

#### Public Functions

- `parseNaturalLanguageTask(_ input: String) async throws -> PlannerTask?` (line 32)
  - Parses natural language input into structured task objects
  - Extracts priority, due dates, and times from text
  - Supports patterns like "urgent task by tomorrow at 2pm"
  - Returns nil if parsing fails

- `generateTaskSuggestions(currentTasks: [PlannerTask], recentActivity: [ActivityRecord], userGoals: [Goal]) -> [TaskSuggestion]` (line 75)
  - Generates AI-powered task suggestions based on user patterns and goals
  - Analyzes completion patterns, goal progress, and time-based opportunities
  - Returns prioritized list of actionable suggestions

- `generateProductivityInsights(activityData: [ActivityRecord], taskData: [PlannerTask], goalData: [Goal]) -> [ProductivityInsight]` (line 184)
  - Analyzes user activity to generate productivity insights
  - Calculates productivity scores, identifies trends, and provides optimization recommendations
  - Returns up to 5 most relevant insights sorted by priority

#### Supporting Data Models

- **public struct TaskSuggestion: Identifiable, Codable {** (line 334)
  - Represents an AI-generated task suggestion
  - Properties: id, title, subtitle, reasoning, priority, urgency, suggestedTime, category, confidence

- **public struct ProductivityInsight: Identifiable, Codable {** (line 356)
  - Represents an AI-generated productivity insight
  - Properties: id, title, description, icon, priority, category, actionable

- **public enum ActivityType: String, Codable {** (line 372)
  - Types of user activities tracked for AI analysis
  - Cases: taskCreated, taskCompleted, goalCreated, goalCompleted

- **public struct ActivityRecord: Codable {** (line 377)
  - Records user activity for pattern analysis
  - Properties: id, type, timestamp

### DashboardViewModel AI Integration

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/ViewModels/DashboardViewModel.swift`

Enhanced dashboard view model with AI-powered suggestions and productivity insights.

#### AI-Related Properties

- `@Published var aiSuggestions: [AISuggestion] = []` (line 44)
  - Array of AI-generated task suggestions for display
- `@Published var productivityInsights: [ProductivityInsight] = []` (line 45)
  - Array of AI-generated productivity insights
- `private let aiService = AITaskPrioritizationService.shared` (line 54)
  - Reference to the shared AI service instance

#### AI Caching Properties

- `private var lastAISuggestionsUpdate: Date?` (line 70)
  - Timestamp of last AI suggestions update for caching
- `private var lastProductivityInsightsUpdate: Date?` (line 71)
  - Timestamp of last productivity insights update for caching
- `private let aiCacheTimeout: TimeInterval = 300` (line 72)
  - 5-minute cache timeout for AI-generated content

#### AI Data Models

- **public struct AISuggestion: Identifiable {** (line 10)
  - UI-friendly representation of AI task suggestions
  - Properties: id, title, subtitle, reasoning, priority, urgency, suggestedTime, icon, color

## Classes and Structs

### DashboardViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/ViewModels/DashboardViewModel.swift`

#### Public Types

- **public struct DashboardActivity: Identifiable {** (line 8)
- **public struct UpcomingItem: Identifiable {** (line 17)
- **public class DashboardViewModel: ObservableObject {** (line 27)

#### Public Properties

- `let id = UUID()` (line 9)
- `let id = UUID()` (line 18)

### fixes_dashboard_items

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/fixes_dashboard_items.swift`

### PlannerAppUITestsLaunchTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/PlannerAppUITests/PlannerAppUITestsLaunchTests.swift`

### PlannerAppUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/PlannerAppUITests/PlannerAppUITests.swift`

### PerformanceManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/PerformanceManager.swift`

#### Public Types

- **public class PerformanceManager {** (line 10)

#### Public Functions

- `recordFrame() {` (line 19)
- `getCurrentFPS() -> Double {` (line 29)
- `getMemoryUsage() -> Double {` (line 44)
- `isPerformanceDegraded() -> Bool {` (line 62)

### CloudKitManager_Simplified

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/CloudKit/CloudKitManager_Simplified.swift`

#### Public Types

- **public class CloudKitManager: ObservableObject {** (line 13)

### CloudKitOnboardingView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/CloudKit/CloudKitOnboardingView.swift`

#### Public Types

- **public struct CloudKitOnboardingView: View {** (line 6)

#### Public Properties

- `var body: some View {` (line 14)

### CloudKitSyncView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/CloudKit/CloudKitSyncView.swift`

### EnhancedCloudKitManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/CloudKit/EnhancedCloudKitManager.swift`

#### Public Types

- **public class EnhancedCloudKitManager: ObservableObject {** (line 21)
- **public struct EnhancedSyncStatusView: View {** (line 857)

#### Public Properties

- `var body: some View {` (line 869)

### CloudKitManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/CloudKit/CloudKitManager.swift`

#### Public Types

- **public class CloudKitManager: ObservableObject {** (line 13)

### CloudKitEnhancements

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/CloudKit/CloudKitEnhancements.swift`

### CloudKitMigrationHelper

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/CloudKit/CloudKitMigrationHelper.swift`

### Dependencies

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Dependencies.swift`

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

### PlatformFeatures

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Platform/PlatformFeatures.swift`

### ContentView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/PlannerApp/ContentView.swift`

#### Public Types

- **public struct ContentView: View {** (line 10)

#### Public Properties

- `var body: some View {` (line 11)

### ContentViewTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/ContentViewTestsTests.swift`

### TaskDataManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/TaskDataManagerTests.swift`

### GoalTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/GoalTests.swift`

### AddJournalEntryViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/AddJournalEntryViewTests.swift`

### DependenciesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/DependenciesTests.swift`

### ModernThemesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/ModernThemesTests.swift`

### AddGoalView_SimpleTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/AddGoalView_SimpleTests.swift`

### SettingsView_NewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/SettingsView_NewTests.swift`

### AddGoalViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/AddGoalViewTests.swift`

### DashboardViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/DashboardViewModelTests.swift`

### JournalRowTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/JournalRowTests.swift`

### DateSectionViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/DateSectionViewTests.swift`

### EventRowViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/EventRowViewTests.swift`

### QuickStatCardTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/QuickStatCardTests.swift`

### GoalsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/GoalsViewTests.swift`

### GoalDataManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/GoalDataManagerTests.swift`

### CloudKitManager_SimplifiedTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CloudKitManager_SimplifiedTests.swift`

### AddGoalView_WorkingTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/AddGoalView_WorkingTests.swift`

### ModernCardTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/ModernCardTests.swift`

### ThemeManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/ThemeManagerTests.swift`

### PlatformAdaptiveNavigationTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/PlatformAdaptiveNavigationTests.swift`

### MainTabViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/MainTabViewTests.swift`

### JournalDataManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/JournalDataManagerTests.swift`

### CalendarViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CalendarViewTests.swift`

### PerformanceManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/PerformanceManagerTests.swift`

### CloudKitManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CloudKitManagerTests.swift`

### SettingsView_BackupTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/SettingsView_BackupTests.swift`

### GoalRowViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/GoalRowViewTests.swift`

### iOSAdaptivePopupsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/iOSAdaptivePopupsTests.swift`

### DataManagerErrorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/DataManagerErrorTests.swift`

### AddCalendarEventViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/AddCalendarEventViewTests.swift`

### GoalsHeaderViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/GoalsHeaderViewTests.swift`

### CloudKitMigrationHelperTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CloudKitMigrationHelperTests.swift`

### ProgressUpdateSheetTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/ProgressUpdateSheetTests.swift`

### ContentViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/ContentViewTests.swift`

### PlannerAppTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/PlannerAppTestsTests.swift`

### DashboardViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/DashboardViewTests.swift`

### CalendarEventTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CalendarEventTests.swift`

### JournalEntryTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/JournalEntryTests.swift`

### MainTabView_EnhancedTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/MainTabView_EnhancedTests.swift`

### TaskInputViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/TaskInputViewTests.swift`

### NotificationExtensionsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/NotificationExtensionsTests.swift`

### EnhancedCloudKitManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/EnhancedCloudKitManagerTests.swift`

### AddGoalView_MinimalTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/AddGoalView_MinimalTests.swift`

### SettingsView_CleanTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/SettingsView_CleanTests.swift`

### JournalHeaderViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/JournalHeaderViewTests.swift`

### PlannerAppUITestsLaunchTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/PlannerAppUITestsLaunchTestsTests.swift`

### fixes_dashboard_itemsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/fixes_dashboard_itemsTests.swift`

### PlatformFeaturesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/PlatformFeaturesTests.swift`

### SettingsView_SimpleTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/SettingsView_SimpleTests.swift`

### JournalEmptyStateViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/JournalEmptyStateViewTests.swift`

### DashboardView_ModernTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/DashboardView_ModernTests.swift`

### CalendarView_NewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CalendarView_NewTests.swift`

### JournalViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/JournalViewTests.swift`

### run_testsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/run_testsTests.swift`

### TaskTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/TaskTests.swift`

### PlannerAppUITestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/PlannerAppUITestsTests.swift`

### SyncStatusViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/SyncStatusViewTests.swift`

### TaskManagerViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/TaskManagerViewTests.swift`

### GoalItemViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/GoalItemViewTests.swift`

### CloudKitEnhancementsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CloudKitEnhancementsTests.swift`

### DataManagersTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/DataManagersTests.swift`

### EnhancedPlatformNavigationTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/EnhancedPlatformNavigationTests.swift`

### SettingsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/SettingsViewTests.swift`

### AccessibilityEnhancementsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/AccessibilityEnhancementsTests.swift`

### VisualEnhancementsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/VisualEnhancementsTests.swift`

### NetworkMonitorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/NetworkMonitorTests.swift`

### TaskRowViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/TaskRowViewTests.swift`

### AddGoalView_NewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/AddGoalView_NewTests.swift`

### JournalListViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/JournalListViewTests.swift`

### TaskManagerHeaderViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/TaskManagerHeaderViewTests.swift`

### AppSettingKeysTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/AppSettingKeysTests.swift`

### AddGoalView_FinalTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/AddGoalView_FinalTests.swift`

### CalendarGridTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CalendarGridTests.swift`

### TaskRowTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/TaskRowTests.swift`

### UpcomingItemViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/UpcomingItemViewTests.swift`

### PlannerAppTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/PlannerAppTests.swift`

### TaskListViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/TaskListViewTests.swift`

### ThemePreviewViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/ThemePreviewViewTests.swift`

### CalendarComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CalendarComponentsTests.swift`

### GoalsListViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/GoalsListViewTests.swift`

### ThemeTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/ThemeTests.swift`

### JournalDetailViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/JournalDetailViewTests.swift`

### GoalsEmptyStateViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/GoalsEmptyStateViewTests.swift`

### CloudKitOnboardingViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CloudKitOnboardingViewTests.swift`

### SettingsView_Simple_TestTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/SettingsView_Simple_TestTests.swift`

### CalendarDataManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CalendarDataManagerTests.swift`

### QuickActionCardTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/QuickActionCardTests.swift`

### CloudKitSyncViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tests/CloudKitSyncViewTests.swift`

### ContentViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/PlannerAppTests/ContentViewTests.swift`

#### Public Types

- **public class ContentViewTests: XCTestCase {** (line 5)

### PlannerAppTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/PlannerAppTests/PlannerAppTests.swift`

### CalendarEvent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Models/CalendarEvent.swift`

#### Public Types

- **public struct CalendarEvent: Identifiable, Codable {** (line 7)

#### Public Properties

- `let id: UUID` (line 9)

### CalendarDataManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Models/CalendarDataManager.swift`

### Goal

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Models/Goal.swift`

#### Public Types

- **public enum GoalPriority: String, CaseIterable, Codable {** (line 7)
- **public struct Goal: Identifiable, Codable {** (line 35)

#### Public Properties

- `let id: UUID` (line 37)

### TaskDataManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Models/TaskDataManager.swift`

### GoalDataManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Models/GoalDataManager.swift`

### JournalDataManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Models/JournalDataManager.swift`

### DataManagers

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Models/DataManagers.swift`

### JournalEntry

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Models/JournalEntry.swift`

#### Public Types

- **public struct JournalEntry: Identifiable, Codable {** (line 6)

#### Public Properties

- `let id: UUID` (line 7)

### Task

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Models/Task.swift`

#### Public Types

- **public enum TaskPriority: String, CaseIterable, Codable {** (line 8)
- **public struct PlannerTask: Identifiable, Codable, Transferable {** (line 36)

#### Public Properties

- `let id: UUID` (line 38)

### AppSettingKeys

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Utilities/AppSettingKeys.swift`

### NotificationExtensions

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Utilities/NotificationExtensions.swift`

### NetworkMonitor

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Utilities/NetworkMonitor.swift`

### JournalRow

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Journal/JournalRow.swift`

#### Public Types

- **public struct JournalRow: View {** (line 3)
- **public struct JournalRow_Previews: PreviewProvider {** (line 50)

#### Public Properties

- `var body: some View {` (line 14)

### JournalEmptyStateView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Journal/JournalEmptyStateView.swift`

#### Public Types

- **public struct JournalEmptyStateView: View {** (line 3)
- **public struct JournalEmptyStateView_Previews: PreviewProvider {** (line 21)

#### Public Properties

- `var body: some View {` (line 7)

### JournalHeaderView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Journal/JournalHeaderView.swift`

#### Public Types

- **public struct JournalHeaderView: View {** (line 3)
- **public struct JournalHeaderView_Previews: PreviewProvider {** (line 26)

#### Public Properties

- `var body: some View {` (line 7)

### JournalListView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Journal/JournalListView.swift`

#### Public Types

- **public struct JournalListView: View {** (line 3)
- **public struct JournalListView_Previews: PreviewProvider {** (line 35)

#### Public Properties

- `var body: some View {` (line 10)

### TaskListView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Tasks/TaskListView.swift`

#### Public Types

- **public struct TaskListView: View {** (line 9)

#### Public Properties

- `var body: some View {` (line 18)

### TaskManagerHeaderView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Tasks/TaskManagerHeaderView.swift`

#### Public Types

- **public struct TaskManagerHeaderView: View {** (line 9)

#### Public Properties

- `var body: some View {` (line 13)

### TaskInputView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Tasks/TaskInputView.swift`

#### Public Types

- **public struct TaskInputView: View {** (line 5)

#### Public Properties

- `var body: some View {` (line 11)

### TaskRow

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Tasks/TaskRow.swift`

#### Public Types

- **public struct TaskRow: View {** (line 10)

#### Public Properties

- `var body: some View {` (line 18)

### GoalItemView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Goals/GoalItemView.swift`

#### Public Types

- **public struct GoalItemView: View {** (line 5)

#### Public Properties

- `var body: some View {` (line 73)

### ProgressUpdateSheet

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Goals/ProgressUpdateSheet.swift`

#### Public Types

- **public struct ProgressUpdateSheet: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 21)

### GoalsEmptyStateView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Goals/GoalsEmptyStateView.swift`

#### Public Types

- **public struct GoalsEmptyStateView: View {** (line 5)

#### Public Properties

- `var body: some View {` (line 8)

### GoalsListView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Goals/GoalsListView.swift`

#### Public Types

- **public struct GoalsListView: View {** (line 5)

#### Public Properties

- `var body: some View {` (line 12)

### GoalsHeaderView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Goals/GoalsHeaderView.swift`

#### Public Types

- **public struct GoalsHeaderView: View {** (line 5)

#### Public Properties

- `var body: some View {` (line 9)

### EnhancedPlatformNavigation

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/EnhancedPlatformNavigation.swift`

#### Public Types

- **public struct MacOSSidebarView: View {** (line 95)
- **public struct IPadSidebarView: View {** (line 149)
- **public struct MacOSToolbarButtons: View {** (line 230)
- **public struct IPadToolbarButtons: View {** (line 260)
- **public struct IPhoneToolbarButtons: View {** (line 284)
- **public struct QuickActionButton: View {** (line 305)
- **public struct KeyboardShortcutsView: View {** (line 338)
- **public struct ShortcutRow: View {** (line 362)

#### Public Properties

- `var body: some View {` (line 130)
- `var body: some View {` (line 162)
- `var body: some View {` (line 233)
- `var body: some View {` (line 261)
- `var body: some View {` (line 285)
- `var body: some View {` (line 313)
- `var body: some View {` (line 339)
- `var body: some View {` (line 366)

### SyncStatusView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/SyncStatusView.swift`

### ModernCard

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/ModernCard.swift`

#### Public Types

- **public struct ModernButton: View {** (line 46)
- **public struct ProgressBar: View {** (line 140)
- **public struct ModernTextField: View {** (line 176)

#### Public Properties

- `var body: some View {` (line 88)
- `var body: some View {` (line 147)
- `var body: some View {` (line 186)

### QuickActionCard

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Dashboard/QuickActionCard.swift`

#### Public Types

- **public struct QuickActionCard: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 11)

### QuickStatCard

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Dashboard/QuickStatCard.swift`

#### Public Types

- **public struct QuickStatCard: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 12)

### UpcomingItemView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/Dashboard/UpcomingItemView.swift`

#### Public Types

- **public struct UpcomingItemView: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 7)

### PlatformAdaptiveNavigation

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/PlatformAdaptiveNavigation.swift`

#### Public Types

- **public struct SidebarView: View {** (line 44)
- **public struct PlatformToolbar: ViewModifier {** (line 94)
- **public struct ExamplePlatformView: View {** (line 280)

#### Public Functions

- `body(content: Content) -> some View {` (line 113)
- `body(content: Content) -> some View {` (line 186)
- `body(content: Content) -> some View {` (line 251)

#### Public Properties

- `var body: some View {` (line 68)
- `var body: some View {` (line 233)
- `var body: some View {` (line 284)

### VisualEnhancements

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/VisualEnhancements.swift`

#### Public Types

- **public struct AnimatedProgressRing: View {** (line 71)
- **public struct ProgressChangeModifier: ViewModifier {** (line 133)
- **public struct FloatingActionButton: View {** (line 152)
- **public struct ParticleSystem: View {** (line 246)
- **public struct ShimmerView: View {** (line 319)
- **public struct VisualEnhancementsPreview: View {** (line 437)

#### Public Functions

- `body(content: Content) -> some View {` (line 137)

#### Public Properties

- `var body: some View {` (line 81)
- `var body: some View {` (line 160)
- `var body: some View {` (line 260)
- `var body: some View {` (line 323)
- `var body: some View {` (line 441)

### iOSAdaptivePopups

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/iOSAdaptivePopups.swift`

### DashboardView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/MainApp/DashboardView.swift`

#### Public Types

- **public struct DashboardView: View {** (line 5)

#### Public Properties

- `var body: some View {` (line 45)

### DashboardView_Modern

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/MainApp/DashboardView_Modern.swift`

#### Public Types

- **public struct DashboardView: View {** (line 7)
- **public struct QuickStatCard: View {** (line 385)
- **public struct QuickActionCard: View {** (line 427)
- **public struct ActivityRowView: View {** (line 460)
- **public struct UpcomingItemView: View {** (line 515)

### MainTabView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/MainApp/MainTabView.swift`

#### Public Types

- **public struct MainTabView: View {** (line 10)
- **public struct MainTabView_Previews: PreviewProvider {** (line 117)

#### Public Properties

- `var body: some View {` (line 27)

### PlannerApp

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/MainApp/PlannerApp.swift`

#### Public Types

- **public struct PlannerApp: App {** (line 6)

#### Public Properties

- `var body: some Scene {` (line 29)

### MainTabView_Enhanced

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/MainApp/MainTabView_Enhanced.swift`

#### Public Types

- **public struct MainTabView_Enhanced: View {** (line 16)

#### Public Properties

- `var body: some View {` (line 60)

### ThemeManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Styling/ThemeManager.swift`

#### Public Types

- **public class ThemeManager: ObservableObject {** (line 10)

### ModernThemes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Styling/ModernThemes.swift`

### Theme

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Styling/Theme.swift`

#### Public Types

- **public struct Theme: Identifiable, Equatable { // Added Equatable for comparison** (line 19)

#### Public Properties

- `let id = UUID()` (line 20)

### CalendarDataManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/DataManagers/CalendarDataManager.swift`

### TaskDataManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/DataManagers/TaskDataManager.swift`

### GoalDataManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/DataManagers/GoalDataManager.swift`

### JournalDataManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/DataManagers/JournalDataManager.swift`

### DataManagerError

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/DataManagers/DataManagerError.swift`

#### Public Types

- **public enum DataManagerError: Error {** (line 12)

### AccessibilityEnhancements

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Accessibility/AccessibilityEnhancements.swift`

#### Public Types

- **public class AccessibilityManager: ObservableObject {** (line 20)
- **public struct AccessibleButton: View {** (line 82)
- **public struct HighContrastModifier: ViewModifier {** (line 195)
- **public struct ReducedMotionModifier: ViewModifier {** (line 215)
- **public struct FocusChangeModifier: ViewModifier {** (line 263)
- **public struct DynamicTypeText: View {** (line 321)
- **public struct AccessibleProgressView: View {** (line 339)
- **public struct AccessibilityDemoView: View {** (line 361)

#### Public Functions

- `body(content: Content) -> some View {` (line 198)
- `body(content: Content) -> some View {` (line 219)
- `body(content: Content) -> some View {` (line 266)

#### Public Properties

- `var body: some View {` (line 91)
- `var body: some View {` (line 169)
- `var body: some View {` (line 253)
- `var body: some View {` (line 328)
- `var body: some View {` (line 343)
- `var body: some View {` (line 365)

### JournalDetailView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Journal/JournalDetailView.swift`

#### Public Types

- **public struct JournalDetailView: View {** (line 4)
- **public struct JournalDetailView_Previews: PreviewProvider {** (line 72)

#### Public Properties

- `var body: some View {` (line 23)

### JournalView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Journal/JournalView.swift`

#### Public Types

- **public struct JournalView: View {** (line 6)
- **public struct JournalView_Previews: PreviewProvider {** (line 111)

#### Public Properties

- `var body: some View {` (line 33)

### AddJournalEntryView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Journal/AddJournalEntryView.swift`

#### Public Types

- **public struct AddJournalEntryView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 24)

### SettingsView_Clean

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Settings/SettingsView_Clean.swift`

#### Public Types

- **public struct SettingsView: View {** (line 11)
- **public struct ThemePreviewSheet: View {** (line 129)
- **public struct ThemeCard: View {** (line 162)
- **public struct SettingsView_Previews: PreviewProvider {** (line 218)

### SettingsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Settings/SettingsView.swift`

#### Public Types

- **public struct SettingsView: View {** (line 12)
- **public struct ThemePreviewSheet: View {** (line 141)
- **public struct ThemeCard: View {** (line 177)
- **public struct SettingsView_Previews: PreviewProvider {** (line 233)
- **public struct NotificationToggleModifier: ViewModifier {** (line 242)

#### Public Functions

- `body(content: Content) -> some View {` (line 245)

#### Public Properties

- `var body: some View {` (line 27)
- `var body: some View {` (line 145)
- `var body: some View {` (line 181)

### SettingsView_Backup

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Settings/SettingsView_Backup.swift`

#### Public Types

- **public struct SettingsView: View {** (line 12)

### SettingsView_Simple_Test

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Settings/SettingsView_Simple_Test.swift`

#### Public Types

- **public struct SettingsView: View {** (line 6)
- **public struct SettingsView_Previews: PreviewProvider {** (line 17)

### SettingsView_New

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Settings/SettingsView_New.swift`

#### Public Types

- **public struct SettingsView: View {** (line 12)
- **public struct CloudKitSettingsView: View {** (line 308)
- **public struct ThemePreviewSheet: View {** (line 331)
- **public struct ThemeCard: View {** (line 363)
- **public struct SettingsView_Previews: PreviewProvider {** (line 413)

### ThemePreviewView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Settings/ThemePreviewView.swift`

#### Public Types

- **public struct ThemePreviewView: View {** (line 10)
- **public struct ThemePreviewCard: View {** (line 179)

#### Public Properties

- `var body: some View {` (line 28)
- `var body: some View {` (line 184)

### SettingsView_Simple

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Settings/SettingsView_Simple.swift`

#### Public Types

- **public struct SettingsView: View {** (line 12)

### TaskInputView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Tasks/TaskInputView.swift`

#### Public Types

- **public struct TaskInputView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 9)

### TaskManagerView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Tasks/TaskManagerView.swift`

#### Public Types

- **public struct TaskManagerView: View {** (line 13)

#### Public Properties

- `var body: some View {` (line 30)

### GoalRowView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Calendar/GoalRowView.swift`

#### Public Types

- **public struct GoalRowView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 34)

### CalendarGrid

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Calendar/CalendarGrid.swift`

#### Public Types

- **public struct CalendarGrid: View {** (line 4)
- **public struct CalendarDayView: View {** (line 95)

#### Public Properties

- `var body: some View {` (line 62)
- `var body: some View {` (line 120)

### DateSectionView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Calendar/DateSectionView.swift`

### CalendarView_New

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Calendar/CalendarView_New.swift`

#### Public Types

- **public struct CalendarView_New: View {** (line 3)
- **public struct CalendarView_New_Previews: PreviewProvider {** (line 9)
- **public struct CalendarView_New: View {** (line 15)
- **public struct CalendarView_New_Previews: PreviewProvider {** (line 21)
- **public struct CalendarView: View {** (line 32)
- **public struct CalendarView_Previews: PreviewProvider {** (line 303)

### AddCalendarEventView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Calendar/AddCalendarEventView.swift`

#### Public Types

- **public struct AddCalendarEventView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 18)

### CalendarComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Calendar/CalendarComponents.swift`

### TaskRowView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Calendar/TaskRowView.swift`

#### Public Types

- **public struct TaskRowView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 35)

### EventRowView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Calendar/EventRowView.swift`

#### Public Types

- **public struct EventRowView: View {** (line 4)

#### Public Properties

- `var body: some View {` (line 19)

### CalendarView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Calendar/CalendarView.swift`

#### Public Types

- **public struct CalendarView: View {** (line 7)
- **public struct CalendarView_Previews: PreviewProvider {** (line 304)

#### Public Properties

- `var body: some View {` (line 100)

### AddGoalView_Final

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Goals/AddGoalView_Final.swift`

#### Public Types

- **public struct AddGoalView: View {** (line 4)

### AddGoalView_New

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Goals/AddGoalView_New.swift`

#### Public Types

- **public struct AddGoalView: View {** (line 6)
- **public struct AddGoalView_Previews: PreviewProvider {** (line 106)

### GoalsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Goals/GoalsView.swift`

#### Public Types

- **public struct GoalsView: View {** (line 4)
- **public struct GoalsView_Previews: PreviewProvider {** (line 96)

#### Public Properties

- `var body: some View {` (line 13)

### AddGoalView_Working

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Goals/AddGoalView_Working.swift`

#### Public Types

- **public struct AddGoalView: View {** (line 4)
- **public struct AddGoalView_Previews: PreviewProvider {** (line 102)

### AddGoalView_Minimal

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Goals/AddGoalView_Minimal.swift`

#### Public Types

- **public struct AddGoalView: View {** (line 4)

### AddGoalView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Goals/AddGoalView.swift`

#### Public Types

- **public struct AddGoalView: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 11)

### AddGoalView_Simple

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Goals/AddGoalView_Simple.swift`

#### Public Types

- **public struct AddGoalView: View {** (line 4)
- **public struct AddGoalView_Previews: PreviewProvider {** (line 61)

### run_tests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/run_tests.swift`

#### Public Types

- **public enum TaskPriority: String, CaseIterable, Codable {** (line 27)
- **public struct PlannerTask: Identifiable, Codable {** (line 39)
- **public enum GoalPriority: String, CaseIterable, Codable {** (line 84)
- **public struct Goal: Identifiable, Codable {** (line 96)
- **public struct JournalEntry: Identifiable, Codable {** (line 124)

## Dependencies
