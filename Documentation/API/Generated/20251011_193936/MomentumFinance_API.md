# MomentumFinance API Documentation

**Generated:** Sat Oct 11 19:39:44 CDT 2025
**Version:** 1.0.0

## Overview

This document provides comprehensive API reference for MomentumFinance.

---

## AccountDetailView.swift

**Path:** `Platforms/macOS/AccountDetailView.swift`

### Description

Account detail view optimized for macOS screen real estate

### Structs

#### `AccountDetailView`

Account detail view optimized for macOS screen real estate


---

## AccountDetailViewExport.swift

**Path:** `Platforms/macOS/AccountDetailViewExport.swift`

### Description

Export options sheet for exporting account transactions

### Structs

#### `ExportOptionsView`

Export options sheet for exporting account transactions


---

## AccountDetailViewDetails.swift

**Path:** `Platforms/macOS/AccountDetailViewDetails.swift`

### Description

Detail field component for displaying labeled values

### Structs

#### `AccountDetailField`

Detail field component for displaying labeled values


#### `AccountTypeBadge`

Account type badge for displaying account types with color coding


#### `CreditAccountDetailsView`

Credit account specific details view


---

## EnhancedAccountDetailView_Transactions.swift

**Path:** `Platforms/macOS/EnhancedAccountDetailView_Transactions.swift`

### Description

Transaction-related view components for the enhanced account detail view

### Structs

#### `TransactionRow`

Transaction-related view components for the enhanced account detail view


---

## AccountDetailViewCharts.swift

**Path:** `Platforms/macOS/AccountDetailViewCharts.swift`

### Description

Balance trend chart showing account balance over time

### Structs

#### `BalanceTrendChart`

Balance trend chart showing account balance over time


#### `SpendingBreakdownChart`

Spending breakdown chart showing category spending


---

## EnhancedAccountDetailView_Models.swift

**Path:** `Platforms/macOS/EnhancedAccountDetailView_Models.swift`

### Description

Model for editing account information

### Structs

#### `AccountEditModel`

Model for editing account information


---

## SampleDataGenerators.swift

**Path:** `Core/Models/SampleDataGenerators.swift`

### Description

Legacy data generator protocol for backward compatibility

### Protocols

#### `LegacyDataGenerator`

Legacy data generator protocol for backward compatibility

- `var modelContext: ModelContext `
- `func generate()`

---

## SampleData.swift

**Path:** `Core/Models/SampleData.swift`

### Description

Main utility class to generate sample data for the app

### Classes

#### `SampleDataGenerator`

Main utility class to generate sample data for the app


---

## DataExporter_Original.swift

**Path:** `Core/Utilities/DataExporter_Original.swift`

### Description

Slim coordinator for backward compatibility. Delegates to `ExportEngineService` for heavy lifting.

### Actors

#### `DataExporter`

Slim coordinator for backward compatibility. Delegates to `ExportEngineService` for heavy lifting.


---

## DataImporter.swift

**Path:** `Core/Utilities/DataImporter.swift`

### Description

Handles importing financial data from CSV files

### Actors

#### `DataImporter`

Handles importing financial data from CSV files


---

## DataExporter.swift

**Path:** `Core/Utilities/DataExporter.swift`

### Description

Slim coordinator for backward compatibility. Delegates to `ExportEngineService` for heavy lifting.

### Actors

#### `DataExporter`

Slim coordinator for backward compatibility. Delegates to `ExportEngineService` for heavy lifting.


---

## FinancialIntelligencePrediction.swift

**Path:** `Core/Services/FinancialIntelligencePrediction.swift`

### Description

Component containing predictive analytics methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligencePrediction`

Component containing predictive analytics methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceRisk.swift

**Path:** `Core/Services/FinancialIntelligenceRisk.swift`

### Description

Component containing risk assessment methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceRisk`

Component containing risk assessment methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceAnalysis.swift

**Path:** `Core/Services/FinancialIntelligenceAnalysis.swift`

### Description

Component containing core financial analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceAnalysis`

Component containing core financial analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceHelpers.swift

**Path:** `Core/Services/FinancialIntelligenceHelpers.swift`

### Description

Component containing utility helper methods for financial intelligence
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceHelpers`

Component containing utility helper methods for financial intelligence
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceAutoAnalysis.swift

**Path:** `Core/Services/FinancialIntelligenceAutoAnalysis.swift`

### Description

