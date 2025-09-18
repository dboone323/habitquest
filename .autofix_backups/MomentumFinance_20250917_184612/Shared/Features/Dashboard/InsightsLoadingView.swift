import SwiftUI

public struct InsightsLoadingView: View {
    @State private var isAnimating = false

    public var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: 0.8)
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(self.isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: self.isAnimating)
            }

            VStack(spacing: 8) {
                Text("Analyzing your finances...")
                    .font(.headline)

                Text("This may take a few moments")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            self.isAnimating = true
        }
    }
}
