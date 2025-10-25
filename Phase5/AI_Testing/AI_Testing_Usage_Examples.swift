//
//  AI_Testing_Usage_Examples.swift
//  AI-Powered Test Generation System
//
//  This file demonstrates practical usage examples of the AI-powered testing system
//  including test generation, mutation testing, and property-based testing.
//

import Foundation

// MARK: - Usage Examples

/// Example 1: Basic Test Generation
func exampleBasicTestGeneration() async {
    print("=== Basic Test Generation Example ===")

    // Initialize the AI test generator
    let testGenerator = TestGenerator()

    // Sample code to test
    let code = """
    func calculateArea(width: Double, height: Double) -> Double {
        return width * height
    }

    func isPositive(_ number: Int) -> Bool {
        return number > 0
    }
    """

    do {
        // Generate comprehensive tests
        let testCases = try await testGenerator.generateTests(for: code)

        print("Generated \(testCases.count) test cases:")
        for testCase in testCases {
            print(
                "- \(testCase.name) (Priority: \(testCase.priority), Coverage: \(String(format: "%.1f%%", testCase.estimatedCoverage * 100)))"
            )
        }

        // Predict coverage
        let coverage = try await testGenerator.predictCoverage(for: testCases, code: code)
        print("Estimated coverage: \(String(format: "%.1f%%", coverage * 100))")

    } catch {
        print("Error generating tests: \(error)")
    }
}

/// Example 2: Mutation Testing for Test Quality
func exampleMutationTesting() async {
    print("\n=== Mutation Testing Example ===")

    let mutationEngine = MutationEngine()

    let code = """
    func findMax(_ array: [Int]) -> Int? {
        guard !array.isEmpty else { return nil }
        return array.max()
    }
    """

    // Create a test suite to validate
    let testSuite = """
    func testFindMax() {
        XCTAssertEqual(findMax([1, 2, 3]), 3)
        XCTAssertEqual(findMax([5]), 5)
        XCTAssertNil(findMax([]))
        XCTAssertEqual(findMax([-1, -2, -3]), -1)
    }
    """

    do {
        let results = try await mutationEngine.runMutationTesting(on: code, testSuite: testSuite)

        print("Mutation Testing Results:")
        print("- Mutation Score: \(String(format: "%.1f%%", results.mutationScore * 100))")
        print("- Total Mutations: \(results.mutations.count)")
        print("- Killed: \(results.mutations.filter { $0.status == .killed }.count)")
        print("- Survived: \(results.mutations.filter { $0.status == .survived }.count)")

        if !results.suggestions.isEmpty {
            print("\nImprovement Suggestions:")
            for suggestion in results.suggestions {
                print("- \(suggestion)")
            }
        }

    } catch {
        print("Error running mutation testing: \(error)")
    }
}

/// Example 3: Property-Based Testing
func examplePropertyBasedTesting() async {
    print("\n=== Property-Based Testing Example ===")

    let propertyTester = PropertyTester()

    let code = """
    struct Queue<T> {
        private var elements: [T] = []

        mutating func enqueue(_ element: T) {
            elements.append(element)
        }

        mutating func dequeue() -> T? {
            guard !elements.isEmpty else { return nil }
            return elements.removeFirst()
        }

        var count: Int { elements.count }
        var isEmpty: Bool { elements.isEmpty }
    }
    """

    do {
        let results = try await propertyTester.runPropertyTests(on: code)

        print("Property-Based Testing Results:")
        print("- Identified \(results.properties.count) properties")

        for property in results.properties {
            print(
                "- \(property.description) (\(property.category.rawValue), \(property.complexity.rawValue))"
            )
        }

        print("\nTest Summary:")
        print("- Total Tests: \(results.summary.totalTests)")
        print("- Passed: \(results.summary.passedTests)")
        print("- Failed: \(results.summary.failedTests)")
        print("- Pass Rate: \(String(format: "%.1f%%", results.summary.passRate * 100))")
        print(
            "- Estimated Coverage: \(String(format: "%.1f%%", results.summary.coverageEstimate * 100))"
        )

    } catch {
        print("Error running property testing: \(error)")
    }
}

/// Example 4: Advanced Configuration and Optimization
func exampleAdvancedConfiguration() async {
    print("\n=== Advanced Configuration Example ===")

    // Configure test generator with custom settings
    let testConfig = TestGenerator.Configuration(
        coverageTarget: 0.95,
        maxTestsPerFunction: 15,
        includeEdgeCases: true,
        includeBoundaryTests: true,
        enableAIEnhancement: true
    )

    let testGenerator = TestGenerator(configuration: testConfig)

    // Configure mutation testing
    let mutationConfig = MutationEngine.Configuration(
        mutationOperators: [.arithmeticOperatorReplacement, .relationalOperatorReplacement],
        maxMutationsPerFile: 30,
        timeoutPerMutation: 15.0,
        enableParallelExecution: true,
        mutationScoreTarget: 0.90
    )

    let mutationEngine = MutationEngine(configuration: mutationConfig)

    // Configure property testing
    let propertyConfig = PropertyTester.Configuration(
        maxTestCasesPerProperty: 50,
        maxShrinksPerFailure: 5,
        timeoutPerTest: 5.0,
        enableParallelExecution: true,
        coverageTarget: 0.85
    )

    let propertyTester = PropertyTester(configuration: propertyConfig)

    let code = """
    func binarySearch<T: Comparable>(_ array: [T], _ target: T) -> Int? {
        var left = 0
        var right = array.count - 1

        while left <= right {
            let mid = left + (right - left) / 2

            if array[mid] == target {
                return mid
            } else if array[mid] < target {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }

        return nil
    }
    """

    do {
        // Generate optimized tests
        let testCases = try await testGenerator.generateTests(for: code)
        print("Generated \(testCases.count) optimized test cases")

        // Run comprehensive mutation testing
        let mutationResults = try await mutationEngine.runMutationTesting(
            on: code, testSuite: "// Tests"
        )
        print("Mutation score: \(String(format: "%.1f%%", mutationResults.mutationScore * 100))")

        // Run property-based tests
        let propertyResults = try await propertyTester.runPropertyTests(on: code)
        print(
            "Property tests pass rate: \(String(format: "%.1f%%", propertyResults.summary.passRate * 100))"
        )

        // Optimize the test suite
        let optimizedTests = try await testGenerator.optimizeTestSuite(testCases)
        print("Optimized to \(optimizedTests.count) test cases")

    } catch {
        print("Error in advanced testing: \(error)")
    }
}

