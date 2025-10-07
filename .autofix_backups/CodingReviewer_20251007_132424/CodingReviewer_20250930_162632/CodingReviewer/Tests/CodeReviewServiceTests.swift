//
// CodeReviewServiceTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

@MainActor
class CodeReviewServiceTests: XCTestCase {
    private var service: CodeReviewService!

    override func setUp() {
        super.setUp()
        self.service = CodeReviewService()
    }

    override func tearDown() {
        self.service = nil
        super.tearDown()
    }

    func testAnalyzeCodeReturnsBugIssues() async throws {
        let code = "// TODO: fix logic"

        let result = try await service.analyzeCode(code, language: "Swift", analysisType: .bugs)

        XCTAssertEqual(result.language, "Swift")
        XCTAssertEqual(result.analysisType, .bugs)
        XCTAssertEqual(result.issues.count, 1)
        XCTAssertEqual(result.issues.first?.description, "TODO comment found - this should be addressed")
    }

    func testGenerateDocumentationIncludesLanguage() async throws {
        let code = "struct Greeter { func greet() {} }"

        let result = try await service.generateDocumentation(code, language: "Swift", includeExamples: true)

        XCTAssertTrue(result.documentation.contains("Generated documentation for Swift code"))
        XCTAssertEqual(result.language, "Swift")
        XCTAssertTrue(result.includesExamples)
    }

    func testGenerateTestsReturnsEstimatedCoverage() async throws {
        let code = "struct Greeter { func greet() {} }"

        let result = try await service.generateTests(code, language: "Swift", testFramework: "XCTest")

        XCTAssertEqual(result.language, "Swift")
        XCTAssertEqual(result.testFramework, "XCTest")
        XCTAssertFalse(result.testCode.isEmpty)
        XCTAssertGreaterThan(result.estimatedCoverage, 0)
    }

    func testTrackReviewProgressDoesNotThrow() async throws {
        try await self.service.trackReviewProgress(UUID())
    }
}
