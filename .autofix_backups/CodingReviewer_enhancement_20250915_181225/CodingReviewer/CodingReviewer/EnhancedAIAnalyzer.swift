import Foundation
import Combine
import SwiftUI

// Enhanced AI Integration with Real Functionality
/// EnhancedAIService provides advanced code analysis using both local heuristics and AI-powered services.
///
/// This class manages the process of analyzing code snippets, combining fast local analysis with optional
/// cloud or local AI model integration (such as Ollama). It exposes published properties for UI updates
/// and handles error reporting for analysis failures.
@MainActor
// / EnhancedAIService class
public class EnhancedAIService: ObservableObject {
    @Published public var isAnalyzing: Bool = false
    @Published public var analysisResult: String = ""
    @Published public var errorMessage: String?

    private let apiKeyManager: APIKeyManager
    private let session: URLSession

    init(apiKeyManager: APIKeyManager, session: URLSession = .shared) {
        self.apiKeyManager = apiKeyManager
        self.session = session
    }

    // / analyzeCodeWithEnhancedAI function
    /// Analyzes the provided code using both local heuristics and, if available, an AI-powered service.
    ///
    /// - Parameters:
    ///   - code: The source code to analyze.
    ///   - language: The programming language of the code (default: "swift").
    ///
    /// This method first performs a local analysis for immediate feedback, then attempts to use an
    /// AI service (if available) for deeper insights. Results and errors are published for UI consumption.
    public func analyzeCodeWithEnhancedAI(_ code: String, language: String = "swift") async {
        isAnalyzing = true
        errorMessage = nil

        // Always perform local analysis first for immediate results
        let localResults = performLocalAnalysis(code, language: language)

        DispatchQueue.main.async {
            self.analysisResult = localResults
        }

        // Try AI analysis if Ollama is available
        if apiKeyManager.hasOllamaAvailable {
            await performAIAnalysis(code, language: language)
        }

        DispatchQueue.main.async {
            self.isAnalyzing = false
        }
    }

    private func performLocalAnalysis(_ code: String, language: String) -> String {
        var analysis = "🔍 Enhanced Local Code Analysis\n"
        analysis += String(repeating: "=", count: 40) + "\n\n"

        // Basic metrics
        let lineCount = code.components(separatedBy: .newlines).count
        let charCount = code.count
        let functionCount = code.components(separatedBy: "func ").count - 1

        analysis += "📊 Code Metrics:\n"
        analysis += "• Lines of code: \(lineCount)\n"
        analysis += "• Characters: \(charCount)\n"
        analysis += "• Functions: \(functionCount)\n\n"

        // Quality checks
        var issues: [String] = []
        var suggestions: [String] = []

        // Swift-specific analysis
        if language.lowercased() == "swift" {
            if code.contains("!") && !code.contains("// ") {
                issues.append("⚠️ Force unwrapping detected - consider using optional binding")
            }

            if code.contains("self?.") && code.contains("{") {
                suggestions.append("💡 Consider using [weak self] or [unowned self] in closures")
            }

            if code.range(of: "var [A-Z]", options: .regularExpression) != nil {
                suggestions.append("💡 Variable names should start with lowercase (camelCase)")
            }
        }

        // Generic checks
        let longLines = code.components(separatedBy: .newlines).filter { $0.count > 120 }
        if !longLines.isEmpty {
            issues.append("⚠️ \(longLines.count) lines exceed 120 characters")
        }

        // Security patterns
        let securityPatterns = ["password", "api_key", "secret", "token"]
        for pattern in securityPatterns {
            if code.lowercased().contains(pattern) {
                issues.append("🔒 Potential hardcoded \(pattern) detected")
            }
        }

        // Calculate quality score
        _ = 10  // Total quality checks to perform
        let issuesFound = issues.count
        let qualityScore = max(0, 100 - (issuesFound * 10))

        analysis += "🎯 Quality Score: \(qualityScore)/100\n\n"

        if issues.isEmpty {
            analysis += "✅ No issues found! Your code looks great.\n\n"
        } else {
            analysis += "⚠️ Issues Found (\(issues.count)):\n"
            for (index, issue) in issues.enumerated() {
                analysis += "\(index + 1). \(issue)\n"
            }
            analysis += "\n"
        }

        if !suggestions.isEmpty {
            analysis += "💡 Suggestions (\(suggestions.count)):\n"
            for (index, suggestion) in suggestions.enumerated() {
                analysis += "\(index + 1). \(suggestion)\n"
            }
            analysis += "\n"
        }

        // Complexity analysis
        let complexity = calculateComplexity(code)
        analysis += "🧮 Complexity Analysis:\n"
        analysis += "• Cyclomatic Complexity: \(complexity)\n"
        analysis += "• Complexity Level: \(complexityLevel(complexity))\n\n"

        return analysis
    }

    private func performAIAnalysis(_ code: String, language: String) async {
        do {
            let prompt = createAnalysisPrompt(code: code, language: language)
            let response = try await callOllama(prompt: prompt)

            DispatchQueue.main.async {
                self.analysisResult += "🤖 AI Enhanced Analysis:\n"
                self.analysisResult += String(repeating: "=", count: 40) + "\n"
                self.analysisResult += response + "\n"
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "AI analysis failed: \(error.localizedDescription)"
            }
        }
    }

    private func createAnalysisPrompt(code: String, language: String) -> String {
        """
        Analyze this \(language) code and provide actionable insights:

        ```\(language)
        \(code)
        ```

        Please provide:
        1. Code quality assessment with specific feedback
        2. Potential bugs or issues with line references if possible
        3. Performance optimization opportunities
        4. Security considerations
        5. Best practice recommendations
        6. Refactoring suggestions if applicable

        Keep the response concise but thorough, focusing on actionable improvements.
        """
    }

    private func callOllama(prompt: String) async throws -> String {
        guard let url = URL(string: "http://localhost:11434/api/generate") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "model": "codellama",  // Using CodeLlama for code analysis
            "prompt": prompt,
            "stream": false
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw AIAnalysisError.apiError(
                "HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let responseText = json?["response"] as? String else {
            return "No response received from Ollama"
        }

        return responseText
    }

    private func calculateComplexity(_ code: String) -> Int {
        let keywords = ["if", "else", "for", "while", "switch", "case", "guard", "catch"]
        return keywords.reduce(1) { complexity, keyword in
            complexity + (code.components(separatedBy: keyword).count - 1)
        }
    }

    private func complexityLevel(_ complexity: Int) -> String {
        switch complexity {
        case 1...5: "Low ✅"
        case 6...10: "Moderate ⚠️"
        case 11...15: "High ❌"
        default: "Very High 🚨"
        }
    }
}

// MARK: - Supporting Types

public enum AIAnalysisError: Error {
    case ollamaUnavailable
    case apiError(String)
    case invalidResponse
    case networkError

    public var localizedDescription: String {
        switch self {
        case .ollamaUnavailable:
            "Ollama is not available. Please start Ollama with 'ollama serve'."
        case .apiError(let message):
            "API Error: \(message)"
        case .invalidResponse:
            "Invalid response from Ollama"
        case .networkError:
            "Network error occurred"
        }
    }
}
