import SwiftUI

public struct CharacterAvatarSection: View {
    let level: Int
    let currentXP: Int
    let xpToNextLevel: Int
    let avatarImageName: String

    public init(level: Int, currentXP: Int, xpToNextLevel: Int, avatarImageName: String) {
        self.level = level
        self.currentXP = currentXP
        self.xpToNextLevel = xpToNextLevel
        self.avatarImageName = avatarImageName
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Avatar Circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: self.avatarImageName)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }

            // Level Badge
            Text("Level \(self.level)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            // XP Progress
            VStack(spacing: 4) {
                HStack {
                    Text("XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(self.currentXP) / \(self.xpToNextLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                ProgressView(value: Double(self.currentXP), total: Double(self.xpToNextLevel))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 1.5)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
