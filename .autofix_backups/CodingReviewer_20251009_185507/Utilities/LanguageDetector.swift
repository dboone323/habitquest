//
//  LanguageDetector.swift
//  CodingReviewer
//
//  Helper responsible for determining programming language based on file URL.
//

import Foundation

struct LanguageDetector {
    func detectLanguage(from url: URL?) -> String {
        guard let url else { return "Swift" }
        return self.detectLanguage(forExtension: url.pathExtension.lowercased())
    }

    func detectLanguage(forExtension pathExtension: String) -> String {
        switch pathExtension {
        case "swift": "Swift"
        case "py": "Python"
        case "js", "ts": "JavaScript"
        case "java": "Java"
        case "cpp", "cc", "cxx": "C++"
        case "c": "C"
        case "h": "C/C++ Header"
        case "m": "Objective-C"
        case "rb": "Ruby"
        case "php": "PHP"
        case "go": "Go"
        case "rs": "Rust"
        default: "Swift"
        }
    }
}
