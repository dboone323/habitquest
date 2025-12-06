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
                    Text("\(self.currentXP) / \(self.xpToNextLevel)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                ProgressView(value: Double(self.currentXP), total: Double(self.xpToNextLevel))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))

                HStack {
                    Text("Total XP Earned")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(self.totalXP)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
