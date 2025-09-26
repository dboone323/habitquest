# MomentumFinance API Documentation

Generated: Wed Sep 24 09:04:08 CDT 2025
Project: MomentumFinance
Location: /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance

## Overview

This document contains the public API reference for MomentumFinance.

## Classes and Structs

### EnhancedAccountDetailView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/EnhancedAccountDetailView.swift`

### MacOSUIIntegration

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/MacOSUIIntegration.swift`

### EnhancedSubscriptionDetailView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/EnhancedSubscriptionDetailView.swift`

### MacOS_UI_Enhancements

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/MacOS_UI_Enhancements.swift`

### UpdatedMomentumFinanceApp

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/UpdatedMomentumFinanceApp.swift`

#### Public Types

- **public struct MomentumFinanceApp: App {** (line 21)

### EnhancedBudgetDetailView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/EnhancedBudgetDetailView.swift`

### KeyboardShortcutManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/KeyboardShortcutManager.swift`

### ContentView_macOS

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/ContentView_macOS.swift`

### EnhancedContentView_macOS

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/EnhancedContentView_macOS.swift`

### EnhancedDetailViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/EnhancedDetailViews.swift`

### DragAndDropSupport

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/macOS/DragAndDropSupport.swift`

### PerformanceManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/PerformanceManager.swift`

#### Public Types

- **public class PerformanceManager {** (line 10)

#### Public Functions

- `recordFrame() {` (line 19)
- `getCurrentFPS() -> Double {` (line 29)
- `getMemoryUsage() -> Double {` (line 44)
- `isPerformanceDegraded() -> Bool {` (line 62)

### test_models

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/test_models.swift`

### Dependencies

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Dependencies.swift`

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

### test_minimal_app

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/test_minimal_app.swift`

#### Public Types

- **public struct TestApp: App {** (line 6)

### AccountUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceUITests/AccountUITests.swift`

### BudgetUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceUITests/BudgetUITests.swift`

### TransactionUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceUITests/TransactionUITests.swift`

### MomentumFinanceUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceUITests/MomentumFinanceUITests.swift`

### BudgetsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/BudgetsViewTests.swift`

### ColorDefinitionsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ColorDefinitionsTests.swift`

### SecuritySettingsSectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SecuritySettingsSectionTests.swift`

### AccountsGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AccountsGeneratorTests.swift`

### TransactionComponentStubsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionComponentStubsTests.swift`

### ImportValidatorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportValidatorTests.swift`

### DataImporterErrorTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataImporterErrorTestsTests.swift`

### CSVParserEdgeCasesTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/CSVParserEdgeCasesTestsTests.swift`

### MacOSUIIntegrationTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MacOSUIIntegrationTests.swift`

### NotificationModelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/NotificationModelsTests.swift`

### EnhancedSubscriptionDetailViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/EnhancedSubscriptionDetailViewTests.swift`

### ThemeEnumsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeEnumsTests.swift`

### DependenciesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DependenciesTests.swift`

### SubscriptionRowViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SubscriptionRowViewsTests.swift`

### FinancialIntelligenceAnalysisTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialIntelligenceAnalysisTests.swift`

### CSVMappingTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/CSVMappingTests.swift`

### NotificationsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/NotificationsViewTests.swift`

### SubscriptionsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SubscriptionsViewTests.swift`

### ColorExtensionsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ColorExtensionsTests.swift`

### ForecastDataTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ForecastDataTests.swift`

### DragAndDropSupportTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DragAndDropSupportTests.swift`

### AccountDetailViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AccountDetailViewTests.swift`

### FinancialMLModelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialMLModelsTests.swift`

### test_crash_debugTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/test_crash_debugTests.swift`

### DashboardViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardViewModelTests.swift`

### ThemePersistenceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemePersistenceTests.swift`

### InsightsWidgetTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightsWidgetTests.swift`

### DataImportHeaderComponentTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataImportHeaderComponentTests.swift`

### PackageTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/PackageTests.swift`

### BudgetRecommendationsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/BudgetRecommendationsTests.swift`

### SearchTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SearchTypesTests.swift`

### DashboardInsightsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardInsightsTests.swift`

### TransactionsGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionsGeneratorTests.swift`

### GoalsAndReportsViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/GoalsAndReportsViewModelTests.swift`

### ColorThemePreviewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ColorThemePreviewTests.swift`

### CategoryTransactionsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/CategoryTransactionsViewTests.swift`

### ThemeManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeManagerTests.swift`

### ThemeComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeComponentsTests.swift`

### TransactionComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionComponentsTests.swift`

### SimpleTransactionRowTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SimpleTransactionRowTests.swift`

### NavigationCoordinatorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/NavigationCoordinatorTests.swift`

### SimpleTransactionSectionHeaderTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SimpleTransactionSectionHeaderTests.swift`

### SavingsGoalViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SavingsGoalViewsTests.swift`

### ImportErrorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportErrorTests.swift`

### DashboardSubscriptionsSectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardSubscriptionsSectionTests.swift`

### NotificationTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/NotificationTypesTests.swift`

### TransactionPatternAnalyzerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionPatternAnalyzerTests.swift`

### SavingsGoalTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SavingsGoalTests.swift`

### AppearanceSettingsSectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AppearanceSettingsSectionTests.swift`

### MissingTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MissingTypesTests.swift`

### TransactionDetailViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionDetailViewTests.swift`

### ThemeModelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeModelsTests.swift`

### ButtonStylesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ButtonStylesTests.swift`

### ImportExportTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportExportTests.swift`

### NotificationCenterViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/NotificationCenterViewTests.swift`

### ThemeDemoComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeDemoComponentsTests.swift`

### PerformanceManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/PerformanceManagerTests.swift`

### MomentumFinanceAppTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MomentumFinanceAppTests.swift`

### EnhancedAccountDetailViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/EnhancedAccountDetailViewTests.swift`

### CoreFinancialModelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/CoreFinancialModelsTests.swift`

### UpdatedMomentumFinanceAppTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/UpdatedMomentumFinanceAppTests.swift`

### ContentView_iOSTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ContentView_iOSTests.swift`

### EnhancedDetailViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/EnhancedDetailViewsTests.swift`

### FinancialIntelligenceService.ForecastingTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialIntelligenceService.ForecastingTests.swift`

### MomentumFinanceUITestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MomentumFinanceUITestsTests.swift`

### test_minimal_appTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/test_minimal_appTests.swift`

### SampleDataTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SampleDataTests.swift`

### ImportButtonComponentTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportButtonComponentTests.swift`

### SampleDataGeneratorsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SampleDataGeneratorsTests.swift`

### FinancialIntelligenceModelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialIntelligenceModelsTests.swift`

### ContentView_macOSTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ContentView_macOSTests.swift`

### AnimationManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AnimationManagerTests.swift`

### FinancialTransactionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialTransactionTests.swift`

### regenerate_projectTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/regenerate_projectTests.swift`

### TransactionModelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionModelsTests.swift`

### FinancialIntelligenceService.HelpersTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialIntelligenceService.HelpersTests.swift`

### DataImportViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataImportViewTests.swift`

### InsightsSummaryWidgetTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightsSummaryWidgetTests.swift`

### ThemeSettingsComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeSettingsComponentsTests.swift`

### SearchHeaderComponentTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SearchHeaderComponentTests.swift`

### ContentViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ContentViewTests.swift`

### ExportDataViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ExportDataViewTests.swift`

### BudgetUITestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/BudgetUITestsTests.swift`

### DashboardViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardViewTests.swift`

### ThemeDemoPlaceholdersTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeDemoPlaceholdersTests.swift`

### test_modelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/test_modelsTests.swift`

### SettingsTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SettingsTypesTests.swift`

### DataImportHelpersTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataImportHelpersTests.swift`

### FinancialForecastingTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialForecastingTests.swift`

### DashboardAccountsSummaryTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardAccountsSummaryTests.swift`

### MacOS_UI_EnhancementsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MacOS_UI_EnhancementsTests.swift`

### AboutSectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AboutSectionTests.swift`

### AppLoggerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AppLoggerTests.swift`

### OptimizationSuggestionsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/OptimizationSuggestionsTests.swift`

### FormattingUtilitiesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FormattingUtilitiesTests.swift`

### BreadcrumbNavigationTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/BreadcrumbNavigationTests.swift`

### TransactionFilterTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionFilterTests.swift`

### TransactionEmptyStateViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionEmptyStateViewTests.swift`

### TransactionsHeaderSectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionsHeaderSectionTests.swift`

### SimpleDashboardViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SimpleDashboardViewTests.swift`

### DataManagementSectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataManagementSectionTests.swift`

### BudgetsViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/BudgetsViewModelTests.swift`

### TransactionListViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionListViewTests.swift`

### CoreExportsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/CoreExportsTests.swift`

### ThemeDemoViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeDemoViewTests.swift`

### InsightsLoadingViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightsLoadingViewTests.swift`

### QueryFallbackTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/QueryFallbackTests.swift`

### InsightsComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightsComponentsTests.swift`

### EnhancedContentView_macOSTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/EnhancedContentView_macOSTests.swift`

### FinancialIntelligenceService.SpendingTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialIntelligenceService.SpendingTests.swift`

### InsightsEmptyStateViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightsEmptyStateViewTests.swift`

### ThemeSettingsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeSettingsViewTests.swift`

### FinancialUtilitiesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialUtilitiesTests.swift`

### EnhancedBudgetDetailViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/EnhancedBudgetDetailViewTests.swift`

### SavingsGoalsGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SavingsGoalsGeneratorTests.swift`

### AnomalyDetectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AnomalyDetectionTests.swift`

### TransactionUITestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionUITestsTests.swift`

### FinancialIntelligenceService.BudgetsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialIntelligenceService.BudgetsTests.swift`

### TransactionStatsCardTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionStatsCardTests.swift`

### AnimationTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AnimationTypesTests.swift`

### NotificationManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/NotificationManagerTests.swift`

### SearchEngineServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SearchEngineServiceTests.swift`

### FeaturesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FeaturesTests.swift`

### InsightRowViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightRowViewTests.swift`

### ThemeComponentStubsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeComponentStubsTests.swift`

### DataExporterDateRangeTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataExporterDateRangeTestsTests.swift`

### DataImporterTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataImporterTests.swift`

### AddTransactionViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AddTransactionViewTests.swift`

### SectionHeaderTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SectionHeaderTests.swift`

### ThemeDemoPublicWrappersTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeDemoPublicWrappersTests.swift`

### SubscriptionsViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SubscriptionsViewModelTests.swift`

### CSVParserTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/CSVParserTests.swift`

### ColorTheme+ConvenienceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ColorTheme+ConvenienceTests.swift`

### LoggerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/LoggerTests.swift`

### TemporaryImportNotificationStubsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TemporaryImportNotificationStubsTests.swift`

### ComplexDataGeneratorsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ComplexDataGeneratorsTests.swift`

### KeyboardShortcutManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/KeyboardShortcutManagerTests.swift`

### DataImportModelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataImportModelsTests.swift`

### DashboardComponentStubsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardComponentStubsTests.swift`

### AccountUITestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AccountUITestsTests.swift`

### AdvancedFinancialIntelligenceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AdvancedFinancialIntelligenceTests.swift`

### FinancialIntelligenceService.OptimizationsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialIntelligenceService.OptimizationsTests.swift`

### FinancialSummaryCardTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialSummaryCardTests.swift`

### FinancialTransactionModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MomentumFinanceTests/FinancialTransactionModelTests.swift`

### MomentumFinanceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MomentumFinanceTests/MomentumFinanceTests.swift`

### FinancialAccountModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MomentumFinanceTests/FinancialAccountModelTests.swift`

### TransactionModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MomentumFinanceTests/TransactionModelTests.swift`

### ExpenseCategoryModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MomentumFinanceTests/ExpenseCategoryModelTests.swift`

### create_xcode_projectTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/create_xcode_projectTests.swift`

### FileSelectionComponentTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FileSelectionComponentTests.swift`

### FinancialServicesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialServicesTests.swift`

### NavigationModelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/NavigationModelsTests.swift`

### NavigationTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/NavigationTypesTests.swift`

### AccountsListViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AccountsListViewTests.swift`

### DataImportComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataImportComponentsTests.swift`

### run_testsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/run_testsTests.swift`

### InsightDetailViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightDetailViewTests.swift`

### ErrorHandlerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ErrorHandlerTests.swift`

### FinancialMLStubsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialMLStubsTests.swift`

### MacOSNavigationTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MacOSNavigationTypesTests.swift`

### CSVParserTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/CSVParserTestsTests.swift`

### InsightsModelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightsModelsTests.swift`

### AccessibilitySettingsSectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AccessibilitySettingsSectionTests.swift`

### TransactionsComponentStubsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionsComponentStubsTests.swift`

### ImportProgressComponentTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportProgressComponentTests.swift`

### SettingsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SettingsViewTests.swift`

### CoreImportsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/CoreImportsTests.swift`

### FinancialIntelligenceService.AnomalyTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialIntelligenceService.AnomalyTests.swift`

### DashboardComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardComponentsTests.swift`

### EnhancedReportsSectionViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/EnhancedReportsSectionViewsTests.swift`

### InsightsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightsViewTests.swift`

### HapticManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/HapticManagerTests.swift`

### DarkModePreferenceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DarkModePreferenceTests.swift`

### InsightsFilterBarTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightsFilterBarTests.swift`

### TransactionsViewModelTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionsViewModelTests.swift`

### EnhancedDashboardViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/EnhancedDashboardViewTests.swift`

### ReportsViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ReportsViewsTests.swift`

### SettingsSectionStubsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SettingsSectionStubsTests.swift`

### DataExporterContentTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataExporterContentTestsTests.swift`

### BudgetTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/BudgetTests.swift`

### AnimatedComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AnimatedComponentsTests.swift`

### SubscriptionSummaryViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SubscriptionSummaryViewsTests.swift`

### BudgetsGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/BudgetsGeneratorTests.swift`

### GlobalSearchViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/GlobalSearchViewTests.swift`

### CategoriesGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/CategoriesGeneratorTests.swift`

### ExportTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ExportTypesTests.swift`

### DashboardWelcomeHeaderTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardWelcomeHeaderTests.swift`

### ImportExportSectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportExportSectionTests.swift`

### TransactionRowViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionRowViewTests.swift`

### SearchResultsComponentTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SearchResultsComponentTests.swift`

### DataExporter_OriginalTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataExporter_OriginalTests.swift`

### DataExporter_SimplifiedTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataExporter_SimplifiedTests.swift`

### ImportResultViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportResultViewTests.swift`

### SavingsGoalManagementViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SavingsGoalManagementViewsTests.swift`

### GoalUtilityViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/GoalUtilityViewsTests.swift`

### EnhancedGoalsSectionViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/EnhancedGoalsSectionViewsTests.swift`

### DataExporterTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataExporterTests.swift`

### GoalsAndReportsView_NewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/GoalsAndReportsView_NewTests.swift`

### EntityManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/EntityManagerTests.swift`

### CategoryTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/CategoryTests.swift`

### MomentumFinanceTypesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/MomentumFinanceTypesTests.swift`

### TransactionFiltersTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionFiltersTests.swift`

### SubscriptionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SubscriptionTests.swift`

### SampleDataProvidersTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SampleDataProvidersTests.swift`

### SearchAndFilterSectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SearchAndFilterSectionTests.swift`

### AnimationComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/AnimationComponentsTests.swift`

### DashboardUpcomingSubscriptionsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardUpcomingSubscriptionsTests.swift`

### FinancialInsightModelsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialInsightModelsTests.swift`

### FinancialAccountTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialAccountTests.swift`

### SubscriptionsView_NewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SubscriptionsView_NewTests.swift`

### ThemeTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ThemeTests.swift`

### DataExportViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataExportViewTests.swift`

### ColorThemeTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ColorThemeTests.swift`

### ImportDataViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportDataViewTests.swift`

### TransactionPatternDetectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionPatternDetectionTests.swift`

### SubscriptionDetailViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SubscriptionDetailViewTests.swift`

### TransactionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionTests.swift`

### TabSectionTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TabSectionTests.swift`

### ImportComponentsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportComponentsTests.swift`

### DashboardQuickActionsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardQuickActionsTests.swift`

### ExpenseCategoryTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ExpenseCategoryTests.swift`

### DashboardBudgetProgressTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DashboardBudgetProgressTests.swift`

### TransactionsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/TransactionsViewTests.swift`

### GoalsAndReportsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/GoalsAndReportsViewTests.swift`

### DataParserTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/DataParserTests.swift`

### SubscriptionManagementViewsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SubscriptionManagementViewsTests.swift`

### ImportInstructionsComponentTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportInstructionsComponentTests.swift`

### FinancialIntelligenceServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/FinancialIntelligenceServiceTests.swift`

### ExportEngineServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ExportEngineServiceTests.swift`

### ImportResultComponentTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/ImportResultComponentTests.swift`

### SwiftDataCompatTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/SwiftDataCompatTests.swift`

### InsightUIStubsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Tests/InsightUIStubsTests.swift`

### SearchEngineService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/SearchEngineService.swift`

#### Public Functions

- `setModelContext(_ context: ModelContext) {` (line 21)
- `search(query: String, filter: SearchFilter) -> [SearchResult] {` (line 30)

### FinancialInsightModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/FinancialInsightModels.swift`

#### Public Types

- **public struct FinancialInsightModels {** (line 6)
- **public enum RiskLevel: String, CaseIterable, Identifiable {** (line 13)
- **public enum InsightPriority: String, CaseIterable, Comparable, Identifiable {** (line 63)
- **public enum InsightType: String, CaseIterable, Identifiable {** (line 118)
- **public enum InsightCategory: String, CaseIterable, Identifiable {** (line 174)
- **public enum AIConfidenceLevel: String, CaseIterable {** (line 278)
- **public enum VisualizationType: String, CaseIterable {** (line 319)
- **public enum FinancialAnalysisType: String, CaseIterable {** (line 346)

#### Public Properties

- `var id: String { rawValue }` (line 21)
- `var color: Color {` (line 24)
- `var icon: String {` (line 36)
- `var score: Double {` (line 48)
- `var id: String { rawValue }` (line 69)
- `var color: Color {` (line 72)
- `var icon: String {` (line 82)
- `var urgencyScore: Int {` (line 92)
- `var id: String { rawValue }` (line 135)
- `var icon: String {` (line 138)
- `var category: InsightCategory {` (line 159)
- `var id: String { rawValue }` (line 182)
- `var displayName: String {` (line 184)
- `var icon: String {` (line 195)
- `var id: UUID` (line 212)
- `var title: String` (line 213)
- `var insightDescription: String // Renamed from description to avoid SwiftData conflict` (line 214)
- `var priority: InsightPriority` (line 215)
- `var type: InsightType` (line 216)
- `var confidence: Double // 0.0 to 1.0` (line 217)
- `var createdAt: Date` (line 218)
- `var isRead: Bool` (line 219)
- `var relatedAccountId: String?` (line 220)
- `var relatedTransactionId: String?` (line 221)
- `var relatedCategoryId: String?` (line 222)
- `var relatedBudgetId: String?` (line 223)
- `var actionTaken: Bool` (line 224)
- `var impactScore: Double // 0.0 to 10.0 - measures potential financial impact` (line 227)
- `var actionRecommendations: [String] // AI-generated action items` (line 228)
- `var potentialSavings: Double? // Estimated savings if action is taken` (line 229)
- `var riskLevel: RiskLevel // Associated risk level` (line 230)
- `var aiAnalysisVersion: String // Version of AI model used for analysis` (line 231)
- `var contextualTags: [String] // Tags for better categorization` (line 232)
- `var followUpDate: Date? // When to follow up on this insight` (line 233)
- `var isUserFeedbackPositive: Bool? // User feedback for ML improvement` (line 234)
- `var range: ClosedRange<Double> {` (line 285)
- `var displayName: String {` (line 295)
- `var color: Color {` (line 305)
- `var displayName: String {` (line 329)
- `var displayName: String {` (line 356)

### FinancialInsightModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialInsightModels.swift`

#### Public Types

- **public enum FinancialInsightType: String, CaseIterable, Identifiable, Hashable {** (line 4)
- **public struct FinancialInsight: Identifiable, Hashable {** (line 22)

#### Public Properties

- `var id: String { rawValue }` (line 7)
- `var icon: String {` (line 8)
- `let id = UUID()` (line 23)
- `let type: FinancialInsightType` (line 24)
- `let title: String` (line 25)
- `let description: String` (line 26)
- `let priority: Int` (line 27)
- `let createdAt: Date` (line 28)

### FinancialIntelligenceService.Budgets

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialIntelligenceService.Budgets.swift`

### FinancialIntelligenceService.Forecasting

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialIntelligenceService.Forecasting.swift`

### FinancialIntelligenceService.Anomaly

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialIntelligenceService.Anomaly.swift`

### FinancialMLStubs

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialMLStubs.swift`

### FinancialMLModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialMLModels.swift`

### FinancialIntelligenceService.Helpers

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialIntelligenceService.Helpers.swift`

### AdvancedFinancialIntelligence

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/AdvancedFinancialIntelligence.swift`

#### Public Types

- **public class AdvancedFinancialIntelligence: ObservableObject {** (line 16)
- **public enum BudgetPeriod {** (line 570)
- **public struct Investment {** (line 574)
- **public enum RiskTolerance {** (line 580)
- **public enum TimeHorizon {** (line 584)

#### Public Functions

- `generateInsights(` (line 41)
- `getInvestmentRecommendations(` (line 77)
- `predictCashFlow(` (line 90)
- `detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {` (line 101)

#### Public Properties

- `let id = UUID()` (line 401)
- `let title: String` (line 402)
- `let description: String` (line 403)
- `let priority: InsightPriority` (line 404)
- `let type: InsightType` (line 405)
- `let confidence: Double` (line 406)
- `let relatedAccountId: String?` (line 407)
- `let relatedTransactionId: String?` (line 408)
- `let relatedCategoryId: String?` (line 409)
- `let relatedBudgetId: String?` (line 410)
- `let actionRecommendations: [String]` (line 411)
- `let potentialSavings: Double?` (line 412)
- `let impactScore: Double // 0-10 scale` (line 413)
- `let createdAt: Date` (line 414)

### FinancialIntelligenceService.Optimizations

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialIntelligenceService.Optimizations.swift`

### InsightsModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/InsightsModels.swift`

### TransactionPatternAnalyzer

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/TransactionPatternAnalyzer.swift`

### FinancialIntelligenceService.Spending

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialIntelligenceService.Spending.swift`

### FinancialForecasting

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/Helpers/FinancialForecasting.swift`

### OptimizationSuggestions

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/Helpers/OptimizationSuggestions.swift`

### AnomalyDetection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/Helpers/AnomalyDetection.swift`

### TransactionPatternDetection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/Helpers/TransactionPatternDetection.swift`

### BudgetRecommendations

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/Helpers/BudgetRecommendations.swift`

### FormattingUtilities

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/Helpers/FormattingUtilities.swift`

### FinancialIntelligenceService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialIntelligenceService.swift`

#### Public Types

- **public class FinancialIntelligenceService: ObservableObject {** (line 18)

### SearchTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/SearchTypes.swift`

#### Public Types

- **public enum SearchFilter: String, CaseIterable, Hashable {** (line 6)
- **public struct SearchResult: Identifiable, Hashable {** (line 14)
- **public enum SearchConfiguration {** (line 46)

#### Public Functions

- `hash(into hasher: inout Hasher) {` (line 36)

#### Public Properties

- `let id: String` (line 15)
- `let title: String` (line 16)
- `let subtitle: String?` (line 17)
- `let type: SearchFilter` (line 18)
- `let iconName: String` (line 19)
- `let data: Any?` (line 20)
- `let relevanceScore: Double` (line 21)

### InsightUIStubs

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Insights/InsightUIStubs.swift`

### InsightsFilterBar

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Insights/InsightsFilterBar.swift`

### NotificationCenterView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/NotificationCenterView.swift`

#### Public Types

- **public struct NotificationCenterView: View {** (line 15)
- **public struct EmptyNotificationsView: View {** (line 99)
- **public struct ScheduledNotificationRow: View {** (line 122)

### FinancialSummaryCard

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/FinancialSummaryCard.swift`

### EnhancedReportsSectionViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/EnhancedReportsSectionViews.swift`

### GoalsAndReportsViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/GoalsAndReportsViewModel.swift`

### SavingsGoalViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/SavingsGoalViews.swift`

#### Public Types

- **public struct SavingsGoalsSection: View {** (line 15)
- **public struct SavingsGoalCard: View {** (line 43)

#### Public Properties

- `var body: some View {` (line 20)
- `var body: some View {` (line 57)

### GoalsAndReportsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/GoalsAndReportsView.swift`

### GoalsAndReportsView_New

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/GoalsAndReportsView_New.swift`

### EnhancedGoalsSectionViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/EnhancedGoalsSectionViews.swift`

### ReportsViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/ReportsViews.swift`

#### Public Types

- **public struct ReportsSection: View {** (line 14)
- **public struct FinancialSummaryCard: View {** (line 107)
- **public struct SpendingByCategoryCard: View {** (line 183)
- **public struct BudgetPerformanceCard: View {** (line 261)
- **public struct RecentTransactionsCard: View {** (line 345)

#### Public Properties

- `var body: some View {` (line 28)
- `var body: some View {` (line 134)
- `var body: some View {` (line 216)
- `var body: some View {` (line 283)
- `var body: some View {` (line 359)

### GoalUtilityViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/GoalUtilityViews.swift`

### SavingsGoalManagementViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/SavingsGoalManagementViews.swift`

#### Public Types

- **public struct AddSavingsGoalView: View {** (line 10)
- **public struct SavingsGoalDetailView: View {** (line 116)

#### Public Properties

- `var body: some View {` (line 27)
- `var body: some View {` (line 126)

### SubscriptionDetailView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Subscriptions/SubscriptionDetailView.swift`

#### Public Types

- **public struct SubscriptionDetailRow: View {** (line 294)

#### Public Properties

- `var body: some View {` (line 54)
- `var body: some View {` (line 299)

### SubscriptionManagementViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Subscriptions/SubscriptionManagementViews.swift`

### SubscriptionsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Subscriptions/SubscriptionsView.swift`

#### Public Properties

- `var body: some View {` (line 44)
- `var body: some View {` (line 89)
- `var body: some View {` (line 344)

### SubscriptionSummaryViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Subscriptions/SubscriptionSummaryViews.swift`

### SubscriptionRowViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Subscriptions/SubscriptionRowViews.swift`

### SubscriptionsView_New

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Subscriptions/SubscriptionsView_New.swift`

### SubscriptionsViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Subscriptions/SubscriptionsViewModel.swift`

### DashboardView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardView.swift`

### DashboardUpcomingSubscriptions

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardUpcomingSubscriptions.swift`

### InsightRowView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightRowView.swift`

#### Public Types

- **public struct InsightRowView: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 12)

### DashboardSubscriptionsSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardSubscriptionsSection.swift`

#### Public Types

- **public struct DashboardSubscriptionsSection: View {** (line 11)

### SimpleDashboardView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/SimpleDashboardView.swift`

#### Public Types

- **public struct SimpleDashboardView: View {** (line 7)

### InsightsWidget

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightsWidget.swift`

#### Public Types

- **public struct InsightsWidget: View {** (line 8)
- **public struct CompactInsightRow: View {** (line 139)

### InsightsFilterBar

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightsFilterBar.swift`

#### Public Types

- **public struct InsightsFilterBar: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 12)

### InsightsEmptyStateView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightsEmptyStateView.swift`

#### Public Types

- **public struct InsightsEmptyStateView: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 4)

### DashboardBudgetProgress

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardBudgetProgress.swift`

### InsightDetailView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightDetailView.swift`

#### Public Types

- **public struct InsightDetailView: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 10)

### DashboardQuickActions

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardQuickActions.swift`

#### Public Types

- **public struct DashboardQuickActions: View {** (line 5)
- **public struct QuickActionButton: View {** (line 48)

### InsightsSummaryWidget

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightsSummaryWidget.swift`

#### Public Types

- **public struct InsightsSummaryWidget: View {** (line 8)

### InsightsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightsView.swift`

#### Public Types

- **public struct InsightsView: View {** (line 11)

### EnhancedDashboardView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/EnhancedDashboardView.swift`

### DashboardWelcomeHeader

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardWelcomeHeader.swift`

### DashboardComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardComponents.swift`

#### Public Types

- **public struct DashboardSubscriptionsSection: View {** (line 3)
- **public struct DashboardAccountsSummary: View {** (line 62)
- **public struct DashboardBudgetProgress: View {** (line 108)
- **public struct DashboardInsights: View {** (line 164)
- **public struct DashboardQuickActions: View {** (line 218)

#### Public Properties

- `var body: some View {` (line 19)
- `var body: some View {` (line 75)
- `var body: some View {` (line 122)
- `var body: some View {` (line 173)
- `var body: some View {` (line 234)

### DashboardViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardViewModel.swift`

### InsightsLoadingView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightsLoadingView.swift`

#### Public Types

- **public struct InsightsLoadingView: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 6)

### DashboardAccountsSummary

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardAccountsSummary.swift`

### DashboardComponentStubs

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardComponentStubs.swift`

### DashboardInsights

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardInsights.swift`

#### Public Types

- **public struct DashboardInsights: View {** (line 5)
- **public struct InsightItem: View {** (line 51)

### TransactionEmptyStateView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionEmptyStateView.swift`

### AccountDetailView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/AccountDetailView.swift`

#### Public Types

- **public struct AccountDetailView: View {** (line 7)
- **public struct StatView: View {** (line 270)
- **public struct ActivityChartView: View {** (line 290)

#### Public Properties

- `var body: some View {` (line 66)
- `var body: some View {` (line 275)
- `var body: some View {` (line 344)

### TransactionsViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionsViewModel.swift`

### TransactionComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionComponents.swift`

#### Public Types

- **public struct TransactionEmptyStateView: View {** (line 3)
- **public struct TransactionListView: View {** (line 46)
- **public struct TransactionRowView: View {** (line 81)
- **public struct AddTransactionView: View {** (line 105)
- **public struct TransactionDetailView: View {** (line 186)
- **public struct TransactionStatsCard: View {** (line 218)
- **public struct SearchAndFilterSection: View {** (line 254)

#### Public Properties

- `var body: some View {` (line 12)
- `var body: some View {` (line 61)
- `var body: some View {` (line 89)
- `var body: some View {` (line 121)
- `var body: some View {` (line 189)
- `var body: some View {` (line 231)
- `var body: some View {` (line 267)

### AccountsListView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/AccountsListView.swift`

### TransactionRowView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionRowView.swift`

### SearchAndFilterSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/SearchAndFilterSection.swift`

#### Public Types

- **public enum TransactionFilter: String, CaseIterable {** (line 13)

### TransactionsComponentStubs

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionsComponentStubs.swift`

### TransactionFilters

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionFilters.swift`

### TransactionsHeaderSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionsHeaderSection.swift`

### SimpleTransactionRow

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/SimpleTransactionRow.swift`

### TransactionComponentStubs

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionComponentStubs.swift`

### TransactionFilter

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionFilter.swift`

#### Public Types

- **public enum TransactionFilter: String, CaseIterable, Identifiable {** (line 3)

#### Public Properties

- `var id: String { rawValue }` (line 5)
- `var displayName: String {` (line 6)

### TransactionsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionsView.swift`

### SimpleTransactionSectionHeader

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/SimpleTransactionSectionHeader.swift`

### AddTransactionView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/AddTransactionView.swift`

### CategoryTransactionsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/CategoryTransactionsView.swift`

### TransactionDetailView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionDetailView.swift`

### TransactionStatsCard

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionStatsCard.swift`

### TransactionListView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionListView.swift`

### Features

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Features.swift`

#### Public Types

- **public enum Features {}** (line 7)

#### Public Properties

- `var body: some View {` (line 79)

### BudgetsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Budgets/BudgetsView.swift`

#### Public Types

- **public struct BudgetSearchView: View {** (line 488)

#### Public Properties

- `var body: some View {` (line 221)
- `var body: some View {` (line 309)
- `var body: some View {` (line 399)
- `var body: some View {` (line 505)

### BudgetsViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Budgets/BudgetsViewModel.swift`

### GlobalSearchView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GlobalSearchView.swift`

### NotificationsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/NotificationsView.swift`

#### Public Types

- **public struct NotificationsView: View {** (line 14)
- **public enum NotificationFilter: String, CaseIterable {** (line 233)
- **public struct FilterButton: View {** (line 251)
- **public struct NotificationRow: View {** (line 295)

### SearchEngineService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GlobalSearch/SearchEngineService.swift`

#### Public Functions

- `setModelContext(_ context: ModelContext) {` (line 14)
- `search(query: String, filter: SearchFilter = .all) -> [SearchResult] {` (line 18)

### SearchResultsComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GlobalSearch/SearchResultsComponent.swift`

#### Public Types

- **public struct SearchResultsComponent: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 14)

### SearchHeaderComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GlobalSearch/SearchHeaderComponent.swift`

#### Public Types

- **public struct SearchHeaderComponent: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 14)

### GlobalSearchView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GlobalSearch/GlobalSearchView.swift`

#### Public Types

- **public struct GlobalSearchView: View {** (line 4)
- **public struct SearchResultRow: View {** (line 165)
- **public struct SearchResultDetailView: View {** (line 227)
- **public struct DetailRow: View {** (line 304)

#### Public Properties

- `var body: some View {` (line 20)

### NavigationModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Navigation/NavigationModels.swift`

### BreadcrumbNavigation

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Navigation/BreadcrumbNavigation.swift`

#### Public Types

- **public struct BreadcrumbItem: Identifiable, Hashable {** (line 3)
- **public enum DeepLink: Hashable {** (line 15)

#### Public Properties

- `let id = UUID()` (line 4)
- `let title: String` (line 5)
- `let destination: AnyHashable?` (line 6)
- `let timestamp: Date` (line 7)
- `var path: String {` (line 24)

### TabSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Navigation/TabSection.swift`

#### Public Types

- **public enum AppTabSection: String, CaseIterable, Hashable {** (line 11)

#### Public Properties

- `var title: String {` (line 18)

### NavigationTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Navigation/NavigationTypes.swift`

#### Public Types

- **public enum TransactionsDestination: Hashable {** (line 14)
- **public enum BudgetsDestination: Hashable {** (line 19)
- **public enum SubscriptionsDestination: Hashable {** (line 24)
- **public enum GoalsDestination: Hashable {** (line 29)
- **public struct NavigationContext {** (line 35)

#### Public Properties

- `let breadcrumbTitle: String` (line 36)
- `let sourceModule: String` (line 37)
- `let metadata: [String: String]?` (line 38)

### MacOSNavigationTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Navigation/MacOSNavigationTypes.swift`

#### Public Types

- **public enum SidebarItem: Hashable {** (line 8)
- **public struct ListableItem: Identifiable, Hashable {** (line 17)
- **public enum ListItemType: Hashable {** (line 46)

#### Public Functions

- `hash(into hasher: inout Hasher) {` (line 30)

#### Public Properties

- `let id: String?` (line 18)
- `let name: String` (line 19)
- `let type: ListItemType` (line 20)
- `var identifier: String {` (line 22)
- `var identifierId: String { self.identifier }` (line 27)

### NavigationCoordinator

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Navigation/NavigationCoordinator.swift`

#### Public Types

- **public enum SidebarItem: Hashable {** (line 12)
- **public struct ListableItem: Identifiable, Hashable {** (line 21)
- **public enum ListItemType: Hashable {** (line 50)

#### Public Functions

- `hash(into hasher: inout Hasher) {` (line 34)

#### Public Properties

- `let id: String?` (line 22)
- `let name: String` (line 23)
- `let type: ListItemType` (line 24)
- `var identifier: String {` (line 26)
- `var identifierId: String { self.identifier }` (line 31)

### MomentumFinanceTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/MomentumFinanceTypes.swift`

### DataExporter_Original

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/DataExporter_Original.swift`

### HapticManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/HapticManager.swift`

#### Public Types

- **public class HapticManager: ObservableObject {** (line 14)
- **public struct HapticFeedbackModifier: ViewModifier {** (line 224)
- **public struct SelectionHapticModifier: ViewModifier {** (line 253)
- **public struct SuccessHapticModifier: ViewModifier {** (line 266)

#### Public Functions

- `body(content: Content) -> some View {` (line 243)
- `body(content: Content) -> some View {` (line 258)
- `body(content: Content) -> some View {` (line 271)

### CSVParser

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/ImportComponents/CSVParser.swift`

### ImportValidator

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/ImportComponents/ImportValidator.swift`

### CSVMapping

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/ImportComponents/CSVMapping.swift`

### DataParser

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/ImportComponents/DataParser.swift`

### EntityManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/ImportComponents/EntityManager.swift`

### ImportError

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/ImportComponents/ImportError.swift`

### DataImportHelpers

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/DataImportHelpers.swift`

### ExportTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/ExportTypes.swift`

#### Public Types

- **public struct ExportSettings: Sendable {** (line 8)
- **public enum ExportFormat: String, CaseIterable, Sendable {** (line 41)
- **public enum DateRange: String, CaseIterable, Sendable {** (line 97)
- **public enum ExportConstants {** (line 125)
- **public enum ExportError: Error {** (line 133)

#### Public Properties

- `let format: ExportFormat` (line 9)
- `let startDate: Date` (line 10)
- `let endDate: Date` (line 11)
- `let includeTransactions: Bool` (line 12)
- `let includeAccounts: Bool` (line 13)
- `let includeBudgets: Bool` (line 14)
- `let includeSubscriptions: Bool` (line 15)
- `let includeGoals: Bool` (line 16)
- `var displayName: String {` (line 46)
- `var icon: String {` (line 57)
- `var description: String {` (line 68)
- `var fileExtension: String {` (line 79)
- `var mimeType: String {` (line 83)
- `var displayName: String {` (line 105)

### ExportEngineService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/ExportEngineService.swift`

### DataExporter_Simplified

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/DataExporter_Simplified.swift`

### DataImporter

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/DataImporter.swift`

#### Public Types

- **public enum ImportError: Error {** (line 16)

### DataExporter

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/DataExporter.swift`

### CoreImports

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/CoreImports.swift`

### FinancialIntelligenceAnalysis

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Insights/FinancialIntelligenceAnalysis.swift`

### ForecastData

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Insights/ForecastData.swift`

### ExpenseCategory

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/ExpenseCategory.swift`

#### Public Functions

- `totalSpent(for month: Date) -> Double {` (line 44)
- `hash(into hasher: inout Hasher) {` (line 64)

#### Public Properties

- `var id: UUID` (line 11)
- `var name: String` (line 13)
- `var iconName: String` (line 15)
- `var createdDate: Date` (line 17)
- `var transactions: [FinancialTransaction] = []` (line 22)
- `var budgets: [Budget] = []` (line 25)
- `var subscriptions: [Subscription] = []` (line 28)

### NavigationModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/NavigationModels.swift`

### ComplexDataGenerators

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/ComplexDataGenerators.swift`

#### Public Types

- **public class TransactionsDataGenerator: DataGenerator {** (line 9)
- **public class SubscriptionsDataGenerator: DataGenerator {** (line 137)

### FinancialAccount

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/FinancialAccount.swift`

#### Public Types

- **public enum AccountType: String, CaseIterable, Codable {** (line 11)

#### Public Functions

- `updateBalance(for transaction: FinancialTransaction) {` (line 74)
- `hash(into hasher: inout Hasher) {` (line 90)

#### Public Properties

- `var name: String` (line 28)
- `var balance: Double` (line 30)
- `var iconName: String` (line 32)
- `var createdDate: Date` (line 34)
- `var accountType: AccountType` (line 36)
- `var currencyCode: String` (line 38)
- `var creditLimit: Double?` (line 40)
- `var transactions: [FinancialTransaction] = []` (line 45)
- `var subscriptions: [Subscription] = []` (line 48)

### SavingsGoal

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SavingsGoal.swift`

#### Public Functions

- `addFunds(_ amount: Double) {` (line 84)
- `removeFunds(_ amount: Double) {` (line 90)

#### Public Properties

- `var name: String` (line 11)
- `var targetAmount: Double` (line 13)
- `var currentAmount: Double` (line 15)
- `var targetDate: Date?` (line 17)
- `var notes: String?` (line 19)
- `var createdDate: Date` (line 21)
- `var progressPercentage: Double {` (line 43)
- `var remainingAmount: Double {` (line 49)
- `var isCompleted: Bool {` (line 54)
- `var formattedTargetAmount: String {` (line 59)
- `var formattedCurrentAmount: String {` (line 67)
- `var formattedRemainingAmount: String {` (line 75)
- `var daysRemaining: Int? {` (line 95)
- `var title: String {` (line 103)

### Subscription

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Subscription.swift`

#### Public Types

- **public enum BillingCycle: String, CaseIterable, Codable {** (line 8)

#### Public Functions

- `nextDueDate(from date: Date) -> Date {` (line 43)
- `processPayment(modelContext: ModelContext) {` (line 147)

#### Public Properties

- `var daysInCycle: Int {` (line 17)
- `var dateComponent: DateComponents {` (line 29)
- `var name: String` (line 60)
- `var amount: Double` (line 62)
- `var billingCycle: BillingCycle` (line 64)
- `var nextDueDate: Date` (line 66)
- `var isActive: Bool` (line 68)
- `var notes: String?` (line 70)
- `var icon: String` (line 72)
- `var category: ExpenseCategory?` (line 76)
- `var account: FinancialAccount?` (line 78)
- `var payments: [SubscriptionPayment] = []` (line 81)
- `var formattedAmount: String {` (line 105)
- `var daysUntilDue: Int {` (line 113)
- `var nextBillingDate: Date? {` (line 121)
- `var monthlyEquivalent: Double {` (line 133)
- `var date: Date` (line 173)
- `var amount: Double` (line 175)
- `var notes: String?` (line 177)
- `var subscription: Subscription?` (line 181)
- `var formattedAmount: String {` (line 197)

### DataImportModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/DataImportModels.swift`

#### Public Types

- **public struct ColumnMapping: Codable {** (line 14)
- **public enum DataType: String, CaseIterable, Codable {** (line 39)
- **public enum EntityType: String, CaseIterable, Codable {** (line 69)
- **public struct ValidationError: Identifiable, Codable {** (line 95)
- **public struct ImportResult: Codable {** (line 131)
- **public struct CSVColumnMapping: Sendable {** (line 162)

#### Public Properties

- `let csvColumn: String` (line 15)
- `let modelProperty: String` (line 16)
- `let dataType: DataType` (line 17)
- `let isRequired: Bool` (line 18)
- `let defaultValue: String?` (line 19)
- `var displayName: String {` (line 46)
- `var displayName: String {` (line 76)
- `let id: UUID` (line 96)
- `let field: String` (line 97)
- `let message: String` (line 98)
- `let severity: Severity` (line 99)
- `var displayName: String {` (line 117)
- `let success: Bool` (line 132)
- `let transactionsImported: Int` (line 133)
- `let accountsImported: Int` (line 134)
- `let categoriesImported: Int` (line 135)
- `let duplicatesSkipped: Int` (line 136)
- `let errors: [ValidationError]` (line 137)
- `let warnings: [ValidationError]` (line 138)
- `let dateColumn: String` (line 163)
- `let amountColumn: String` (line 164)
- `let descriptionColumn: String` (line 165)
- `let categoryColumn: String?` (line 166)
- `let accountColumn: String?` (line 167)

### FinancialIntelligenceModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/FinancialIntelligenceModels.swift`

#### Public Types

- **public enum InsightType: Sendable {** (line 7)
- **public struct FinancialInsight: Identifiable, Sendable {** (line 37)
- **public enum InsightPriority: Int, CaseIterable, Sendable, Comparable {** (line 73)
- **public struct ForecastData: Identifiable, Sendable {** (line 94)

#### Public Properties

- `var displayName: String {` (line 11)
- `var icon: String {` (line 23)
- `let id = UUID()` (line 38)
- `let title: String` (line 39)
- `let description: String` (line 40)
- `let type: InsightType` (line 41)
- `let priority: InsightPriority` (line 42)
- `let confidence: Double` (line 43)
- `let value: Double?` (line 44)
- `let category: String?` (line 45)
- `let dateGenerated: Date` (line 46)
- `let actionable: Bool` (line 47)
- `var color: Color {` (line 83)
- `let id = UUID()` (line 95)
- `let date: Date` (line 96)
- `let predictedBalance: Double` (line 97)
- `let confidence: Double` (line 98)

### TransactionModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/TransactionModels.swift`

#### Public Types

- **public enum TransactionFilter: String, CaseIterable, Sendable {** (line 5)
- **public struct BreadcrumbItem: Identifiable, Sendable {** (line 21)
- **public struct DeepLink: Sendable {** (line 32)

#### Public Properties

- `var displayName: String {` (line 10)
- `let id = UUID()` (line 22)
- `let title: String` (line 23)
- `let destination: String?` (line 24)
- `let path: String` (line 33)
- `let parameters: [String: String]` (line 34)

### NotificationModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/NotificationModels.swift`

### Category

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Category.swift`

### Budget

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Budget.swift`

#### Public Functions

- `calculateRolloverAmount() -> Double {` (line 99)
- `applyRollover(_ amount: Double) {` (line 109)
- `resetRollover() {` (line 114)
- `createNextPeriodBudget(for nextMonth: Date) -> Budget {` (line 121)

#### Public Properties

- `var id = UUID()` (line 11)
- `var name: String` (line 13)
- `var limitAmount: Double` (line 15)
- `var month: Date` (line 17)
- `var createdDate: Date` (line 19)
- `var rolloverEnabled: Bool = false` (line 23)
- `var rolledOverAmount: Double = 0.0` (line 25)
- `var maxRolloverPercentage: Double = 1.0` (line 27)
- `var category: ExpenseCategory?` (line 31)
- `var spentAmount: Double {` (line 46)
- `var effectiveLimit: Double {` (line 52)
- `var remainingAmount: Double {` (line 57)
- `var progressPercentage: Double {` (line 62)
- `var isOverBudget: Bool {` (line 68)
- `var formattedLimitAmount: String {` (line 73)
- `var formattedRemainingAmount: String {` (line 81)
- `var formattedMonth: String {` (line 89)

### SampleDataProviders

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SampleDataProviders.swift`

### Transaction

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Transaction.swift`

#### Public Types

- **public struct Transaction: Identifiable, Codable {** (line 8)

#### Public Properties

- `var id: UUID` (line 10)

### SampleDataGenerators

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SampleDataGenerators.swift`

### CoreFinancialModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/CoreFinancialModels.swift`

#### Public Types

- **public struct FinancialAccount: Identifiable, Codable, Sendable {** (line 8)
- **public struct ExpenseCategory: Identifiable, Codable, Sendable {** (line 35)
- **public struct FinancialTransaction: Identifiable, Codable, Sendable {** (line 55)
- **public struct Budget: Identifiable, Codable, Sendable {** (line 91)

#### Public Properties

- `let id: UUID` (line 9)
- `let name: String` (line 10)
- `let type: AccountType` (line 11)
- `let balance: Double` (line 12)
- `let currency: String` (line 13)
- `let id: UUID` (line 36)
- `let name: String` (line 37)
- `let color: String` (line 38)
- `let icon: String` (line 39)
- `let id: UUID` (line 56)
- `let title: String` (line 57)
- `let amount: Double` (line 58)
- `let date: Date` (line 59)
- `let category: ExpenseCategory?` (line 60)
- `let account: FinancialAccount?` (line 61)
- `let type: TransactionType` (line 62)
- `let notes: String?` (line 63)
- `let id: UUID` (line 92)
- `let name: String` (line 93)
- `let category: ExpenseCategory` (line 94)
- `let limit: Double` (line 95)
- `let spent: Double` (line 96)
- `let period: BudgetPeriod` (line 97)

### TransactionsGenerator

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Generators/TransactionsGenerator.swift`

### CategoriesGenerator

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Generators/CategoriesGenerator.swift`

### AccountsGenerator

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Generators/AccountsGenerator.swift`

### BudgetsGenerator

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Generators/BudgetsGenerator.swift`

### SavingsGoalsGenerator

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Generators/SavingsGoalsGenerator.swift`

### ThemeModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/ThemeModels.swift`

#### Public Types

- **public enum ThemeMode: String, CaseIterable, Sendable {** (line 6)
- **public struct ColorDefinitions: Sendable {** (line 28)
- **public enum TextType: Sendable {** (line 159)
- **public enum AccentType: Sendable {** (line 163)
- **public enum FinancialType: Sendable {** (line 167)
- **public enum BudgetType: Sendable {** (line 171)
- **public enum DarkModePreference: String, CaseIterable, Sendable {** (line 177)

#### Public Properties

- `var displayName: String {` (line 11)
- `var icon: String {` (line 19)
- `var displayName: String {` (line 182)

### SampleData

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SampleData.swift`

### FinancialTransaction

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/FinancialTransaction.swift`

#### Public Types

- **public enum TransactionType: String, CaseIterable, Codable {** (line 8)

#### Public Properties

- `var title: String` (line 21)
- `var amount: Double` (line 23)
- `var date: Date` (line 25)
- `var transactionType: TransactionType` (line 27)
- `var notes: String?` (line 29)
- `var category: ExpenseCategory?` (line 33)
- `var account: FinancialAccount?` (line 35)
- `var formattedAmount: String {` (line 56)
- `var formattedDate: String {` (line 68)

### Logger

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/Logger.swift`

#### Public Types

- **public enum Logger {** (line 17)
- **public struct PerformanceMeasurement {** (line 200)

### NotificationManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/NotificationManager.swift`

#### Public Types

- **public class NotificationManager: ObservableObject {** (line 25)

### ErrorHandler

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/ErrorHandler.swift`

#### Public Types

- **public struct ErrorRecoveryOption: Identifiable {** (line 165)
- **public enum AppError: LocalizedError, Identifiable {** (line 172)
- **public struct ErrorAlert: ViewModifier {** (line 383)

#### Public Functions

- `body(content: Content) -> some View {` (line 425)

#### Public Properties

- `let id = UUID()` (line 166)
- `var id: String {` (line 186)
- `var errorDescription: String? {` (line 215)
- `var failureReason: String? {` (line 244)
- `var recoverySuggestion: String? {` (line 273)

### SwiftDataCompat

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/SwiftDataCompat.swift`

#### Public Types

- **public struct Query<Value> {** (line 20)

#### Public Properties

- `var wrappedValue: Value {` (line 27)
- `var projectedValue: Query<Value> { self }` (line 32)

### FinancialUtilities

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/FinancialUtilities.swift`

#### Public Functions

- `formatCurrency(_ amount: Double) -> String {` (line 5)

### NotificationTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/NotificationTypes.swift`

#### Public Types

- **public enum NotificationUrgency {** (line 15)
- **public struct ScheduledNotification: Identifiable {** (line 38)
- **public struct NotificationPermissionManager {** (line 57)
- **public struct BudgetNotificationScheduler {** (line 122)
- **public struct SubscriptionNotificationScheduler {** (line 471)
- **public struct GoalNotificationScheduler {** (line 556)

#### Public Functions

- `requestNotificationPermission() async -> Bool {` (line 67)
- `checkNotificationPermissionAsync() async -> Bool {` (line 89)
- `setupNotificationCategories() {` (line 95)
- `scheduleWarningNotifications(for budgets: [Budget]) {` (line 132)
- `scheduleRolloverNotifications(for budgets: [Budget]) {` (line 452)
- `scheduleSpendingPredictionNotifications(for budgets: [Budget]) {` (line 463)
- `scheduleDueDateReminders(for subscriptions: [Subscription]) {` (line 480)
- `scheduleNotifications(for subscriptions: [Subscription]) {` (line 487)
- `scheduleProgressReminders(for goals: [SavingsGoal]) {` (line 565)
- `checkMilestones(for goals: [SavingsGoal]) {` (line 572)

#### Public Properties

- `var title: String {` (line 18)
- `var sound: UNNotificationSound {` (line 27)
- `let id: String` (line 39)
- `let title: String` (line 40)
- `let body: String` (line 41)
- `let type: String` (line 42)
- `let scheduledDate: Date?` (line 43)

### QueryFallback

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/QueryFallback.swift`

#### Public Types

- **public struct Query<Value> {** (line 8)

#### Public Properties

- `var wrappedValue: Value {` (line 15)
- `var projectedValue: Query<Value> { self }` (line 20)

### AppLogger

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/AppLogger.swift`

### FormattingUtilities

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/FormattingUtilities.swift`

### MomentumFinanceApp

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/MomentumFinanceApp.swift`

#### Public Types

- **public struct MomentumFinanceApp: App {** (line 42)

#### Public Properties

- `var body: some Scene {` (line 189)

### SecuritySettingsSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/SecuritySettingsSection.swift`

#### Public Types

- **public struct SecuritySettingsSection: View {** (line 3)

### ExportDataView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/ExportDataView.swift`

#### Public Types

- **public struct ExportDataView: View {** (line 4)

### AppearanceSettingsSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/AppearanceSettingsSection.swift`

#### Public Types

- **public struct AppearanceSettingsSection: View {** (line 3)

### DataManagementSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/DataManagementSection.swift`

#### Public Types

- **public struct DataManagementSection: View {** (line 3)

### ImportDataView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/ImportDataView.swift`

#### Public Types

- **public struct ImportDataView: View {** (line 5)

### ImportResultView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/ImportResultView.swift`

#### Public Types

- **public struct ImportResultView: View {** (line 3)

### AccessibilitySettingsSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/AccessibilitySettingsSection.swift`

#### Public Types

- **public struct AccessibilitySettingsSection: View {** (line 3)

### ImportExportSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/ImportExportSection.swift`

#### Public Types

- **public struct ImportExportSection: View {** (line 4)

### AboutSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/AboutSection.swift`

#### Public Types

- **public struct AboutSection: View {** (line 3)

### ThemeDemoComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/ThemeDemoComponents.swift`

#### Public Types

- **public struct ThemeSelectorCard: View {** (line 6)
- **public struct ThemeFinancialSummaryCard: View {** (line 61)
- **public struct ThemeAccountsList: View {** (line 113)

#### Public Properties

- `let theme: Any?` (line 8)
- `var body: some View {` (line 15)
- `var body: some View {` (line 62)
- `var body: some View {` (line 114)

### TransactionComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/TransactionComponents.swift`

#### Public Types

- **public struct TransactionEmptyStateView: View {** (line 8)
- **public struct TransactionListView: View {** (line 49)
- **public struct TransactionRowView: View {** (line 78)
- **public struct AddTransactionView: View {** (line 128)
- **public struct TransactionDetailView: View {** (line 177)
- **public struct TransactionStatsCard: View {** (line 242)
- **public struct SearchAndFilterSection: View {** (line 283)

#### Public Properties

- `let searchText: String` (line 9)
- `let onAddTransaction: () -> Void` (line 10)
- `var body: some View {` (line 12)
- `let transactions: [FinancialTransaction]` (line 50)
- `let onTransactionTapped: (FinancialTransaction) -> Void` (line 51)
- `let onDeleteTransaction: (FinancialTransaction) -> Void` (line 52)
- `var body: some View {` (line 54)
- `let transaction: FinancialTransaction` (line 79)
- `let onTap: () -> Void` (line 80)
- `let onDelete: (() -> Void)?` (line 81)
- `var body: some View {` (line 83)
- `let categories: [Any]` (line 129)
- `let accounts: [Any]` (line 130)
- `var body: some View {` (line 133)
- `let transaction: Any` (line 178)
- `var body: some View {` (line 181)
- `let transactions: [Any]` (line 243)
- `var body: some View {` (line 245)
- `var body: some View {` (line 288)

### DashboardComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Dashboard/DashboardComponents.swift`

#### Public Types

- **public struct DashboardWelcomeHeader: View {** (line 17)
- **public struct DashboardAccountsSummary: View {** (line 41)
- **public struct AccountSummaryCard: View {** (line 68)
- **public struct DashboardMetricsCards: View {** (line 116)
- **public struct MetricCard: View {** (line 158)

#### Public Properties

- `let userName: String` (line 18)
- `var body: some View {` (line 20)
- `let accounts: [FinancialAccount]` (line 42)
- `var body: some View {` (line 44)
- `let account: FinancialAccount` (line 69)
- `var body: some View {` (line 71)
- `let totalBalance: Double` (line 117)
- `let monthlyIncome: Double` (line 118)
- `let monthlyExpenses: Double` (line 119)
- `var body: some View {` (line 121)
- `let title: String` (line 159)
- `let value: String` (line 160)
- `let icon: String` (line 161)
- `let color: Color` (line 162)
- `var body: some View {` (line 164)

### AnimationComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/AnimationComponents.swift`

#### Public Types

- **public enum AnimatedCardComponent {** (line 6)
- **public enum AnimatedButtonComponent {** (line 17)
- **public enum AnimatedTransactionComponent {** (line 40)
- **public enum AnimatedProgressComponents {** (line 65)
- **public enum FloatingActionButtonComponent {** (line 94)

#### Public Properties

- `var body: some View {` (line 8)
- `var body: some View {` (line 22)
- `var body: some View {` (line 42)
- `var body: some View {` (line 69)
- `var body: some View {` (line 82)
- `var body: some View {` (line 99)

### ButtonStyles

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/ButtonStyles.swift`

#### Public Types

- **public struct PrimaryButtonStyle: ButtonStyle {** (line 6)
- **public struct SecondaryButtonStyle: ButtonStyle {** (line 23)
- **public struct TextButtonStyle: ButtonStyle {** (line 40)
- **public struct DestructiveButtonStyle: ButtonStyle {** (line 55)

#### Public Functions

- `makeBody(configuration: Configuration) -> some View {` (line 13)
- `makeBody(configuration: Configuration) -> some View {` (line 30)
- `makeBody(configuration: Configuration) -> some View {` (line 47)
- `makeBody(configuration: Configuration) -> some View {` (line 62)

#### Public Properties

- `let theme: Any?` (line 7)
- `let theme: Any?` (line 24)
- `let theme: Any?` (line 41)
- `let theme: Any?` (line 56)

### ImportButtonComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/ImportButtonComponent.swift`

#### Public Types

- **public struct ImportButtonComponent: View {** (line 3)

### ImportProgressComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/ImportProgressComponent.swift`

#### Public Types

- **public struct ImportProgressComponent: View {** (line 3)

### DataImportHeaderComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/DataImportHeaderComponent.swift`

#### Public Types

- **public struct DataImportHeaderComponent: View {** (line 3)

### ImportResultView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/ImportResultView.swift`

### ImportInstructionsComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/ImportInstructionsComponent.swift`

#### Public Types

- **public struct ImportInstructionsComponent: View {** (line 3)

### ImportResultComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/ImportResultComponent.swift`

#### Public Types

- **public struct ImportResultView: View {** (line 3)

### FileSelectionComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/FileSelectionComponent.swift`

#### Public Types

- **public struct FileSelectionComponent: View {** (line 3)

### InsightsComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/InsightsComponents.swift`

#### Public Types

- **public struct InsightsLoadingView: View {** (line 8)
- **public struct InsightsEmptyStateView: View {** (line 24)
- **public struct InsightRowView: View {** (line 48)
- **public struct InsightsFilterBar: View {** (line 99)
- **public struct FilterChip: View {** (line 137)
- **public struct InsightDetailView: View {** (line 163)

#### Public Properties

- `var body: some View {` (line 9)
- `var body: some View {` (line 25)
- `let insight: FinancialInsight` (line 49)
- `let action: () -> Void` (line 50)
- `var body: some View {` (line 52)
- `var body: some View {` (line 103)
- `var body: some View {` (line 142)
- `let insight: FinancialInsight` (line 164)
- `var body: some View {` (line 167)

### ImportComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/ImportComponents.swift`

#### Public Types

- **public struct DataImportHeaderComponent: View {** (line 6)
- **public struct FileSelectionComponent: View {** (line 27)
- **public struct ImportProgressComponent: View {** (line 59)
- **public struct ImportButtonComponent: View {** (line 82)
- **public struct ImportInstructionsComponent: View {** (line 111)

#### Public Properties

- `var body: some View {` (line 7)
- `let onFileSelected: () -> Void` (line 29)
- `var body: some View {` (line 31)
- `let progress: Double` (line 60)
- `var body: some View {` (line 62)
- `let isImporting: Bool` (line 83)
- `let action: () -> Void` (line 84)
- `var body: some View {` (line 86)
- `var body: some View {` (line 112)

### ThemeSettingsComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/ThemeSettingsComponents.swift`

#### Public Types

- **public struct ThemeBudgetProgress: View {** (line 6)
- **public struct ThemeSubscriptionsList: View {** (line 18)
- **public struct ThemeTypographyShowcase: View {** (line 30)
- **public struct ThemeButtonStylesShowcase: View {** (line 42)
- **public struct ThemeSettingsSheet: View {** (line 54)

#### Public Properties

- `let theme: Any?` (line 7)
- `var body: some View {` (line 13)
- `let theme: Any?` (line 19)
- `var body: some View {` (line 25)
- `let theme: Any?` (line 31)
- `var body: some View {` (line 37)
- `let theme: Any?` (line 43)
- `var body: some View {` (line 49)
- `let theme: Any?` (line 58)
- `var body: some View {` (line 70)

### SectionHeader

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/SectionHeader.swift`

#### Public Types

- **public struct SectionHeader: View {** (line 3)

#### Public Properties

- `var body: some View {` (line 12)

### DarkModePreference

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/DarkModePreference.swift`

### ThemeDemoComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemeDemoComponents.swift`

#### Public Types

- **public struct ThemeSelectorCard: View {** (line 14)
- **public struct ThemeFinancialSummaryCard: View {** (line 42)
- **public struct ThemeAccountsList: View {** (line 82)
- **public struct ThemeBudgetProgress: View {** (line 122)
- **public struct ThemeSubscriptionsList: View {** (line 172)
- **public struct ThemeTypographyShowcase: View {** (line 216)
- **public struct ThemeButtonStylesShowcase: View {** (line 275)
- **public struct ThemeSettingsSheet: View {** (line 308)

### ThemeDemoPublicWrappers

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemeDemoPublicWrappers.swift`

### ColorDefinitions

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ColorDefinitions.swift`

#### Public Types

- **public enum ColorDefinitions {** (line 12)

### ThemeEnums

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemeEnums.swift`

#### Public Types

- **public enum ColorScheme {** (line 12)
- **public enum TextStyle {** (line 18)
- **public enum AccentType {** (line 25)
- **public enum BudgetType {** (line 31)

### ThemeManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemeManager.swift`

### ColorTheme

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ColorTheme.swift`

### ThemeDemoPlaceholders

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemeDemoPlaceholders.swift`

### ThemeDemoView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemeDemoView.swift`

#### Public Types

- **public struct ThemeDemoView: View {** (line 12)

### ColorTheme+Convenience

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ColorTheme+Convenience.swift`

### ButtonStyles

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ButtonStyles.swift`

#### Public Types

- **public struct PrimaryButtonStyle: ButtonStyle {** (line 14)
- **public struct SecondaryButtonStyle: ButtonStyle {** (line 32)
- **public struct TextButtonStyle: ButtonStyle {** (line 54)
- **public struct DestructiveButtonStyle: ButtonStyle {** (line 68)

#### Public Functions

- `makeBody(configuration: Configuration) -> some View {` (line 17)
- `makeBody(configuration: Configuration) -> some View {` (line 35)
- `makeBody(configuration: Configuration) -> some View {` (line 57)
- `makeBody(configuration: Configuration) -> some View {` (line 71)

### ThemeComponentStubs

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemeComponentStubs.swift`

### ThemeSettingsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemeSettingsView.swift`

#### Public Types

- **public struct ThemeSettingsView: View {** (line 11)
- **public struct ThemeModeOption: View {** (line 139)

### ThemeComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemeComponents.swift`

#### Public Types

- **public struct ThemeComponents: @unchecked Sendable {** (line 20)

### ColorDefinitions

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ColorComponents/ColorDefinitions.swift`

### ThemeEnums

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ColorComponents/ThemeEnums.swift`

#### Public Types

- **public struct ThemeEnums {** (line 12)
- **public enum ThemeMode: String, CaseIterable, Identifiable, Hashable {** (line 19)
- **public enum ThemeScheme {** (line 52)
- **public enum TextLevel {** (line 60)
- **public enum AccentLevel {** (line 69)
- **public enum FinancialType {** (line 77)
- **public enum BudgetStatus {** (line 88)

#### Public Properties

- `var id: String { rawValue }` (line 24)

### ColorExtensions

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ColorComponents/ColorExtensions.swift`

### ColorThemePreview

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ColorComponents/ColorThemePreview.swift`

### ThemePersistence

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemePersistence.swift`

### MissingTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/MissingTypes.swift`

#### Public Types

- **public struct BreadcrumbItem: Identifiable, Hashable {** (line 7)
- **public enum DeepLink {** (line 19)

#### Public Properties

- `let id = UUID()` (line 8)
- `let title: String` (line 9)
- `let destination: AnyHashable?` (line 10)
- `let timestamp: Date` (line 11)
- `var path: String {` (line 27)

### TemporaryImportNotificationStubs

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Bridging/TemporaryImportNotificationStubs.swift`

### Theme

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme.swift`

#### Public Types

- **public enum ThemeMode: String, CaseIterable, Identifiable, Hashable {** (line 35)
- **public enum DarkModePreference: String, CaseIterable {** (line 55)
- **public enum ThemeScheme { case light, dark }** (line 60)
- **public enum TextLevel { case primary, secondary, tertiary }** (line 61)
- **public enum AccentLevel { case primary, secondary }** (line 62)
- **public enum FinancialType { case income, expense, savings, warning, critical }** (line 63)
- **public enum BudgetStatus { case under, near, over }** (line 64)

#### Public Properties

- `var id: String { rawValue }` (line 37)

### ExportEngineService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Export/ExportEngineService.swift`

### ImportExport

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/ImportExport.swift`

#### Public Types

- **public enum ImportError: Error {** (line 4)
- **public struct CSVColumnMapping {** (line 15)
- **public class CSVParser {** (line 26)
- **public class DataParser {** (line 50)
- **public class DefaultEntityManager: EntityManager {** (line 89)
- **public enum ExportFormat: String, CaseIterable {** (line 103)
- **public enum DateRange: String, CaseIterable {** (line 118)
- **public struct ExportSettings {** (line 129)
- **public struct ImportResult {** (line 157)
- **public class DataExporter {** (line 171)
- **public class DataImporter {** (line 207)

#### Public Functions

- `getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping)` (line 91)
- `getOrCreateCategory(` (line 96)
- `exportData(settings: ExportSettings) async throws -> URL {` (line 175)
- `importFromCSV(_ content: String) async throws -> ImportResult {` (line 211)

#### Public Properties

- `var dateIndex: Int?` (line 16)
- `var titleIndex: Int?` (line 17)
- `var amountIndex: Int?` (line 18)
- `var typeIndex: Int?` (line 19)
- `var notesIndex: Int?` (line 20)
- `var accountIndex: Int?` (line 21)
- `var categoryIndex: Int?` (line 22)
- `var displayName: String { rawValue }` (line 108)
- `var icon: String {` (line 109)
- `var displayName: String { rawValue }` (line 126)
- `let format: ExportFormat` (line 130)
- `let dateRange: DateRange` (line 131)
- `let includeCategories: Bool` (line 132)
- `let includeAccounts: Bool` (line 133)
- `let includeBudgets: Bool` (line 134)
- `let startDate: Date` (line 135)
- `let endDate: Date` (line 136)
- `let success: Bool` (line 158)
- `let itemsImported: Int` (line 159)
- `let errors: [String]` (line 160)
- `let warnings: [String]` (line 161)

### SettingsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/SettingsView.swift`

#### Public Types

- **public struct SettingsView: View {** (line 6)

#### Public Properties

- `var body: some View {` (line 45)

### SettingsSectionStubs

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/SettingsSectionStubs.swift`

### DataImportComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/DataImportComponents.swift`

#### Public Types

- **public struct DataImportHeaderComponent: View {** (line 3)
- **public struct FileSelectionComponent: View {** (line 15)
- **public struct ImportProgressComponent: View {** (line 35)
- **public struct ImportButtonComponent: View {** (line 49)
- **public struct ImportInstructionsComponent: View {** (line 74)
- **public struct ImportResultView: View {** (line 94)

#### Public Properties

- `var body: some View {` (line 5)
- `var body: some View {` (line 18)
- `var body: some View {` (line 38)
- `var body: some View {` (line 57)
- `var body: some View {` (line 76)
- `var body: some View {` (line 102)

### SettingsTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/SettingsTypes.swift`

#### Public Types

- **public enum DarkModePreference: String, CaseIterable {** (line 14)

#### Public Properties

- `var displayName: String {` (line 19)

### DataExportView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/DataExportView.swift`

#### Public Types

- **public struct DataExportView: View {** (line 10)

#### Public Properties

- `var body: some View {` (line 29)
- `var body: some View {` (line 295)

### DataImportView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/DataImportView.swift`

#### Public Types

- **public struct DataImportView: View {** (line 9)

#### Public Properties

- `var body: some View {` (line 21)

### ContentView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/ContentView.swift`

#### Public Types

- **public struct DashboardView: View {** (line 9)
- **public struct ContentView: View {** (line 15)

#### Public Properties

- `var body: some View {` (line 10)
- `var body: some View {` (line 19)

### FinancialServices

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Services/FinancialServices.swift`

#### Public Types

- **public struct SpendingPattern {** (line 299)
- **public struct TransactionAnomaly {** (line 309)
- **public struct TransactionPattern {** (line 403)
- **public struct CategorySuggestion {** (line 410)

#### Public Functions

- `save() async throws {` (line 26)
- `delete(_ entity: some Any) async throws {` (line 30)
- `fetch<T>(_ type: T.Type) async throws -> [T] {` (line 35)
- `getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping)` (line 40)
- `getOrCreateCategory(` (line 74)
- `exportToCSV() async throws -> URL {` (line 148)
- `export(settings: [String: Any]) async throws -> URL {` (line 158)
- `predictSpending(for category: ExpenseCategory? = nil, daysAhead: Int = 30) async -> Double {` (line 227)
- `analyzeSpendingPatterns() async -> [SpendingPattern] {` (line 251)
- `detectAnomalies() async -> [TransactionAnomaly] {` (line 274)
- `analyzePatterns() async -> [TransactionPattern] {` (line 332)
- `suggestCategories() async -> [CategorySuggestion] {` (line 365)

#### Public Properties

- `let category: String` (line 300)
- `let totalAmount: Double` (line 301)
- `let trend: Trend` (line 302)
- `let transaction: FinancialTransaction` (line 310)
- `let type: AnomalyType` (line 311)
- `let severity: Severity` (line 312)
- `let title: String` (line 404)
- `let frequency: Int` (line 405)
- `let averageAmount: Double` (line 406)
- `let isRecurring: Bool` (line 407)
- `let transaction: FinancialTransaction` (line 411)
- `let suggestedCategory: String` (line 412)
- `let confidence: Double` (line 413)

### AnimationManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Animations/AnimationManager.swift`

#### Public Types

- **public struct CardFlipModifier: ViewModifier {** (line 270)
- **public struct LoadingIndicator: View {** (line 287)
- **public struct AnimatedProgressBar: View {** (line 347)

### AnimatedComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Animations/AnimatedComponents.swift`

### AnimationComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Animations/AnimationComponents.swift`

### AnimationTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Animations/AnimationTypes.swift`

#### Public Types

- **public enum AnimatedCardComponent {** (line 12)
- **public enum AnimatedButtonComponent {** (line 28)
- **public enum AnimatedTransactionComponent {** (line 46)
- **public enum AnimatedProgressComponents {** (line 62)
- **public enum FloatingActionButtonComponent {** (line 91)

#### Public Properties

- `var body: some View {` (line 20)
- `var body: some View {` (line 38)
- `var body: some View {` (line 54)
- `var body: some View {` (line 70)
- `var body: some View {` (line 83)
- `var body: some View {` (line 99)

### ContentView_iOS

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/iOS/ContentView_iOS.swift`

### CSVParserEdgeCasesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceTests/CSVParserEdgeCasesTests.swift`

### DataImporterErrorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceTests/DataImporterErrorTests.swift`

### DataExporterContentTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceTests/DataExporterContentTests.swift`

### CSVParserTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceTests/CSVParserTests.swift`

### DataExporterDateRangeTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceTests/DataExporterDateRangeTests.swift`

### MissingTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MissingTypes.swift`

#### Public Types

- **public enum InsightType: Sendable {** (line 10)
- **public struct ModelContext: Sendable {** (line 59)

#### Public Properties

- `var displayName: String {` (line 14)
- `var icon: String {` (line 26)

### create_xcode_project

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/XcodeWrapper/create_xcode_project.swift`

### Package

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Package.swift`

### test_crash_debug

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/test_crash_debug.swift`

### regenerate_project

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/regenerate_project.swift`

### CoreExports

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceCore/CoreExports.swift`

#### Public Types

- **public struct CoreMarker {}** (line 6)

### run_tests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/run_tests.swift`

## Dependencies

### Swift Package Manager Dependencies

Package.swift location: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Package.swift`

#### External Dependencies

        .package(path: "../../Shared")
