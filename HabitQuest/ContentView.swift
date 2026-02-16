import SwiftData
import SwiftUI

#if os(iOS)
    import UIKit
#endif

//
//  ContentView.swift
//  HabitQuest - Enhanced Architecture
//
//  Created by Daniel Stevens on 6/27/25.
//  Enhanced: 9/12/25 - Improved architecture with better separation of concerns
//  Redesigned: 12/05/25 - Modern Card UI
//

public struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: ThemeManager

    /// Query Habits instead of Items
    @Query(sort: \Habit.creationDate, order: .reverse) private var habits: [Habit]

    // Gamification Queries
    @Query private var profiles: [PlayerProfile]
    @Query private var achievements: [Achievement]
    @Query(sort: \HabitLog.completionDate, order: .reverse) private var logs: [HabitLog]

    private var playerProfile: PlayerProfile? {
        profiles.first
    }

    @State private var showAddSheet = false

    // Alert State
    @State private var showLevelUpAlert = false
    @State private var newLevel = 0
    @State private var showAchievementAlert = false
    @State private var unlockedAchievementName = ""

    private let gamificationService = GamificationService()

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                themeManager.currentTheme.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom Header
                    if let profile = playerProfile {
                        HeaderView(profile: profile)
                    } else {
                        HeaderView(profile: PlayerProfile()) // Fallback
                    }

                    if habits.isEmpty {
                        HabitListEmptyStateView {
                            addItem() // For testing, adds a dummy habit
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(habits) { habit in
                                    HabitCardView(habit: habit) {
                                        toggleHabitCompletion(habit)
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteHabit(habit)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.top)
                        }
                    }
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .overlay(alignment: .bottomTrailing) {
                // Floating Action Button
                Button(
                    action: {
                        addItem() // Will open sheet later
                    },
                    label: {
                        Image(systemName: "plus")
                            .font(.title.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4, y: 3)
                    }
                )
                .padding()
            }
        }
        .onAppear {
            initializeGamification()
        }
        .alert("Level Up!", isPresented: $showLevelUpAlert) {
            Button("Awesome!", role: .cancel) {}
        } message: {
            Text("Congratulations! You've reached Level \(newLevel). Keep up the great work!")
        }
        .alert("Achievement Unlocked!", isPresented: $showAchievementAlert) {
            Button("Nice!", role: .cancel) {}
        } message: {
            Text("You've unlocked: '\(unlockedAchievementName)'")
        }
    }

    private func initializeGamification() {
        if profiles.isEmpty {
            modelContext.insert(PlayerProfile())
        }

        if achievements.isEmpty {
            let defaults = AchievementService.createDefaultAchievements()
            for achievement in defaults {
                modelContext.insert(achievement)
            }
        }
    }

    // MARK: - Business Logic

    private func addItem() {
        withAnimation {
            let newHabit = Habit(
                name: "New Quest \(Int.random(in: 1...100))",
                habitDescription: "Daily task",
                frequency: .daily,
                category: HabitCategory.allCases.randomElement() ?? .health
            )
            modelContext.insert(newHabit)
            triggerHapticFeedback()
        }
    }

    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            modelContext.delete(habit)
        }
    }

    private func toggleHabitCompletion(_ habit: Habit) {
        // Check if completed today
        let today = Date()
        let calendar = Calendar.current

        if let existingLog = habit.logs.first(where: {
            calendar.isDate($0.completionDate, inSameDayAs: today)
        }) {
            // Already completed, toggle off (delete log)
            modelContext.delete(existingLog)
            if habit.streak > 0 { habit.streak -= 1 }
        } else {
            // Not completed, create log
            let log = HabitLog(habit: habit, completionDate: today, isCompleted: true)
            habit.logs.append(log)
            modelContext.insert(log)
            habit.streak += 1

            // Gamification Logic
            if let profile = playerProfile {
                let result = gamificationService.processHabitCompletion(
                    habit: habit, profile: profile
                )
                if result.leveledUp {
                    newLevel = result.newLevel
                    showLevelUpAlert = true
                }

                // Update Achievements
                let unlocked = AchievementService.updateAchievementProgress(
                    achievements: achievements,
                    player: profile,
                    habits: habits,
                    recentLogs: logs
                )

                if let first = unlocked.first {
                    unlockedAchievementName = first.name
                    showAchievementAlert = true
                }
            }
        }

        triggerHapticFeedback()
    }

    private func triggerHapticFeedback() {
        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        #endif
    }
}

// MARK: - Extensions

extension HabitCategory {
    var viewColor: Color {
        switch self {
        case .health: .red
        case .fitness: .orange
        case .learning: .blue
        case .productivity: .green
        case .social: .purple
        case .creativity: .yellow
        case .mindfulness: .indigo
        case .other: .gray
        }
    }
}

// MARK: - Subviews

struct HabitListEmptyStateView: View {
    var onAdd: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checklist")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            Text("No Active Quests")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            Text("Start your journey by adding a new habit quest.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Create First Quest", action: onAdd)
                .buttonStyle(.borderedProminent)
            Spacer()
        }
    }
}

struct HabitCardView: View {
    @Bindable var habit: Habit
    var onToggle: () -> Void

    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(habit.category.viewColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                Text(habit.category.emoji)
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .strikethrough(habit.isCompletedToday, color: .secondary)

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("\(habit.streak) day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isAnimating = true
                        onToggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isAnimating = false
                    }
                },
                label: {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                            .frame(width: 44, height: 44)
                        if habit.isCompletedToday {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.green)
                                .transition(.scale)
                        }
                    }
                }
            )
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
            #if os(iOS)
                .fill(Color(.secondarySystemBackground))
            #else
                .fill(Color(nsColor: .controlBackgroundColor))
            #endif
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

struct HeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let profile: PlayerProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text("HabitQuest")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    Text("Your Journey Awaits")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }
                Spacer()
            }
            .padding()
            LevelProgressView(level: profile.level, xpProgress: profile.xpProgress)
                .padding(.horizontal)
                .padding(.bottom, 8)
            Divider()
        }
        .background(themeManager.currentTheme.backgroundColor)
    }
}

struct HabitWidgetView: View {
    let habits: [Habit]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Quests")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)

            if habits.isEmpty {
                Text("No quests active")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                ForEach(habits.prefix(4)) { habit in
                    HStack {
                        Circle()
                            .fill(habit.category.viewColor.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text(habit.name)
                            .font(.caption2)
                            .lineLimit(1)
                        Spacer()
                        if habit.isCompletedToday {
                            Image(systemName: "checkmark")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        #if os(iOS)
            .background(Color(UIColor.systemBackground))
        #else
            .background(Color(nsColor: .windowBackgroundColor))
        #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
        .environmentObject(ThemeManager())
}

#Preview("Widget") {
    HabitWidgetView(habits: [
        Habit(name: "Read", habitDescription: "", frequency: .daily, category: .learning),
        Habit(name: "Run", habitDescription: "", frequency: .daily, category: .fitness),
    ])
    .frame(width: 170, height: 170)
    .cornerRadius(20)
}
