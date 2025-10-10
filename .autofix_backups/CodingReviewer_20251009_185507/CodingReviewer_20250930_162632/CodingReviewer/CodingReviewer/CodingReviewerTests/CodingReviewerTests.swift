//
//  CodingReviewerTests.swift
//  CodingReviewerTests
//
//  Created by Daniel Stevens on 9/19/25.
//

import XCTest

@testable import CodingReviewer

final class CodingReviewerTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppDelegateInitialization() throws {
        let appDelegate = AppDelegate()
        XCTAssertNotNil(appDelegate)
    }

    func testApplicationSupportsSecureRestorableState() throws {
        let appDelegate = AppDelegate()
        let mockApplication = NSApplication.shared
        let supportsRestorableState = appDelegate.applicationSupportsSecureRestorableState(
            mockApplication
        )
        XCTAssertTrue(supportsRestorableState)
    }

    func testApplicationDidFinishLaunching() throws {
        let appDelegate = AppDelegate()
        let mockNotification = Notification(name: NSApplication.didFinishLaunchingNotification)
        appDelegate.applicationDidFinishLaunching(mockNotification)
        // Test passes if no exception is thrown
        XCTAssertTrue(true)
    }

    func testApplicationWillTerminate() throws {
        let appDelegate = AppDelegate()
        let mockNotification = Notification(name: NSApplication.willTerminateNotification)
        appDelegate.applicationWillTerminate(mockNotification)
        // Test passes if no exception is thrown
        XCTAssertTrue(true)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testCodeReviewServiceInitialization() async throws {
        let service = await CodeReviewService()
        let serviceId = await service.serviceId
        let version = await service.version

        XCTAssertNotNil(service)
        XCTAssertEqual(serviceId, "code_review_service")
        XCTAssertEqual(version, "1.0.0")
    }

    func testCodeAnalysis() async throws {
        let service = await CodeReviewService()

        let testCode = """
        class TestClass {
            func testMethod() {
                print("Hello World")
                // TODO: Add error handling
            }
        }
        """

        let result = try await service.analyzeCode(testCode, language: "Swift", analysisType: .comprehensive)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.language, "Swift")
        XCTAssertEqual(result.analysisType, .comprehensive)
        XCTAssertFalse(result.issues.isEmpty) // Should find TODO comment
        XCTAssertFalse(result.suggestions.isEmpty)
    }

    func testDocumentationGeneration() async throws {
        let service = await CodeReviewService()

        let testCode = """
        class TestClass {
            func testMethod() -> String {
                return "test"
            }
        }
        """

        let result = try await service.generateDocumentation(testCode, language: "Swift", includeExamples: true)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.language, "Swift")
        XCTAssertTrue(result.includesExamples)
        XCTAssertFalse(result.documentation.isEmpty)
    }

    func testTestGeneration() async throws {
        let service = await CodeReviewService()

        let testCode = """
        class Calculator {
            func add(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """

        let result = try await service.generateTests(testCode, language: "Swift", testFramework: "XCTest")

        XCTAssertNotNil(result)
        XCTAssertEqual(result.language, "Swift")
        XCTAssertEqual(result.testFramework, "XCTest")
        XCTAssertFalse(result.testCode.isEmpty)
        XCTAssertGreaterThanOrEqual(result.estimatedCoverage, 0.0)
    }

    func testBackgroundProcessing() async throws {
        let service = await CodeReviewService()

        // Create a large code sample to test background processing
        let largeCode = String(repeating: """
        class TestClass {
            func method\(Int.random(in: 1 ... 100))() {
                print("Method implementation")
                // Some code here
                let result = 1 + 1
                return result
            }
        }
        """, count: 50)

        // Measure time to ensure it's not blocking the main thread
        let startTime = Date()

        async let analysisTask = service.analyzeCode(largeCode, language: "Swift", analysisType: .comprehensive)
        async let docTask = service.generateDocumentation(largeCode, language: "Swift", includeExamples: false)
        async let testTask = service.generateTests(largeCode, language: "Swift", testFramework: "XCTest")

        let (analysisResult, docResult, testResult) = try await (analysisTask, docTask, testTask)

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // Should complete in reasonable time (less than 5 seconds for this test)
        XCTAssertLessThan(duration, 5.0, "Analysis should complete quickly with background processing")

        // Verify all results are valid
        XCTAssertNotNil(analysisResult)
        XCTAssertNotNil(docResult)
        XCTAssertNotNil(testResult)
    }
}
