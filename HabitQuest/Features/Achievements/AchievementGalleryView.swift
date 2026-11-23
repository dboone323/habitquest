import HabitQuestCore
import SwiftUI

/// Comprehensive interactive gallery for viewing all achievements, categories, progress, and rewards
public struct AchievementGalleryView: View {
    public let achievements: [Achievement]
    @State private var selectedAchievement: Achievement?
    @State private var selectedCategory: AchievementCategory? = nil
    @Environment(\.dismiss) private var dismiss

    public init(achievements: [Achievement], selectedAchievement: Achievement? = nil) {
        self.achievements = achievements
        _selectedAchievement = State(initialValue: selectedAchievement)
    }

    public var visibleAchievements: [Achievement] {
        achievements.filter { !$0.isHidden || $0.isUnlocked }
    }

    private var filteredAchievements: [Achievement] {
        if let selectedCategory {
            return visibleAchievements.filter { $0.category == selectedCategory }
        }
        return visibleAchievements
    }

    private var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }

    private var totalEarnedXP: Int {
        achievements.filter(\.isUnlocked).reduce(0) { $0 + $1.xpReward }
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Header Card
                    summaryHeader

                    // Category Filter Chips
                    categoryFilterBar

                    // Achievement List
                    LazyVStack(spacing: 12) {
                        ForEach(filteredAchievements, id: \.id) { achievement in
                            AchievementGalleryCard(achievement: achievement) {
                                selectedAchievement = achievement
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Achievement Gallery")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                }
            }
            .sheet(item: $selectedAchievement) { achievement in
                AchievementDetailSheet(achievement: achievement)
            }
        }
    }

    // MARK: - Subviews

    private var summaryHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.headline)
                    Text("\(unlockedCount) of \(visibleAchievements.count) Unlocked")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(totalEarnedXP) XP")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    Text("Earned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            ProgressView(value: Double(unlockedCount), total: Double(max(1, visibleAchievements.count)))
                .tint(.yellow)
        }
        .padding()
        .background(Color.gray.opacity(0.12))
        .cornerRadius(16)
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue.capitalized,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Achievement Gallery Card

public struct AchievementGalleryCard: View {
    public let achievement: Achievement
    public let onTap: () -> Void

    public init(achievement: Achievement, onTap: @escaping () -> Void) {
        self.achievement = achievement
        self.onTap = onTap
    }

    private var formattedDate: String {
        if let date = achievement.unlockedDate {
            return "Unlocked \(date.formatted(date: .abbreviated, time: .omitted))"
        }
        return "Locked"
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon Badge
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.15))
                        .frame(width: 54, height: 54)

                    Image(systemName: achievement.iconName)
                        .font(.title2)
                        .foregroundColor(achievement.isUnlocked ? .yellow : .secondary)

                    if !achievement.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .offset(x: 16, y: 16)
                    }
                }

                // Details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(achievement.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("+\(achievement.xpReward) XP")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }

                    Text(achievement.achievementDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    Text(achievement.requirement.description)
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.8))

                    // Progress bar
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            ProgressView(value: Double(achievement.progress), total: 1.0)
                                .tint(achievement.isUnlocked ? .yellow : .blue)
                            Text("\(Int(achievement.progress * 100))%")
                                .font(.caption2.monospacedDigit())
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Image(systemName: achievement.isUnlocked ? "checkmark.seal.fill" : "lock")
                                .font(.caption2)
                                .foregroundColor(achievement.isUnlocked ? .green : .secondary)
                            Text(formattedDate)
                                .font(.caption2)
                                .foregroundColor(achievement.isUnlocked ? .green : .secondary)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.08))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(achievement.isUnlocked ? Color.yellow.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("AchievementCard_\(achievement.name)")
        .accessibilityLabel("\(achievement.name), \(achievement.isUnlocked ? "Unlocked" : "Locked")")
    }
}

// MARK: - Detail Sheet

public struct AchievementDetailSheet: View {
    public let achievement: Achievement
    @Environment(\.dismiss) private var dismiss

    public init(achievement: Achievement) {
        self.achievement = achievement
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon Display
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: achievement.iconName)
                        .font(.system(size: 44))
                        .foregroundColor(achievement.isUnlocked ? .yellow : .secondary)
                }
                .padding(.top, 20)

                VStack(spacing: 8) {
                    Text(achievement.name)
                        .font(.title2.bold())

                    Text(achievement.category.rawValue.capitalized)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(achievement.category.color.opacity(0.2))
                        .foregroundColor(achievement.category.color)
                        .cornerRadius(8)

                    Text(achievement.achievementDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Requirements & Progress
                VStack(alignment: .leading, spacing: 12) {
                    Text("Requirements")
                        .font(.headline)

                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.blue)
                        Text(achievement.requirement.description)
                            .font(.subheadline)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Progress")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(achievement.progress * 100))%")
                                .font(.caption.bold().monospacedDigit())
                        }

                        ProgressView(value: Double(achievement.progress), total: 1.0)
                            .tint(achievement.isUnlocked ? .yellow : .blue)
                    }

                    HStack {
                        Text("Reward")
                            .font(.subheadline)
                        Spacer()
                        Text("+\(achievement.xpReward) XP")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)

                    HStack {
                        Text("Status")
                            .font(.subheadline)
                        Spacer()
                        if achievement.isUnlocked, let date = achievement.unlockedDate {
                            Text("Unlocked \(date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline.bold())
                                .foregroundColor(.green)
                        } else {
                            Text("Locked")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Achievement Detail")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }
}
