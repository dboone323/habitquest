//
// PerformanceAnalysisServiceTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

class PerformanceAnalysisServiceTests: XCTestCase {
    private var sut: PerformanceAnalysisService!

    override func setUp() {
        super.setUp()
        self.sut = PerformanceAnalysisService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testDetectsFilterMapChainInSwift() {
        let code = """
        let result = numbers
            .filter { $0 > 0 }
            .map { $0 * 2 }
        """

        let issues = self.sut.detectPerformanceIssues(in: code, language: "Swift")

        XCTAssertTrue(issues.contains { $0.description.contains("filter followed by map") })
        XCTAssertTrue(issues.contains { $0.description.contains("Multiple array operations") })
    }

    func testAvoidsDuplicateEntriesForSamePattern() {
        let code = """
        let first = numbers.filter { $0 > 0 }.map { $0 * 2 }
        let second = numbers.filter { $0 < 0 }.map { $0 * -1 }
        """

        let issues = self.sut.detectPerformanceIssues(in: code, language: "Swift")

        let filterMapCount = issues.count(where: { $0.description.contains("filter followed by map") })
        XCTAssertEqual(filterMapCount, 1)
    }

    func testDetectsForEachPushPatternInJavaScript() {
        let code = """
        const result = [];
        items.forEach(item => {
            result.push(item * 2);
        });
        """

        let issues = self.sut.detectPerformanceIssues(in: code, language: "JavaScript")

        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues.first?.category, .performance)
        XCTAssertEqual(issues.first?.severity, .medium)
    }
}
