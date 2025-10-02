//
//  AnalysisSummaryGeneratorTests.swift
//  CodingReviewerTests
//
//  Unit tests for AnalysisSummaryGenerator
//

@testable import CodingReviewer
import XCTest

final class AnalysisSummaryGeneratorTests: XCTestCase {
    var summaryGenerator: AnalysisSummaryGenerator!

    override func setUp() {
        super.setUp()
        summaryGenerator = AnalysisSummaryGenerator()
    }

    override func tearDown() {
        summaryGenerator = nil
        super.tearDown()
    }

    // MARK: - Basic Summary Generation Tests

    func testGenerateSummary_EmptyIssues() {
        // Given empty issues array
        let issues: [CodeIssue] = []

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then summary should indicate no issues found
        XCTAssertFalse(summary.isEmpty)
        XCTAssertTrue(summary.contains("Analysis completed"))
        XCTAssertTrue(summary.contains("No issues found"))
    }

    func testGenerateSummary_SingleIssue() {
        // Given single issue
        let issue = CodeIssue(
            description: "Force unwrap detected",
            severity: IssueSeverity.high,
            line: 10,
            category: IssueCategory.bug
        )
        let issues = [issue]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(
            issues: issues,
            suggestions: ["Use optional binding instead"],
            analysisType: .bugs
        )

        // Then summary should contain issue details
        XCTAssertTrue(summary.contains("Analysis completed"))
        XCTAssertTrue(summary.contains("1 issue(s)"))
        XCTAssertTrue(summary.contains("Force unwrap detected"))
        XCTAssertTrue(summary.contains("High"))
    }

    func testGenerateSummary_MultipleIssues() {
        // Given multiple issues of different types
        let issues = [
            CodeIssue(description: "Force unwrap", severity: IssueSeverity.high, line: 10, category: IssueCategory.bug),
            CodeIssue(description: "Eval usage", severity: IssueSeverity.critical, line: 20, category: IssueCategory.security),
            CodeIssue(description: "Inefficient loop", severity: IssueSeverity.medium, line: 30, category: IssueCategory.performance),
            CodeIssue(description: "Long line", severity: IssueSeverity.low, line: 40, category: IssueCategory.style),
        ]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then summary should contain all issue types and severities
        XCTAssertTrue(summary.contains("Total Issues: 4"))
        XCTAssertTrue(summary.contains("Critical Priority: 1"))
        XCTAssertTrue(summary.contains("High Priority: 1"))
        XCTAssertTrue(summary.contains("Medium Priority: 1"))
        XCTAssertTrue(summary.contains("Low Priority: 1"))
        XCTAssertTrue(summary.contains("Bug Issues: 1"))
        XCTAssertTrue(summary.contains("Security Issues: 1"))
        XCTAssertTrue(summary.contains("Performance Issues: 1"))
        XCTAssertTrue(summary.contains("Style Issues: 1"))
    }

    func testGenerateSummary_IssuesByFile() {
        // Given issues in different files
        let issues = [
            CodeIssue(description: "Issue 1", severity: IssueSeverity.high, line: 10, category: IssueCategory.bug),
            CodeIssue(description: "Issue 2", severity: IssueSeverity.high, line: 20, category: IssueCategory.bug),
            CodeIssue(description: "Issue 3", severity: IssueSeverity.medium, line: 15, category: IssueCategory.security),
        ]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then summary should group issues by file
        XCTAssertTrue(summary.contains("FileA.swift: 2 issues"))
        XCTAssertTrue(summary.contains("FileB.js: 1 issue"))
    }

    // MARK: - Severity Distribution Tests

    func testGenerateSummary_SeverityDistribution() {
        // Given issues with different severities
        let issues = [
            CodeIssue(description: "Critical bug", severity: IssueSeverity.critical, line: 1, category: IssueCategory.bug),
            CodeIssue(description: "Another critical", severity: IssueSeverity.critical, line: 2, category: IssueCategory.bug),
            CodeIssue(description: "High security", severity: IssueSeverity.high, line: 3, category: IssueCategory.security),
            CodeIssue(description: "Medium perf", severity: IssueSeverity.medium, line: 4, category: IssueCategory.performance),
            CodeIssue(description: "Low style", severity: IssueSeverity.low, line: 5, category: IssueCategory.style),
        ]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then severity counts should be correct
        XCTAssertTrue(summary.contains("Critical Priority: 2"))
        XCTAssertTrue(summary.contains("High Priority: 1"))
        XCTAssertTrue(summary.contains("Medium Priority: 1"))
        XCTAssertTrue(summary.contains("Low Priority: 1"))
    }

    func testGenerateSummary_TypeDistribution() {
        // Given issues with different types
        let issues = [
            CodeIssue(description: "Bug 1", severity: IssueSeverity.high, line: 1, category: IssueCategory.bug),
            CodeIssue(description: "Bug 2", severity: IssueSeverity.high, line: 2, category: IssueCategory.bug),
            CodeIssue(description: "Security 1", severity: IssueSeverity.high, line: 3, category: IssueCategory.security),
            CodeIssue(description: "Performance 1", severity: IssueSeverity.high, line: 4, category: IssueCategory.performance),
            CodeIssue(description: "Style 1", severity: IssueSeverity.high, line: 5, category: IssueCategory.style),
        ]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then type counts should be correct
        XCTAssertTrue(summary.contains("Bug Issues: 2"))
        XCTAssertTrue(summary.contains("Security Issues: 1"))
        XCTAssertTrue(summary.contains("Performance Issues: 1"))
        XCTAssertTrue(summary.contains("Style Issues: 1"))
    }

