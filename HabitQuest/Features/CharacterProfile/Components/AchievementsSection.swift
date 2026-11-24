import HabitQuestCore

import SwiftUI

public struct AchievementsSection: View {
    public let achievements: [Achievement]
    public var onViewAll: () -> Void = {}
    public var onSelectAchievement: (Achievement) -> Void = { _ in }

    public init(
        achievements: [Achievement],
        onViewAll: @escaping () -> Void = {},
        onSelectAchievement: @escaping (Achievement) -> Void = { _ in }
    ) {
        self.achievements = achievements
        self.onViewAll = onViewAll
        self.onSelectAchievement = onSelectAchievement
    }

    public var previewAchievements: [Achievement] {
        Array(achievements.filter { !$0.isHidden || $0.isUnlocked }.prefix(6))
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if !achievements.isEmpty {
                    Button("View All") {
                        onViewAll()
                    }
                    .accessibilityLabel("View All")
                    .accessibilityIdentifier("ViewAllAchievementsButton")
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
                    ForEach(previewAchievements) { achievement in
                        AchievementBadge(achievement: achievement)
                            .onTapGesture {
                                onSelectAchievement(achievement)
                            }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

public struct AchievementBadge: View {
    public let achievement: Achievement

    public init(achievement: Achievement) {
        self.achievement = achievement
    }

    public var body: some View {
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
        .accessibilityIdentifier("AchievementBadge_\(achievement.name)")
        .accessibilityLabel("\(achievement.name), \(achievement.isUnlocked ? "Unlocked" : "Locked")")
    }
}
