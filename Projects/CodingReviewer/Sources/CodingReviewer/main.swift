import CodingReviewerLib
import SwiftUI

#if os(macOS)
    import AppKit
#endif

struct CodingReviewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

CodingReviewerApp.main()