    // MARK: - Language-Specific Tests

    func testGenerateSummary_SwiftLanguage() {
        // Given Swift issues
        let issues = [
            CodeIssue(description: "Swift issue", severity: IssueSeverity.high, line: 1, category: IssueCategory.bug),
        ]

        // When generating summary for Swift
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then summary should mention Swift
        XCTAssertTrue(summary.contains("Swift code analysis"))
    }

    func testGenerateSummary_JavaScriptLanguage() {
        // Given JavaScript issues
        let issues = [
            CodeIssue(description: "JS issue", severity: IssueSeverity.high, line: 1, category: IssueCategory.security),
        ]

        // When generating summary for JavaScript
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then summary should mention JavaScript
        XCTAssertTrue(summary.contains("JavaScript code analysis"))
    }

    // MARK: - Detailed Issues Section Tests

    func testGenerateSummary_DetailedIssuesSection() {
        // Given issues with suggestions
        let issues = [
            CodeIssue(description: "Force unwrap", severity: IssueSeverity.high, line: 10, category: IssueCategory.bug),
            CodeIssue(description: "Eval usage", severity: IssueSeverity.critical, line: 20, category: IssueCategory.security),
        ]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(
            issues: issues,
            suggestions: ["Use optional binding", "Avoid eval for security"],
            analysisType: .comprehensive
        )

        // Then detailed issues section should contain all details
        XCTAssertTrue(summary.contains("## Detailed Issues"))
        XCTAssertTrue(summary.contains("**File:** Test.swift"))
        XCTAssertTrue(summary.contains("**Line:** 10"))
        XCTAssertTrue(summary.contains("**Severity:** High"))
        XCTAssertTrue(summary.contains("**Type:** Bug"))
        XCTAssertTrue(summary.contains("Force unwrap"))
        XCTAssertTrue(summary.contains("Use optional binding"))

        XCTAssertTrue(summary.contains("**File:** Test.js"))
        XCTAssertTrue(summary.contains("**Line:** 20"))
        XCTAssertTrue(summary.contains("**Severity:** Critical"))
        XCTAssertTrue(summary.contains("**Type:** Security"))
        XCTAssertTrue(summary.contains("Eval usage"))
        XCTAssertTrue(summary.contains("Avoid eval for security"))
    }

    func testGenerateSummary_IssuesWithoutSuggestions() {
        // Given issues without suggestions
        let issues = [
            CodeIssue(description: "Long line", severity: IssueSeverity.low, line: 1, category: IssueCategory.style),
        ]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then summary should still include the issue but without suggestion section
        XCTAssertTrue(summary.contains("Long line"))
        XCTAssertFalse(summary.contains("**Suggestion:**"))
    }

    // MARK: - Edge Cases

    func testGenerateSummary_VeryLongMessages() {
        // Given issue with very long message
        let longMessage = String(repeating: "A", count: 1000)
        let issues = [
            CodeIssue(description: longMessage, severity: IssueSeverity.high, line: 1, category: IssueCategory.bug),
        ]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then summary should handle long messages gracefully
        XCTAssertTrue(summary.contains(longMessage))
    }

    func testGenerateSummary_SpecialCharactersInMessages() {
        // Given issues with special characters
        let issues = [
            CodeIssue(description: "Issue with <>&\"'", severity: IssueSeverity.high, line: 1, category: IssueCategory.bug),
        ]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then special characters should be preserved
        XCTAssertTrue(summary.contains("Issue with <>&\"'"))
    }

    func testGenerateSummary_ManyFiles() {
        // Given issues across many files
        var issues: [CodeIssue] = []
        for issueIndex in 1 ... 10 {
            issues.append(CodeIssue(
                description: "Issue \(issueIndex)",
                severity: IssueSeverity.high,
                line: issueIndex,
                category: IssueCategory.bug
            ))
        }

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then all files should be listed
        for issueIndex in 1 ... 10 {
            XCTAssertTrue(summary.contains("File\(issueIndex).swift: 1 issue"))
        }
    }

    // MARK: - Summary Structure Tests

    func testGenerateSummary_Structure() {
        // Given some issues
        let issues = [
            CodeIssue(description: "Test issue", severity: IssueSeverity.high, line: 1, category: IssueCategory.bug),
        ]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then summary should have proper structure
        XCTAssertTrue(summary.hasPrefix("# Code Analysis Summary"))
        XCTAssertTrue(summary.contains("## Summary Statistics"))
        XCTAssertTrue(summary.contains("## Issues by File"))
        XCTAssertTrue(summary.contains("## Detailed Issues"))
    }

    func testGenerateSummary_NoEmptySections() {
        // Given issues that don't create empty sections
        let issues = [
            CodeIssue(description: "Test", severity: IssueSeverity.high, line: 1, category: IssueCategory.bug),
        ]

        // When generating summary
        let summary = summaryGenerator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

        // Then there should be no empty sections
        let lines = summary.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("##") {
                // Next line should not be empty if there's content
                if let index = lines.firstIndex(of: line), index + 1 < lines.count {
                    XCTAssertFalse(lines[index + 1].isEmpty || lines[index + 1].hasPrefix("##"))
                }
            }
        }
    }
}
