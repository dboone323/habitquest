//
//  ProfileStatsSection.swift
//  HabitQuest
//
//  Created by Automated Code Generation
//  Component extracted from ProfileView.swift
//  Contains statistics display functionality
//

import SwiftUI

public struct StatsSection: View {
    let totalHabits: Int
    let activeStreaks: Int
    let completedToday: Int
    let longestStreak: Int
    let perfectDays: Int
    let weeklyCompletion: Double

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(title: "Total Habits", value: "\(self.totalHabits)", icon: "list.bullet")
                StatCard(title: "Active Streaks", value: "\(self.activeStreaks)", icon: "flame")
                StatCard(
                    title: "Completed Today", value: "\(self.completedToday)", icon: "checkmark.circle"
                )
                StatCard(title: "Longest Streak", value: "\(self.longestStreak)", icon: "star")
                StatCard(title: "Perfect Days", value: "\(self.perfectDays)", icon: "crown")
                StatCard(title: "Weekly Rate", value: "\(Int(self.weeklyCompletion))%", icon: "percent")
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(16)
    }
}

public struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    public init(title: String, value: String, icon: String, color: Color = .blue) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }

    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: self.icon)
                .font(.title2)
                .foregroundColor(color)

            Text(self.value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(self.title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(12)
    }
}
