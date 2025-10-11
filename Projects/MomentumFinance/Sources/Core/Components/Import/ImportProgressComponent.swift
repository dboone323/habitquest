import SwiftUI

public struct ImportProgressComponent: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: self.progress, total: 1.0)
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)

            Text("Importing data...")
                .font(.headline)

            Text("\(Int(self.progress * 100))% complete")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
