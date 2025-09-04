import SwiftUI

struct FileSelectionComponent: View {
    @Binding var showingFilePicker: Bool
    let onSelectFile: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("Select a CSV file to import")
                .font(.headline)
                .foregroundColor(.secondary)

            Button(action: {
                showingFilePicker = true
                onSelectFile()
            }) {
                HStack {
                    Image(systemName: "folder")
                    Text("Choose File")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
