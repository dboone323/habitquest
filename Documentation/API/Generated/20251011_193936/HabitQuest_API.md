# HabitQuest API Documentation

**Generated:** Sat Oct 11 19:39:37 CDT 2025
**Version:** 1.0.0

## Overview

This document provides comprehensive API reference for HabitQuest.

---

## validate_ai_features.swift

**Path:** `validate_ai_features.swift`

### Structs

#### `MockHabit`


#### `MockPlayerProfile`


---

## Logger.swift

**Path:** `HabitQuest/Core/Utilities/Logger.swift`

### Description

Centralized logging utility for the HabitQuest app
Provides structured logging with different levels and categories

### Structs

#### `Logger`

Centralized logging utility for the HabitQuest app
Provides structured logging with different levels and categories


---

## StreakService.swift

**Path:** `HabitQuest/Core/Services/StreakService.swift`

### Description

Service for handling streak calculations, milestone detection, and streak analytics

### Classes

#### `StreakService`

Service for handling streak calculations, milestone detection, and streak analytics


### Structs

#### `StreakAnalytics`

Represents a single day in streak visualization
Comprehensive streak analytics for a habit


---

## GameRules.swift

**Path:** `HabitQuest/Core/Services/GameRules.swift`

### Description

Contains all game logic and progression calculations
Pure functions that handle XP calculation, level progression, and habit completion rewards

### Enums

#### `GameRules`

Contains all game logic and progression calculations
Pure functions that handle XP calculation, level progression, and habit completion rewards


---

## NotificationService.swift

**Path:** `HabitQuest/Core/Services/NotificationService.swift`

### Description

Service for managing push notifications and habit reminders
Handles notification scheduling, permission requests, and reminder management

### Enums

#### `NotificationService`

Service for managing push notifications and habit reminders
Handles notification scheduling, permission requests, and reminder management


---

## AchievementService.swift

**Path:** `HabitQuest/Core/Services/AchievementService.swift`

### Description

Service for managing achievements and badge unlocking logic
Handles progress tracking, achievement unlocking, and reward distribution

### Enums

#### `AchievementService`

Service for managing achievements and badge unlocking logic
Handles progress tracking, achievement unlocking, and reward distribution


---

## BehavioralAdaptationService.swift

**Path:** `HabitQuest/Core/Services/Notifications/BehavioralAdaptationService.swift`

### Description

Service responsible for adapting notifications based on user behavior patterns

### Structs

#### `UserResponseAnalysis`


#### `NotificationBehavioralInsights`


#### `FatigueIndicator`


#### `NotificationInteractionData`


### Enums

#### `NotificationInteraction`


#### `TimingAdjustment`


#### `ResponsivenessPattern`


#### `FatigueType`


---

## ContextAwarenessService.swift

**Path:** `HabitQuest/Core/Services/Notifications/ContextAwarenessService.swift`

### Description

Service responsible for context-aware notification features

### Structs

#### `ContextualInsights`


#### `ContextualOpportunity`


#### `ContextualRecommendation`


### Enums

#### `HabitContext`


#### `RiskLevel`


#### `OpportunityType`


#### `RecommendationType`


#### `RecommendationPriority`


---

## StreakHeatMapView.swift

**Path:** `HabitQuest/Features/StreakVisualization/StreakHeatMapView.swift`

### Description

GitHub-style contribution heat map for habit streaks

### Structs

#### `DayIntensity`


#### `StreakPrediction`


---

## AnalyticsTestView.swift

**Path:** `HabitQuest/Features/AnalyticsTest/AnalyticsTestView.swift`

### Description

Live analytics test runner that can be accessed from within the app

### Structs

#### `TestResults`


#### `TestResult`


---

## StreakAnalyticsData.swift

**Path:** `HabitQuest/Features/StreakAnalytics/StreakAnalyticsData.swift`

### Description

Data structures for streak analytics

### Structs

#### `StreakAnalyticsData`

Data structures for streak analytics


#### `TopPerformer`


#### `StreakDistributionData`


#### `ConsistencyInsight`


#### `WeeklyPattern`


---

## test_ai_service.swift

**Path:** `test_ai_service.swift`

### Classes

#### `MockAIHabitRecommender`


### Structs

#### `AIHabitRecommendation`


### Enums

#### `AIProcessingStatus`


---

