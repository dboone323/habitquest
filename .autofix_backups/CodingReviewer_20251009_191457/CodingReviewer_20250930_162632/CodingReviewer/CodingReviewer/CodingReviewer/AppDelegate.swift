import Cocoa
import os

public class AppDelegate: NSObject, NSApplicationDelegate {
    private let logger = Logger(subsystem: "com.quantum.codingreviewer", category: "AppDelegate")

    public func applicationDidFinishLaunching(_: Notification) {
        self.logger.info("CodingReviewer application did finish launching")
        // Insert code here to initialize your application
    }

    public func applicationWillTerminate(_: Notification) {
        self.logger.info("CodingReviewer application will terminate")
        // Insert code here to tear down your application
    }

    public func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        true
    }
}
