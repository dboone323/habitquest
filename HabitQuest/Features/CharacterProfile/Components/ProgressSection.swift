import SwiftUI

public struct ProgressSection: View {
    let currentXP: Int
    let xpToNextLevel: Int
    let totalXP: Int

    public init(currentXP: Int, xpToNextLevel: Int, totalXP: Int) {
        self.currentXP = currentXP
        self.xpToNextLevel = xpToNextLevel
        self.totalXP = totalXP
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                HStack {
                    Text("Current Level XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(currentXP) / \(xpToNextLevel)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                ProgressView(value: Double(currentXP), total: Double(xpToNextLevel))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))

                HStack {
                    Text("Total XP Earned")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(totalXP)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        #if os(iOS)
            .background(Color(.systemGray6))
        #else
            .background(Color(nsColor: .windowBackgroundColor))
        #endif
            .cornerRadius(16)
    }
}
