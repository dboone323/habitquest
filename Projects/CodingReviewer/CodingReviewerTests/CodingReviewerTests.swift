//
//  CodingReviewerTests.swift
//  CodingReviewerTests
//
//  Created by Daniel Stevens on 9/19/25.
//

import XCTest

@testable import CodingReviewer

class CodingReviewerTests: XCTestCase {

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
            mockApplication)
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
