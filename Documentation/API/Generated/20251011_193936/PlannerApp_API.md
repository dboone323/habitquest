# PlannerApp API Documentation

**Generated:** Sat Oct 11 19:39:40 CDT 2025
**Version:** 1.0.0

## Overview

This document provides comprehensive API reference for PlannerApp.

---

## run_tests.swift

**Path:** `Tools/Automation/run_tests.swift`

### Classes

#### `TaskDataManager`


#### `JournalDataManager`


---

## SharedArchitecture.swift

**Path:** `Core/SharedArchitecture.swift`

### Description

Protocol for standardized MVVM pattern across all projects
Supports both ObservableObject and @Observable patterns for maximum compatibility

### Protocols

#### `StorageService`

Shared storage interface

- `func store(_ object: some Codable, key: String) throws`
- `func retrieve<T: Codable>(_ type: T.Type, key: String) throws -> T?`
- `func remove(key: String) throws`
- `func clear() throws`

### Classes

#### `BaseListViewModel`

Base class for list view models with standardized functionality


#### `BaseFormViewModel`

Base class for form view models with validation


#### `PerformanceMonitor`

Shared performance monitoring


### Enums

#### `ValidationUtilities`

Shared storage interface


---

## CloudKitManager.swift

**Path:** `CloudKit/CloudKitManager.swift`

### Description

This provides better abstraction and testability for CloudKit functionality

### Protocols

#### `CloudKitService`

This provides better abstraction and testability for CloudKit functionality

- `func performFullSync() async`
- `func performSync() async`
- `func forcePushLocalChanges() async`
- `func resolveConflict(_ conflict: CloudKitManager.SyncConflict, useLocal: Bool) async`
- `func resolveAllConflicts(useLocal: Bool) async`
- `func requestiCloudAccess() async`
- `func handleNewDeviceLogin() async`
- `func uploadTasks(_ tasks: [PlannerTask]) async throws`
- `func uploadGoals(_ goals: [Goal]) async throws`
- `func uploadEvents(_ events: [CalendarEvent]) async throws`
- `func uploadJournalEntries(_ entries: [JournalEntry]) async throws`
- `func setupCloudKitSubscriptions() async throws`
- `func handleDatabaseNotification(_ notification: CKDatabaseNotification) async`
- `func createCustomZone() async throws`
- `func fetchZones() async throws -> [CKRecordZone]`
- `func deleteZone(named zoneName: String) async throws`
- `func getSyncedDevices() async -> [CloudKitManager.SyncedDevice]`
- `func removeDevice(_ deviceID: String) async throws`
- `func handleError(_ error: Error)`
- `func resetCloudKitData() async`
- `func configureAutoSync(interval: TimeInterval)`
- `var isSignedInToiCloud: Bool `
- `var syncStatus: CloudKitManager.SyncStatus `
- `var lastSyncDate: Date? `
- `var syncProgress: Double `
- `var conflictItems: [CloudKitManager.SyncConflict] `
- `var errorMessage: String? `
- `var currentError: CloudKitManager.CloudKitError? `

---

## CloudKitMigrationHelper.swift

**Path:** `CloudKit/CloudKitMigrationHelper.swift`

### Classes

#### `CloudKitMigrationHelper`


---

## PlatformFeatures.swift

**Path:** `Platform/PlatformFeatures.swift`

### Protocols

#### `PlatformFeatureProvider`

- `func setupPlatformFeatures()`
- `func handleDeepLink(_ url: URL)`
- `func shareContent(_ content: String)`
- `func openSystemSettings()`

### Classes

#### `MenuBarManager`


#### `TouchBarProvider`


#### `IOSFeatureProvider`


#### `MacOSFeatureProvider`


### Structs

#### `PlannerWidget`


#### `TaskProgressActivity`


#### `SplitViewContainer`


#### `ScribbleTextField`


#### `DragDropTaskView`


#### `KeyboardShortcutHandler`


### Enums

#### `ShortcutsIntentHandler`


#### `FocusModeManager`


#### `WindowManager`


#### `FileExportManager`


---

## PlannerEntities.swift

**Path:** `Models/PlannerEntities.swift`

### Description

Protocol defining the interface for all planner entities

### Protocols

#### `PlannerEntity`

Protocol defining the interface for all planner entities

- `var id: UUID `
- `var title: String `
- `var createdAt: Date `
- `var modifiedAt: Date? `
- `var isCompleted: Bool `
- `var priority: any PlannerPriority `

#### `Schedulable`

Protocol for entities that have due dates

- `var dueDate: Date? `

#### `PlannerRenderable`

Protocol for entities that have due dates
Protocol for entities that can be rendered

- `var color: String `
- `var iconName: String `

