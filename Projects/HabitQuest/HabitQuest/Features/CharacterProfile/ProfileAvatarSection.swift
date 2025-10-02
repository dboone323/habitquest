//
//  ProfileAvatarSection.swift
//  HabitQuest
//
//  Created by Automated Code Generation
//  Component extracted from ProfileView.swift
//  Contains character avatar and level display functionality
//

import SwiftUI

public struct CharacterAvatarSection: View {
    let level: Int
    let currentXP: Int
    let xpToNextLevel: Int
    let avatarImageName: String

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
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(16)
    }
}
