//
// OnboardingView.swift
// HabitQuest
//
// Onboarding flow for new users
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        TabView {
            OnboardingPage(
                title: "Welcome to HabitQuest",
                description: "Gamify your life and build better habits.",
                imageName: "star.fill",
                color: .blue
            )

            OnboardingPage(
                title: "Track Progress",
                description: "Keep streaks alive and earn XP.",
                imageName: "chart.bar.fill",
                color: .green
            )

            OnboardingPage(
                title: "Level Up",
                description: "Complete quests to unlock rewards.",
                imageName: "arrow.up.circle.fill",
                color: .purple
            )

            VStack {
                Text("Ready to begin?")
                    .font(.title)
                    .bold()

                Button("Start Quest") {
                    hasCompletedOnboarding = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        #if os(iOS)
        .tabViewStyle(.page)
        #endif
    }
}

struct OnboardingPage: View {
    let title: String
    let description: String
    let imageName: String
    let color: Color

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .font(.system(size: 80))
                .foregroundColor(color)

            Text(title)
                .font(.largeTitle)
                .bold()

            Text(description)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
