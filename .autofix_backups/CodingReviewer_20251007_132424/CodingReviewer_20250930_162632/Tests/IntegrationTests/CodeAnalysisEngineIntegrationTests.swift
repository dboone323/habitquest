#!/usr/bin/env swift

import Foundation

// Simple test to see what the CodeAnalysisEngine returns for the failing integration test
class BugDetectionService {
    func detectBasicBugs(code: String, language: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []

        if language.lowercased() == "swift" {
            let lines = code.split(separator: "\n", omittingEmptySubsequences: false)

            for (index, line) in lines.enumerated() {
                let lineNumber = index + 1
                let lineStr = String(line)

                // Check for TODO/FIXME comments
                if lineStr.contains("TODO") || lineStr.contains("FIXME") {
                    let issue = CodeIssue(
                        description: "TODO/FIXME comment found: \(lineStr.trimmingCharacters(in: .whitespaces))",
                        severity: .medium,
                        line: lineNumber,
                        category: .bug
                    )
                    issues.append(issue)
                }

                // Check for debug print statements
                if lineStr.contains("print("), lineStr.contains("Debug") || lineStr.contains("debug") {
                    let issue = CodeIssue(
                        description: "Debug print statement found: \(lineStr.trimmingCharacters(in: .whitespaces))",
                        severity: .low,
                        line: lineNumber,
                        category: .bug
                    )
                    issues.append(issue)
                }

                // Check for force unwrap
                if lineStr.contains("!"), !lineStr.contains("!="), !lineStr.contains("?!") {
                    let issue = CodeIssue(
                        description: "Force unwrap detected: \(lineStr.trimmingCharacters(in: .whitespaces))",
                        severity: .high,
                        line: lineNumber,
                        category: .bug
                    )
                    issues.append(issue)
                }
            }
        }

        return issues
    }
}

class PerformanceAnalysisService {
    func detectPerformanceIssues(code: String, language: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []

        if language.lowercased() == "swift" {
            let lines = code.split(separator: "\n", omittingEmptySubsequences: false)

            for (index, line) in lines.enumerated() {
                let lineNumber = index + 1
                let lineStr = String(line)

                // Check for forEach with append pattern
                if lineStr.contains("forEach"), lineStr.contains("append") {
                    let issue = CodeIssue(
                        description: "Inefficient forEach + append pattern detected: \(lineStr.trimmingCharacters(in: .whitespaces))",
                        severity: .medium,
                        line: lineNumber,
                        category: .performance
                    )
                    issues.append(issue)
                }
            }
        }

        return issues
    }
}

class SecurityAnalysisService {
    func detectSecurityIssues(code: String, language: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []
        print("DEBUG: SecurityAnalysisService called with language: \(language)")
        print("DEBUG: Code contains 'UserDefaults': \(code.contains("UserDefaults"))")
        print("DEBUG: Code contains 'password': \(code.contains("password"))")

        if code.contains("eval("), language == "JavaScript" {
            issues.append(CodeIssue(
                description: "Use of eval() detected - security risk",
                severity: .high,
                line: nil,
                category: .security
            ))
        }

        if code.contains("innerHTML"), language == "JavaScript" {
            issues.append(CodeIssue(
                description: "Direct innerHTML assignment - potential XSS vulnerability",
                severity: .medium,
                line: nil,
                category: .security
            ))
        }

        if language == "Swift", code.contains("UserDefaults"), code.contains("password") {
            print("DEBUG: Adding UserDefaults security issue")
            issues.append(CodeIssue(
                description: "Storing passwords in UserDefaults - use Keychain instead",
                severity: .high,
                line: nil,
                category: .security
            ))
        }

        print("DEBUG: SecurityAnalysisService returning \(issues.count) issues")
        return issues
    }
}

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

struct CodeAnalysisEngine {
    private let bugDetector = BugDetectionService()
    private let performanceAnalyzer = PerformanceAnalysisService()
    private let securityAnalyzer = SecurityAnalysisService()
    private let styleAnalyzer = StyleAnalysisService()

