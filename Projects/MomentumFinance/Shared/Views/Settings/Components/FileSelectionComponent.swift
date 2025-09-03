import SwiftUI
import UniformTypeIdentifiers

struct FileSelectionComponent: View {
    @Binding var showingFilePicker: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingFilePicker = true
                onSelect()
            }) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)

                            Text("Select CSV File")
                                .font(.headline)
                                .foregroundColor(.blue)

                            Text("Tap to browse files")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        },
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    FileSelectionComponent(showingFilePicker: .constant(false), onSelect: {})
}
