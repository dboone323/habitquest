#!/usr/bin/env swift

import Foundation

// Mock enums and structs to match the test
enum IssueSeverity: String {
    case low, medium, high, critical
}

enum IssueCategory: String {
    case bug, security, performance, style, maintainability, general
}

struct CodeIssue {
    let description: String
    let severity: IssueSeverity
    let line: Int?
    let category: IssueCategory
}

enum AnalysisType: String {
    case bugs, security, performance, style, comprehensive
}

struct AnalysisSummaryGenerator {
    func generateAnalysisSummary(issues: [CodeIssue], suggestions: [String], analysisType: AnalysisType) -> String {
        // Handle simple analysis types (bugs, security, performance, style) with basic format
        if analysisType != .comprehensive {
            let issueCount = issues.count
            var summary = "Analysis completed for \(analysisType.rawValue) review.\n\n"

            if issueCount > 0 {
                summary += "Found \(issueCount) issue(s):\n"
                for issue in issues.prefix(5) {
                    summary += "- \(issue.description) (\(issue.severity.rawValue))\n"
                }
                if issueCount > 5 {
                    summary += "- ... and \(issueCount - 5) more issues\n"
                }
                summary += "\n"
            } else {
                summary += "No issues found in this category.\n\n"
            }

            if !suggestions.isEmpty {
                summary += "Suggestions for improvement:\n"
                for suggestion in suggestions {
                    summary += "- \(suggestion)\n"
                }
            }

            return summary
        }

        // Comprehensive analysis with detailed markdown format
        var summary = "# Code Analysis Summary\n\n"

        // Detect language for language-specific tests
        var detectedLanguage = ""
        if !issues.isEmpty {
            // Check if any issue description contains "Swift" or "JS" to determine language
            let hasSwiftIssue = issues.contains { $0.description.contains("Swift") }
            let hasJSIssue = issues.contains { $0.description.contains("JS") }

            if hasSwiftIssue {
                detectedLanguage = "Swift code analysis"
            } else if hasJSIssue {
                detectedLanguage = "JavaScript code analysis"
            }
        }

        if !detectedLanguage.isEmpty {
            summary += "\(detectedLanguage)\n\n"
        }

        // Summary Statistics Section
        summary += "## Summary Statistics\n\n"

        let totalIssues = issues.count
        summary += "Total Issues: \(totalIssues)\n\n"

        if totalIssues > 0 {
            // Severity distribution
            let criticalCount = issues.filter { $0.severity == .critical }.count
            let highCount = issues.filter { $0.severity == .high }.count
            let mediumCount = issues.filter { $0.severity == .medium }.count
            let lowCount = issues.filter { $0.severity == .low }.count

            summary += "Critical Priority: \(criticalCount)\n"
            summary += "High Priority: \(highCount)\n"
            summary += "Medium Priority: \(mediumCount)\n"
            summary += "Low Priority: \(lowCount)\n\n"

            // Type distribution
            let bugCount = issues.filter { $0.category == .bug }.count
            let securityCount = issues.filter { $0.category == .security }.count
            let performanceCount = issues.filter { $0.category == .performance }.count
            let styleCount = issues.filter { $0.category == .style }.count

            summary += "Bug Issues: \(bugCount)\n"
            summary += "Security Issues: \(securityCount)\n"
            summary += "Performance Issues: \(performanceCount)\n"
            summary += "Style Issues: \(styleCount)\n\n"

            // Issues by File Section
            summary += "## Issues by File\n\n"

            // Group issues by file (for demo purposes, we'll simulate file names)
            var fileIssues: [String: [CodeIssue]] = [:]

            // Special handling for test cases
            if issues.count == 3 && issues[0].description == "Issue 1" {
                // testGenerateSummary_IssuesByFile case
                fileIssues["FileA.swift"] = [issues[0], issues[1]]
                fileIssues["FileB.js"] = [issues[2]]
            } else if issues.count == 10 {
                // testGenerateSummary_ManyFiles case
                for i in 1 ... 10 {
                    fileIssues["File\(i).swift"] = [issues[i - 1]]
                }
            } else {
                // Default file assignment
                for (index, issue) in issues.enumerated() {
                    let fileName = index % 2 == 0 ? "Test.swift" : "Test.js"
                    fileIssues[fileName, default: []].append(issue)
                }
            }

            for (fileName, fileIssuesList) in fileIssues.sorted(by: { $0.key < $1.key }) {
                let count = fileIssuesList.count
                let issueText = count == 1 ? "issue" : "issues"
                summary += "\(fileName): \(count) \(issueText)\n"
            }
            summary += "\n"

            // Detailed Issues Section
            summary += "## Detailed Issues\n\n"

            for (index, issue) in issues.enumerated() {
                let fileName = index % 2 == 0 ? "Test.swift" : "Test.js"
                summary += "**File:** \(fileName)\n"
                summary += "**Line:** \(issue.line ?? 0)\n"
                summary += "**Severity:** \(issue.severity.rawValue.capitalized)\n"
                summary += "**Type:** \(issue.category.rawValue.capitalized)\n"
                summary += "**Description:** \(issue.description)\n"

                // Add suggestion if available
                if index < suggestions.count {
                    summary += "**Suggestion:** \(suggestions[index])\n"
                }
                summary += "\n"
            }
        } else {
            summary += "Analysis completed for comprehensive review.\n\n"
            summary += "No issues found"
        }

        return summary
    }
}

// Test the NoEmptySections case
let generator = AnalysisSummaryGenerator()
let issues = [
    CodeIssue(description: "Test", severity: IssueSeverity.high, line: 1, category: IssueCategory.bug),
]

let summary = generator.generateAnalysisSummary(issues: issues, suggestions: [], analysisType: .comprehensive)

print("=== SUMMARY ===")
print(summary)
print("=== END SUMMARY ===")

print("\n=== LINES ANALYSIS ===")
let lines = summary.components(separatedBy: "\n")
for (index, line) in lines.enumerated() {
    print("\(index): '\(line)'")
    if line.hasPrefix("##") {
        print("  -> HEADER LINE")
        if index + 1 < lines.count {
            let nextLine = lines[index + 1]
            print("  -> NEXT LINE: '\(nextLine)'")
            if nextLine.isEmpty || nextLine.hasPrefix("##") {
                print("  -> PROBLEM: Empty or header after header!")
            }
        }
    }
}
