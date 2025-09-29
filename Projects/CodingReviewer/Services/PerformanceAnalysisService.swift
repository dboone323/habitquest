//
//  PerformanceAnalysisService.swift
//  CodingReviewer
//
//  Service for detecting performance issues in code
//

import CodingReviewer
import Foundation

/// Service responsible for detecting performance issues in code
struct PerformanceAnalysisService {
    /// Detect performance issues in the provided code
    /// - Parameters:
    ///   - code: The source code to analyze
    ///   - language: The programming language of the code
    /// - Returns: Array of detected performance issues
    func detectPerformanceIssues(in code: String, language: String) -> [CodeIssue] {
        var issues: [CodeIssue] = []
        var addedDescriptions = Set<String>() // Track added issue descriptions to avoid duplicates

        if language == "Swift" {
            // Swift performance patterns - case sensitive
            let multilinePatterns = [
                ("(?s)forEach.*append", "forEach with append", IssueSeverity.medium),
            ]

            let linePatterns = [
                ("filter.*map", "filter followed by map", IssueSeverity.low),
                ("map.*filter", "map followed by filter", IssueSeverity.low),
            ]

            // Check multiline patterns on entire code
            for (pattern, description, severity) in multilinePatterns {
                if let _ = code.range(of: pattern, options: .regularExpression) {
                    let fullDescription = "Performance issue: \(description) can be optimized"
                    if !addedDescriptions.contains(fullDescription) {
                        let issue = CodeIssue(
                            description: fullDescription,
                            severity: severity,
                            line: 1, // Approximate line for multiline patterns
                            category: IssueCategory.performance
                        )
                        issues.append(issue)
                        addedDescriptions.insert(fullDescription)
                    }
                }
            }

            // Check line-by-line patterns
            let lines = code.components(separatedBy: .newlines)
            for (lineIndex, line) in lines.enumerated() {
                for (pattern, description, severity) in linePatterns {
                    // Use case-sensitive regex matching
                    if let _ = line.range(of: pattern, options: .regularExpression) {
                        let fullDescription = "Performance issue: \(description) can be optimized"
                        if !addedDescriptions.contains(fullDescription) {
                            let issue = CodeIssue(
                                description: fullDescription,
                                severity: severity,
                                line: lineIndex + 1,
                                category: IssueCategory.performance
                            )
                            issues.append(issue)
                            addedDescriptions.insert(fullDescription)
                        }
                    }
                }
            }

            // Check for multiple chained array operations (suggesting flatMap optimization)
            // Look for patterns like .filter { ... }.map { ... } on separate lines or same line
            let flatMapDescription = "Performance issue: Multiple array operations can be optimized with flatMap"
            let hasFilter = code.contains(".filter")
            let hasMap = code.contains(".map")

            // Check for chained operations pattern: filter followed by map (possibly across lines)
            let chainedPattern = "(?s)\\.filter\\s*\\{[^}]*\\}\\s*\\.map\\s*\\{[^}]*\\}"
            let hasChainedOperations = code.range(of: chainedPattern, options: .regularExpression) != nil

            if hasFilter, hasMap, hasChainedOperations, code.contains("\n"), !addedDescriptions.contains(flatMapDescription) {
                let issue = CodeIssue(
                    description: flatMapDescription,
                    severity: IssueSeverity.low,
                    line: 1, // Approximate line
                    category: IssueCategory.performance
                )
                issues.append(issue)
                addedDescriptions.insert(flatMapDescription)
            }
        } else if language == "JavaScript" {
            // JavaScript performance patterns - check entire code for multiline patterns
            let patterns = [
                ("forEach.*push", "forEach with push", IssueSeverity.medium),
            ]

            // Check entire code for multiline patterns
            for (pattern, description, severity) in patterns {
                let multilinePattern = "(?s)" + pattern // (?s) makes . match newlines
                if let _ = code.range(of: multilinePattern, options: .regularExpression) {
                    let fullDescription = "Performance issue: \(description) can be optimized"
                    if !addedDescriptions.contains(fullDescription) {
                        let issue = CodeIssue(
                            description: fullDescription,
                            severity: severity,
                            line: 1, // Approximate line for multiline patterns
                            category: IssueCategory.performance
                        )
                        issues.append(issue)
                        addedDescriptions.insert(fullDescription)
                    }
                }
            }

            // Also check line by line for single-line patterns
            let lines = code.components(separatedBy: .newlines)
            for (lineIndex, line) in lines.enumerated() {
                // Add single-line patterns here if needed
            }
        }

        return issues
    }
}