Component containing auto-analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceAutoAnalysis`

Component containing auto-analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceService.Spending.swift

**Path:** `Core/Services/FinancialIntelligenceService.Spending.swift`

### Structs

#### `BudgetAnalysisContext`


---

## FinancialAnalyticsSharedCore.swift

**Path:** `Core/Services/FinancialAnalyticsSharedCore.swift`

### Protocols

#### `FinancialAnalyticsTransactionConvertible`

- `var faAmount: Double `
- `var faDate: Date `
- `var faCategory: String `
- `var faMerchant: String? `

#### `FinancialAnalyticsAccountConvertible`

- `var faType: FinancialAnalyticsAccountKind `
- `var faBalance: Double `

#### `FinancialAnalyticsBudgetConvertible`

- `var faCategory: String `
- `var faAmount: Double `
- `var faPeriod: FinancialAnalyticsBudgetPeriod `

### Enums

#### `FinancialAnalyticsAccountKind`


#### `FinancialAnalyticsBudgetPeriod`


#### `FinancialAnalyticsSharedCore`


---

## BudgetsView.swift

**Path:** `Features/Budgets/BudgetsView.swift`

### Structs

#### `BudgetHealthCard`


#### `RiskAlertsCard`


#### `SpendingPredictionsCard`


#### `OptimizationCard`


#### `HealthIndicator`


---

## BudgetsViewModel.swift

**Path:** `Features/Budgets/BudgetsViewModel.swift`

### Description

Budget insight model for AI analysis

### Structs

#### `BudgetInsight`

Budget insight model for AI analysis


#### `SpendingPrediction`

Spending prediction model


#### `BudgetAlert`

Budget alert model


#### `BudgetProgressSummary`

Trend direction for budget analysis


#### `MonthlySpending`


#### `BudgetRolloverSummary`


### Enums

#### `TrendDirection`

Trend direction for budget analysis


---

## FinancialIntelligencePrediction.swift

**Path:** `Shared/Intelligence/FinancialIntelligencePrediction.swift`

### Description

Component containing predictive analytics methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligencePrediction`

Component containing predictive analytics methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceRisk.swift

**Path:** `Shared/Intelligence/FinancialIntelligenceRisk.swift`

### Description

Component containing risk assessment methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceRisk`

Component containing risk assessment methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceAnalysis.swift

**Path:** `Shared/Intelligence/FinancialIntelligenceAnalysis.swift`

### Description

Component containing core financial analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceAnalysis`

Component containing core financial analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceHelpers.swift

**Path:** `Shared/Intelligence/FinancialIntelligenceHelpers.swift`

### Description

Component containing utility helper methods for financial intelligence
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceHelpers`

Component containing utility helper methods for financial intelligence
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceAutoAnalysis.swift

**Path:** `Shared/Intelligence/FinancialIntelligenceAutoAnalysis.swift`

### Description

Component containing auto-analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceAutoAnalysis`

Component containing auto-analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceService.Spending.swift

**Path:** `Shared/Intelligence/FinancialIntelligenceService.Spending.swift`

### Structs

#### `BudgetAnalysisContext`


---

## FinancialAnalyticsSharedCore.swift

**Path:** `Shared/Intelligence/FinancialAnalyticsSharedCore.swift`

### Protocols

#### `FinancialAnalyticsTransactionConvertible`

- `var faAmount: Double `
- `var faDate: Date `
- `var faCategory: String `
- `var faMerchant: String? `

#### `FinancialAnalyticsAccountConvertible`

- `var faType: FinancialAnalyticsAccountKind `
- `var faBalance: Double `

#### `FinancialAnalyticsBudgetConvertible`

- `var faCategory: String `
- `var faAmount: Double `
- `var faPeriod: FinancialAnalyticsBudgetPeriod `

### Enums

#### `FinancialAnalyticsAccountKind`


#### `FinancialAnalyticsBudgetPeriod`


#### `FinancialAnalyticsSharedCore`


---

## GoalsAndReportsViewModel.swift

**Path:** `Shared/Features/GoalsAndReports/GoalsAndReportsViewModel.swift`

### Structs

#### `SpendingReport`


#### `MonthlySpendingData`


#### `CategorySpendingComparison`


#### `BudgetVsActual`


---

## BudgetsViewModel.swift

**Path:** `Shared/Features/Budgets/BudgetsViewModel.swift`

### Structs

#### `BudgetProgressSummary`


#### `MonthlySpending`


#### `BudgetRolloverSummary`


