# MomentumFinance API Documentation
**Generated:** Tue Oct 28 14:23:54 CDT 2025
**Framework:** AI-Powered Documentation

## Overview

This document provides comprehensive API documentation for the MomentumFinance application.
Documentation is automatically generated from code analysis and AI-enhanced descriptions.

## Table of Contents

- [Public API Reference](#public-api-reference)
- [Class Hierarchy](#class-hierarchy)
- [Protocols](#protocols)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)

## Public API Reference

### Manual API Documentation Required

AI generation failed. Please document the following manually:

#### Functions
```swift
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/.build/arm64-apple-macosx/debug/MomentumFinancePackageTests.derived/runner.swift\n41:    public func testBundleWillStart(_ testBundle: Bundle) {
46:    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
51:    public func testCaseWillStart(_ testCase: XCTestCase) {
57:    public func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
62:    public func testCase(_ testCase: XCTestCase, didRecord expectedFailure: XCTExpectedFailure) {
67:    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
74:    public func testCaseDidFinish(_ testCase: XCTestCase) {
80:    public func testSuite(_ testSuite: XCTestSuite, didRecord issue: XCTIssue) {
85:    public func testSuite(_ testSuite: XCTestSuite, didRecord expectedFailure: XCTExpectedFailure) {
90:    public func testSuite(_ testSuite: XCTestSuite, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/PerformanceManager.swift\n51:    public func recordFrame() {
64:    public func getCurrentFPS() -> Double {
79:    public func getCurrentFPS(completion: @escaping (Double) -> Void) {
99:    public func getMemoryUsage() -> Double {
107:    public func getMemoryUsage(completion: @escaping (Double) -> Void) {
117:    public func isPerformanceDegraded() -> Bool {
135:    public func isPerformanceDegraded(completion: @escaping (Bool) -> Void) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Models/ExpenseCategory.swift\n44:    public func totalSpent(for month: Date) -> Double {
64:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Models/FinancialAccount.swift\n73:    public func updateBalance(for transaction: FinancialTransaction) {
89:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Models/SavingsGoal.swift\n84:    public func addFunds(_ amount: Double) {
90:    public func removeFunds(_ amount: Double) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Models/Subscription.swift\n43:    public func nextDueDate(from date: Date) -> Date {
147:    public func processPayment(modelContext: ModelContext) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Models/Budget.swift\n99:    public func calculateRolloverAmount() -> Double {
109:    public func applyRollover(_ amount: Double) {
114:    public func resetRollover() {
121:    public func createNextPeriodBudget(for nextMonth: Date) -> Budget {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Utilities/GoalNotificationScheduler.swift\n18:    public func scheduleProgressReminders(for goals: [SavingsGoal]) {
25:    public func checkMilestones(for goals: [SavingsGoal]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Utilities/HapticManager.swift\n243:    public func body(content: Content) -> some View {
258:    public func body(content: Content) -> some View {
271:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Utilities/BudgetNotificationScheduler.swift\n18:    public func scheduleWarningNotifications(for budgets: [Budget]) {
338:    public func scheduleRolloverNotifications(for budgets: [Budget]) {
349:    public func scheduleSpendingPredictionNotifications(for budgets: [Budget]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Utilities/ErrorHandler.swift\n426:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Utilities/FinancialUtilities.swift\n5:public func formatCurrency(_ amount: Double) -> String {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Utilities/NotificationPermissionManager.swift\n19:    public func requestNotificationPermission() async -> Bool {
41:    public func checkNotificationPermissionAsync() async -> Bool {
47:    public func setupNotificationCategories() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Utilities/NotificationTypes.swift\n67:    public func requestNotificationPermission() async -> Bool {
89:    public func checkNotificationPermissionAsync() async -> Bool {
95:    public func setupNotificationCategories() {
132:    public func scheduleWarningNotifications(for budgets: [Budget]) {
452:    public func scheduleRolloverNotifications(for budgets: [Budget]) {
463:    public func scheduleSpendingPredictionNotifications(for budgets: [Budget]) {
480:    public func scheduleDueDateReminders(for subscriptions: [Subscription]) {
487:    public func scheduleNotifications(for subscriptions: [Subscription]) {
565:    public func scheduleProgressReminders(for goals: [SavingsGoal]) {
572:    public func checkMilestones(for goals: [SavingsGoal]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Utilities/SubscriptionNotificationScheduler.swift\n18:    public func scheduleDueDateReminders(for subscriptions: [Subscription]) {
25:    public func scheduleNotifications(for subscriptions: [Subscription]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Services/SearchEngineService.swift\n21:    public func setModelContext(_ context: ModelContext) {
30:    public func search(query: String, filter: SearchFilter) -> [SearchResult] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Services/SearchTypes.swift\n36:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Services/FinancialServices.swift\n26:    public func save() async throws {
30:    public func delete(_ entity: some Any) async throws {
35:    public func fetch<T>(_: T.Type) async throws -> [T] {
40:    public func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping)
75:    public func getOrCreateCategory(
149:    public func exportToCSV() async throws -> URL {
159:    public func export(settings: [String: Any]) async throws -> URL {
228:    public func predictSpending(for category: ExpenseCategory? = nil, daysAhead: Int = 30) async -> Double {
252:    public func analyzeSpendingPatterns() async -> [SpendingPattern] {
275:    public func detectAnomalies() async -> [TransactionAnomaly] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Services/FinancialIntelligenceEngines.swift\n16:    public func generateInvestmentRecommendations(
26:    public func detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {
35:    public func predictCashFlow(transactions: [Transaction], monthsAhead: Int) -> [CashFlowPrediction] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Services/AdvancedFinancialIntelligence.swift\n64:    public func generateInsights(
100:    public func getInvestmentRecommendations(
113:    public func predictCashFlow(
124:    public func detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {
621:        public func makeSnapshot() async throws -> AdvancedFinancialDomainSnapshot {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Services/FinancialIntelligenceDataProvider.swift\n54:        public func makeSnapshot() async throws -> AdvancedFinancialDomainSnapshot {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Dependencies.swift\n44:    public func log(_ message: String, level: LogLevel = .info) {
50:    public func logSync(_ message: String, level: LogLevel = .info) {
57:    public func error(_ message: String) {
62:    public func warning(_ message: String) {
67:    public func info(_ message: String) {
71:    public func setOutputHandler(_ handler: @escaping @Sendable (String) -> Void) {
77:    public func resetOutputHandler() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Features/Shared/Services/FinancialInsightsService.swift\n51:    public func initialize() async throws {
57:    public func cleanup() async {
66:    public func healthCheck() async -> ServiceHealthStatus {
86:    public func createTransaction(_ transaction: EnhancedFinancialTransaction) async throws -> EnhancedFinancialTransaction {
100:    public func calculateAccountBalance(_ accountId: UUID, asOf: Date? = nil) async throws -> Double {
114:    public func getBudgetInsights(for budgetId: UUID, timeRange: DateInterval) async throws -> BudgetInsights {
155:    public func calculateNetWorth(for userId: String, asOf: Date? = nil) async throws -> NetWorthSummary {
200:    public func generateFinancialRecommendations(for userId: String) async throws -> [FinancialRecommendation] {
267:    public func categorizeTransaction(_ transaction: EnhancedFinancialTransaction) async throws -> TransactionCategory {
301:    public func analyzeSpendingPatterns(for userId: String) async throws -> SpendingPatternAnalysis {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Features/Shared/Services/ServiceLocator.swift\n29:    public func register<T>(_ service: T, for type: T.Type) {
35:    public func registerFactory<T>(_ factory: @escaping () -> T, for type: T.Type) {
43:    public func resolve<T>(_ type: T.Type) -> T? {
64:    public func resolve<T>(_ type: T.Type) -> T {
74:    public func setup(with modelContext: ModelContext) {
85:    public func reset() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Features/Budgets/BudgetsViewModel.swift\n380:    public func scheduleBudgetNotifications(for _: [Budget]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/SearchEngineService.swift\n21:    public func setModelContext(_ context: ModelContext) {
30:    public func search(query: String, filter: SearchFilter) -> [SearchResult] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialIntelligenceEngines.swift\n16:    public func generateInvestmentRecommendations(
26:    public func detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {
35:    public func predictCashFlow(transactions: [Transaction], monthsAhead: Int) -> [CashFlowPrediction] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/AdvancedFinancialIntelligence.swift\n64:    public func generateInsights(
100:    public func getInvestmentRecommendations(
113:    public func predictCashFlow(
124:    public func detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {
621:        public func makeSnapshot() async throws -> AdvancedFinancialDomainSnapshot {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialIntelligenceDataProvider.swift\n54:        public func makeSnapshot() async throws -> AdvancedFinancialDomainSnapshot {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/SearchTypes.swift\n36:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Navigation/MacOSNavigationTypes.swift\n30:        public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Navigation/NavigationCoordinator.swift\n34:        public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utils/HapticManager.swift\n243:    public func body(content: Content) -> some View {
258:    public func body(content: Content) -> some View {
271:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/ExpenseCategory.swift\n44:    public func totalSpent(for month: Date) -> Double {
64:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/FinancialAccount.swift\n73:    public func updateBalance(for transaction: FinancialTransaction) {
89:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SavingsGoal.swift\n84:    public func addFunds(_ amount: Double) {
90:    public func removeFunds(_ amount: Double) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Subscription.swift\n43:    public func nextDueDate(from date: Date) -> Date {
147:    public func processPayment(modelContext: ModelContext) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Budget.swift\n99:    public func calculateRolloverAmount() -> Double {
109:    public func applyRollover(_ amount: Double) {
114:    public func resetRollover() {
121:    public func createNextPeriodBudget(for nextMonth: Date) -> Budget {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Search/SearchEngineService.swift\n21:    public func setModelContext(_ context: ModelContext) {
30:    public func search(query: String, filter: SearchFilter) -> [SearchResult] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Search/SearchTypes.swift\n36:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/GoalNotificationScheduler.swift\n18:    public func scheduleProgressReminders(for goals: [SavingsGoal]) {
25:    public func checkMilestones(for goals: [SavingsGoal]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/BudgetNotificationScheduler.swift\n18:    public func scheduleWarningNotifications(for budgets: [Budget]) {
338:    public func scheduleRolloverNotifications(for budgets: [Budget]) {
349:    public func scheduleSpendingPredictionNotifications(for budgets: [Budget]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/ErrorHandler.swift\n426:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/FinancialUtilities.swift\n5:public func formatCurrency(_ amount: Double) -> String {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/NotificationPermissionManager.swift\n19:    public func requestNotificationPermission() async -> Bool {
41:    public func checkNotificationPermissionAsync() async -> Bool {
47:    public func setupNotificationCategories() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/NotificationTypes.swift\n67:    public func requestNotificationPermission() async -> Bool {
89:    public func checkNotificationPermissionAsync() async -> Bool {
95:    public func setupNotificationCategories() {
132:    public func scheduleWarningNotifications(for budgets: [Budget]) {
452:    public func scheduleRolloverNotifications(for budgets: [Budget]) {
463:    public func scheduleSpendingPredictionNotifications(for budgets: [Budget]) {
480:    public func scheduleDueDateReminders(for subscriptions: [Subscription]) {
487:    public func scheduleNotifications(for subscriptions: [Subscription]) {
565:    public func scheduleProgressReminders(for goals: [SavingsGoal]) {
572:    public func checkMilestones(for goals: [SavingsGoal]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Utilities/SubscriptionNotificationScheduler.swift\n18:    public func scheduleDueDateReminders(for subscriptions: [Subscription]) {
25:    public func scheduleNotifications(for subscriptions: [Subscription]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/ButtonStyles.swift\n17:    public func makeBody(configuration: Configuration) -> some View {
35:    public func makeBody(configuration: Configuration) -> some View {
57:    public func makeBody(configuration: Configuration) -> some View {
71:    public func makeBody(configuration: Configuration) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/ImportExport.swift\n91:    public func getOrCreateAccount(from _: [String], columnMapping _: CSVColumnMapping)
97:    public func getOrCreateCategory(
176:    public func exportData(settings: ExportSettings) async throws -> URL {
212:    public func importFromCSV(_ content: String) async throws -> ImportResult {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/MacOSNavigationTypes.swift\n30:        public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/NavigationCoordinator.swift\n34:        public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/AnimationManager.swift\n116:    public func body(content: Content) -> some View {
136:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/MF_SPMSources_backup/AnimationManager.swift\n116:    public func body(content: Content) -> some View {
136:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/MF_SPMSources_backup/AdvancedFinancialIntelligence.swift\n245:    public func generateInsights(
276:    public func getInvestmentRecommendations(
288:    public func predictCashFlow(
295:    public func detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/MF_SPMSources_backup/ButtonStyles.swift\n16:    public func setThemeMode(_ mode: ThemeMode) {
32:    public func makeBody(configuration: Configuration) -> some View {
50:    public func makeBody(configuration: Configuration) -> some View {
67:    public func makeBody(configuration: Configuration) -> some View {
81:    public func makeBody(configuration: Configuration) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/MF_SPMSources_backup/FinancialInsights.swift\n47:public func fi_findBudgetRecommendations(
109:public func fi_detectCategoryOutliers(_ transactions: [FinancialTransaction]) -> [FinancialInsight] {
136:public func fi_detectRecentFrequencyAnomalies(
169:public func fi_suggestDuplicatePaymentInsights(transactions: [FinancialTransaction]) -> [FinancialInsight] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/MF_SPMSources_backup/AppLogger.swift\n28:    public func log(_ message: String, level: LogLevel, category: Category) {
32:    public func debug(_ message: String) {
36:    public func logWarning(_ message: String) {
40:    public func logError(_ error: Error) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/MF_SPMSources_backup/BudgetsViewModel.swift\n81:    public func budgetsForMonth(_ budgets: [Budget], month: Date) -> [Budget] {
85:    public func totalBudgetedAmount(_ budgets: [Budget], for month: Date) -> Double {
89:    public func remainingBudget(_ budgets: [Budget], for month: Date) -> Double {
96:    public func hasOverBudgetCategories(_ budgets: [Budget], for month: Date) -> Bool {
100:    public func overBudgetCategories(_ budgets: [Budget], for month: Date) -> [Budget] {
104:    public func budgetProgressSummary(_ budgets: [Budget], for month: Date) -> BudgetProgressSummary {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/AdvancedFinancialIntelligence.swift\n245:    public func generateInsights(
276:    public func getInvestmentRecommendations(
288:    public func predictCashFlow(
295:    public func detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/ButtonStyles.swift\n16:    public func setThemeMode(_ mode: ThemeMode) {
32:    public func makeBody(configuration: Configuration) -> some View {
50:    public func makeBody(configuration: Configuration) -> some View {
67:    public func makeBody(configuration: Configuration) -> some View {
81:    public func makeBody(configuration: Configuration) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/FinancialInsights.swift\n47:public func fi_findBudgetRecommendations(
109:public func fi_detectCategoryOutliers(_ transactions: [FinancialTransaction]) -> [FinancialInsight] {
136:public func fi_detectRecentFrequencyAnomalies(
169:public func fi_suggestDuplicatePaymentInsights(transactions: [FinancialTransaction]) -> [FinancialInsight] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/AppLogger.swift\n28:    public func log(_ message: String, level: LogLevel, category: Category) {
32:    public func debug(_ message: String) {
36:    public func logWarning(_ message: String) {
40:    public func logError(_ error: Error) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/SPMSources/BudgetsViewModel.swift\n81:    public func budgetsForMonth(_ budgets: [Budget], month: Date) -> [Budget] {
85:    public func totalBudgetedAmount(_ budgets: [Budget], for month: Date) -> Double {
89:    public func remainingBudget(_ budgets: [Budget], for month: Date) -> Double {
96:    public func hasOverBudgetCategories(_ budgets: [Budget], for month: Date) -> Bool {
100:    public func overBudgetCategories(_ budgets: [Budget], for month: Date) -> [Budget] {
104:    public func budgetProgressSummary(_ budgets: [Budget], for month: Date) -> BudgetProgressSummary {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/SearchEngineService.swift\n21:    public func setModelContext(_ context: ModelContext) {
30:    public func search(query: String, filter: SearchFilter) -> [SearchResult] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Intelligence/FinancialIntelligenceEngines.swift\n16:    public func generateInvestmentRecommendations(
26:    public func detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {
35:    public func predictCashFlow(transactions: [Transaction], monthsAhead: Int) -> [CashFlowPrediction] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Intelligence/AdvancedFinancialIntelligence.swift\n64:    public func generateInsights(
100:    public func getInvestmentRecommendations(
113:    public func predictCashFlow(
124:    public func detectAnomalies(in transactions: [Transaction]) -> [TransactionAnomaly] {
621:        public func makeSnapshot() async throws -> AdvancedFinancialDomainSnapshot {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Intelligence/FinancialIntelligenceDataProvider.swift\n54:        public func makeSnapshot() async throws -> AdvancedFinancialDomainSnapshot {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/SearchTypes.swift\n36:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Features/GlobalSearch/SearchEngineService.swift\n14:    public func setModelContext(_ context: ModelContext) {
18:    public func search(query: String, filter: SearchFilter = .all) -> [SearchResult] {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Navigation/MacOSNavigationTypes.swift\n30:        public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Navigation/NavigationCoordinator.swift\n34:        public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Utils/HapticManager.swift\n243:    public func body(content: Content) -> some View {
258:    public func body(content: Content) -> some View {
271:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Models/ExpenseCategory.swift\n44:    public func totalSpent(for month: Date) -> Double {
64:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Models/FinancialAccount.swift\n73:    public func updateBalance(for transaction: FinancialTransaction) {
89:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Models/SavingsGoal.swift\n84:    public func addFunds(_ amount: Double) {
90:    public func removeFunds(_ amount: Double) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Models/Subscription.swift\n43:    public func nextDueDate(from date: Date) -> Date {
147:    public func processPayment(modelContext: ModelContext) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Models/DataImportModels.swift\n131:    public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Models/Budget.swift\n99:    public func calculateRolloverAmount() -> Double {
109:    public func applyRollover(_ amount: Double) {
114:    public func resetRollover() {
121:    public func createNextPeriodBudget(for nextMonth: Date) -> Budget {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Utilities/GoalNotificationScheduler.swift\n18:    public func scheduleProgressReminders(for goals: [SavingsGoal]) {
25:    public func checkMilestones(for goals: [SavingsGoal]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Utilities/BudgetNotificationScheduler.swift\n18:    public func scheduleWarningNotifications(for budgets: [Budget]) {
338:    public func scheduleRolloverNotifications(for budgets: [Budget]) {
349:    public func scheduleSpendingPredictionNotifications(for budgets: [Budget]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Utilities/ErrorHandler.swift\n426:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Utilities/FinancialUtilities.swift\n5:public func formatCurrency(_ amount: Double) -> String {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Utilities/NotificationPermissionManager.swift\n19:    public func requestNotificationPermission() async -> Bool {
41:    public func checkNotificationPermissionAsync() async -> Bool {
47:    public func setupNotificationCategories() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Utilities/NotificationTypes.swift\n67:    public func requestNotificationPermission() async -> Bool {
89:    public func checkNotificationPermissionAsync() async -> Bool {
95:    public func setupNotificationCategories() {
132:    public func scheduleWarningNotifications(for budgets: [Budget]) {
452:    public func scheduleRolloverNotifications(for budgets: [Budget]) {
463:    public func scheduleSpendingPredictionNotifications(for budgets: [Budget]) {
480:    public func scheduleDueDateReminders(for subscriptions: [Subscription]) {
487:    public func scheduleNotifications(for subscriptions: [Subscription]) {
565:    public func scheduleProgressReminders(for goals: [SavingsGoal]) {
572:    public func checkMilestones(for goals: [SavingsGoal]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Utilities/SubscriptionNotificationScheduler.swift\n18:    public func scheduleDueDateReminders(for subscriptions: [Subscription]) {
25:    public func scheduleNotifications(for subscriptions: [Subscription]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Components/ButtonStyles.swift\n13:    public func makeBody(configuration: Configuration) -> some View {
30:    public func makeBody(configuration: Configuration) -> some View {
47:    public func makeBody(configuration: Configuration) -> some View {
62:    public func makeBody(configuration: Configuration) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Theme/ButtonStyles.swift\n17:    public func makeBody(configuration: Configuration) -> some View {
35:    public func makeBody(configuration: Configuration) -> some View {
57:    public func makeBody(configuration: Configuration) -> some View {
71:    public func makeBody(configuration: Configuration) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/ImportExport.swift\n16:    public func exportToCSV(settings: ExportSettings) async throws -> URL {
51:    public func importFromCSV(_ content: String) async throws -> ImportResult {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/NavigationCoordinator.swift\n44:        public func hash(into hasher: inout Hasher) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/BudgetsViewModel.swift\n246:    public func scheduleBudgetNotifications(for _: [Budget]) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Services/FinancialServices.swift\n26:    public func save() async throws {
30:    public func delete(_ entity: some Any) async throws {
35:    public func fetch<T>(_: T.Type) async throws -> [T] {
40:    public func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping)
75:    public func getOrCreateCategory(
149:    public func exportToCSV() async throws -> URL {
159:    public func export(settings: [String: Any]) async throws -> URL {
228:    public func predictSpending(for category: ExpenseCategory? = nil, daysAhead: Int = 30) async -> Double {
252:    public func analyzeSpendingPatterns() async -> [SpendingPattern] {
275:    public func detectAnomalies() async -> [TransactionAnomaly] {\n\n
```

#### Classes
```swift
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Models/SampleData.swift\n11:class SampleDataGenerator {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SampleData.swift\n11:class SampleDataGenerator {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/UI/macOS/KeyboardShortcutManager.swift\n9:    class KeyboardShortcutManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Models/SampleData.swift\n11:class SampleDataGenerator {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Components/Settings/ImportDataView.swift\n142:    class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {\n\n
```

#### Protocols
```swift
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Models/SampleDataGenerators.swift\n14:protocol LegacyDataGenerator {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Core/Services/FinancialAnalyticsSharedCore.swift\n3:protocol FinancialAnalyticsTransactionConvertible {
10:protocol FinancialAnalyticsAccountConvertible {
15:protocol FinancialAnalyticsBudgetConvertible {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Intelligence/FinancialAnalyticsSharedCore.swift\n3:protocol FinancialAnalyticsTransactionConvertible {
10:protocol FinancialAnalyticsAccountConvertible {
15:protocol FinancialAnalyticsBudgetConvertible {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/SampleDataGenerators.swift\n14:protocol LegacyDataGenerator {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Shared/Models/Generators/CategoriesGenerator.swift\n6:protocol DataGenerator {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/UI/macOS/DragAndDropSupport.swift\n17:    protocol DraggableFinanceItem: Identifiable, Codable {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Intelligence/FinancialAnalyticsSharedCore.swift\n3:protocol FinancialAnalyticsTransactionConvertible {
10:protocol FinancialAnalyticsAccountConvertible {
15:protocol FinancialAnalyticsBudgetConvertible {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Models/SampleDataGenerators.swift\n14:protocol LegacyDataGenerator {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/Sources/Core/Models/Generators/CategoriesGenerator.swift\n6:protocol DataGenerator {\n\n
```

---
*Generated by AI Documentation Agent*
