//
//  SecurityAnalysisService.swift
//  CodingReviewer
//
//  Service for detecting security vulnerabilities in code
//

import Foundation

/// Service responsible for detecting security issues in code
struct SecurityAnalysisService {
    /// Detect security issues in the provided code
    /// - Parameters:
    ///   - code: The source code to analyze
    ///   - language: The programming language of the code
    /// - Returns: Array of detected security issues
    func detectSecurityIssues(code: String, language: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []

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

        if language == "Swift" {
            // Check for UserDefaults + password combinations
            let lines = code.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() {
                // Skip comment lines
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                if trimmedLine.hasPrefix("//") || trimmedLine.hasPrefix("/*") {
                    continue
                }

                // Check for UserDefaults usage (either direct or via variable)
                let hasUserDefaults = line.contains("UserDefaults") || line.contains(".set(") || line.contains(".standard")
                let hasPassword = line.lowercased().contains("password")

                if hasUserDefaults, hasPassword {
                    issues.append(CodeIssue(
                        description: "Storing passwords in UserDefaults - use Keychain instead",
                        severity: .high,
                        line: index + 1, // 1-based line numbering
                        category: .security
                    ))
                }
            }
        }

        return issues
    }
}
