import CodingReviewerLib
import SwiftUI

#if os(macOS)
    import AppKit
#endif

@main
struct CodingReviewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
