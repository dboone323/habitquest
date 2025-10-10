import Foundation

// MARK: - AI Model Communication

func callOllamaModel(model: String, prompt: String, temperature _: Double = 0.5) async throws -> String {
    // This would use the actual OllamaClient - for now, simulating the call
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ollama")
    process.arguments = ["run", model]

    let inputPipe = Pipe()
    let outputPipe = Pipe()

    process.standardInput = inputPipe
    process.standardOutput = outputPipe

    try process.run()

    // Send prompt
    let inputData = prompt.data(using: .utf8)!
    inputPipe.fileHandleForWriting.write(inputData)
    inputPipe.fileHandleForWriting.closeFile()

    // Read response
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let response = String(data: outputData, encoding: .utf8) ?? "No response"

    process.waitUntilExit()

    return response.trimmingCharacters(in: .whitespacesAndNewlines)
}

// MARK: - Code Analysis Helpers

func generateCodeSuggestions(_: String, language _: String, analysis: String) async throws -> [CodeImprovement] {
    let suggestionsPrompt = """
    Based on this code analysis, generate specific code improvement suggestions:

    Analysis: \(String(analysis.prefix(1000)))

    For each suggestion, provide:
    1. Specific issue or improvement area
    2. Current code example
    3. Improved code example
    4. Explanation of benefits

    Limit to top 5 most impactful suggestions.
    """

    let suggestions = try await callOllamaModel(
        model: "qwen3-coder:480b-cloud",
        prompt: suggestionsPrompt,
        temperature: 0.3
    )

    // Parse suggestions (simplified)
    let lines = suggestions.components(separatedBy: .newlines)
    return lines.enumerated().compactMap { index, line in
        if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return CodeImprovement(
                title: "Improvement \(index + 1)",
                description: line,
                currentCode: "",
                improvedCode: "",
                benefits: [],
                priority: .medium
            )
        }
        return nil
    }
}

func compareCodeVersions(original: String, refactored: String) async throws -> CodeComparison {
    let comparisonPrompt = """
    Compare these two versions of Swift code:

    Original:
    \(String(original.prefix(1000)))

    Refactored:
    \(String(refactored.prefix(1000)))

    Analyze:
    1. Lines of code change
    2. Complexity reduction
    3. Performance impact
    4. Maintainability improvement
    5. Readability enhancement
    """

    let comparison = try await callOllamaModel(
        model: "deepseek-v3.1:671b-cloud",
        prompt: comparisonPrompt,
        temperature: 0.2
    )

    return CodeComparison(
        originalLinesOfCode: original.components(separatedBy: .newlines).count,
        refactoredLinesOfCode: refactored.components(separatedBy: .newlines).count,
        complexityReduction: 0.0, // Would be calculated
        performanceImpact: comparison.contains("performance") ? .positive : .neutral,
        maintainabilityScore: 0.0, // Would be calculated
        readabilityImprovement: comparison.contains("readable") || comparison.contains("clear")
    )
}

func estimateTestCoverage(_ tests: String) -> Int {
    // Simple heuristic based on test method count
    let testMethods = tests.components(separatedBy: "func test").count - 1
    return min(testMethods * 15, 95) // Rough estimate
}

// MARK: - Parsing Helpers

func extractQualityScore(from analysis: String) -> Int {
    // Extract quality score from analysis text
    let numbers = analysis.matches(of: /(\d+)\/10|\b(\d)\s*out\s*of\s*10/).compactMap { match in
        Int(match.output.1 ?? match.output.2 ?? "0")
    }
    return numbers.first ?? 7
}

func extractSecurityIssues(from analysis: String) -> [SecurityIssue] {
    // Parse security issues from analysis
    let securityKeywords = ["security", "vulnerability", "exploit", "injection", "authentication"]
    let lines = analysis.components(separatedBy: .newlines)

    return lines.compactMap { line in
        for keyword in securityKeywords {
            if line.lowercased().contains(keyword) {
                return SecurityIssue(
                    type: keyword.capitalized,
                    severity: line.lowercased().contains("critical") || line.lowercased().contains("high") ? .high : .medium,
                    description: line,
                    recommendation: "Address security concern"
                )
            }
        }
        return nil
    }
}

func extractPerformanceIssues(from analysis: String) -> [PerformanceIssue] {
    let performanceKeywords = ["performance", "slow", "inefficient", "optimization", "bottleneck"]
    let lines = analysis.components(separatedBy: .newlines)

    return lines.compactMap { line in
        for keyword in performanceKeywords {
            if line.lowercased().contains(keyword) {
                return PerformanceIssue(
                    type: "Performance Concern",
                    impact: line.lowercased().contains("critical") ? .high : .medium,
                    description: line,
                    suggestion: "Optimize for better performance"
                )
            }
        }
        return nil
    }
}

func extractBestPracticeViolations(from analysis: String) -> [BestPracticeViolation] {
    let practiceKeywords = ["best practice", "convention", "style", "pattern", "anti-pattern"]
    let lines = analysis.components(separatedBy: .newlines)

    return lines.compactMap { line in
        for keyword in practiceKeywords {
            if line.lowercased().contains(keyword) {
                return BestPracticeViolation(
                    rule: "Code Convention",
                    violation: line,
                    suggestion: "Follow Swift best practices"
                )
            }
        }
        return nil
    }
}

func extractRecommendations(from analysis: String) -> [String] {
    let lines = analysis.components(separatedBy: .newlines)
    return lines.compactMap { line in
        if line.contains("recommend") || line.contains("suggest") || line.contains("should") {
            return line.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
}

func extractTechnicalDebt(from analysis: String) -> TechnicalDebtLevel {
    if analysis.lowercased().contains("high debt") || analysis.lowercased().contains("significant debt") {
        .high
    } else if analysis.lowercased().contains("medium debt") || analysis.lowercased().contains("moderate debt") {
        .medium
    } else {
        .low
    }
}

func extractChangesExplanation(from response: String) -> String {
    // Extract explanation section from refactoring response
    let lines = response.components(separatedBy: .newlines)
    return lines.first { $0.contains("explanation") || $0.contains("changes") } ?? "Refactoring completed"
}

func extractBenefits(from response: String) -> [String] {
    let lines = response.components(separatedBy: .newlines)
    return lines.compactMap { line in
        if line.contains("benefit") || line.contains("improvement") {
            return line.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
}

func extractPotentialIssues(from response: String) -> [String] {
    let lines = response.components(separatedBy: .newlines)
    return lines.compactMap { line in
        if line.contains("issue") || line.contains("concern") || line.contains("breaking") {
            return line.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
}

func extractQualityRating(from response: String) -> Int {
    let numbers = response.matches(of: /(\d+)\/10/).compactMap { match in
        Int(match.output.1 ?? "0")
    }
    return numbers.first ?? 7
}

func extractTopImprovements(from response: String) -> [String] {
    let lines = response.components(separatedBy: .newlines)
    return lines.prefix(3).compactMap { line in
        if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return line
        }
        return nil
    }
}
