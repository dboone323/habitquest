//
//  TestGenerator.swift
//  CodingReviewer
//
//  Service for generating test code and estimating coverage
//

import Foundation

/// Service responsible for generating test code and estimating coverage
struct TestGenerator {
    /// Generate basic test code for the provided code
    /// - Parameters:
    ///   - code: The source code to test
    ///   - language: The programming language of the code
    ///   - testFramework: The test framework to use
    /// - Returns: Generated test code as a string
    func generateBasicTests(code _: String, language: String, testFramework: String) -> String {
        var testCode = ""

        if language == "Swift", testFramework == "XCTest" {
            testCode = """
            import XCTest
            @testable import YourApp

            class CodeTests: XCTestCase {

                func testExample() {
                    // Basic test example
                    XCTAssertTrue(true, "This is a placeholder test")
                }

                // Add more tests based on your code functionality
            }
            """
        }
        // Return empty string for unsupported languages/frameworks

        return testCode
    }

    /// Estimate test coverage based on code and test code
    /// - Parameters:
    ///   - code: The source code
    ///   - testCode: The test code
    /// - Returns: Estimated coverage percentage (0.0 to 100.0)
    func estimateTestCoverage(code: String, testCode: String) -> Double {
        // Count lines by splitting on newlines, adjusting for trailing empty components
        let codeComponents = code.components(separatedBy: .newlines)
        let testComponents = testCode.components(separatedBy: .newlines)

        // Handle empty strings
        if code.isEmpty {
            return testCode.isEmpty ? 0.0 : 85.0
        }
        if testCode.isEmpty {
            return 0.0
        }

        // If the last component is empty (string ends with newline), don't count it as a line
        let codeLines = codeComponents.last?.isEmpty == true && codeComponents.count > 1 ? codeComponents.count - 1 : codeComponents.count
        let testLines = testComponents.last?.isEmpty == true && testComponents.count > 1 ? testComponents.count - 1 : testComponents.count

        // Estimate coverage as test lines relative to code lines
        let coverage = Double(testLines) / Double(codeLines) * 100.0
        return min(round(coverage), 85.0)
    }
}
