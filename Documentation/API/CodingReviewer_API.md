# CodingReviewer API Documentation

Generated: Wed Sep 24 09:04:04 CDT 2025
Project: CodingReviewer
Location: /Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer

## Overview

This document contains the public API reference for CodingReviewer.

## Classes and Structs

### CodingReviewerUITests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewerUITests/CodingReviewerUITests.swift`

#### Public Types

- **public class CodingReviewerUITests: XCTestCase {** (line 10)

### PerformanceManager

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/PerformanceManager.swift`

#### Public Types

- **public class PerformanceManager {** (line 10)

#### Public Functions

- `recordFrame() {` (line 19)
- `getCurrentFPS() -> Double {` (line 29)
- `getMemoryUsage() -> Double {` (line 44)
- `isPerformanceDegraded() -> Bool {` (line 62)

### test_linesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/AIGeneratedTests/test_linesTests.swift`

### CodingReviewerUITestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/AIGeneratedTests/CodingReviewerUITestsTests.swift`

### debug_engineTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/AIGeneratedTests/debug_engineTests.swift`

### debug_integrationTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/AIGeneratedTests/debug_integrationTests.swift`

### test_120Tests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/AIGeneratedTests/test_120Tests.swift`

### Dependencies

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Dependencies.swift`

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

### AppDelegateTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/AppDelegateTests.swift`

### SecurityAnalysisServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/SecurityAnalysisServiceTests.swift`

### DocumentationGeneratorTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/DocumentationGeneratorTestsTests.swift`

### StyleAnalysisServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/StyleAnalysisServiceTests.swift`

### DependenciesTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/DependenciesTests.swift`

### CodeReviewServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/CodeReviewServiceTests.swift`

### TestResultsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/TestResultsViewTests.swift`

### PerformanceAnalysisServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/PerformanceAnalysisServiceTests.swift`

### debug_engineTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/debug_engineTestsTests.swift`

### CodingReviewerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/CodingReviewerTests.swift`

### TestGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/TestGeneratorTests.swift`

### PerformanceManagerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/PerformanceManagerTests.swift`

### debug_integrationTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/debug_integrationTestsTests.swift`

### CodingReviewerTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/CodingReviewerTestsTests.swift`

### AnalysisSummaryGeneratorTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/AnalysisSummaryGeneratorTestsTests.swift`

### ContentViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/ContentViewTests.swift`

### PerformanceAnalysisServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/PerformanceAnalysisServiceTestsTests.swift`

### CodeAnalysisEngineIntegrationTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/CodeAnalysisEngineIntegrationTestsTests.swift`

### SecurityAnalysisServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/SecurityAnalysisServiceTestsTests.swift`

### AnalysisResultsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/AnalysisResultsViewTests.swift`

### CodingReviewerUITestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/CodingReviewerUITestsTests.swift`

#### Public Types

- **public class CodingReviewerUITests: XCTestCase {** (line 10)

### DocumentationResultsViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/DocumentationResultsViewTests.swift`

### JSTestGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/UnitTests/JSTestGeneratorTests.swift`

### CodeAnalysisEngineTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/UnitTests/Core/Engine/CodeAnalysisEngineTests.swift`

### MultipleFileTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/UnitTests/Integration/MultipleFileTests.swift`

### LineEndingTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/UnitTests/Style/LineEndingTests.swift`

### IndentationTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/UnitTests/Style/IndentationTests.swift`

### LineLengthTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/UnitTests/Style/LineLengthTests.swift`

### CodeReviewServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/UnitTests/Services/CodeReviewServiceTests.swift`

### StyleAnalysisServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/UnitTests/Services/Analysis/StyleAnalysisServiceTests.swift`

### BugDetectionServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/UnitTests/Services/Analysis/BugDetectionServiceTests.swift`

### IssueRowTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/IssueRowTests.swift`

### WelcomeViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/WelcomeViewTests.swift`

### CodeAnalysisEngineIntegrationTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/IntegrationTests/CodeAnalysisEngineIntegrationTests.swift`

### CodeReviewServiceProtocolTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/CodeReviewServiceProtocolTests.swift`

### TestGeneratorTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/TestGeneratorTestsTests.swift`

### CodingReviewerUITestsTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/CodingReviewerUITestsTestsTests.swift`

#### Public Types

- **public class CodingReviewerUITests: XCTestCase {** (line 3)

### ErrorHandlerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/ErrorHandlerTests.swift`

### StyleAnalysisServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/StyleAnalysisServiceTestsTests.swift`

### DocumentationGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/DocumentationGeneratorTests.swift`

### BugDetectionServiceTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/BugDetectionServiceTestsTests.swift`

### CodeReviewViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/CodeReviewViewTests.swift`

### AnalysisSummaryGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/AnalysisSummaryGeneratorTests.swift`

### SidebarViewTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/SidebarViewTests.swift`

### BugDetectionServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/BugDetectionServiceTests.swift`

### test_linesTestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/test_linesTestsTests.swift`

### test_120TestsTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/test_120TestsTests.swift`

### CodeAnalysisEngineTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/CodeAnalysisEngineTests.swift`

### AIEnhancedCodeAnalysisServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/Tests/AIEnhancedCodeAnalysisServiceTests.swift`

### SecurityAnalysisServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewerTests/SecurityAnalysisServiceTests.swift`

#### Public Types

- **public class SecurityAnalysisServiceTests: XCTestCase {** (line 11)

### StyleAnalysisServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewerTests/StyleAnalysisServiceTests.swift`

#### Public Types

- **public class StyleAnalysisServiceTests: XCTestCase {** (line 11)

### PerformanceAnalysisServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewerTests/PerformanceAnalysisServiceTests.swift`

#### Public Types

- **public class PerformanceAnalysisServiceTests: XCTestCase {** (line 10)

### CodingReviewerTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewerTests/CodingReviewerTests.swift`

#### Public Types

- **public class CodingReviewerTests: XCTestCase {** (line 12)

### TestGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewerTests/TestGeneratorTests.swift`

#### Public Types

- **public class TestGeneratorTests: XCTestCase {** (line 11)

### CodeAnalysisEngineIntegrationTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewerTests/CodeAnalysisEngineIntegrationTests.swift`

#### Public Types

- **public class CodeAnalysisEngineIntegrationTests: XCTestCase {** (line 11)

### DocumentationGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewerTests/DocumentationGeneratorTests.swift`

#### Public Types

- **public class DocumentationGeneratorTests: XCTestCase {** (line 11)

### AnalysisSummaryGeneratorTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewerTests/AnalysisSummaryGeneratorTests.swift`

#### Public Types

- **public class AnalysisSummaryGeneratorTests: XCTestCase {** (line 11)

### BugDetectionServiceTests

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewerTests/BugDetectionServiceTests.swift`

#### Public Types

- **public class BugDetectionServiceTests: XCTestCase {** (line 11)

### AboutView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/AboutView.swift`

### CodeReviewView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/CodeReviewView.swift`

#### Public Types

- **public struct CodeReviewView: View {** (line 10)
- **public struct ResultsPanel: View {** (line 77)

#### Public Properties

- `var body: some View {` (line 23)
- `var body: some View {` (line 84)

### DocumentationResultsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/DocumentationResultsView.swift`

#### Public Types

- **public struct DocumentationResultsView: View {** (line 10)

#### Public Properties

- `var body: some View {` (line 13)

### IssueRow

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/IssueRow.swift`

#### Public Types

- **public struct IssueRow: View {** (line 10)

#### Public Properties

- `var body: some View {` (line 13)

### AnalysisResultsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/AnalysisResultsView.swift`

#### Public Types

- **public struct AnalysisResultsView: View {** (line 10)

#### Public Properties

- `var body: some View {` (line 13)

### SidebarView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/SidebarView.swift`

#### Public Types

- **public struct SidebarView: View {** (line 10)

#### Public Properties

- `var body: some View {` (line 16)

### TestResultsView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/TestResultsView.swift`

#### Public Types

- **public struct TestResultsView: View {** (line 10)

#### Public Properties

- `var body: some View {` (line 13)

### WelcomeView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/WelcomeView.swift`

#### Public Types

- **public struct WelcomeView: View {** (line 10)

#### Public Properties

- `var body: some View {` (line 13)

### ErrorHandler

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Utilities/ErrorHandler.swift`

#### Public Types

- **public enum CodingReviewerErrorHandler {** (line 6)

#### Public Properties

- `var errorDescription: String? {` (line 14)
- `var recoverySuggestion: String? {` (line 27)

### CodingReviewer

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/MainApp/CodingReviewer.swift`

#### Public Types

- **public struct CodingReviewer: App {** (line 12)

#### Public Properties

- `var body: some Scene {` (line 18)

### AppDelegate

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/AppDelegate.swift`

#### Public Types

- **public class AppDelegate: NSObject, NSApplicationDelegate {** (line 4)

#### Public Functions

- `applicationDidFinishLaunching(_: Notification) {` (line 7)
- `applicationWillTerminate(_: Notification) {` (line 12)
- `applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {` (line 17)

### ContentView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/ContentView.swift`

#### Public Types

- **public struct ContentView: View {** (line 16)
- **public struct ContentView_Previews: PreviewProvider {** (line 178)

#### Public Properties

- `var body: some View {` (line 32)

### NewReviewView

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/NewReviewView.swift`

### PerformanceAnalysisService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/PerformanceAnalysisService.swift`

### TestGenerator

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/TestGenerator.swift`

### BugDetectionService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/BugDetectionService.swift`

### CodeAnalysisEngine

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/CodeAnalysisEngine.swift`

### CodeReviewService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/CodeReviewService.swift`

#### Public Types

- **public class CodeReviewService: CodeReviewServiceProtocol {** (line 13)

#### Public Functions

- `initialize() async throws {` (line 28)
- `cleanup() async {` (line 32)
- `healthCheck() async -> ServiceHealthStatus {` (line 36)
- `analyzeCode(_ code: String, language: String, analysisType: AnalysisType) async throws -> CodeAnalysisResult {` (line 42)
- `generateDocumentation(_ code: String, language: String, includeExamples: Bool) async throws -> DocumentationResult {` (line 62)
- `generateTests(_ code: String, language: String, testFramework: String) async throws -> TestGenerationResult {` (line 80)
- `trackReviewProgress(_ reviewId: UUID) async throws {` (line 96)

#### Public Properties

- `let serviceId = code_review_service` (line 14)
- `let version = 1.0.0` (line 15)

### DocumentationGenerator

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/DocumentationGenerator.swift`

### StyleAnalysisService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/StyleAnalysisService.swift`

### CodeReviewServiceProtocol

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/CodeReviewServiceProtocol.swift`

#### Public Types

- **public enum ServiceHealthStatus: Sendable {** (line 35)
- **public enum AnalysisType: String, Codable, CaseIterable, Sendable {** (line 42)
- **public enum IssueSeverity: String, Codable, CaseIterable, Sendable {** (line 51)
- **public enum IssueCategory: String, Codable, CaseIterable, Sendable {** (line 59)
- **public struct CodeIssue: Codable, Identifiable, Sendable {** (line 69)
- **public struct CodeAnalysisResult: Codable, Identifiable, Sendable {** (line 86)
- **public struct DocumentationResult: Codable, Identifiable, Sendable {** (line 105)
- **public struct TestGenerationResult: Codable, Identifiable, Sendable {** (line 120)

#### Public Properties

- `let id: UUID` (line 70)
- `let description: String` (line 71)
- `let severity: IssueSeverity` (line 72)
- `let line: Int?` (line 73)
- `let category: IssueCategory` (line 74)
- `let id: UUID` (line 87)
- `let analysis: String` (line 88)
- `let issues: [CodeIssue]` (line 89)
- `let suggestions: [String]` (line 90)
- `let language: String` (line 91)
- `let analysisType: AnalysisType` (line 92)
- `let id: UUID` (line 106)
- `let documentation: String` (line 107)
- `let language: String` (line 108)
- `let includesExamples: Bool` (line 109)
- `let id: UUID` (line 121)
- `let testCode: String` (line 122)
- `let language: String` (line 123)
- `let testFramework: String` (line 124)
- `let estimatedCoverage: Double` (line 125)

### AIEnhancedCodeAnalysisService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/AIEnhancedCodeAnalysisService.swift`

#### Public Types

- **public class AIEnhancedCodeAnalysisService: ObservableObject {** (line 10)
- **public struct AIAnalysisResult {** (line 661)
- **public enum AIAnalysisType {** (line 668)
- **public struct AICodeAnalysisResult {** (line 677)
- **public struct AICodeGenerationResult {** (line 690)
- **public struct AIRefactoringResult {** (line 699)
- **public struct AIDocumentationResult {** (line 710)
- **public struct AITestGenerationResult {** (line 717)
- **public struct AICodeReviewResult {** (line 725)
- **public struct FileReviewAnalysis {** (line 734)
- **public enum CodeStyle {** (line 743)
- **public struct RefactoringGoal {** (line 757)
- **public enum DocumentationType {** (line 762)
- **public enum TestType {** (line 776)
- **public enum ReviewType {** (line 790)
- **public struct SecurityIssue {** (line 806)
- **public struct PerformanceIssue {** (line 813)
- **public struct BestPracticeViolation {** (line 820)
- **public struct CodeImprovement {** (line 826)
- **public struct CodeComparison {** (line 835)
- **public enum Severity {** (line 844)
- **public enum Impact {** (line 848)
- **public enum Priority {** (line 852)
- **public enum PerformanceImpact {** (line 856)
- **public enum TechnicalDebtLevel {** (line 860)
- **public struct AISuggestion {** (line 864)

#### Public Functions

- `analyzeCodeWithAI(_ code: String, language: String = swift, context: String? = nil) async throws -> AICodeAnalysisResult {` (line 25)
- `generateCodeWithAI(` (line 95)
- `refactorCodeWithAI(` (line 154)
- `generateDocumentationWithAI(` (line 219)
- `generateTestsWithAI(_ code: String, testType: TestType = .unit) async throws -> AITestGenerationResult {` (line 272)
- `performAICodeReview(_ files: [String], reviewType: ReviewType = .comprehensive) async throws -> AICodeReviewResult {` (line 322)

### AnalysisSummaryGenerator

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/AnalysisSummaryGenerator.swift`

### SecurityAnalysisService

File: `/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer/CodingReviewer/Services/SecurityAnalysisService.swift`

## Dependencies
