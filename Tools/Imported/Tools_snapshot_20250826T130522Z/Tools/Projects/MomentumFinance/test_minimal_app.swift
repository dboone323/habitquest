import SwiftData
import SwiftUI

// Minimal test app to debug crash
@main
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Minimal Test App")
                .padding()
                .onAppear {
                    print("App launched successfully")
                }
        }
    }
}
