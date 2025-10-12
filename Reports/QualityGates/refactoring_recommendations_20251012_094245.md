# File Size Refactoring Recommendations

## Strategy for Breaking Down Large Files

### 1. **Extract Related Types**
Large files often contain multiple types that can be separated:
- Move structs/enums to their own files
- Group related extensions together
- Separate protocols and their conformances

### 2. **Feature-Based Organization**
```
OriginalLargeFile.swift (1000+ lines)
├── OriginalLargeFile+CoreLogic.swift
├── OriginalLargeFile+UI.swift
├── OriginalLargeFile+Networking.swift
└── OriginalLargeFile+Models.swift
```

### 3. **Protocol-Oriented Design**
- Extract protocols to separate files
- Move implementations to extensions
- Create protocol composition for complex behaviors

### 4. **MVVM Pattern Enhancement**
```
Feature/
├── FeatureView.swift           (UI only, ~150 lines)
├── FeatureViewModel.swift      (Business logic, ~200 lines)
├── FeatureModels.swift         (Data structures, ~100 lines)
└── FeatureServices.swift       (External dependencies, ~150 lines)
```

## Automated Refactoring Checklist

- [ ] Identify logical boundaries in large files
- [ ] Extract reusable components
- [ ] Move view-related code to separate files
- [ ] Separate data models from view models
- [ ] Extract utility functions to shared modules
- [ ] Split large classes using partial class pattern (extensions)

## Priority Files for Refactoring

### Top 20 Largest Files

- **Projects/PlannerApp/CloudKit/CloudKitManager.swift** (    1513 lines)
- **Projects/MomentumFinance/Sources/UI/macOS/UIEnhancements.swift** (    1342 lines)
- **Projects/MomentumFinance/Sources/UI/macOS/AccountDetailView.swift** (    1309 lines)
- **Projects/MomentumFinance/Platforms/macOS/AccountDetailView.swift** (    1309 lines)
- **Projects/MomentumFinance/Sources/UI/macOS/SubscriptionDetailView.swift** (    1305 lines)
- **Projects/MomentumFinance/Sources/UI/macOS/UIIntegration.swift** (    1250 lines)
- **Projects/HabitQuest/HabitQuest/Core/Services/OllamaIntegrationManager.swift** (    1197 lines)
- **Projects/MomentumFinance/Sources/UI/macOS/EnhancedDetailViews.swift** (    1101 lines)
- **Projects/AvoidObstaclesGame/AvoidObstaclesGame/Services/PlayerAnalyticsAI.swift** (    1007 lines)
- **Projects/PlannerApp/Core/OllamaIntegrationManager.swift** (     950 lines)
- **Projects/CodingReviewer/Sources/Core/OllamaIntegrationManager.swift** (     950 lines)
- **Projects/AvoidObstaclesGame/AvoidObstaclesGame/OllamaIntegrationManager.swift** (     950 lines)
- **Projects/PlannerApp/PlannerAppTests/PlannerAppTests.swift** (     886 lines)
- **Projects/HabitQuest/HabitQuest/Core/Views/AIHabitInsightsView.swift** (     879 lines)
- **Projects/HabitQuest/HabitQuest/Core/Services/HuggingFaceClient.swift** (     871 lines)
- **Projects/MomentumFinance/Sources/Core/Intelligence/AdvancedFinancialIntelligence.swift** (     841 lines)
- **Projects/MomentumFinance/Shared/Intelligence/AdvancedFinancialIntelligence.swift** (     841 lines)
- **Projects/MomentumFinance/Core/Services/AdvancedFinancialIntelligence.swift** (     841 lines)
- **Projects/AvoidObstaclesGame/AvoidObstaclesGame/HuggingFaceClient.swift** (     841 lines)
- **Projects/MomentumFinance/Sources/UI/macOS/BudgetDetailView.swift** (     826 lines)
