//
// ErrorHandlerTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

final class ErrorHandlerTests: XCTestCase {
    func testErrorDescriptionsIncludeContext() {
        let fileError = CodingReviewerErrorHandler.CodingReviewerError.fileOperationError("Missing file")
        XCTAssertEqual(fileError.errorDescription, "File Operation Error: Missing file")
        XCTAssertEqual(fileError.recoverySuggestion, "Please check file permissions and try again.")

        let analysisError = CodingReviewerErrorHandler.CodingReviewerError.analysisError("Invalid syntax")
        XCTAssertEqual(analysisError.errorDescription, "Analysis Error: Invalid syntax")
        XCTAssertEqual(analysisError.recoverySuggestion, "Please check the code file and try again.")
    }

    func testValidateFilePathDetectsEmptyAndMissingFiles() {
        XCTAssertNotNil(CodingReviewerErrorHandler.validateFilePath(""))

        let missingPath = "/tmp/" + UUID().uuidString
        let missingResult = CodingReviewerErrorHandler.validateFilePath(missingPath)
        XCTAssertNotNil(missingResult)
    }

    func testValidateFilePathSucceedsForExistingFile() throws {
        let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try "content".write(to: temporaryURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: temporaryURL) }

        XCTAssertNil(CodingReviewerErrorHandler.validateFilePath(temporaryURL.path))
    }

    func testValidateCodeContentConstraints() {
        XCTAssertNotNil(CodingReviewerErrorHandler.validateCodeContent(""))

        let oversized = String(repeating: "a", count: 1_000_001)
        XCTAssertNotNil(CodingReviewerErrorHandler.validateCodeContent(oversized))

        XCTAssertNil(CodingReviewerErrorHandler.validateCodeContent("struct Example {}"))
    }
}
