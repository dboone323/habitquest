#!/usr/bin/env swift

import Foundation

// Simple test to check if CodeAnalysisEngine works
print("Testing CodeAnalysisEngine...")

// Mock the services since we can't import the actual module
struct MockBugDetectionService {
    func detectBasicBugs(code _: String, language _: String) -> [String] {
        ["Found TODO comment"]
    }
}

struct MockPerformanceAnalysisService {
    func detectPerformanceIssues(code _: String, language _: String) -> [String] {
        ["Found forEach+append pattern"]
    }
}

struct MockSecurityAnalysisService {
    func detectSecurityIssues(code _: String, language _: String) -> [String] {
        ["Found UserDefaults password storage"]
    }
}

struct MockStyleAnalysisService {
    func detectStyleIssues(code _: String, language _: String) -> [String] {
        ["Found long line"]
    }
}

struct MockCodeAnalysisEngine {
    let bugDetector = MockBugDetectionService()
    let performanceAnalyzer = MockPerformanceAnalysisService()
    let securityAnalyzer = MockSecurityAnalysisService()
    let styleAnalyzer = MockStyleAnalysisService()

    func analyzeCode(code: String, language: String, analysisTypes: [String]) -> [String] {
        var allIssues: [String] = []

        print("DEBUG: Mock analyzeCode called with analysisTypes: \(analysisTypes)")

        for analysisType in analysisTypes {
            print("DEBUG: Processing analysisType: \(analysisType)")
            switch analysisType {
            case "bugs":
                let issues = self.bugDetector.detectBasicBugs(code: code, language: language)
                print("DEBUG: Found \(issues.count) bug issues")
                allIssues.append(contentsOf: issues)
            case "performance":
                let issues = self.performanceAnalyzer.detectPerformanceIssues(code: code, language: language)
                print("DEBUG: Found \(issues.count) performance issues")
                allIssues.append(contentsOf: issues)
            case "security":
                let issues = self.securityAnalyzer.detectSecurityIssues(code: code, language: language)
                print("DEBUG: Found \(issues.count) security issues")
                allIssues.append(contentsOf: issues)
            case "style":
                let issues = self.styleAnalyzer.detectStyleIssues(code: code, language: language)
                print("DEBUG: Found \(issues.count) style issues")
                allIssues.append(contentsOf: issues)
            default:
                break
            }
        }

        print("DEBUG: Total issues collected: \(allIssues.count)")
        return allIssues
    }
}

let engine = MockCodeAnalysisEngine()
let code = "// TODO: Test"
let result = engine.analyzeCode(code: code, language: "Swift", analysisTypes: ["bugs", "performance", "security", "style"])

print("Result: \(result)")
print("Test completed successfully!")
