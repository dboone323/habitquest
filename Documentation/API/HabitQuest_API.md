# HabitQuest API Documentation
**Generated:** Tue Oct 28 14:24:01 CDT 2025
**Framework:** AI-Powered Documentation

## Overview

This document provides comprehensive API documentation for the HabitQuest application.
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
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/Dependencies.swift\n44:    public func log(_ message: String, level: LogLevel = .info) {
50:    public func logSync(_ message: String, level: LogLevel = .info) {
57:    public func error(_ message: String) {
62:    public func warning(_ message: String) {
67:    public func info(_ message: String) {
71:    public func setOutputHandler(_ handler: @escaping @Sendable (String) -> Void) {
77:    public func resetOutputHandler() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/ViewModels/SmartHabitManager.swift\n71:    public func handle(_ action: Action) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/ViewModels/HabitViewModel.swift\n70:    public func handle(_ action: Action) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Utilities/SharedArchitecture.swift\n21:    public func resetError() {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Utilities/PerformanceManager.swift\n51:    public func recordFrame() {
64:    public func getCurrentFPS() -> Double {
79:    public func getCurrentFPS(completion: @escaping (Double) -> Void) {
99:    public func getMemoryUsage() -> Double {
107:    public func getMemoryUsage(completion: @escaping (Double) -> Void) {
117:    public func isPerformanceDegraded() -> Bool {
135:    public func isPerformanceDegraded(completion: @escaping (Bool) -> Void) {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/OllamaClient.swift\n124:    public func generate(
184:    public func generateWithProgress(
204:    public func quantumChat(
304:    public func generateAdvanced(
337:    public func chat(
362:    public func listModels() async throws -> [String] {
368:    public func pullModel(_ modelName: String) async throws {
377:    public func checkModelAvailability(_ model: String) async -> Bool {
388:    public func isServerRunning() async -> Bool {
397:    public func getServerStatus() async -> OllamaServerStatus {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/HuggingFaceClient.swift\n101:    public func generate(
232:    public func analyzeCode(
267:    public func generateDocumentation(
302:    public func generateWithFallback(
391:    public func getPerformanceMetrics() -> PerformanceMetrics {
402:    public func isAvailable() async -> Bool {
414:    public func getHealthStatus() async -> ServiceHealth {
435:    public func generateText(prompt: String, maxTokens: Int, temperature: Double) async throws -> String {
446:    public func analyzeCode(code: String, language: String, analysisType: AnalysisType) async throws -> CodeAnalysisResult {
492:    public func generateCode(description: String, language: String, context: String?) async throws -> CodeGenerationResult {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/AIServiceProtocols.swift\n531:    public func encode(to encoder: Encoder) throws {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/OllamaIntegrationManager.swift\n26:    public func generateText(prompt: String, maxTokens: Int, temperature: Double) async throws -> String {
69:    public func isAvailable() async -> Bool {
74:    public func getHealthStatus() async -> ServiceHealth {
114:    public func analyzeCode(code: String, language: String, analysisType: AnalysisType) async throws -> CodeAnalysisResult {
154:    public func generateDocumentation(code: String, language: String) async throws -> String {
195:    public func generateTests(code: String, language: String) async throws -> String {
238:    public func generateCode(description: String, language: String, context: String?) async throws -> CodeGenerationResult {
296:    public func generateCodeWithFallback(description: String, language: String, context: String?) async throws -> CodeGenerationResult {
371:    public func analyzeCodebase(
469:    public func generateDocumentation(\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Features/DataManagement/DataManagementView.swift\n71:    public func body(content: Content) -> some View {
77:    public func body(content: Content) -> some View {\n\n
```

#### Classes
```swift
// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuest/Core/Services/StreakService.swift\n6:class StreakService {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/test_ai_service.swift\n23:class MockAIHabitRecommender {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/StreakAnalyticsDataTests.swift\n4:class StreakAnalyticsDataTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/ContextAwarenessServiceTests.swift\n4:class ContextAwarenessServiceTests: XCTestCase {\n\n// /Users/danielstevens/Desktop/Quantum-workspace/Projects/HabitQuest/HabitQuestTests/BehavioralAdaptationServiceTests.swift\n4:class BehavioralAdaptationServiceTests: XCTestCase {\n\n
```

#### Protocols
```swift

```

---
*Generated by AI Documentation Agent*
