import SwiftUI

struct ImportProgressComponent: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 16) {
            ProgressView("Importing data...", value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())

            Text("\(Int(progress * 100))% complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ImportProgressComponent(progress: 0.5)
}
