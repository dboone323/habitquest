# MomentumFinance API Documentation

Generated: Fri Sep 19 10:28:59 CDT 2025
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

### test_models

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/test_models.swift`

### test_minimal_app

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/test_minimal_app.swift`

### AccountUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceUITests/AccountUITests.swift`

### BudgetUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceUITests/BudgetUITests.swift`

### TransactionUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceUITests/TransactionUITests.swift`

### MomentumFinanceUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceUITests/MomentumFinanceUITests.swift`

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

### FinancialSummaryCard

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/FinancialSummaryCard.swift`

### EnhancedReportsSectionViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/EnhancedReportsSectionViews.swift`

### GoalsAndReportsViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/GoalsAndReportsViewModel.swift`

### SavingsGoalViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/SavingsGoalViews.swift`

### GoalsAndReportsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/GoalsAndReportsView.swift`

### GoalsAndReportsView_New

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/GoalsAndReportsView_New.swift`

### EnhancedGoalsSectionViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/EnhancedGoalsSectionViews.swift`

### ReportsViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/ReportsViews.swift`

### GoalUtilityViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/GoalUtilityViews.swift`

### SavingsGoalManagementViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GoalsAndReports/SavingsGoalManagementViews.swift`

### SubscriptionDetailView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Subscriptions/SubscriptionDetailView.swift`

### SubscriptionManagementViews

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Subscriptions/SubscriptionManagementViews.swift`

### SubscriptionsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Subscriptions/SubscriptionsView.swift`

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

### SimpleDashboardView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/SimpleDashboardView.swift`

### InsightsWidget

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightsWidget.swift`

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

### InsightsSummaryWidget

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightsSummaryWidget.swift`

### InsightsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/InsightsView.swift`

### EnhancedDashboardView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/EnhancedDashboardView.swift`

### DashboardWelcomeHeader

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Dashboard/DashboardWelcomeHeader.swift`

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

### TransactionEmptyStateView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionEmptyStateView.swift`

### AccountDetailView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/AccountDetailView.swift`

### TransactionsViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Transactions/TransactionsViewModel.swift`

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

### BudgetsViewModel

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/Budgets/BudgetsViewModel.swift`

### GlobalSearchView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/GlobalSearchView.swift`

### NotificationsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Features/NotificationsView.swift`

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

#### Public Properties

- `var body: some View {` (line 20)

### NavigationModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Navigation/NavigationModels.swift`

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

### DataExporter

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/DataExporter.swift`

### FinancialIntelligenceAnalysis

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Insights/FinancialIntelligenceAnalysis.swift`

### ForecastData

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Insights/ForecastData.swift`

### ExpenseCategory

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/ExpenseCategory.swift`

#### Public Functions

- `hash(into hasher: inout Hasher) {` (line 61)

### NavigationModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/NavigationModels.swift`

### ComplexDataGenerators

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/ComplexDataGenerators.swift`

### FinancialAccount

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/FinancialAccount.swift`

#### Public Functions

- `hash(into hasher: inout Hasher) {` (line 90)

### SavingsGoal

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SavingsGoal.swift`

### Subscription

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Subscription.swift`

### DataImportModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/DataImportModels.swift`

#### Public Types

