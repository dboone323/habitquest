//
// DocumentationGeneratorTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

class DocumentationGeneratorTests: XCTestCase {
    private var sut: DocumentationGenerator!

    override func setUp() {
        super.setUp()
        self.sut = DocumentationGenerator()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testGeneratesFunctionListForSwiftCode() {
        let code = """
        public struct Greeter {
            public func greet(name: String) {
                print("Hello, \(name)")
            }

            private func helper() {}
        }
        """

        let documentation = self.sut.generateBasicDocumentation(code: code, language: "Swift", includeExamples: false)

        XCTAssertTrue(documentation.contains("## Functions"))
        XCTAssertTrue(documentation.contains("public func greet"))
        XCTAssertTrue(documentation.contains("private func helper"))
    }

    func testIncludesUsageExamplesWhenRequested() {
        let code = "struct Example {}"

        let documentation = self.sut.generateBasicDocumentation(code: code, language: "Swift", includeExamples: true)

        XCTAssertTrue(documentation.contains("## Usage Examples"))
        XCTAssertTrue(documentation.contains("```swift"))
    }

    func testOutputEndsWithNewline() {
        let doc = self.sut.generateBasicDocumentation(code: "", language: "Swift", includeExamples: false)

        XCTAssertTrue(doc.hasSuffix("\n"))
    }
}