    func analyzeCode(code: String, language: String, analysisTypes: [AnalysisType]) -> CodeAnalysisResult {
        var allIssues: [CodeIssue] = []
        var allSuggestions: [String] = []

        // Perform analysis for each type
        for analysisType in analysisTypes {
            let issues = self.performBasicAnalysis(code: code, language: language, analysisType: analysisType)
            allIssues.append(contentsOf: issues)
            // Simplified - not generating suggestions for this debug
        }

        return CodeAnalysisResult(
            analysis: "Analysis summary",
            issues: allIssues,
            suggestions: allSuggestions,
            language: language,
            analysisType: .comprehensive
        )
    }

    private func performBasicAnalysis(code: String, language: String, analysisType: AnalysisType) -> [CodeIssue] {
        var issues: [CodeIssue] = []

        // Perform analysis based on analysis type
        switch analysisType {
        case .bugs:
            issues.append(contentsOf: self.bugDetector.detectBasicBugs(code: code, language: language))
        case .performance:
            issues.append(contentsOf: self.performanceAnalyzer.detectPerformanceIssues(code: code, language: language))
        case .security:
            issues.append(contentsOf: self.securityAnalyzer.detectSecurityIssues(code: code, language: language))
        case .style:
            issues.append(contentsOf: self.styleAnalyzer.detectStyleIssues(code: code, language: language))
        case .comprehensive:
            issues.append(contentsOf: self.bugDetector.detectBasicBugs(code: code, language: language))
            issues.append(contentsOf: self.performanceAnalyzer.detectPerformanceIssues(code: code, language: language))
            issues.append(contentsOf: self.securityAnalyzer.detectSecurityIssues(code: code, language: language))
            issues.append(contentsOf: self.styleAnalyzer.detectStyleIssues(code: code, language: language))
        }

        return issues
    }
}

struct CodeAnalysisResult {
    let analysis: String
    let issues: [CodeIssue]
    let suggestions: [String]
    let language: String
    let analysisType: AnalysisType
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

enum AnalysisType {
    case bugs, security, performance, style, comprehensive
}

// Test the failing integration test case
print("=== Testing testAnalyzeCode_AllServicesIntegration ===")
let testCode = """
// Integration scenario exercising multiple analysis services
import Foundation

class TestClass {
    // Force unwrap - Bug
    func dangerousFunction() -> String {
        let optionalValue: String? = nil
        return optionalValue! // Force unwrap detected by BugDetectionService
    }

    // Security issue - UserDefaults with password
    func storePassword(_ password: String) {
        UserDefaults.standard.set(password, forKey: "userPassword") // Security issue
    }

    // Performance issue - forEach with append
    func processArray(_ items: [Int]) -> [Int] {
        var result: [Int] = []
        items.forEach { item in
            result.append(item * 2) // Performance issue
        }
        return result
    }

    // Style issue - very long line
    func veryLongFunctionNameThatExceedsRecommendedLineLength(parameter1: String, parameter2: Int, parameter3: Bool, parameter4: Double, parameter5: Date) -> String {
        return "This is an extremely long line that definitely exceeds the maximum recommended line length for Swift code and should be flagged as a style violation by the StyleAnalysisService"
    }
}
"""

let engine = CodeAnalysisEngine()
let result = engine.analyzeCode(
    code: testCode,
    language: "Swift",
    analysisTypes: [AnalysisType.bugs, AnalysisType.security, AnalysisType.performance, AnalysisType.style]
)

print("Total issues found: \(result.issues.count)")
print("Issues by category:")
let bugIssues = result.issues.filter { $0.category == IssueCategory.bug }
let securityIssues = result.issues.filter { $0.category == IssueCategory.security }
let performanceIssues = result.issues.filter { $0.category == IssueCategory.performance }
let styleIssues = result.issues.filter { $0.category == IssueCategory.style }

print("  Bugs: \(bugIssues.count)")
for issue in bugIssues {
    print("    - Line \(issue.line ?? 0): \(issue.description)")
}

print("  Security: \(securityIssues.count)")
for issue in securityIssues {
    print("    - Line \(issue.line ?? 0): \(issue.description)")
}

print("  Performance: \(performanceIssues.count)")
for issue in performanceIssues {
    print("    - Line \(issue.line ?? 0): \(issue.description)")
}

print("  Style: \(styleIssues.count)")
for issue in styleIssues {
    print("    - Line \(issue.line ?? 0): \(issue.description)")
}
