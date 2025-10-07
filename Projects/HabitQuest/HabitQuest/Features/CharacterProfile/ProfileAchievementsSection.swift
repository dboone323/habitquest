import SwiftData
import SwiftUI

public struct AchievementsSection: View {
    let achievements: [Achievement]

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if self.achievements.count > 3 {
                    Button("View All") {
                        // Navigate to achievements view
                    }
                    .accessibilityLabel("Button")
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            if self.achievements.isEmpty {
                Text("No achievements yet. Keep building habits!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(self.achievements.prefix(6)) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(16)
    }
}

public struct AchievementBadge: View {
    let achievement: Achievement

    public var body: some View {
        VStack(spacing: 4) {
            Image(systemName: self.achievement.iconName)
                .font(.title2)
                .foregroundColor(self.achievement.isUnlocked ? .yellow : .gray)

            Text(self.achievement.name)
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(self.achievement.isUnlocked ? .primary : .secondary)
        }
        .padding(8)
        .background(self.achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