- **public struct ColumnMapping: Codable {** (line 14)
- **public enum DataType: String, CaseIterable, Codable {** (line 39)
- **public enum EntityType: String, CaseIterable, Codable {** (line 69)
- **public struct ValidationError: Identifiable, Codable {** (line 95)
- **public struct ImportResult: Codable {** (line 131)

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

### NotificationModels

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/NotificationModels.swift`

### Category

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Category.swift`

### Budget

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Budget.swift`

### SampleDataProviders

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SampleDataProviders.swift`

### Transaction

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Transaction.swift`

### SampleDataGenerators

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SampleDataGenerators.swift`

### SampleData

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SampleData.swift`

### FinancialTransaction

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/FinancialTransaction.swift`

#### Public Types

- **public enum TransactionType: String, CaseIterable, Codable {** (line 8)

### Logger

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/Logger.swift`

### NotificationManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/NotificationManager.swift`

### ErrorHandler

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/ErrorHandler.swift`

### SwiftDataCompat

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/SwiftDataCompat.swift`

#### Public Properties

- `var wrappedValue: Value {` (line 27)
- `var projectedValue: Query<Value> { self }` (line 32)

### NotificationTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/NotificationTypes.swift`

#### Public Types

- **public enum NotificationUrgency {** (line 15)
- **public struct ScheduledNotification: Identifiable {** (line 38)
- **public struct NotificationPermissionManager {** (line 57)
- **public struct BudgetNotificationScheduler {** (line 122)
- **public struct SubscriptionNotificationScheduler {** (line 244)
- **public struct GoalNotificationScheduler {** (line 329)

#### Public Functions

- `requestNotificationPermission() async -> Bool {` (line 67)
- `checkNotificationPermissionAsync() async -> Bool {` (line 89)
- `setupNotificationCategories() {` (line 95)
- `scheduleWarningNotifications(for budgets: [Budget]) {` (line 132)
- `scheduleDueDateReminders(for subscriptions: [Subscription]) {` (line 253)
- `scheduleNotifications(for subscriptions: [Subscription]) {` (line 260)
- `scheduleProgressReminders(for goals: [SavingsGoal]) {` (line 338)
- `checkMilestones(for goals: [SavingsGoal]) {` (line 345)

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

### SecuritySettingsSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/SecuritySettingsSection.swift`

### AppearanceSettingsSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/AppearanceSettingsSection.swift`

### DataManagementSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/DataManagementSection.swift`

### AccessibilitySettingsSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/AccessibilitySettingsSection.swift`

### ImportExportSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/ImportExportSection.swift`

### AboutSection

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Settings/AboutSection.swift`

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

### ImportButtonComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/ImportButtonComponent.swift`

### ImportProgressComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/ImportProgressComponent.swift`

### DataImportHeaderComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/DataImportHeaderComponent.swift`

### ImportResultView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/ImportResultView.swift`

### ImportInstructionsComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/ImportInstructionsComponent.swift`

### ImportResultComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/ImportResultComponent.swift`

### FileSelectionComponent

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Components/Import/FileSelectionComponent.swift`

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

### ThemeComponents

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Theme/ThemeComponents.swift`

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

- **public enum ThemeMode: String, CaseIterable, Identifiable, Hashable {** (line 53)
- **public enum DarkModePreference: String, CaseIterable {** (line 84)
- **public enum ThemeScheme {** (line 99)
- **public enum TextLevel {** (line 105)
- **public enum AccentLevel {** (line 112)
- **public enum FinancialType {** (line 118)
- **public enum BudgetStatus {** (line 127)
- **public enum TransactionFilter: String, CaseIterable {** (line 235)
- **public struct FinancialInsight: Identifiable, Hashable {** (line 263)
- **public enum InsightPriority: String, CaseIterable {** (line 285)
- **public enum InsightType: String, CaseIterable {** (line 293)
- **public enum ImportError: Error {** (line 309)
- **public class ImportValidator {** (line 321)
- **public class CSVParser {** (line 369)
- **public struct CSVColumnMapping {** (line 414)
- **public class DataParser {** (line 429)
- **public class DefaultEntityManager: EntityManager {** (line 490)
- **public struct BreadcrumbItem: Identifiable, Hashable {** (line 551)
- **public enum DeepLink {** (line 565)
- **public struct ThemeComponents {** (line 602)
- **public struct TransactionRowView: View {** (line 630)
- **public struct DashboardWelcomeHeader: View {** (line 690)
- **public struct DashboardAccountsSummary: View {** (line 750)
- **public struct DashboardSubscriptionsSection: View {** (line 809)
- **public struct DashboardBudgetProgress: View {** (line 874)
- **public struct DashboardInsights: View {** (line 936)
- **public struct DashboardQuickActions: View {** (line 994)
- **public struct TransactionEmptyStateView: View {** (line 1100)
- **public struct TransactionListView: View {** (line 1144)
- **public struct AddTransactionView: View {** (line 1179)
- **public struct TransactionDetailView: View {** (line 1269)
- **public struct TransactionStatsCard: View {** (line 1317)
- **public struct SearchAndFilterSection: View {** (line 1363)
- **public enum ExportFormat: String, CaseIterable {** (line 1481)
- **public enum DateRange: String, CaseIterable {** (line 1500)
- **public struct ImportResult {** (line 1515)
- **public struct ExportSettings {** (line 1530)
- **public class DataExporter {** (line 1554)
- **public struct DataImportHeaderComponent: View {** (line 1580)
- **public struct FileSelectionComponent: View {** (line 1598)
- **public struct ImportProgressComponent: View {** (line 1633)
- **public struct ImportButtonComponent: View {** (line 1658)
- **public struct ImportInstructionsComponent: View {** (line 1685)
- **public struct ImportResultView: View {** (line 1709)
- **public class DataImporter {** (line 1768)

#### Public Functions

- `getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping)` (line 493)
- `getOrCreateCategory(` (line 504)
- `exportData(settings: ExportSettings) async throws -> URL {` (line 1562)
- `importFromCSV(_ content: String) async throws -> ImportResult {` (line 1776)

#### Public Properties

- `var id: String { rawValue }` (line 58)
- `let id = UUID()` (line 264)
- `let title: String` (line 265)
- `let description: String` (line 266)
- `let priority: InsightPriority` (line 267)
- `let type: InsightType` (line 268)
- `let createdAt: Date` (line 269)
- `let actionUrl: String?` (line 270)
- `var dateIndex: Int?` (line 415)
- `var titleIndex: Int?` (line 416)
- `var amountIndex: Int?` (line 417)
- `var typeIndex: Int?` (line 418)
- `var notesIndex: Int?` (line 419)
- `var accountIndex: Int?` (line 420)
- `var categoryIndex: Int?` (line 421)
- `let id = UUID()` (line 552)
- `let title: String` (line 553)
- `let destination: AnyHashable?` (line 554)
- `let timestamp: Date` (line 555)
- `var path: String {` (line 579)
- `var body: some View {` (line 639)
- `var body: some View {` (line 708)
- `var body: some View {` (line 764)
- `var body: some View {` (line 825)
- `var body: some View {` (line 888)
- `var body: some View {` (line 945)
- `var body: some View {` (line 1010)
- `var body: some View {` (line 1109)
- `var body: some View {` (line 1159)
- `var body: some View {` (line 1196)
- `var body: some View {` (line 1276)
- `var body: some View {` (line 1332)
- `var body: some View {` (line 1377)
- `let success: Bool` (line 1516)
- `let itemsImported: Int` (line 1517)
- `let errors: [String]` (line 1518)
- `let warnings: [String]` (line 1519)
- `let format: ExportFormat` (line 1531)
- `let dateRange: DateRange` (line 1532)
- `let includeCategories: Bool` (line 1533)
- `let includeAccounts: Bool` (line 1534)
- `let includeBudgets: Bool` (line 1535)
- `var body: some View {` (line 1583)
- `var body: some View {` (line 1605)
- `var body: some View {` (line 1640)
- `var body: some View {` (line 1667)
- `var body: some View {` (line 1688)
- `var body: some View {` (line 1718)

### TemporaryImportNotificationStubs

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Bridging/TemporaryImportNotificationStubs.swift`

### ExportEngineService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Export/ExportEngineService.swift`

### SettingsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/SettingsView.swift`

### SettingsSectionStubs

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/SettingsSectionStubs.swift`

### SettingsTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/SettingsTypes.swift`

#### Public Types

- **public enum DarkModePreference: String, CaseIterable {** (line 14)

#### Public Properties

- `var displayName: String {` (line 19)

### DataExportView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/DataExportView.swift`

### DataImportView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Views/Settings/DataImportView.swift`

### ContentView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/ContentView.swift`

### AnimationManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Animations/AnimationManager.swift`

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

### MissingTypes

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MissingTypes.swift`

#### Public Types

- **public enum InsightType: Sendable {** (line 10)
- **public struct ValidationError: Identifiable, Codable, Sendable {** (line 44)
- **public struct ImportResult: Codable, Sendable {** (line 78)
- **public enum ThemeMode: String, CaseIterable, Sendable {** (line 116)
- **public struct ColorDefinitions: Sendable {** (line 138)
- **public enum TextType: Sendable {** (line 269)
- **public enum AccentType: Sendable {** (line 273)
- **public enum FinancialType: Sendable {** (line 277)
- **public enum BudgetType: Sendable {** (line 281)
- **public enum DarkModePreference: String, CaseIterable, Sendable {** (line 293)
- **public enum TransactionFilter: String, CaseIterable, Sendable {** (line 309)
- **public struct FinancialInsight: Identifiable, Sendable {** (line 325)
- **public enum InsightPriority: Int, CaseIterable, Sendable, Comparable {** (line 360)
- **public struct CSVColumnMapping: Sendable {** (line 388)
- **public struct BreadcrumbItem: Identifiable, Sendable {** (line 412)
- **public struct DeepLink: Sendable {** (line 423)
- **public enum AnimatedCardComponent {** (line 522)
- **public enum AnimatedButtonComponent {** (line 533)
- **public enum AnimatedTransactionComponent {** (line 556)
- **public enum AnimatedProgressComponents {** (line 581)
- **public enum FloatingActionButtonComponent {** (line 610)
- **public struct DataImportHeaderComponent: View {** (line 637)
- **public struct FileSelectionComponent: View {** (line 658)
- **public struct ImportProgressComponent: View {** (line 690)
- **public struct ImportButtonComponent: View {** (line 713)
- **public struct ImportInstructionsComponent: View {** (line 742)
- **public struct ThemeSelectorCard: View {** (line 780)
- **public struct ThemeFinancialSummaryCard: View {** (line 835)
- **public struct ThemeAccountsList: View {** (line 887)
- **public struct InsightsLoadingView: View {** (line 943)
- **public struct InsightsEmptyStateView: View {** (line 959)
- **public struct InsightRowView: View {** (line 983)
- **public struct Insight: Identifiable, Sendable {** (line 1042)
- **public struct InsightsFilterBar: View {** (line 1070)
- **public struct FilterChip: View {** (line 1108)
- **public struct InsightDetailView: View {** (line 1134)
- **public struct ForecastData: Identifiable, Sendable {** (line 1286)
- **public struct TransactionEmptyStateView: View {** (line 1310)
- **public struct TransactionListView: View {** (line 1351)
- **public struct TransactionRowView: View {** (line 1380)
- **public struct AddTransactionView: View {** (line 1438)
- **public struct TransactionDetailView: View {** (line 1487)
- **public struct TransactionStatsCard: View {** (line 1552)
- **public struct SearchAndFilterSection: View {** (line 1593)
- **public struct ThemeBudgetProgress: View {** (line 1689)
- **public struct ThemeSubscriptionsList: View {** (line 1701)
- **public struct ThemeTypographyShowcase: View {** (line 1713)
- **public struct ThemeButtonStylesShowcase: View {** (line 1725)
- **public struct ThemeSettingsSheet: View {** (line 1737)
- **public struct PrimaryButtonStyle: ButtonStyle {** (line 1770)
- **public struct SecondaryButtonStyle: ButtonStyle {** (line 1787)
- **public struct TextButtonStyle: ButtonStyle {** (line 1804)
- **public struct DestructiveButtonStyle: ButtonStyle {** (line 1819)

#### Public Functions

- `save() async throws {}` (line 455)
- `delete(_ entity: some Any) async throws {}` (line 456)
- `fetch<T>(_ type: T.Type) async throws -> [T] { [] }` (line 457)
- `getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping)` (line 459)
- `getOrCreateCategory(` (line 466)
- `exportToCSV() async throws -> URL {` (line 481)
- `export(settings: Any) async throws -> URL {` (line 486)
- `predictSpending() async -> Double {` (line 506)
- `analyzePatterns() async -> [String] {` (line 515)
- `makeBody(configuration: Configuration) -> some View {` (line 1777)
- `makeBody(configuration: Configuration) -> some View {` (line 1794)
- `makeBody(configuration: Configuration) -> some View {` (line 1811)
- `makeBody(configuration: Configuration) -> some View {` (line 1826)
- `formatCurrency(_ amount: Double) -> String {` (line 1838)

#### Public Properties

- `var displayName: String {` (line 14)
- `var icon: String {` (line 26)
- `let id: UUID` (line 45)
- `let field: String` (line 46)
- `let message: String` (line 47)
- `let severity: Severity` (line 48)
- `var displayName: String {` (line 66)
- `let success: Bool` (line 79)
- `let transactionsImported: Int` (line 80)
- `let accountsImported: Int` (line 81)
- `let categoriesImported: Int` (line 82)
- `let duplicatesSkipped: Int` (line 83)
- `let errors: [ValidationError]` (line 84)
- `let warnings: [ValidationError]` (line 85)
- `var displayName: String {` (line 121)
- `var icon: String {` (line 129)
- `var displayName: String {` (line 298)
- `var displayName: String {` (line 314)
- `let id = UUID()` (line 326)
- `let title: String` (line 327)
- `let description: String` (line 328)
- `let type: InsightType` (line 329)
- `let priority: InsightPriority` (line 330)
- `let confidence: Double` (line 331)
- `let value: Double?` (line 332)
- `let category: String?` (line 333)
- `let dateGenerated: Date` (line 334)
- `let actionable: Bool` (line 335)
- `var color: Color {` (line 370)
- `let dateColumn: String` (line 389)
- `let amountColumn: String` (line 390)
- `let descriptionColumn: String` (line 391)
- `let categoryColumn: String?` (line 392)
- `let accountColumn: String?` (line 393)
- `let id = UUID()` (line 413)
- `let title: String` (line 414)
- `let destination: String?` (line 415)
- `let path: String` (line 424)
- `let parameters: [String: String]` (line 425)
- `var body: some View {` (line 524)
- `var body: some View {` (line 538)
- `var body: some View {` (line 558)
- `var body: some View {` (line 585)
- `var body: some View {` (line 598)
- `var body: some View {` (line 615)
- `var body: some View {` (line 638)
- `let onFileSelected: () -> Void` (line 660)
- `var body: some View {` (line 662)
- `let progress: Double` (line 691)
- `var body: some View {` (line 693)
- `let isImporting: Bool` (line 714)
- `let action: () -> Void` (line 715)
- `var body: some View {` (line 717)
- `var body: some View {` (line 743)
- `let theme: Any?` (line 782)
- `var body: some View {` (line 789)
- `var body: some View {` (line 836)
- `var body: some View {` (line 888)
- `var body: some View {` (line 944)
- `var body: some View {` (line 960)
- `let insight: FinancialInsight` (line 984)
- `let action: () -> Void` (line 985)
- `var body: some View {` (line 987)
- `let id = UUID()` (line 1043)
- `let title: String` (line 1044)
- `let description: String` (line 1045)
- `let value: String?` (line 1046)
- `let priority: InsightPriority` (line 1047)
- `let category: String?` (line 1048)
- `let dateCreated: Date` (line 1049)
- `var body: some View {` (line 1074)
- `var body: some View {` (line 1113)
- `let insight: FinancialInsight` (line 1135)
- `var body: some View {` (line 1138)
- `let id = UUID()` (line 1287)
- `let date: Date` (line 1288)
- `let predictedBalance: Double` (line 1289)
- `let confidence: Double` (line 1290)
- `let searchText: String` (line 1311)
- `let onAddTransaction: () -> Void` (line 1312)
- `var body: some View {` (line 1314)
- `let transactions: [FinancialTransaction]` (line 1352)
- `let onTransactionTapped: (FinancialTransaction) -> Void` (line 1353)
- `let onDeleteTransaction: (FinancialTransaction) -> Void` (line 1354)
- `var body: some View {` (line 1356)
- `let transaction: FinancialTransaction` (line 1381)
- `let onTap: () -> Void` (line 1382)
- `let onDelete: (() -> Void)?` (line 1383)
- `var body: some View {` (line 1385)
- `let categories: [Any]` (line 1439)
- `let accounts: [Any]` (line 1440)
- `var body: some View {` (line 1443)
- `let transaction: Any` (line 1488)
- `var body: some View {` (line 1491)
- `let transactions: [Any]` (line 1553)
- `var body: some View {` (line 1555)
- `var body: some View {` (line 1598)
- `let theme: Any?` (line 1690)
- `var body: some View {` (line 1696)
- `let theme: Any?` (line 1702)
- `var body: some View {` (line 1708)
- `let theme: Any?` (line 1714)
- `var body: some View {` (line 1720)
- `let theme: Any?` (line 1726)
- `var body: some View {` (line 1732)
- `let theme: Any?` (line 1741)
- `var body: some View {` (line 1753)
- `let theme: Any?` (line 1771)
- `let theme: Any?` (line 1788)
- `let theme: Any?` (line 1805)
- `let theme: Any?` (line 1820)

### create_xcode_project

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/XcodeWrapper/create_xcode_project.swift`

### Package

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Package.swift`

### test_crash_debug

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/test_crash_debug.swift`

### regenerate_project

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/regenerate_project.swift`

### run_tests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/run_tests.swift`

## Dependencies

### Swift Package Manager Dependencies

Package.swift location: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Package.swift`

#### External Dependencies
        .package(path: "../../Shared")
