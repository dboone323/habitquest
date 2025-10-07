@testable import CodingReviewer
import XCTest

final class LanguageDetectorTests: XCTestCase {
    private var sut: LanguageDetector!

    override func setUp() {
        super.setUp()
        self.sut = LanguageDetector()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testDetectLanguageHandlesNilURLByReturningSwift() {
        XCTAssertEqual(self.sut.detectLanguage(from: nil), "Swift")
    }

    func testDetectLanguageMatchesKnownExtensions() {
        let swiftURL = URL(fileURLWithPath: "/tmp/example.swift")
        let pythonURL = URL(fileURLWithPath: "/tmp/script.py")
        let javascriptURL = URL(fileURLWithPath: "/tmp/app.ts")

        XCTAssertEqual(self.sut.detectLanguage(from: swiftURL), "Swift")
        XCTAssertEqual(self.sut.detectLanguage(from: pythonURL), "Python")
        XCTAssertEqual(self.sut.detectLanguage(from: javascriptURL), "JavaScript")
    }

    func testDetectLanguageFallsBackToSwiftForUnknownExtension() {
        let unknownURL = URL(fileURLWithPath: "/tmp/data.unknown")

        XCTAssertEqual(self.sut.detectLanguage(from: unknownURL), "Swift")
    }
}
