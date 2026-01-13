//
// OnboardingView.swift
// HabitQuest
//
// Step 22: Onboarding flow for new users.
//

import SwiftUI

/// Onboarding page data.
struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

/// Multi-page onboarding view for new users.
struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track Your Habits",
            description: "Build positive habits by tracking your daily progress. Set goals and watch yourself improve over time.",
            imageName: "checkmark.circle.fill",
            color: .green
        ),
        OnboardingPage(
            title: "Build Streaks",
            description: "Stay consistent and build impressive streaks. The longer your streak, the more rewards you earn!",
            imageName: "flame.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "Level Up",
            description: "Complete habits to earn XP and level up your character. Unlock achievements and special rewards.",
            imageName: "star.fill",
            color: .yellow
        ),
        OnboardingPage(
            title: "Stay Motivated",
            description: "Get reminders, view statistics, and celebrate your progress. Your journey to self-improvement starts now!",
            imageName: "chart.line.uptrend.xyaxis",
            color: .blue
        )
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            Spacer()
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isOnboardingComplete = true
        }
    }
}

/// Individual onboarding page view.
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: page.imageName)
                .font(.system(size: 100))
                .foregroundColor(page.color)
                .shadow(color: page.color.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

/// Helper to check onboarding status.
struct OnboardingHelper {
    static var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    static func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
}
