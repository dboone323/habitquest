//
//  CodeAnalysisEngine.swift
//  CodingReviewer
//
//  Main analysis engine that orchestrates all analysis services
//

import CodingReviewer
import Foundation

/// Main analysis engine that coordinates all code analysis services
struct CodeAnalysisEngine {
    // Service instances
    private let bugDetector = BugDetectionService()
    private let performanceAnalyzer = PerformanceAnalysisService()
    private let securityAnalyzer = SecurityAnalysisService()
    private let styleAnalyzer = StyleAnalysisService()
    private let documentationGenerator = DocumentationGenerator()
    private let testGenerator = TestGenerator()
    private let summaryGenerator = AnalysisSummaryGenerator()

    /// Perform basic analysis using all appropriate services
    /// - Parameters:
    ///   - code: The source code to analyze
    ///   - language: The programming language of the code
    ///   - analysisType: The type of analysis to perform
    /// - Returns: Array of detected code issues
    func performBasicAnalysis(code: String, language: String, analysisType: AnalysisType) -> [CodeIssue] {
        var issues: [CodeIssue] = []

        // Perform analysis based on analysis type
        switch analysisType {
        case .bugs:
            issues.append(contentsOf: self.bugDetector.detectBasicBugs(code: code, language: language))
        case .performance:
            issues.append(contentsOf: self.performanceAnalyzer.detectPerformanceIssues(in: code, language: language))
        case .security:
            issues.append(contentsOf: self.securityAnalyzer.detectSecurityIssues(code: code, language: language))
        case .style:
            issues.append(contentsOf: self.styleAnalyzer.detectStyleIssues(code: code, language: language))
        case .comprehensive:
            issues.append(contentsOf: self.bugDetector.detectBasicBugs(code: code, language: language))
            issues.append(contentsOf: self.performanceAnalyzer.detectPerformanceIssues(in: code, language: language))
            issues.append(contentsOf: self.securityAnalyzer.detectSecurityIssues(code: code, language: language))
            issues.append(contentsOf: self.styleAnalyzer.detectStyleIssues(code: code, language: language))
        }

        return issues
    }

    /// Generate suggestions for code improvement
    /// - Parameters:
    ///   - code: The source code
    ///   - language: The programming language
    ///   - analysisType: The type of analysis
    /// - Returns: Array of suggestion strings
    func generateSuggestions(code: String, language: String, analysisType: AnalysisType) -> [String] {
        self.summaryGenerator.generateSuggestions(code: code, language: language, analysisType: analysisType)
    }

    /// Generate analysis summary
    /// - Parameters:
    ///   - issues: Issues found during analysis
    ///   - suggestions: Generated suggestions
    ///   - analysisType: Type of analysis performed
    /// - Returns: Formatted summary string
    func generateAnalysisSummary(
        issues: [CodeIssue],
        suggestions: [String],
        analysisType: AnalysisType,
        language: String? = nil
    ) -> String {
        self.summaryGenerator.generateAnalysisSummary(
            issues: issues,
            suggestions: suggestions,
            analysisType: analysisType,
            language: language
        )
    }

    /// Generate basic documentation
    /// - Parameters:
    ///   - code: The source code
    ///   - language: The programming language
    ///   - includeExamples: Whether to include examples
    /// - Returns: Generated documentation string
    func generateBasicDocumentation(code: String, language: String, includeExamples: Bool) -> String {
        self.documentationGenerator.generateBasicDocumentation(code: code, language: language, includeExamples: includeExamples)
    }

    /// Generate basic test code
    /// - Parameters:
    ///   - code: The source code
    ///   - language: The programming language
    ///   - testFramework: The test framework to use
    /// - Returns: Generated test code string
    func generateBasicTests(code: String, language: String, testFramework: String) -> String {
        self.testGenerator.generateBasicTests(code: code, language: language, testFramework: testFramework)
    }

    /// Estimate test coverage
    /// - Parameters:
    ///   - code: The source code
    ///   - testCode: The generated test code
    /// - Returns: Estimated coverage percentage
    func estimateTestCoverage(code: String, testCode: String) -> Double {
        self.testGenerator.estimateTestCoverage(code: code, testCode: testCode)
    }

    /// Analyze code and return comprehensive analysis result
    /// - Parameters:
    ///   - code: The source code to analyze
    ///   - language: The programming language of the code
    ///   - analysisTypes: Array of analysis types to perform
    /// - Returns: Complete analysis result with issues and suggestions
    func analyzeCode(code: String, language: String, analysisTypes: [AnalysisType]) -> CodeAnalysisResult {
        var allIssues: [CodeIssue] = []
        var allSuggestions: [String] = []

        // Perform analysis for each type
        for analysisType in analysisTypes {
            let serviceIssues = self.performBasicAnalysis(code: code, language: language, analysisType: analysisType)
            allIssues.append(contentsOf: serviceIssues)
        }

        // Generate summary analysis text
        let analysisSummary = self.generateAnalysisSummary(
            issues: allIssues,
            suggestions: allSuggestions,
            analysisType: .comprehensive,
            language: language
        )

        return CodeAnalysisResult(
            analysis: analysisSummary,
            issues: allIssues,
            suggestions: allSuggestions,
            language: language,
            analysisType: .comprehensive
        )
    }
}