---

## SampleDataGenerators.swift

**Path:** `Shared/Models/SampleDataGenerators.swift`

### Description

Legacy data generator protocol for backward compatibility

### Protocols

#### `LegacyDataGenerator`

Legacy data generator protocol for backward compatibility

- `var modelContext: ModelContext `
- `func generate()`

---

## CategoriesGenerator.swift

**Path:** `Shared/Models/Generators/CategoriesGenerator.swift`

### Description

Protocol for data generators

### Protocols

#### `DataGenerator`

Protocol for data generators

- `var modelContext: ModelContext `
- `func generate()`

---

## SampleData.swift

**Path:** `Shared/Models/SampleData.swift`

### Description

Main utility class to generate sample data for the app

### Classes

#### `SampleDataGenerator`

Main utility class to generate sample data for the app


---

## Theme.swift

**Path:** `Shared/Theme.swift`

### Enums

#### `ColorDefinitions`


---

## DataExportView.swift

**Path:** `Shared/Views/Settings/DataExportView.swift`

### Description

Comprehensive data export view with multiple format options

### Structs

#### `ShareSheet`


#### `ShareSheet`


---

## ThemePersistence.swift

**Path:** `Shared/ThemePersistence.swift`

### Description

Handles persistent storage of theme preferences

### Enums

#### `ThemePersistence`

Handles persistent storage of theme preferences


---

## AccountDetailView.swift

**Path:** `Sources/UI/macOS/AccountDetailView.swift`

### Description

Account detail view optimized for macOS screen real estate

### Structs

#### `AccountDetailView`

Account detail view optimized for macOS screen real estate


---

## AccountDetailViewExport.swift

**Path:** `Sources/UI/macOS/AccountDetailViewExport.swift`

### Description

Export options sheet for exporting account transactions

### Structs

#### `ExportOptionsView`

Export options sheet for exporting account transactions


---

## UIIntegrationHelpers.swift

**Path:** `Sources/UI/macOS/UIIntegrationHelpers.swift`

### Structs

#### `TransactionsOverviewView`


#### `BudgetsOverviewView`


#### `SubscriptionsOverviewView`


#### `GoalsAndReportsOverviewView`


#### `WelcomeView`


---

## AccountDetailViewDetails.swift

**Path:** `Sources/UI/macOS/AccountDetailViewDetails.swift`

### Description

Detail field component for displaying labeled values

### Structs

#### `AccountDetailField`

Detail field component for displaying labeled values


#### `AccountTypeBadge`

Account type badge for displaying account types with color coding


#### `CreditAccountDetailsView`

Credit account specific details view


---

## UIEnhancements.swift

**Path:** `Sources/UI/macOS/UIEnhancements.swift`

### Structs

#### `ListableItem`


#### `ContentView_macOS`


### Enums

#### `SidebarItem`


#### `ListItemType`


#### `SortOrder`


#### `macOSSpecificViews`


---

## UIIntegration.swift

**Path:** `Sources/UI/macOS/UIIntegration.swift`

### Description

This file provides integration between the macOS three-column UI and the app's navigation system
It connects existing view models and data with the enhanced macOS interface

### Structs

#### `IntegratedMacOSContentView`

Main macOS content view with integrated navigation


#### `DashboardListView`


#### `TransactionsListView`


#### `BudgetListView`


#### `SubscriptionListView`


#### `GoalsListView`


#### `TransactionsOverviewView`


#### `BudgetsOverviewView`


#### `SubscriptionsOverviewView`


#### `GoalsAndReportsOverviewView`


#### `WelcomeView`


#### `EnhancedAccountDetailView`


#### `EnhancedGoalDetailView`


#### `EnhancedReportDetailView`


---

## UIIntegrationViews.swift

**Path:** `Sources/UI/macOS/UIIntegrationViews.swift`

### Description

Main macOS content view with integrated navigation

### Structs

#### `IntegratedMacOSContentView`

Main macOS content view with integrated navigation


---

## EnhancedAccountDetailView_Transactions.swift

**Path:** `Sources/UI/macOS/EnhancedAccountDetailView_Transactions.swift`

### Description

Transaction-related view components for the enhanced account detail view

### Structs

#### `TransactionRow`

Transaction-related view components for the enhanced account detail view


---

## AccountDetailViewCharts.swift

**Path:** `Sources/UI/macOS/AccountDetailViewCharts.swift`

### Description

Balance trend chart showing account balance over time

### Structs

#### `BalanceTrendChart`

