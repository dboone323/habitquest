import SwiftUI

struct AchievementsSection: View {
    let achievements: [Achievement]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if achievements.count > 3 {
                    Button("View All") {
                        // Navigate to achievements view
                    }
                    .accessibilityLabel("Button")
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            if achievements.isEmpty {
                Text("No achievements yet. Keep building habits!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(achievements.prefix(6)) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)

            Text(achievement.name)
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
        }
        .padding(8)
        .background(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
