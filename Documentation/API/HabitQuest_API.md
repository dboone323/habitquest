# HabitQuest API Documentation

Generated: Fri Sep 19 10:28:58 CDT 2025
Project: HabitQuest
Location: /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest

## Overview

This document contains the public API reference for HabitQuest.

## Classes and Structs

### HabitQuestUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestUITests/HabitQuestUITests.swift`

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

### Achievement

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Models/Achievement.swift`

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

### Logger

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Utilities/Logger.swift`

### ErrorHandler

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Utilities/ErrorHandler.swift`

### SharedAnalyticsComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Views/SharedAnalyticsComponents.swift`

### SmartNotificationService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/SmartNotificationService.swift`

### AnalyticsTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/AnalyticsTypes.swift`

### AdvancedAnalyticsEngine

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/AdvancedAnalyticsEngine.swift`

### StreakService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/StreakService.swift`

### GameRules

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/GameRules.swift`

### NotificationService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/NotificationService.swift`

### DataExportService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/DataExportService.swift`

### AnalyticsService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/AnalyticsService.swift`

### AchievementService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/AchievementService.swift`

### Item

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Item.swift`

### QuestLogView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/QuestLog/QuestLogView.swift`

### QuestLogViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/QuestLog/QuestLogViewModel.swift`

### StreakVisualizationView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakVisualization/StreakVisualizationView.swift`

### StreakHeatMapView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakVisualization/StreakHeatMapView.swift`

### DataManagementView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/DataManagement/DataManagementView.swift`

### DataManagementViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/DataManagement/DataManagementViewModel.swift`

### ProfileView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/CharacterProfile/ProfileView.swift`

### ProfileViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/CharacterProfile/ProfileViewModel.swift`

### AnalyticsTestView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/AnalyticsTest/AnalyticsTestView.swift`

### TodaysQuestsViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/TodaysQuests/TodaysQuestsViewModel.swift`

### TodaysQuestsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/TodaysQuests/TodaysQuestsView.swift`

### StreakAnalyticsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/StreakAnalytics/StreakAnalyticsView.swift`

### HabitQuestBridging

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/HabitQuestBridging.swift`

### AppMainView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Application/AppMainView.swift`

### ContentView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/ContentView.swift`

### HabitQuestApp

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/HabitQuestApp.swift`

### ProfileViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/ProfileViewTests.swift`

### TodaysQuestsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/TodaysQuestsViewTests.swift`

### QuestLogViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/QuestLogViewTests.swift`

### SharedAnalyticsComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/SharedAnalyticsComponentsTests.swift`

### ContentViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/ContentViewTests.swift`

### DataManagementViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/DataManagementViewTests.swift`

### GameRulesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/GameRulesTests.swift`

### DataManagementViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/DataManagementViewModelTests.swift`

### LoggerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/LoggerTests.swift`

### DataExportServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/DataExportServiceTests.swift`

### TodaysQuestsViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/TodaysQuestsViewModelTests.swift`

### QuestLogViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/QuestLogViewModelTests.swift`

### AnalyticsTestViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AnalyticsTestViewTests.swift`

### ErrorHandlerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/ErrorHandlerTests.swift`

### AppMainViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AppMainViewTests.swift`

### AnalyticsTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AnalyticsTypesTests.swift`

### SmartNotificationServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/SmartNotificationServiceTests.swift`

### StreakServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakServiceTests.swift`

### StreakAnalyticsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakAnalyticsViewTests.swift`

### AchievementTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AchievementTests.swift`

### SharedArchitectureTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/SharedArchitectureTests.swift`

### HabitQuestAppTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/HabitQuestAppTests.swift`

### AchievementServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AchievementServiceTests.swift`

### StreakHeatMapViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakHeatMapViewTests.swift`

### ProfileViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/ProfileViewModelTests.swift`

### NotificationServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/NotificationServiceTests.swift`

### AnalyticsServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/AnalyticsServiceTests.swift`

### StreakVisualizationViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakVisualizationViewTests.swift`

### HabitQuestTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/HabitQuestTests.swift`

### StreakMilestoneTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakMilestoneTests.swift`

## Dependencies