Balance trend chart showing account balance over time


#### `SpendingBreakdownChart`

Spending breakdown chart showing category spending


---

## KeyboardShortcutManager.swift

**Path:** `Sources/UI/macOS/KeyboardShortcutManager.swift`

### Description

Manages keyboard shortcuts for the macOS version of Momentum Finance

### Classes

#### `KeyboardShortcutManager`

Manages keyboard shortcuts for the macOS version of Momentum Finance


### Structs

#### `MacOSKeyboardShortcuts`

View modifier for applying keyboard shortcuts to macOS views


#### `KeyboardShortcutHandler`

Internal helper for keyboard shortcut support


---

## MacOSUIIntegration_Placeholders.swift

**Path:** `Sources/UI/macOS/MacOSUIIntegration_Placeholders.swift`

### Structs

#### `EnhancedAccountDetailView`


#### `EnhancedGoalDetailView`


#### `EnhancedReportDetailView`


---

## ContentView_macOS.swift

**Path:** `Sources/UI/macOS/ContentView_macOS.swift`

### Structs

#### `SettingsView`


#### `GeneralSettingsView`


#### `DataSettingsView`


#### `AdvancedSettingsView`


### Enums

#### `macOSSpecificViews`


---

## EnhancedContentView_macOS.swift

**Path:** `Sources/UI/macOS/EnhancedContentView_macOS.swift`

### Structs

#### `ContentView_macOS`


#### `ListableItem`


### Enums

#### `SidebarItem`


#### `ListItemType`


#### `macOSSpecificViews`


---

## EnhancedAccountDetailView_Models.swift

**Path:** `Sources/UI/macOS/EnhancedAccountDetailView_Models.swift`

### Description

Model for editing account information

### Structs

#### `AccountEditModel`

Model for editing account information


---

## DragAndDropSupport.swift

**Path:** `Sources/UI/macOS/DragAndDropSupport.swift`

### Description

Implements drag and drop functionality for the macOS version of Momentum Finance
This enhances desktop productivity by allowing users to drag items between lists and views

### Protocols

#### `DraggableFinanceItem`

Implements drag and drop functionality for the macOS version of Momentum Finance
This enhances desktop productivity by allowing users to drag items between lists and views
Protocol for items that can be dragged in the app

- `var dragItemType: FinanceDragItemType `
- `var dragItemTitle: String `
- `var dragItemIconName: String `

### Structs

#### `FinanceItemDragPreview`


#### `DraggableFinanceItemModifier`

View modifier for making a view draggable with a finance item


#### `DroppableFinanceItemModifier`

View modifier for making a view accept drops of finance items


#### `TransactionItemView`


### Enums

#### `FinanceDragItemType`

Protocol for items that can be dragged in the app
Types of items that can be dragged in the app


---

## UIIntegrationLists.swift

**Path:** `Sources/UI/macOS/UIIntegrationLists.swift`

### Structs

#### `DashboardListView`


#### `TransactionsListView`


#### `BudgetListView`


#### `SubscriptionListView`


#### `GoalsListView`


---

## MacOS_SharedTypes.swift

**Path:** `Sources/UI/macOS/MacOS_SharedTypes.swift`

### Structs

#### `ListableItem`


### Enums

#### `SidebarItem`


#### `ListItemType`


#### `SortOrder`


#### `macOSSpecificViews`


---

## ContentView.swift

**Path:** `Sources/UI/iOS/ContentView.swift`

### Enums

#### `iOSSpecificViews`


---

## FinancialIntelligencePrediction.swift

**Path:** `Sources/Core/Intelligence/FinancialIntelligencePrediction.swift`

### Description

Component containing predictive analytics methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligencePrediction`

Component containing predictive analytics methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceRisk.swift

**Path:** `Sources/Core/Intelligence/FinancialIntelligenceRisk.swift`

### Description

Component containing risk assessment methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceRisk`

Component containing risk assessment methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceAnalysis.swift

**Path:** `Sources/Core/Intelligence/FinancialIntelligenceAnalysis.swift`

### Description

Component containing core financial analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceAnalysis`

Component containing core financial analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceHelpers.swift

**Path:** `Sources/Core/Intelligence/FinancialIntelligenceHelpers.swift`

### Description

Component containing utility helper methods for financial intelligence
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceHelpers`

Component containing utility helper methods for financial intelligence
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceAutoAnalysis.swift