#### `PlannerPriority`

Protocol for entities that can be rendered
Protocol for priority systems

- `var displayName: String `
- `var sortOrder: Int `
- `var color: String `

### Enums

#### `EventPriority`


#### `JournalPriority`


#### `PlannerEntityFactory`


---

## AppSettingKeys.swift

**Path:** `Utilities/AppSettingKeys.swift`

### Enums

#### `AppSettingKeys`


---

## NetworkMonitor.swift

**Path:** `Utilities/NetworkMonitor.swift`

### Classes

#### `NetworkMonitor`


---

## EnhancedPlatformNavigation.swift

**Path:** `Components/EnhancedPlatformNavigation.swift`

### Structs

#### `EnhancedPlatformNavigation`


---

## ModernCard.swift

**Path:** `Components/ModernCard.swift`

### Structs

#### `ModernCard`


---

## PlatformAdaptiveNavigation.swift

**Path:** `Components/PlatformAdaptiveNavigation.swift`

### Structs

#### `PlatformAdaptiveNavigation`


#### `PlatformContextMenu`


#### `AdaptiveGrid`


#### `PlatformSheet`


---

## VisualEnhancements.swift

**Path:** `Components/VisualEnhancements.swift`

### Structs

#### `GlassMorphismCard`


#### `FlipCard`


#### `Interactive3DCard`


#### `BreathingView`


---

## iOSAdaptivePopups.swift

**Path:** `Components/iOSAdaptivePopups.swift`

### Structs

#### `IOSFormField`


#### `IOSPrimaryButton`


#### `IOSSecondaryButton`


### Enums

#### `HapticManager`


---

## ModernThemes.swift

**Path:** `Styling/ModernThemes.swift`

### Structs

#### `GradientCard`


---

## AccessibilityEnhancements.swift

**Path:** `Accessibility/AccessibilityEnhancements.swift`

### Structs

#### `AccessibleListRow`


#### `FocusableView`


### Enums

#### `ScreenReaderAnnouncement`


---

## DateSectionView.swift

**Path:** `Views/Calendar/DateSectionView.swift`

### Structs

#### `DateSectionView`


---

## CalendarDataManager.swift

**Path:** `Services/CalendarDataManager.swift`

### Description

Protocol defining the interface for calendar event data management

### Protocols

#### `CalendarDataManaging`

Protocol defining the interface for calendar event data management

- `func load() -> [CalendarEvent]`
- `func save(events: [CalendarEvent])`
- `func add(_ event: CalendarEvent)`
- `func update(_ event: CalendarEvent)`
- `func delete(_ event: CalendarEvent)`
- `func find(by id: UUID) -> CalendarEvent?`

---

## TaskDataManager.swift

**Path:** `Services/TaskDataManager.swift`

### Description

Protocol defining the interface for task data management

### Protocols

#### `TaskDataManaging`

Protocol defining the interface for task data management

- `func load() -> [PlannerTask]`
- `func save(tasks: [PlannerTask])`
- `func add(_ task: PlannerTask)`
- `func update(_ task: PlannerTask)`
- `func delete(_ task: PlannerTask)`
- `func find(by id: UUID) -> PlannerTask?`

---

## GoalDataManager.swift

**Path:** `Services/GoalDataManager.swift`

### Description

Protocol defining the interface for goal data management

### Protocols

#### `GoalDataManaging`

Protocol defining the interface for goal data management

- `func load() -> [Goal]`
- `func save(goals: [Goal])`
- `func add(_ goal: Goal)`
- `func update(_ goal: Goal)`
- `func delete(_ goal: Goal)`
- `func find(by id: UUID) -> Goal?`

---

## JournalDataManager.swift

**Path:** `Services/JournalDataManager.swift`

### Description

Protocol defining the interface for journal entry data management

### Protocols

#### `JournalDataManaging`

Protocol defining the interface for journal entry data management

- `func load() -> [JournalEntry]`
- `func save(entries: [JournalEntry])`
- `func add(_ entry: JournalEntry)`
- `func update(_ entry: JournalEntry)`
- `func delete(_ entry: JournalEntry)`
- `func find(by id: UUID) -> JournalEntry?`

---

## PlannerDataManager.swift

**Path:** `Services/PlannerDataManager.swift`

### Description

Protocol defining the interface for all data management operations

### Protocols

#### `DataManaging`

Protocol defining the interface for all data management operations

- `associatedtype DataType: Identifiable & Codable`
- `func load() -> [DataType]`
- `func save(items: [DataType])`
- `func add(_ item: DataType)`
- `func update(_ item: DataType)`
- `func delete(_ item: DataType)`
- `func find(by id: UUID) -> DataType?`

---

