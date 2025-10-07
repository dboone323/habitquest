//
//  DocumentationGeneratorTests.swift
//  CodingReviewerTests
//
//  Unit tests for DocumentationGenerator
//

@testable import CodingReviewer
import XCTest

final class DocumentationGeneratorTests: XCTestCase {
    var docGenerator: DocumentationGenerator!

    override func setUp() {
        super.setUp()
        docGenerator = DocumentationGenerator()
    }

    override func tearDown() {
        docGenerator = nil
        super.tearDown()
    }

    // MARK: - Basic Documentation Generation Tests

    func testGenerateBasicDocumentation_Swift_WithExamples() {
        // Given Swift code with functions
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }

            func multiply(_ a: Int, _ b: Int) -> Int {
                return a * b
            }
        }
        """

        // When generating documentation with examples
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: true)

        // Then documentation should be generated
        XCTAssertFalse(documentation.isEmpty)
        XCTAssertTrue(documentation.contains("# Code Documentation"))
        XCTAssertTrue(documentation.contains("Generated documentation for Swift code"))
        XCTAssertTrue(documentation.contains("## Functions"))
        XCTAssertTrue(documentation.contains("func add"))
        XCTAssertTrue(documentation.contains("func multiply"))
        XCTAssertTrue(documentation.contains("## Usage Examples"))
        XCTAssertTrue(documentation.contains("```swift"))
    }

    func testGenerateBasicDocumentation_Swift_WithoutExamples() {
        // Given Swift code with functions
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        // When generating documentation without examples
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: false)

        // Then documentation should be generated but without examples section
        XCTAssertFalse(documentation.isEmpty)
        XCTAssertTrue(documentation.contains("# Code Documentation"))
        XCTAssertTrue(documentation.contains("## Functions"))
        XCTAssertTrue(documentation.contains("func add"))
        XCTAssertFalse(documentation.contains("## Usage Examples"))
        XCTAssertFalse(documentation.contains("```swift"))
    }

    func testGenerateBasicDocumentation_Swift_NoFunctions() {
        // Given Swift code without functions
        let code = """
        class Calculator {
            let name = "Calc"
            var value: Int = 0
        }
        """

        // When generating documentation
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: true)

        // Then documentation should be generated but without functions section
        XCTAssertFalse(documentation.isEmpty)
        XCTAssertTrue(documentation.contains("# Code Documentation"))
        XCTAssertFalse(documentation.contains("## Functions"))
        XCTAssertTrue(documentation.contains("## Usage Examples"))
    }

    func testGenerateBasicDocumentation_NonSwiftLanguage() {
        // Given code in non-Swift language
        let code = """
        function add(a, b) {
            return a + b;
        }
        """

        // When generating documentation
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "JavaScript", includeExamples: true)

        // Then documentation should be generated but without functions section (only Swift is supported)
        XCTAssertFalse(documentation.isEmpty)
        XCTAssertTrue(documentation.contains("# Code Documentation"))
        XCTAssertTrue(documentation.contains("Generated documentation for JavaScript code"))
        XCTAssertFalse(documentation.contains("## Functions"))
        XCTAssertTrue(documentation.contains("## Usage Examples"))
        XCTAssertTrue(documentation.contains("```javascript"))
    }

    func testGenerateBasicDocumentation_EmptyCode() {
        // Given empty code
        let code = ""

        // When generating documentation
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: false)

        // Then basic documentation should still be generated
        XCTAssertFalse(documentation.isEmpty)
        XCTAssertTrue(documentation.contains("# Code Documentation"))
        XCTAssertTrue(documentation.contains("Generated documentation for Swift code"))
        XCTAssertFalse(documentation.contains("## Functions"))
        XCTAssertFalse(documentation.contains("## Usage Examples"))
    }

    // MARK: - Function Extraction Tests

    func testGenerateBasicDocumentation_FunctionExtraction() {
        // Given Swift code with various function signatures
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }

            private func helper() -> Void {
                print("helper")
            }

            func multiply(a: Int, b: Int) -> Int {
                return a * b
            }

            static func create() -> Calculator {
                return Calculator()
            }
        }
        """

        // When generating documentation
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: false)

        // Then all functions should be extracted and documented
        XCTAssertTrue(documentation.contains("func add(_ a: Int, _ b: Int) -> Int"))
        XCTAssertTrue(documentation.contains("private func helper() -> Void"))
        XCTAssertTrue(documentation.contains("func multiply(a: Int, b: Int) -> Int"))
        XCTAssertTrue(documentation.contains("static func create() -> Calculator"))
    }

    func testGenerateBasicDocumentation_FunctionWithWhitespace() {
        // Given Swift code with extra whitespace around functions
        let code = """
        class Test {

            func   add   (   _ a : Int ,   _ b : Int   )   ->   Int   {

            }

        }
        """

        // When generating documentation
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: false)

        // Then function should be extracted with original formatting
        XCTAssertTrue(documentation.contains("func   add   (   _ a : Int ,   _ b : Int   )   ->   Int"))
    }

    func testGenerateBasicDocumentation_MultipleClasses() {
        // Given Swift code with multiple classes
        let code = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }

        class Printer {
            func print(_ message: String) {
                Swift.print(message)
            }
        }
        """

        // When generating documentation
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: false)

        // Then functions from all classes should be extracted
        XCTAssertTrue(documentation.contains("func add(_ a: Int, _ b: Int) -> Int"))
        XCTAssertTrue(documentation.contains("func print(_ message: String)"))
    }

    // MARK: - Examples Section Tests

    func testGenerateBasicDocumentation_ExamplesContent() {
        // Given any code
        let code = "let x = 1"

        // When generating documentation with examples
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: true)

        // Then examples section should contain proper code block
        XCTAssertTrue(documentation.contains("## Usage Examples"))
        XCTAssertTrue(documentation.contains("```swift"))
        XCTAssertTrue(documentation.contains("// Example usage"))
        XCTAssertTrue(documentation.contains("```"))
    }

    func testGenerateBasicDocumentation_ExamplesForDifferentLanguages() {
        // Test different languages get correct code block syntax
        let languages = ["Swift", "JavaScript", "Python", "Java"]

        for language in languages {
            let documentation = docGenerator.generateBasicDocumentation(
                code: "test",
                language: language,
                includeExamples: true
            )

            XCTAssertTrue(documentation.contains("```\(language.lowercased())"))
        }
    }

    // MARK: - Edge Cases

    func testGenerateBasicDocumentation_OnlyNewlines() {
        // Given code with only newlines
        let code = "\n\n\n"

        // When generating documentation
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: false)

        // Then basic documentation should be generated
        XCTAssertFalse(documentation.isEmpty)
        XCTAssertTrue(documentation.contains("# Code Documentation"))
        XCTAssertFalse(documentation.contains("## Functions"))
    }

    func testGenerateBasicDocumentation_FunctionsWithoutClass() {
        // Given functions not in a class
        let code = """
        func globalAdd(_ a: Int, _ b: Int) -> Int {
            return a + b
        }

        private func helper() {
            // helper function
        }
        """

        // When generating documentation
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: false)

        // Then all functions should be extracted
        XCTAssertTrue(documentation.contains("func globalAdd(_ a: Int, _ b: Int) -> Int"))
        XCTAssertTrue(documentation.contains("private func helper()"))
    }

    func testGenerateBasicDocumentation_ComplexFunctionSignatures() {
        // Given complex function signatures
        let code = """
        func complex<T: Equatable, U>(
            param1: T,
            param2: @escaping (U) -> Bool,
            param3: inout String
        ) async throws -> Result<T, Error> where T: Codable {
            // implementation
        }
        """

        // When generating documentation
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: false)

        // Then complex function should be extracted correctly
        XCTAssertTrue(documentation.contains("func complex<T: Equatable, U>"))
        XCTAssertTrue(documentation.contains("param1: T"))
        XCTAssertTrue(documentation.contains("async throws -> Result<T, Error>"))
    }

    // MARK: - Documentation Structure Tests

    func testGenerateBasicDocumentation_Structure() {
        // Given any Swift code
        let code = "class Test {}"

        // When generating documentation
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: true)

        // Then documentation should have proper structure
        let lines = documentation.components(separatedBy: .newlines)

        XCTAssertTrue(lines[0] == "# Code Documentation")
        XCTAssertTrue(lines[1] == "")
        XCTAssertTrue(lines[2].hasPrefix("Generated documentation for Swift code"))
    }

    func testGenerateBasicDocumentation_NoExtraWhitespace() {
        // Given code without functions
        let code = "let x = 1"

        // When generating documentation without examples
        let documentation = docGenerator.generateBasicDocumentation(code: code, language: "Swift", includeExamples: false)

        // Then there should be no trailing whitespace issues
        XCTAssertFalse(documentation.hasSuffix("\n\n"))
        XCTAssertFalse(documentation.contains("\n\n\n"))
    }
}
