//
//  DocumentationGenerator.swift
//  CodingReviewer
//
//  Service for generating documentation from code
//

import Foundation

/// Service responsible for generating documentation from code
struct DocumentationGenerator {
    /// Generate basic documentation for the provided code
    /// - Parameters:
    ///   - code: The source code to document
    ///   - language: The programming language of the code
    ///   - includeExamples: Whether to include usage examples
    /// - Returns: Generated documentation as a string
    func generateBasicDocumentation(code: String, language: String, includeExamples: Bool) -> String {
        var documentationParts = ["# Code Documentation\n\n"]

        documentationParts.append("Generated documentation for \(language) code.\n\n")

        // Extract function signatures (improved implementation)
        if language == "Swift" {
            let lines = code.components(separatedBy: .newlines)
            var functions: [String] = []
            var currentFunction: [String] = []
            var braceCount = 0
            var inFunction = false

            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)

                // Check if this line starts a function
                if !inFunction,
                   trimmed.hasPrefix("func ") ||
                   trimmed.hasPrefix("private func ") ||
                   trimmed.hasPrefix("public func ") ||
                   trimmed.hasPrefix("internal func ") ||
                   trimmed.hasPrefix("static func ") {
                    inFunction = true
                    currentFunction = [trimmed]
                    braceCount = 0

                    // Count braces in the current line
                    for char in trimmed {
                        if char == "{" {
                            braceCount += 1
                        }
                        if char == "}" {
                            braceCount -= 1
                        }
                    }

                    // If function is complete on this line, save it
                    if braceCount == 0, trimmed.contains("{") {
                        functions.append(trimmed)
                        currentFunction = []
                        inFunction = false
                    }
                } else if inFunction {
                    currentFunction.append(trimmed)

                    // Count braces in the current line
                    for char in trimmed {
                        if char == "{" {
                            braceCount += 1
                        }
                        if char == "}" {
                            braceCount -= 1
                        }
                    }

                    // If braces balance and we have a closing brace, function is complete
                    if braceCount <= 0, trimmed.contains("}") {
                        functions.append(currentFunction.joined(separator: "\n"))
                        currentFunction = []
                        inFunction = false
                    }
                }
            }

            if !functions.isEmpty {
                documentationParts.append("## Functions\n\n")
                for function in functions {
                    documentationParts.append("- `\(function)`\n")
                }
                documentationParts.append("\n")
            }
        }

        if includeExamples {
            documentationParts.append("## Usage Examples\n\n")
            documentationParts.append("```\(language.lowercased())\n// Example usage\n```\n\n")
        }

        let documentation = documentationParts.joined()
        // Remove trailing whitespace but keep one newline at the end
        return documentation.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
    }
}
