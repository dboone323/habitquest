//
//  BugDetectionServiceTests.swift
//  CodingReviewerTests
//
//  Unit tests for BugDetectionService
//

@testable import CodingReviewer
import XCTest

final class BugDetectionServiceTests: XCTestCase {
    var bugDetector: BugDetectionService!

    override func setUp() {
        super.setUp()
        bugDetector = BugDetectionService()
    }

    override func tearDown() {
        bugDetector = nil
        super.tearDown()
    }

    // MARK: - Basic Bug Detection Tests

    func testDetectBasicBugs_NoIssues() {
        // Given clean code with no issues
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectBasicBugs_TODOComment() {
        // Given code with TODO comment
        let code = """
        class Calculator {
            // TODO: Implement error handling
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "Swift")

        // Then TODO issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, .medium)
        XCTAssertEqual(issues[0].category, .bug)
        XCTAssertTrue(issues[0].description.contains("TODO"))
    }

    func testDetectBasicBugs_FIXMEComment() {
        // Given code with FIXME comment
        let code = """
        class Calculator {
            // FIXME: This method needs refactoring
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "Swift")

        // Then FIXME issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, .medium)
        XCTAssertEqual(issues[0].category, .bug)
        XCTAssertTrue(issues[0].description.contains("FIXME"))
    }

    func testDetectBasicBugs_DebugPrintStatement() {
        // Given code with print statement
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                print("Adding numbers")
                return a + b
            }
        }
        """

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "Swift")

        // Then print statement issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, IssueSeverity.low)
        XCTAssertEqual(issues[0].category, IssueCategory.bug)
        XCTAssertTrue(issues[0].description.contains("print statements"))
    }

    func testDetectBasicBugs_DebugPrintStatement_NonSwift() {
        // Given code with print statement in non-Swift language
        let code = """
        function add(a, b) {
            console.log("Adding " + a + " + " + b);
            return a + b;
        }
        """

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "JavaScript")

        // Then no print statement issue should be detected (only checks Swift)
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectBasicBugs_ForceUnwrap() {
        // Given code with force unwrap
        let code = """
        class Calculator {
            func add(_ a: Int?, _ b: Int?) -> Int {
                return a! + b!
            }
        }
        """

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "Swift")

        // Then force unwrap issue should be detected
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues[0].severity, IssueSeverity.medium)
        XCTAssertEqual(issues[0].category, IssueCategory.bug)
        XCTAssertTrue(issues[0].description.contains("Force unwrapping"))
    }

    func testDetectBasicBugs_ForceUnwrap_NonSwift() {
        // Given code with force unwrap syntax in non-Swift language
        let code = """
        function add(a, b) {
            return a! + b!;
        }
        """

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "JavaScript")

        // Then no force unwrap issue should be detected (only checks Swift)
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectBasicBugs_MultipleIssues() {
        // Given code with multiple issues
        let code = """
        class Calculator {
            // TODO: Add validation
            func add(_ a: Int?, _ b: Int?) -> Int {
                print("Debug: adding numbers")
                return a! + b!
            }
        }
        """

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "Swift")

        // Then all issues should be detected
        XCTAssertEqual(issues.count, 3)

        // Check that we have the expected issues
        let todoIssue = issues.first { $0.description.contains("TODO") }
        let printIssue = issues.first { $0.description.contains("print") }
        let unwrapIssue = issues.first { $0.description.contains("Force unwrapping") }

        XCTAssertNotNil(todoIssue)
        XCTAssertNotNil(printIssue)
        XCTAssertNotNil(unwrapIssue)
    }

    func testDetectBasicBugs_EmptyCode() {
        // Given empty code
        let code = ""

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    func testDetectBasicBugs_WhitespaceOnly() {
        // Given whitespace-only code
        let code = "   \n\t   \n  "

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "Swift")

        // Then no issues should be found
        XCTAssertTrue(issues.isEmpty)
    }

    // MARK: - Issue Properties Tests

    func testCodeIssue_UniqueIDs() {
        // Given code with multiple issues of the same type
        let code = """
        // TODO: First task
        // TODO: Second task
        """

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "Swift")

        // Then each issue should have a unique ID
        XCTAssertEqual(issues.count, 2)
        XCTAssertNotEqual(issues[0].id, issues[1].id)
    }

    func testCodeIssue_NoLineNumbers() {
        // Given code with issues
        let code = """
        // TODO: Add implementation
        print("debug")
        """

        // When analyzing for bugs
        let issues = bugDetector.detectBasicBugs(code: code, language: "Swift")

        // Then line numbers should be tracked
        XCTAssertEqual(issues.count, 2)
        XCTAssertEqual(issues[0].line, 1) // TODO: comment on line 1
        XCTAssertEqual(issues[1].line, 2) // print statement on line 2
    }
}
