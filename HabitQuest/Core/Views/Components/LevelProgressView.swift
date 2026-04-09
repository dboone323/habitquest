import SwiftUI

struct LevelProgressView: View {
    let level: Int
    let xpProgress: Float

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Label("Level \(level)", systemImage: "crown.fill")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)

                Spacer()

                Text("\(Int(xpProgress * 100))%")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))

                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(geometry.size.width * CGFloat(xpProgress), geometry.size.width)))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: xpProgress)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Material.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
