import SwiftUI

struct ImportExportSection: View {
    var body: some View {
        Section(header: Text("Import & Export")) {
            Button(action: {
                // Handle export
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Data")
                }
            }

            Button(action: {
                // Handle import navigation
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import Data")
                }
            }
        }
    }
}
