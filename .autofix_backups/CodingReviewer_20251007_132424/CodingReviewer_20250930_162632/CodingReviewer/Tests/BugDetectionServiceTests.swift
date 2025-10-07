//
// BugDetectionServiceTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

class BugDetectionServiceTests: XCTestCase {
    private var sut: BugDetectionService!
    private let todoMarker = "TODO"

    override func setUp() {
        super.setUp()
        self.sut = BugDetectionService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testDetectsTodoCommentsInSwift() {
        let code = """
        // \(todoMarker): refactor this
        func greet() {}
        """

        let issues = self.sut.detectBasicBugs(code: code, language: "Swift")

        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues.first?.description, "TODO comment found - this should be addressed")
        XCTAssertEqual(issues.first?.severity, .medium)
        XCTAssertEqual(issues.first?.line, 1)
        XCTAssertEqual(issues.first?.category, .bug)
    }

    func testDetectsForceUnwrapOnce() {
        let code = """
        let value = optional!
        let another = otherOptional!
        """

        let issues = self.sut.detectBasicBugs(code: code, language: "Swift")

        XCTAssertEqual(issues.count(where: { $0.description.contains("Force unwrapping") }), 1)
    }

    func testIgnoresTodoForUnsupportedLanguage() {
        let code = "// \(todoMarker): handle error"

        let issues = self.sut.detectBasicBugs(code: code, language: "Python")

        XCTAssertTrue(issues.isEmpty)
    }
}