**Path:** `Sources/Core/Intelligence/FinancialIntelligenceAutoAnalysis.swift`

### Description

Component containing auto-analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits

### Structs

#### `FinancialIntelligenceAutoAnalysis`

Component containing auto-analysis methods
Extracted from AdvancedFinancialIntelligence to maintain file size limits


---

## FinancialIntelligenceService.Spending.swift

**Path:** `Sources/Core/Intelligence/FinancialIntelligenceService.Spending.swift`

### Structs

#### `BudgetAnalysisContext`


---

## FinancialAnalyticsSharedCore.swift

**Path:** `Sources/Core/Intelligence/FinancialAnalyticsSharedCore.swift`

### Protocols

#### `FinancialAnalyticsTransactionConvertible`

- `var faAmount: Double `
- `var faDate: Date `
- `var faCategory: String `
- `var faMerchant: String? `

#### `FinancialAnalyticsAccountConvertible`

- `var faType: FinancialAnalyticsAccountKind `
- `var faBalance: Double `

#### `FinancialAnalyticsBudgetConvertible`

- `var faCategory: String `
- `var faAmount: Double `
- `var faPeriod: FinancialAnalyticsBudgetPeriod `

### Enums

#### `FinancialAnalyticsAccountKind`


#### `FinancialAnalyticsBudgetPeriod`


#### `FinancialAnalyticsSharedCore`


---

## GoalsAndReportsViewModel.swift

**Path:** `Sources/Core/Features/GoalsAndReports/GoalsAndReportsViewModel.swift`

### Structs

#### `SpendingReport`


#### `MonthlySpendingData`


#### `CategorySpendingComparison`


#### `BudgetVsActual`


---

## EnhancedDetailViews_TransactionDetail.swift

**Path:** `Sources/Core/Features/Transactions/EnhancedDetailViews_TransactionDetail.swift`

### Description

Enhanced transaction detail view optimized for macOS screen space

### Structs

#### `TransactionDetailContent`

Enhanced transaction detail view optimized for macOS screen space


---

## EnhancedDetailViews_Charts.swift

**Path:** `Sources/Core/Features/Transactions/EnhancedDetailViews_Charts.swift`

### Description

Chart showing spending trends for a specific category

### Structs

#### `CategorySpendingChart`

Chart showing spending trends for a specific category


#### `MerchantSpendingChart`

Chart showing spending patterns for a specific merchant


---

## EnhancedDetailViews_EditView.swift

**Path:** `Sources/Core/Features/Transactions/EnhancedDetailViews_EditView.swift`

### Description

Edit view component for transaction details

### Structs

#### `EnhancedTransactionDetailEditView`

Edit view component for transaction details


#### `TransactionEditModel`

Model for editing transaction data


---

## EnhancedDetailViews_Helpers.swift

**Path:** `Sources/Core/Features/Transactions/EnhancedDetailViews_Helpers.swift`

### Description

Detail field component for displaying labeled values

### Structs

#### `DetailField`

Detail field component for displaying labeled values


#### `CategoryTag`

Category tag component with color coding


#### `BudgetImpactView`

Budget impact view showing spending against budget


#### `ExportOptionsView`

Export options view for transaction export


#### `RelatedTransactionsView`

Related transactions view


---

## EnhancedDetailViews_Actions.swift

**Path:** `Sources/Core/Features/Transactions/EnhancedDetailViews_Actions.swift`

### Description

Action methods for transaction detail operations

### Structs

#### `TransactionDetailActions`

Action methods for transaction detail operations


---

## BudgetsViewModel.swift

**Path:** `Sources/Core/Features/Budgets/BudgetsViewModel.swift`

### Structs

#### `BudgetProgressSummary`


#### `MonthlySpending`


#### `BudgetRolloverSummary`


---

## DataExporter_Original.swift

**Path:** `Sources/Core/Utils/DataExporter_Original.swift`

### Description

Slim coordinator for backward compatibility. Delegates to `ExportEngineService` for heavy lifting.

### Actors

#### `DataExporter`

Slim coordinator for backward compatibility. Delegates to `ExportEngineService` for heavy lifting.


---

## CSVParser.swift

**Path:** `Sources/Core/Utils/ImportComponents/CSVParser.swift`

### Description

Handles CSV parsing and column mapping functionality

### Structs

#### `CSVColumnMapping`

Maps CSV column headers to their respective indices


### Enums

#### `CSVParser`

Handles CSV parsing and column mapping functionality


---

## ImportValidator.swift

