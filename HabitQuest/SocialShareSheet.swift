import SwiftUI

#if canImport(UIKit)
    import UIKit

    /// Enhancement #83: Social Sharing
    struct SocialShareSheet: UIViewControllerRepresentable {
        var items: [Any]

        func makeUIViewController(context _: Context) -> UIActivityViewController {
            UIActivityViewController(activityItems: items, applicationActivities: nil)
        }

        func updateUIViewController(_: UIActivityViewController, context _: Context) {
            // No update needed
        }
    }
#else
    /// Fallback for macOS (AppKit) or other platforms
    struct SocialShareSheet: View {
        var items: [Any]
        var body: some View {
            Text("Sharing not supported on this platform")
                .padding()
        }
    }
#endif

/// Usage Example View
struct ShareProgressView: View {
    @State private var showShareSheet = false

    var body: some View {
        Button("Share Progress") {
            showShareSheet = true
        }
        .sheet(isPresented: $showShareSheet) {
            SocialShareSheet(items: ["I just completed my habit streak on HabitQuest! 🚀"])
        }
    }
}
