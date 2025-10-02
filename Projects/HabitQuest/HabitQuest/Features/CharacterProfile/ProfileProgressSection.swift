//
//  ProfileProgressSection.swift
//  HabitQuest
//
//  Created by Automated Code Generation
//  Component extracted from ProfileView.swift
//  Contains XP progress display functionality
//

import SwiftUI

public struct ProgressSection: View {
    let currentXP: Int
    let xpToNextLevel: Int
    let totalXP: Int

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
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(16)
    }
}
