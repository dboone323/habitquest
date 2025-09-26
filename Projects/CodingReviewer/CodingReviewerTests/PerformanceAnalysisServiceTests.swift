//
//  PerformanceAnalysisServiceTests.swift
//  CodingReviewerTests
//
//  Unit tests for PerformanceAnalysisService
//
@testable import CodingReviewer
import XCTest

final class PerformanceAnalysisServiceTests: XCTestCase {
    var performanceAnalyzer: PerformanceAnalysisService!

    override func setUp() {
        super.setUp()
        performanceAnalyzer = PerformanceAnalysisService()
    }

    override func tearDown() {
        performanceAnalyzer = nil
        super.tearDown()
    }

    // MARK: - Swift Performance Tests

    func testDetectPerformanceIssues_NoIssues() {
        // Given clean Swift code with no performance issues
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectPerformanceIssues_ForEachWithAppend() {
        // Given Swift code using forEach with append
        let code = """
        class DataProcessor {
            func processItems(_ items: [String]) -> [String] {
                var results: [String] = []
                items.forEach { item in
                    results.append(item.uppercased())
                }
                return results
            }
        }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then forEach+append issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, IssueSeverity.medium)
        XCTAssertEqual(issues[0].category, IssueCategory.performance)
        XCTAssertTrue(issues[0].description.contains("forEach"))
    }

    func testDetectPerformanceIssues_ForEachWithoutAppend() {
        // Given Swift code using forEach but not with append
        let code = """
        class DataProcessor {
            func processItems(_ items: [String]) {
                items.forEach { item in
                    print(item)
                }
            }
        }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then no issues should be detected (forEach without append is OK)
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectPerformanceIssues_AppendWithoutForEach() {
        // Given Swift code with append but not forEach
        let code = """
        class DataProcessor {
            func processItems(_ items: [String]) -> [String] {
                var results: [String] = []
                for item in items {
                    results.append(item.uppercased())
                }
                return results
            }
        }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then no issues should be detected (regular for loop with append is OK)
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectPerformanceIssues_MultipleArrayOperations() {
        // Given Swift code with chained array operations
        let code = """
        class DataProcessor {
            func processItems(_ items: [String]) -> [String] {
                return items
                    .filter { $0.count > 3 }
                    .map { $0.uppercased() }
            }
        }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then multiple array operations issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, IssueSeverity.low)
        XCTAssertEqual(issues[0].category, IssueCategory.performance)
        XCTAssertTrue(issues[0].description.contains("Multiple array operations"))
        XCTAssertTrue(issues[0].description.contains("flatMap"))
    }

    func testDetectPerformanceIssues_FilterWithoutMap() {
        // Given Swift code with filter but no map
        let code = """
        class DataProcessor {
            func processItems(_ items: [String]) -> [String] {
                return items.filter { $0.count > 3 }
            }
        }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then no issues should be detected (filter alone is OK)
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectPerformanceIssues_MapWithoutFilter() {
        // Given Swift code with map but no filter
        let code = """
        class DataProcessor {
            func processItems(_ items: [String]) -> [String] {
                return items.map { $0.uppercased() }
            }
        }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then no issues should be detected (map alone is OK)
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectPerformanceIssues_BothIssues() {
        // Given Swift code with both performance issues
        let code = """
        class DataProcessor {
            func processItems1(_ items: [String]) -> [String] {
                var results: [String] = []
                items.forEach { item in
                    results.append(item.uppercased())
                }
                return results
            }

            func processItems2(_ items: [String]) -> [String] {
                return items
                    .filter { $0.count > 3 }
                    .map { $0.uppercased() }
            }
        }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then both issues should be detected
        XCTAssertEqual(issues.count, 2)

        let forEachIssue = issues.first { $0.description.contains("forEach") }
        let arrayOpsIssue = issues.first { $0.description.contains("Multiple array operations") }

        XCTAssertNotNil(forEachIssue)
        XCTAssertNotNil(arrayOpsIssue)
    }

    // MARK: - Non-Swift Language Tests

    func testDetectPerformanceIssues_NonSwiftLanguage() {
        // Given code with JavaScript performance patterns
        let code = """
        function processItems(items) {
            var results = [];
            items.forEach(function(item) {
                results.push(item.toUpperCase());
            });
            return results;
        }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "JavaScript")

        // Then forEach+push issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, IssueSeverity.medium)
        XCTAssertEqual(issues[0].category, IssueCategory.performance)
        XCTAssertTrue(issues[0].description.contains("forEach"))
    }

    // MARK: - Edge Cases

    func testDetectPerformanceIssues_EmptyCode() {
        // Given empty code
        let code = ""

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectPerformanceIssues_WhitespaceOnly() {
        // Given whitespace-only code
        let code = "   \n\t   \n  "

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectPerformanceIssues_CaseSensitivity() {
        // Given code with different cases
        let code1 = "items.forEach { results.append($0) }" // lowercase
        let code2 = "items.FOREACH { results.APPEND($0) }" // uppercase
        let code3 = "items.filter { $0 }.map { $0 }" // lowercase
        let code4 = "items.FILTER { $0 }.MAP { $0 }" // uppercase

        // When analyzing for performance issues
        let issues1 = performanceAnalyzer.detectPerformanceIssues(in: code1, language: "Swift")
        let issues2 = performanceAnalyzer.detectPerformanceIssues(in: code2, language: "Swift")
        let issues3 = performanceAnalyzer.detectPerformanceIssues(in: code3, language: "Swift")
        let issues4 = performanceAnalyzer.detectPerformanceIssues(in: code4, language: "Swift")

        // Then issues should be detected for lowercase but not uppercase
        XCTAssertEqual(issues1.count, 1) // forEach + append detected
        XCTAssertEqual(issues2.count, 0) // FOREACH + APPEND not detected
        XCTAssertEqual(issues3.count, 1) // filter + map detected
        XCTAssertEqual(issues4.count, 0) // FILTER + MAP not detected
    }

    // MARK: - Complex Scenarios

    func testDetectPerformanceIssues_ComplexCode() {
        // Given complex Swift code with multiple performance patterns
        let code = """
        class DataProcessor {
            func inefficientProcessing(_ items: [String]) -> [String] {
                var results: [String] = []

                // Inefficient forEach + append
                items.forEach { item in
                    if item.count > 3 {
                        results.append(item.uppercased())
                    }
                }

                return results
            }

            func chainedOperations(_ items: [String]) -> [String] {
                // Multiple chained operations
                return items
                    .filter { $0.count > 3 }
                    .map { $0.uppercased() }
                    .filter { $0.hasPrefix("A") }
                    .map { $0.lowercased() }
            }

            func efficientProcessing(_ items: [String]) -> [String] {
                // This is efficient
                return items.lazy
                    .filter { $0.count > 3 }
                    .map { $0.uppercased() }
                    .filter { $0.hasPrefix("A") }
                    .map { $0.lowercased() }
            }
        }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then both performance issues should be detected
        XCTAssertEqual(issues.count, 2)

        let forEachIssue = issues.first { $0.description.contains("forEach") }
        let arrayOpsIssue = issues.first { $0.description.contains("Multiple array operations") }

        XCTAssertNotNil(forEachIssue)
        XCTAssertNotNil(arrayOpsIssue)
    }

    // MARK: - Issue Uniqueness

    func testDetectPerformanceIssues_IssueUniqueness() {
        // Given code with repeated patterns
        let code = """
        items.forEach { results.append($0) }
        items.forEach { results.append($0) }
        """

        // When analyzing for performance issues
        let issues = performanceAnalyzer.detectPerformanceIssues(in: code, language: "Swift")

        // Then only one issue should be reported (not duplicated)
        XCTAssertEqual(issues.count, 1)
    }
}
