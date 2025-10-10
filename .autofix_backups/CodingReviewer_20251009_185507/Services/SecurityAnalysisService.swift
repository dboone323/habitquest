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

        // XSS Detection (JavaScript)
        if language == "JavaScript" {
            if code.contains("eval(") {
                issues.append(CodeIssue(
                    description: "Use of eval() detected - security risk",
                    severity: .high,
                    line: nil,
                    category: .security
                ))
            }

            if code.contains("innerHTML") {
                issues.append(CodeIssue(
                    description: "Direct innerHTML assignment - potential XSS vulnerability",
                    severity: .medium,
                    line: nil,
                    category: .security
                ))
            }

            if code.contains("document.write(") {
                issues.append(CodeIssue(
                    description: "Use of document.write() - potential XSS vulnerability",
                    severity: .medium,
                    line: nil,
                    category: .security
                ))
            }
        }

        // Path Traversal Detection
        if code.contains("../") || code.contains("..\\") {
            issues.append(CodeIssue(
                description: "Path traversal pattern detected - potential directory traversal attack",
                severity: .high,
                line: nil,
                category: .security
            ))
        }

        // Swift-specific checks
        if language == "Swift" {
            let lines = code.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() {
                // Skip comment lines
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                if trimmedLine.hasPrefix("//") || trimmedLine.hasPrefix("/*") {
                    continue
                }

                // Check for UserDefaults + password combinations
                let hasUserDefaults = line.contains("UserDefaults") || line.contains(".set(") || line.contains(".standard")
                let hasPassword = line.lowercased().contains("password")

                if hasUserDefaults, hasPassword {
                    issues.append(CodeIssue(
                        description: "Storing passwords in UserDefaults - use Keychain instead",
                        severity: .high,
                        line: index + 1,
                        category: .security
                    ))
                }

                // Memory Safety - Unsafe pointer usage
                if line.contains("unsafeBitCast") || line.contains("unsafeDowncast") {
                    issues.append(CodeIssue(
                        description: "Unsafe type casting detected - potential memory safety issue",
                        severity: .high,
                        line: index + 1,
                        category: .security
                    ))
                }

                if line.contains("UnsafeMutablePointer") || line.contains("UnsafePointer") || line.contains("UnsafeRawPointer") {
                    issues.append(CodeIssue(
                        description: "Unsafe pointer usage - ensure proper memory management",
                        severity: .medium,
                        line: index + 1,
                        category: .security
                    ))
                }

                // Concurrency - Shared mutable state without protection
                if line.contains("var"), line.contains("static") || line.contains("class var"), !line.contains("private") {
                    issues.append(CodeIssue(
                        description: "Shared mutable state without access control - potential race condition",
                        severity: .medium,
                        line: index + 1,
                        category: .security
                    ))
                }
            }
        }

        return issues
    }
}
