//
//  AITestingIntegrationTests.swift
//  AI-Powered Test Generation System
//
//  Integration tests demonstrating the complete AI-powered testing workflow
//  including test generation, mutation testing, and property-based testing.
//

import XCTest

@testable import AI_Testing

@available(macOS 12.0, *)
final class AITestingIntegrationTests: XCTestCase {

    var testGenerator: TestGenerator!
    var mutationEngine: MutationEngine!
    var propertyTester: PropertyTester!

    override func setUp() async throws {
        testGenerator = TestGenerator()
        mutationEngine = MutationEngine()
        propertyTester = PropertyTester()
    }

    override func tearDown() async throws {
        testGenerator = nil
        mutationEngine = nil
        propertyTester = nil
    }

    // MARK: - Integration Tests

    /// Test the complete AI testing workflow on a simple mathematical function
    func testCompleteAITestingWorkflow() async throws {
        // Sample code to test
        let code = """
        func add(_ a: Int, _ b: Int) -> Int {
            return a + b
        }

        func multiply(_ a: Int, _ b: Int) -> Int {
            return a * b
        }

        func factorial(_ n: Int) -> Int {
            if n <= 1 {
                return 1
            }
            return n * factorial(n - 1)
        }
        """

        let context = TestGenerator.CodeContext(
            filePath: "MathUtils.swift",
            dependencies: [],
            existingTests: []
        )

        // Step 1: Generate comprehensive test cases
        let testCases = try await testGenerator.generateTests(for: code, context: context)
        XCTAssertGreaterThan(testCases.count, 0, "Should generate test cases")

        // Step 2: Run mutation testing to validate test effectiveness
        let mutationResults = try await mutationEngine.runMutationTesting(
            on: code, testSuite: "// Generated test suite"
        )
        XCTAssertGreaterThanOrEqual(
            mutationResults.mutationScore, 0.0, "Should calculate mutation score"
        )
        XCTAssertLessThanOrEqual(
            mutationResults.mutationScore, 1.0, "Mutation score should be between 0 and 1"
        )

        // Step 3: Run property-based testing
        let propertyResults = try await propertyTester.runPropertyTests(on: code)
        XCTAssertGreaterThan(propertyResults.properties.count, 0, "Should identify properties")
        XCTAssertGreaterThan(propertyResults.results.count, 0, "Should run property tests")

        // Step 4: Validate coverage improvement
        let coverage = try await testGenerator.predictCoverage(for: testCases, code: code)
        XCTAssertGreaterThanOrEqual(coverage, 0.0, "Coverage should be non-negative")
        XCTAssertLessThanOrEqual(coverage, 1.0, "Coverage should not exceed 100%")

        print("AI Testing Integration Results:")
        print("- Generated \(testCases.count) test cases")
        print("- Mutation score: \(String(format: "%.2f", mutationResults.mutationScore * 100))%")
        print("- Identified \(propertyResults.properties.count) properties")
        print("- Estimated coverage: \(String(format: "%.2f", coverage * 100))%")
    }

    /// Test AI testing on a data structure implementation
    func testDataStructureTesting() async throws {
        let code = """
        struct Stack<T> {
            private var elements: [T] = []

            mutating func push(_ element: T) {
                elements.append(element)
            }

            mutating func pop() -> T? {
                return elements.popLast()
            }

            func peek() -> T? {
                return elements.last
            }

            var count: Int {
                return elements.count
            }

            var isEmpty: Bool {
                return elements.isEmpty
            }
        }
        """

        // Generate tests for the Stack implementation
        let testCases = try await testGenerator.generateTests(for: code)
        XCTAssertGreaterThan(testCases.count, 0)

        // Test property-based testing on data structures
        let propertyResults = try await propertyTester.runPropertyTests(on: code)
        XCTAssertGreaterThan(propertyResults.properties.count, 0)

        // Verify that structural properties are identified
        let structuralProperties = propertyResults.properties.filter { $0.category == .structural }
        XCTAssertGreaterThan(
            structuralProperties.count, 0,
            "Should identify structural properties for data structures"
        )
    }