**Path:** `Sources/Core/Utils/ImportComponents/ImportValidator.swift`

### Description

Handles validation and duplicate detection for imported data

### Structs

#### `ImportValidator`

Handles validation and duplicate detection for imported data


---

## DataParser.swift

**Path:** `Sources/Core/Utils/ImportComponents/DataParser.swift`

### Description

Handles parsing and validation of financial data from CSV fields

### Enums

#### `DataParser`

Handles parsing and validation of financial data from CSV fields


---

## EntityManager.swift

**Path:** `Sources/Core/Utils/ImportComponents/EntityManager.swift`

### Description

Manages creation and retrieval of financial entities during import

### Structs

#### `EntityManager`

Manages creation and retrieval of financial entities during import


---

## DataImporter.swift

**Path:** `Sources/Core/Utils/DataImporter.swift`

### Description

Handles importing financial data from CSV files

### Actors

#### `DataImporter`

Handles importing financial data from CSV files


---

## DataExporter.swift

**Path:** `Sources/Core/Utils/DataExporter.swift`

### Description

Slim coordinator for backward compatibility. Delegates to `ExportEngineService` for heavy lifting.

### Actors

#### `DataExporter`

Slim coordinator for backward compatibility. Delegates to `ExportEngineService` for heavy lifting.


---

## SampleDataGenerators.swift

**Path:** `Sources/Core/Models/SampleDataGenerators.swift`

### Description

Legacy data generator protocol for backward compatibility

### Protocols

#### `LegacyDataGenerator`

Legacy data generator protocol for backward compatibility

- `var modelContext: ModelContext `
- `func generate()`

---

## CategoriesGenerator.swift

**Path:** `Sources/Core/Models/Generators/CategoriesGenerator.swift`

### Description

Protocol for data generators

### Protocols

#### `DataGenerator`

Protocol for data generators

- `var modelContext: ModelContext `
- `func generate()`

---

## SampleData.swift

**Path:** `Sources/Core/Models/SampleData.swift`

### Description

Main utility class to generate sample data for the app

### Classes

#### `SampleDataGenerator`

Main utility class to generate sample data for the app


---

## ImportDataView.swift

**Path:** `Sources/Core/Components/Settings/ImportDataView.swift`

### Classes

#### `DocumentPickerDelegate`


---

## ColorDefinitions.swift

**Path:** `Sources/Core/Theme/ColorComponents/ColorDefinitions.swift`

### Description

Static color definitions for light and dark theme schemes

### Enums

#### `ColorDefinitions`

Static color definitions for light and dark theme schemes


---

## ColorThemePreview.swift

**Path:** `Sources/Core/Theme/ColorComponents/ColorThemePreview.swift`

### Description

Preview component for testing and visualizing color theme variations

### Structs

#### `ColorThemePreview`

Preview component for testing and visualizing color theme variations


---

## ThemePersistence.swift

**Path:** `Sources/Core/Theme/ThemePersistence.swift`

### Description

Handles persistent storage of theme preferences

### Enums

#### `ThemePersistence`

Handles persistent storage of theme preferences


---

## Theme.swift

**Path:** `Sources/Core/Theme.swift`

### Enums

#### `ColorDefinitions`


---

## DataExportView.swift

**Path:** `Sources/Core/Views/Settings/DataExportView.swift`

### Description

Comprehensive data export view with multiple format options

### Structs

#### `ShareSheet`


#### `ShareSheet`


---

## BudgetsViewModel.swift

**Path:** `Sources/Core/BudgetsViewModel.swift`

### Structs

#### `BudgetProgressSummary`


#### `MonthlySpending`


#### `BudgetRolloverSummary`


---

## AnimatedComponents.swift

**Path:** `Sources/Core/Animations/AnimatedComponents.swift`

### Description

Interactive card component with press animations

### Enums

#### `AnimationComponents`

Progress indicators with shine effects and counters
Floating action button with sophisticated entrance animations


---

## TestModels.swift

**Path:** `TestModels.swift`

### Structs

#### `Transaction`


#### `FinancialAccount`


#### `FinancialTransaction`


#### `ExpenseCategory`


### Enums

#### `TransactionType`


#### `AccountType`


#### `TransactionType2`


---

## run_tests.swift

**Path:** `run_tests.swift`

### Structs

#### `Transaction`


#### `FinancialAccount`


#### `FinancialTransaction`


#### `ExpenseCategory`


### Enums

#### `TransactionType`


#### `AccountType`


#### `TransactionType2`


---

