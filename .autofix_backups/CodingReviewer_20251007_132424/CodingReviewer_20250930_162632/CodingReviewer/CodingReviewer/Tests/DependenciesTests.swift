//
// DependenciesTests.swift
// AI-generated test template
//

@testable import CodingReviewer
import XCTest

class DependenciesTests: XCTestCase {
    func testDefaultDependenciesUseSharedInstances() {
        let dependencies = Dependencies.default

        XCTAssertTrue(dependencies.performanceManager === PerformanceManager.shared)
        XCTAssertTrue(dependencies.logger === Logger.shared)
    }

    func testLoggerCustomOutputHandlerReceivesFormattedMessage() {
        let expectation = expectation(description: "Custom logger output")
        var captured: String?

        Logger.shared.setOutputHandler { message in
            captured = message
            expectation.fulfill()
        }

        Logger.shared.log("hello", level: .info)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(captured)
        XCTAssertTrue(captured?.contains("[INFO] hello") ?? false)

        Logger.shared.resetOutputHandler()
    }

    func testLoggerResetAllowsSubsequentHandlers() {
        Logger.shared.resetOutputHandler()

        let expectation = expectation(description: "Subsequent handler is used")
        Logger.shared.setOutputHandler { message in
            if message.contains("[ERROR]") {
                expectation.fulfill()
            }
        }

        Logger.shared.logSync("failure", level: .error)

        wait(for: [expectation], timeout: 1.0)
        Logger.shared.resetOutputHandler()
    }
}
