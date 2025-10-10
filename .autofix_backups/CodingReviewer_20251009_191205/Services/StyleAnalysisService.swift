//
//  StyleAnalysisService.swift
//  CodingReviewer
//
//  Service for detecting code style issues
//

import Foundation

/// Service responsible for detecting code style issues
struct StyleAnalysisService {
    /// Detect style issues in the provided code
    /// - Parameters:
    ///   - code: The source code to analyze
    ///   - language: The programming language of the code
    /// - Returns: Array of detected style issues
    func detectStyleIssues(code: String, language: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []

        if language == "Swift" {
            // Check for long lines (Swift only)
            let lines = code.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() {
                if line.count > 120 {
                    issues.append(CodeIssue(
                        description: "Line \(index + 1) is too long (\(line.count) characters). Maximum allowed is 120 characters.",
                        severity: .low,
                        line: index + 1,
                        category: .style
                    ))
                }
            }

            // Check for missing documentation (Swift only)
            if code.contains("func "), !code.contains("///") {
                issues.append(CodeIssue(
                    description: "Code contains functions without documentation comments. Consider adding /// comments for public functions.",
                    severity: .low,
                    line: nil,
                    category: .style
                ))
            }
        }

        return issues
    }
}
