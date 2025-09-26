//
//  StyleAnalysisServiceTests.swift
//  CodingReviewerTests
//
//  Unit tests for StyleAnalysisService
//

@testable import CodingReviewer
import XCTest

final class StyleAnalysisServiceTests: XCTestCase {
    var styleAnalyzer: StyleAnalysisService!

    override func setUp() {
        super.setUp()
        styleAnalyzer = StyleAnalysisService()
    }

    override func tearDown() {
        styleAnalyzer = nil
        super.tearDown()
    }

    // MARK: - Swift Style Tests

    func testDetectStyleIssues_NoIssues() {
        // Given clean Swift code
        let code = """
        /// Calculates the sum of two numbers
        /// - Parameters:
        ///   - a: First number
        ///   - b: Second number
        /// - Returns: Sum of the numbers
        func add(_ a: Int, _ b: Int) -> Int {
            return a + b
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectStyleIssues_LongLine() {
        // Given Swift code with a long line
        let longLine = String(repeating: "x", count: 125)
        let code = """
        class Calculator {
            func calculate() {
                let result = \(longLine)
            }
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then both long line and documentation issues should be detected
        XCTAssertEqual(issues.count, 2)

        let longLineIssue = issues.first { $0.description.contains("too long") }
        let docIssue = issues.first { $0.description.contains("documentation") }

        XCTAssertNotNil(longLineIssue)
        XCTAssertNotNil(docIssue)
        XCTAssertEqual(longLineIssue!.severity, IssueSeverity.low)
        XCTAssertEqual(longLineIssue!.category, IssueCategory.style)
        XCTAssertTrue(longLineIssue!.description.contains("146 characters"))
        XCTAssertEqual(longLineIssue!.line, 3)
    }

    func testDetectStyleIssues_MultipleLongLines() {
        // Given Swift code with multiple long lines
        let longLine1 = String(repeating: "a", count: 130)
        let longLine2 = String(repeating: "b", count: 140)
        let code = """
        class TestClass {
            func method1() {
                let line1 = "\(longLine1)"
            }

            func method2() {
                let line2 = "\(longLine2)"
            }
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then all three issues should be detected: 2 long lines + 1 documentation
        XCTAssertEqual(issues.count, 3)

        let line1Issue = issues.first { $0.line == 3 }
        let line2Issue = issues.first { $0.line == 7 }
        let docIssue = issues.first { $0.description.contains("documentation") }

        XCTAssertNotNil(line1Issue)
        XCTAssertNotNil(line2Issue)
        XCTAssertNotNil(docIssue)
        XCTAssertTrue(line1Issue!.description.contains("152 characters"))
        XCTAssertTrue(line2Issue!.description.contains("162 characters"))
    }

    func testDetectStyleIssues_LineExactly120Chars() {
        // Given Swift code with line exactly 120 characters or less
        let code = """
        class Calculator {
            func calculate() {
                let result = "This is a string that should be exactly 120 characters or less when counted by the service"
            }
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then only documentation issue should be found (113 chars is under limit)
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, IssueSeverity.low)
        XCTAssertEqual(issues[0].category, IssueCategory.style)
        XCTAssertTrue(issues[0].description.contains("documentation comments"))
    }

    func testDetectStyleIssues_MissingDocumentation() {
        // Given Swift code with functions but no documentation
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }

            func multiply(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then missing documentation issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, IssueSeverity.low)
        XCTAssertEqual(issues[0].category, IssueCategory.style)
        XCTAssertTrue(issues[0].description.contains("documentation comments"))
    }

    func testDetectStyleIssues_HasDocumentation() {
        // Given Swift code with documented functions
        let code = """
        class Calculator {
            /// Adds two numbers
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then no documentation issues should be found
        let docIssues = issues.filter { $0.description.contains("documentation") }
        XCTAssertTrue(docIssues.isEmpty)
    }

    func testDetectStyleIssues_MultipleIssues() {
        // Given Swift code with both long lines and missing documentation
        let longLine = String(repeating: "x", count: 125)
        let code = """
        class Calculator {
            func calculate() {
                let result = \(longLine)
            }

            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then both issues should be detected
        XCTAssertEqual(issues.count, 2)

        let longLineIssue = issues.first { $0.description.contains("too long") }
        let docIssue = issues.first { $0.description.contains("documentation") }

        XCTAssertNotNil(longLineIssue)
        XCTAssertNotNil(docIssue)
    }

    // MARK: - Non-Swift Language Tests

    func testDetectStyleIssues_NonSwiftLanguage() {
        // Given code in a non-Swift language with long lines
        let longLine = String(repeating: "x", count: 125)
        let code = """
        function calculate() {
            const result = \(longLine);
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "JavaScript")

        // Then no issues should be detected (style checks are Swift-only)
        XCTAssertTrue(issues.isEmpty)
    }

    // MARK: - Edge Cases

    func testDetectStyleIssues_EmptyCode() {
        // Given empty code
        let code = ""

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectStyleIssues_OnlyNewlines() {
        // Given code with only newlines
        let code = "\n\n\n"

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectStyleIssues_SingleLongLine() {
        // Given code with single long line
        let code = String(repeating: "a", count: 125)

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then long line issue should be detected on line 1
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].line, 1)
        XCTAssertTrue(issues[0].description.contains("125 characters"))
    }

    func testDetectStyleIssues_LineWithTabs() {
        // Given code with tabs that might affect line length
        let code = """
        class Test {
        \t\tfunc method() {
        \t\t\tlet veryLongVariableName = "This is a very long string that will definitely exceed the line limit when combined with indentation and extra text"
        \t\t}
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then both long line and documentation issues should be detected
        XCTAssertEqual(issues.count, 2)

        let longLineIssue = issues.first { $0.description.contains("too long") }
        let docIssue = issues.first { $0.description.contains("documentation") }

        XCTAssertNotNil(longLineIssue)
        XCTAssertNotNil(docIssue)
        XCTAssertEqual(longLineIssue!.line, 3)
        XCTAssertTrue(longLineIssue!.description.contains("147 characters"))
    }

    // MARK: - Documentation Edge Cases

    func testDetectStyleIssues_NoFunctions() {
        // Given code with no functions
        let code = """
        class TestClass {
            let property = "value"
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then no documentation issues should be found
        let docIssues = issues.filter { $0.description.contains("documentation") }
        XCTAssertTrue(docIssues.isEmpty)
    }

    func testDetectStyleIssues_OnlyComputedProperties() {
        // Given code with only computed properties
        let code = """
        class TestClass {
            var computedProperty: String {
                return "value"
            }
        }
        """

        // When analyzing for style issues
        let issues = styleAnalyzer.detectStyleIssues(code: code, language: "Swift")

        // Then no documentation issues should be found (no functions)
        let docIssues = issues.filter { $0.description.contains("documentation") }
        XCTAssertTrue(docIssues.isEmpty)
    }
}