/// Example 5: CI/CD Integration
func exampleCIIntegration() async {
    print("\n=== CI/CD Integration Example ===")

    // Simulate CI pipeline testing
    let code = """
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func calculateDiscount(price: Double, discountPercent: Double) -> Double {
        guard discountPercent >= 0 && discountPercent <= 100 else {
            return price
        }
        return price * (1 - discountPercent / 100)
    }
    """

    let testGenerator = TestGenerator()
    let mutationEngine = MutationEngine()
    let propertyTester = PropertyTester()

    do {
        // Step 1: Generate comprehensive tests
        print("Step 1: Generating tests...")
        let testCases = try await testGenerator.generateTests(for: code)
        print("✓ Generated \(testCases.count) test cases")

        // Step 2: Validate with mutation testing
        print("Step 2: Running mutation testing...")
        let mutationResults = try await mutationEngine.runMutationTesting(
            on: code, testSuite: "// Generated tests"
        )
        print("✓ Mutation score: \(String(format: "%.1f%%", mutationResults.mutationScore * 100))")

        // Step 3: Run property-based tests
        print("Step 3: Running property tests...")
        let propertyResults = try await propertyTester.runPropertyTests(on: code)
        print(
            "✓ Property tests: \(propertyResults.summary.passedTests)/\(propertyResults.summary.totalTests) passed"
        )

        // Step 4: Quality gate checks
        print("Step 4: Quality gate checks...")

        let coverage = try await testGenerator.predictCoverage(for: testCases, code: code)
        let qualityPassed =
            coverage >= 0.80 && mutationResults.mutationScore >= 0.75
                && propertyResults.summary.passRate >= 0.90

        if qualityPassed {
            print("✓ All quality gates passed!")
            print("  - Coverage: \(String(format: "%.1f%%", coverage * 100)) (target: 80%)")
            print(
                "  - Mutation Score: \(String(format: "%.1f%%", mutationResults.mutationScore * 100)) (target: 75%)"
            )
            print(
                "  - Property Pass Rate: \(String(format: "%.1f%%", propertyResults.summary.passRate * 100)) (target: 90%)"
            )
        } else {
            print("✗ Quality gates failed - review and improve tests")
        }

    } catch {
        print("✗ CI testing failed: \(error)")
        // In real CI, this would fail the build
    }
}

/// Example 6: Real-world Usage with Error Handling
func exampleRealWorldUsage() async {
    print("\n=== Real-World Usage Example ===")

    let testGenerator = TestGenerator()
    let mutationEngine = MutationEngine()

    // Load code from a file (simulated)
    let filePath = "/Users/danielstevens/Desktop/Quantum-workspace/Shared/SharedArchitecture.swift"

    do {
        // In real usage, you would read from file
        let code = """
        @MainActor
        protocol BaseViewModel: ObservableObject {
            associatedtype State
            associatedtype Action
            var state: State { get set }
            var isLoading: Bool { get set }
            func handle(_ action: Action)
        }
        """

        let context = TestGenerator.CodeContext(
            filePath: filePath,
            dependencies: ["SwiftUI", "Combine"],
            existingTests: []
        )

        print("Testing SharedArchitecture protocol...")

        // Generate tests with context
        let testCases = try await testGenerator.generateTests(for: code, context: context)
        print("Generated \(testCases.count) test cases for protocol")

        // Run mutation testing
        let mutationResults = try await mutationEngine.runMutationTesting(
            on: code, testSuite: "// Protocol tests"
        )
        print(
            "Mutation analysis complete - Score: \(String(format: "%.1f%%", mutationResults.mutationScore * 100))"
        )

        // Provide actionable feedback
        if mutationResults.mutationScore < 0.70 {
            print("⚠️  Low mutation score - consider adding more comprehensive tests")
        }

        if !mutationResults.suggestions.isEmpty {
            print("💡 Suggestions for improvement:")
            for suggestion in mutationResults.suggestions.prefix(3) {
                print("   - \(suggestion)")
            }
        }

    } catch let error as TestGenerationError {
        print("Test generation error: \(error)")
        // Handle specific test generation errors
    } catch {
        print("Unexpected error: \(error)")
        // Handle other errors
    }
}

// MARK: - Main Execution

/// Run all usage examples
func runAllExamples() async {
    print("AI-Powered Test Generation System - Usage Examples")
    print("=================================================")

    await exampleBasicTestGeneration()
    await exampleMutationTesting()
    await examplePropertyBasedTesting()
    await exampleAdvancedConfiguration()
    await exampleCIIntegration()
    await exampleRealWorldUsage()

    print("\n=== Examples Complete ===")
    print("The AI testing system provides:")
    print("• Automated test case generation")
    print("• Mutation testing for quality validation")
    print("• Property-based testing for mathematical/behavioral properties")
    print("• Coverage prediction and optimization")
    print("• CI/CD integration with quality gates")
    print("• Real-world usage with error handling")
}

// Uncomment to run examples
// Task { await runAllExamples() }
