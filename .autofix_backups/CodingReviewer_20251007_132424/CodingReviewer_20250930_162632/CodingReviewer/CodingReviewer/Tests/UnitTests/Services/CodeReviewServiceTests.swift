#!/usr/bin/env swift

import Foundation

// Simple test to see what the StyleAnalysisService returns
class StyleAnalysisService {
    func detectStyleIssues(code: String, language: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []

        // Only analyze Swift code for style issues
        guard language.lowercased() == "swift" else {
            return issues
        }

        let lines = code.split(separator: "\n", omittingEmptySubsequences: false)

        // Check for long lines (>120 characters)
        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1
            let lineLength = line.count

            if lineLength > 120 {
                let description = "Line \(lineNumber) is too long (\(lineLength) characters). Maximum allowed is 120 characters."
                let issue = CodeIssue(
                    description: description,
                    severity: .low,
                    line: lineNumber,
                    category: .style
                )
                issues.append(issue)
            }
        }

        // Check for missing documentation
        if !self.hasDocumentationComments(code: code) {
            let description = "Code contains functions without documentation comments. Consider adding /// comments for public functions."
            let issue = CodeIssue(
                description: description,
                severity: .low,
                line: nil,
                category: .style
            )
            issues.append(issue)
        }

        return issues
    }

    private func hasDocumentationComments(code: String) -> Bool {
        // Simple check: look for /// comments before func declarations
        let lines = code.split(separator: "\n", omittingEmptySubsequences: false)

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("func ") {
                // Check if previous lines have documentation
                var hasDoc = false
                var checkIndex = index - 1
                while checkIndex >= 0, checkIndex >= index - 3 {
                    let prevLine = lines[checkIndex].trimmingCharacters(in: .whitespaces)
                    if prevLine.hasPrefix("///") {
                        hasDoc = true
                        break
                    } else if !prevLine.isEmpty, !prevLine.hasPrefix("//") {
                        // Non-comment, non-empty line breaks the documentation check
                        break
                    }
                    checkIndex -= 1
                }
                if !hasDoc {
                    return false
                }
            }
        }

        return true
    }
}

struct CodeIssue {
    let description: String
    let severity: IssueSeverity
    let line: Int?
    let category: IssueCategory
}

enum IssueSeverity {
    case low, medium, high, critical
}

enum IssueCategory {
    case bug, security, performance, style, maintainability, general
}

// Test the service with our failing test cases

let service = StyleAnalysisService()

// Test 1: LineExactly120Chars
print("=== Test 1: LineExactly120Chars ===")
let code1 = """
class Calculator {
    func calculate() {
        let result = "This is a string that should be exactly 120 characters or less when counted by the service"
    }
}
"""
let issues1 = service.detectStyleIssues(code: code1, language: "Swift")
print("Issues found: \(issues1.count)")
for issue in issues1 {
    print("  - Line \(issue.line ?? 0): \(issue.description)")
}

// Test 2: LineWithTabs
print("\n=== Test 2: LineWithTabs ===")
let code2 = """
class Test {
\t\tfunc method() {
\t\t\tlet veryLongVariableName = "This is a very long string that will definitely exceed the line limit when combined with indentation and extra text"
\t\t}
}
"""
let issues2 = service.detectStyleIssues(code: code2, language: "Swift")
print("Issues found: \(issues2.count)")
for issue in issues2 {
    print("  - Line \(issue.line ?? 0): \(issue.description)")
}

// Test 3: LongLine
print("\n=== Test 3: LongLine ===")
let longLine = String(repeating: "x", count: 125)
let code3 = """
class Calculator {
    func calculate() {
        let result = \(longLine)
    }
}
"""
let issues3 = service.detectStyleIssues(code: code3, language: "Swift")
print("Issues found: \(issues3.count)")
for issue in issues3 {
    print("  - Line \(issue.line ?? 0): \(issue.description)")
}

// Test 4: MultipleLongLines
print("\n=== Test 4: MultipleLongLines ===")
let longLine1 = String(repeating: "a", count: 130)
let longLine2 = String(repeating: "b", count: 140)
let code4 = """
class TestClass {
    func method1() {
        let line1 = "\(longLine1)"
    }

    func method2() {
        let line2 = "\(longLine2)"
    }
}
"""
let issues4 = service.detectStyleIssues(code: code4, language: "Swift")
print("Issues found: \(issues4.count)")
for issue in issues4 {
    print("  - Line \(issue.line ?? 0): \(issue.description)")
}