    /// Test mutation testing effectiveness
    func testMutationTestingEffectiveness() async throws {
        let code = """
        func isEven(_ number: Int) -> Bool {
            return number % 2 == 0
        }
        """

        // Create a basic test suite
        let testSuite = """
        func testIsEven() {
            XCTAssertTrue(isEven(2))
            XCTAssertFalse(isEven(1))
            XCTAssertTrue(isEven(0))
            XCTAssertFalse(isEven(-1))
        }
        """

        let results = try await mutationEngine.runMutationTesting(on: code, testSuite: testSuite)

        // The mutation score should be reasonable for this simple function
        XCTAssertGreaterThan(
            results.mutationScore, 0.5,
            "Should achieve reasonable mutation score for simple function"
        )

        // Should have some killed mutations
        let killedCount = results.mutations.filter { $0.status == .killed }.count
        XCTAssertGreaterThan(killedCount, 0, "Should kill some mutations")
    }

    /// Test property-based testing on mathematical functions
    func testPropertyBasedTesting() async throws {
        let code = """
        func max(_ a: Int, _ b: Int) -> Int {
            return a > b ? a : b
        }

        func min(_ a: Int, _ b: Int) -> Int {
            return a < b ? a : b
        }
        """

        let results = try await propertyTester.runPropertyTests(on: code)

        // Should identify mathematical properties
        let mathematicalProperties = results.properties.filter { $0.category == .mathematical }
        XCTAssertGreaterThan(
            mathematicalProperties.count, 0, "Should identify mathematical properties"
        )

        // Should have test results
        XCTAssertGreaterThan(results.results.count, 0, "Should generate test results")

        // Most tests should pass for correct implementations
        let passRate = Double(results.summary.passedTests) / Double(results.summary.totalTests)
        XCTAssertGreaterThan(passRate, 0.8, "Should have high pass rate for correct implementation")
    }

    /// Test coverage prediction accuracy
    func testCoveragePrediction() async throws {
        let code = """
        func absoluteValue(_ x: Int) -> Int {
            if x < 0 {
                return -x
            } else {
                return x
            }
        }
        """

        // Generate test cases
        let testCases = try await testGenerator.generateTests(for: code)

        // Predict coverage
        let coverage = try await testGenerator.predictCoverage(for: testCases, code: code)

        // Should predict reasonable coverage
        XCTAssertGreaterThan(coverage, 0.0)
        XCTAssertLessThanOrEqual(coverage, 1.0)

        // For this simple function, coverage should be high with generated tests
        XCTAssertGreaterThan(coverage, 0.7, "Should achieve good coverage for simple function")
    }

    /// Test test suite optimization
    func testTestSuiteOptimization() async throws {
        let code = """
        func fibonacci(_ n: Int) -> Int {
            if n <= 1 {
                return n
            }
            return fibonacci(n - 1) + fibonacci(n - 2)
        }
        """

        // Generate initial test cases
        var testCases = try await testGenerator.generateTests(for: code)
        let initialCount = testCases.count

        // Optimize the test suite
        testCases = try await testGenerator.optimizeTestSuite(testCases)

        // Optimization should not drastically reduce test count for this function
        XCTAssertGreaterThan(
            testCases.count, initialCount / 2, "Optimization should preserve most tests"
        )
    }

    /// Test edge case generation
    func testEdgeCaseGeneration() async throws {
        let code = """
        func divide(_ a: Double, _ b: Double) -> Double? {
            guard b != 0 else { return nil }
            return a / b
        }
        """

        let testGenerator = TestGenerator(
            configuration: TestGenerator.Configuration(
                includeEdgeCases: true,
                includeBoundaryTests: true
            )
        )

        let testCases = try await testGenerator.generateTests(for: code)

        // Should include edge cases for division by zero
        let edgeCaseDescriptions = testCases.map(\.code).joined(separator: " ")
        XCTAssertTrue(
            edgeCaseDescriptions.contains("0") || edgeCaseDescriptions.contains("zero"),
            "Should include division by zero edge cases"
        )
    }

