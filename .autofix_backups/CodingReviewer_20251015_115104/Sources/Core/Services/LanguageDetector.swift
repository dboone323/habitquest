//
//  LanguageDetector.swift
//  CodingReviewer
//
//  Created by Quality Infrastructure Implementation
//  Date: October 12, 2024
//

import Foundation
import UniformTypeIdentifiers

/// Detects programming language from file extensions and content analysis
class LanguageDetector {

    /// Detect language from a file URL
    /// - Parameter url: File URL to analyze
    /// - Returns: Detected language name
    func detectLanguage(from url: URL) -> String {
        // First try file extension
        if let language = detectFromExtension(url.pathExtension) {
            return language
        }

        // Fallback to content-based detection if possible
        if let content = try? String(contentsOf: url, encoding: .utf8) {
            return detectFromContent(content)
        }

        return "Unknown"
    }

    /// Detect language from file extension
    /// - Parameter extension: File extension
    /// - Returns: Language name if detected
    func detectFromExtension(_ extension: String) -> String? {
        let ext = `extension`.lowercased()

        switch ext {
        case "swift":
            return "Swift"
        case "m", "mm":
            return "Objective-C"
        case "c":
            return "C"
        case "cpp", "cc", "cxx", "c++":
            return "C++"
        case "h", "hpp", "hxx", "h++":
            return "C/C++ Header"
        case "py":
            return "Python"
        case "js":
            return "JavaScript"
        case "ts":
            return "TypeScript"
        case "java":
            return "Java"
        case "kt", "kts":
            return "Kotlin"
        case "rb":
            return "Ruby"
        case "go":
            return "Go"
        case "rs":
            return "Rust"
        case "php":
            return "PHP"
        case "cs":
            return "C#"
        case "sh", "bash":
            return "Shell"
        case "yaml", "yml":
            return "YAML"
        case "json":
            return "JSON"
        case "xml":
            return "XML"
        case "html", "htm":
            return "HTML"
        case "css":
            return "CSS"
        case "sql":
            return "SQL"
        case "md", "markdown":
            return "Markdown"
        default:
            return nil
        }
    }

    /// Detect language from code content
    /// - Parameter content: Source code content
    /// - Returns: Detected language name
    func detectFromContent(_ content: String) -> String {
        // Look for distinctive language patterns
        let lines = content.components(separatedBy: .newlines).prefix(50)

        // Swift patterns
        if lines.contains(where: { $0.contains("import Foundation") || $0.contains("import SwiftUI") || $0.contains("func ") && $0.contains("->") }) {
            return "Swift"
        }

        // Objective-C patterns
        if lines.contains(where: { $0.contains("@interface") || $0.contains("@implementation") || $0.contains("#import") }) {
            return "Objective-C"
        }

        // Python patterns
        if lines.contains(where: { $0.contains("def ") || $0.contains("import ") || $0.contains("from ") && $0.contains("import") }) {
            return "Python"
        }

        // JavaScript/TypeScript patterns
        if lines.contains(where: { $0.contains("function ") || $0.contains("const ") || $0.contains("let ") || $0.contains("var ") }) {
            if lines.contains(where: { $0.contains(": ") && $0.contains("=>") }) {
                return "TypeScript"
            }
            return "JavaScript"
        }

        // Java patterns
        if lines.contains(where: { $0.contains("public class ") || $0.contains("private class ") || $0.contains("package ") }) {
            return "Java"
        }

        // C/C++ patterns
        if lines.contains(where: { $0.contains("#include") }) {
            if lines.contains(where: { $0.contains("std::") || $0.contains("namespace ") }) {
                return "C++"
            }
            return "C"
        }

        // Go patterns
        if lines.contains(where: { $0.contains("package main") || $0.contains("func main()") }) {
            return "Go"
        }

        // Rust patterns
        if lines.contains(where: { $0.contains("fn main") || $0.contains("use std::") }) {
            return "Rust"
        }

        // Ruby patterns
        if lines.contains(where: { $0.contains("def ") && $0.contains("end") || $0.contains("require ") }) {
            return "Ruby"
        }

        // Shell script patterns
        if content.hasPrefix("#!/bin/bash") || content.hasPrefix("#!/bin/sh") {
            return "Shell"
        }

        return "Unknown"
    }

    /// Get common file extensions for a language
    /// - Parameter language: Language name
    /// - Returns: Array of file extensions
    func getExtensions(for language: String) -> [String] {
        switch language.lowercased() {
        case "swift":
            return ["swift"]
        case "objective-c":
            return ["m", "mm", "h"]
        case "c":
            return ["c", "h"]
        case "c++":
            return ["cpp", "cc", "cxx", "c++", "hpp", "hxx", "h++"]
        case "python":
            return ["py"]
        case "javascript":
            return ["js"]
        case "typescript":
            return ["ts"]
        case "java":
            return ["java"]
        case "kotlin":
            return ["kt", "kts"]
        case "ruby":
            return ["rb"]
        case "go":
            return ["go"]
        case "rust":
            return ["rs"]
        case "php":
            return ["php"]
        case "c#":
            return ["cs"]
        case "shell":
            return ["sh", "bash"]
        default:
            return []
        }
    }

    /// Check if a language is supported for analysis
    /// - Parameter language: Language name
    /// - Returns: True if supported
    func isSupported(_ language: String) -> Bool {
        let supportedLanguages = [
            "Swift", "Objective-C", "C", "C++",
            "Python", "JavaScript", "TypeScript",
            "Java", "Kotlin", "Go", "Rust"
        ]
        return supportedLanguages.contains(language)
    }
}
