# PlannerApp API Documentation
**Generated:** Tue Oct 28 14:24:04 CDT 2025
**Framework:** AI-Powered Documentation

## Overview

This document provides comprehensive API documentation for the PlannerApp application.
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
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/ViewModels/DashboardViewModel.swift\n127:    public func handle(_ action: Action) async {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Core/OllamaClient.swift\n124:    public func generate(
186:    public func generateWithProgress(
206:    public func quantumChat(
278:    public func generateAdvanced(
311:    public func chat(
336:    public func listModels() async throws -> [String] {
342:    public func pullModel(_ modelName: String) async throws {
351:    public func checkModelAvailability(_ model: String) async -> Bool {
362:    public func isServerRunning() async -> Bool {
371:    public func getServerStatus() async -> OllamaServerStatus {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Core/AIServiceProtocols.swift\n531:    public func encode(to encoder: Encoder) throws {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Core/OllamaIntegrationManager.swift\n27:    public func generateText(prompt: String, maxTokens: Int, temperature: Double) async throws -> String {
70:    public func isAvailable() async -> Bool {
75:    public func getHealthStatus() async -> ServiceHealth {
115:    public func analyzeCode(code: String, language: String, analysisType: AnalysisType) async throws -> CodeAnalysisResult {
155:    public func generateDocumentation(code: String, language: String) async throws -> String {
196:    public func generateTests(code: String, language: String) async throws -> String {
239:    public func generateCode(description: String, language: String, context: String?) async throws -> CodeGenerationResult {
299:    public func generateCodeWithFallback(description: String, language: String, context: String?) async throws -> CodeGenerationResult {
374:    public func analyzeCodebase(
472:    public func generateDocumentation(\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/PlatformAdaptiveNavigation.swift\n113:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Components/VisualEnhancements.swift\n137:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Accessibility/AccessibilityEnhancements.swift\n198:    public func body(content: Content) -> some View {
219:    public func body(content: Content) -> some View {
266:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Views/Settings/SettingsView.swift\n255:    public func body(content: Content) -> some View {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Services/PerformanceManager.swift\n51:    public func recordFrame() {
64:    public func getCurrentFPS() -> Double {
79:    public func getCurrentFPS(completion: @escaping (Double) -> Void) {
99:    public func getMemoryUsage() -> Double {
107:    public func getMemoryUsage(completion: @escaping (Double) -> Void) {
117:    public func isPerformanceDegraded() -> Bool {
135:    public func isPerformanceDegraded(completion: @escaping (Bool) -> Void) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Services/Dependencies.swift\n44:    public func log(_ message: String, level: LogLevel = .info) {
50:    public func logSync(_ message: String, level: LogLevel = .info) {
57:    public func error(_ message: String) {
62:    public func warning(_ message: String) {
67:    public func info(_ message: String) {
71:    public func setOutputHandler(_ handler: @escaping @Sendable (String) -> Void) {
77:    public func resetOutputHandler() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Services/AITaskPrioritizationService.swift\n33:    public func parseNaturalLanguageTask(_ input: String) async throws -> PlannerTask? {
86:    public func generateTaskSuggestions(
263:    public func generateProductivityInsights(\n\n
```

#### Classes
```swift
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Tools/Automation/run_tests.swift\n65:class TaskDataManager {
145:class JournalDataManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Core/SharedArchitecture.swift\n60:class BaseListViewModel<StateType, ActionType>: ObservableObject {
99:class BaseFormViewModel<StateType, ActionType>: ObservableObject {
141:class PerformanceMonitor: ObservableObject {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/CloudKit/CloudKitMigrationHelper.swift\n7:class CloudKitMigrationHelper {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Platform/PlatformFeatures.swift\n245:    class MenuBarManager: ObservableObject {
313:    class TouchBarProvider: NSViewController {
482:class IOSFeatureProvider: PlatformFeatureProvider {
520:class MacOSFeatureProvider: PlatformFeatureProvider {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Utilities/EncryptionManager.swift\n38:class EncryptionManager {
168:class KeychainManager {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Utilities/NetworkMonitor.swift\n13:class NetworkMonitor {\n\n
```

#### Protocols
```swift
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Core/SharedArchitecture.swift\n174:protocol StorageService {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/CloudKit/CloudKitManager.swift\n21:protocol CloudKitService {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Platform/PlatformFeatures.swift\n474:protocol PlatformFeatureProvider {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Models/PlannerEntities.swift\n4:protocol PlannerEntity: Identifiable, Codable, Hashable {
14:protocol Schedulable {
19:protocol PlannerRenderable {
25:protocol PlannerPriority: Codable, Hashable {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Services/CalendarDataManager.swift\n5:protocol CalendarDataManaging {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Services/TaskDataManager.swift\n5:protocol TaskDataManaging {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Services/GoalDataManager.swift\n5:protocol GoalDataManaging {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Services/JournalDataManager.swift\n5:protocol JournalDataManaging {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/Services/PlannerDataManager.swift\n5:protocol DataManaging {\n\n
```

---
*Generated by AI Documentation Agent*