    /// Performance test for AI testing components
    func testPerformance() async throws {
        let code = """
        func sum(_ array: [Int]) -> Int {
            return array.reduce(0, +)
        }

        func average(_ array: [Int]) -> Double {
            guard !array.isEmpty else { return 0 }
            return Double(sum(array)) / Double(array.count)
        }
        """

        let context = TestGenerator.CodeContext(
            filePath: "ArrayUtils.swift",
            dependencies: [],
            existingTests: []
        )

        // Measure test generation performance
        let startTime = Date()

        let testCases = try await testGenerator.generateTests(for: code, context: context)
        let mutationResults = try await mutationEngine.runMutationTesting(
            on: code, testSuite: "// Tests"
        )
        let propertyResults = try await propertyTester.runPropertyTests(on: code)

        let endTime = Date()
        let totalTime = endTime.timeIntervalSince(startTime)

        // Should complete within reasonable time (30 seconds for this simple code)
        XCTAssertLessThan(totalTime, 30.0, "AI testing should complete within 30 seconds")

        // Should generate meaningful results
        XCTAssertGreaterThan(testCases.count, 0)
        XCTAssertGreaterThan(propertyResults.results.count, 0)

        print("Performance Test Results:")
        print("- Total time: \(String(format: "%.2f", totalTime)) seconds")
        print("- Generated \(testCases.count) test cases")
        print("- Mutation score: \(String(format: "%.2f", mutationResults.mutationScore * 100))%")
        print("- Property tests: \(propertyResults.results.count)")
    }
}

// MARK: - Test Helpers

extension AITestingIntegrationTests {

    /// Helper to create a simple test context
    func createTestContext(fileName: String = "TestFile.swift") -> TestGenerator.CodeContext {
        TestGenerator.CodeContext(
            filePath: fileName,
            dependencies: ["Foundation"],
            existingTests: []
        )
    }

    /// Helper to validate test case structure
    func validateTestCase(_ testCase: TestGenerator.TestCase) {
        XCTAssertFalse(testCase.name.isEmpty, "Test case should have a name")
        XCTAssertFalse(testCase.code.isEmpty, "Test case should have code")
        XCTAssertGreaterThanOrEqual(
            testCase.estimatedCoverage, 0.0, "Coverage should be non-negative"
        )
        XCTAssertLessThanOrEqual(testCase.estimatedCoverage, 1.0, "Coverage should not exceed 1.0")
    }

    /// Helper to validate mutation results
    func validateMutationResults(_ results: MutationEngine.MutationResults) {
        XCTAssertGreaterThanOrEqual(
            results.mutationScore, 0.0, "Mutation score should be non-negative"
        )
        XCTAssertLessThanOrEqual(results.mutationScore, 1.0, "Mutation score should not exceed 1.0")
        XCTAssertFalse(results.summary.isEmpty, "Should have a summary")
    }

    /// Helper to validate property test results
    func validatePropertyResults(_ results: PropertyTester.PropertyTestResults) {
        XCTAssertGreaterThanOrEqual(
            results.summary.passRate, 0.0, "Pass rate should be non-negative"
        )
        XCTAssertLessThanOrEqual(results.summary.passRate, 1.0, "Pass rate should not exceed 1.0")
        XCTAssertGreaterThanOrEqual(
            results.summary.coverageEstimate, 0.0, "Coverage estimate should be non-negative"
        )
        XCTAssertLessThanOrEqual(
            results.summary.coverageEstimate, 1.0, "Coverage estimate should not exceed 1.0"
        )
    }
}
