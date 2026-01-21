//
// AchievementAnimations.swift
// HabitQuest
//
// Step 25: Lottie-style animations for achievements (using native SwiftUI).
//

import SwiftUI

/// Animated achievement celebration view.
struct AchievementCelebrationView: View {
    let achievementName: String
    let achievementIcon: String
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = -30

    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Confetti particles
            if showConfetti {
                ConfettiView()
            }

            // Achievement card
            VStack(spacing: 20) {
                // Icon with animation
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.yellow.opacity(0.5), .orange.opacity(0.3)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 10)

                    Image(systemName: achievementIcon)
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .orange.opacity(0.5), radius: 10)
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))

                Text("Achievement Unlocked!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(achievementName)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))

                // Sparkle ring
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.yellow, .orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 200, height: 200)
                    .opacity(showConfetti ? 0.5 : 0)
                    .scaleEffect(showConfetti ? 1.5 : 1)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground).opacity(0.95))
                    .shadow(radius: 20)
            )
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
                rotation = 0
            }

            withAnimation(.easeOut(duration: 0.3).delay(0.3)) {
                showConfetti = true
            }
        }
    }
}

/// Simple confetti particle view.
struct ConfettiView: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    var body: some View {
        GeometryReader { geo in
            ForEach(0 ..< 50, id: \.self) { i in
                ConfettiParticle(
                    color: colors[i % colors.count],
                    size: CGFloat.random(in: 5 ... 12),
                    startPosition: CGPoint(
                        x: CGFloat.random(in: 0 ... geo.size.width),
                        y: -20
                    ),
                    endPosition: CGPoint(
                        x: CGFloat.random(in: 0 ... geo.size.width),
                        y: geo.size.height + 20
                    ),
                    delay: Double(i) * 0.02
                )
            }
        }
        .allowsHitTesting(false)
    }
}

/// Individual confetti particle.
struct ConfettiParticle: View {
    let color: Color
    let size: CGFloat
    let startPosition: CGPoint
    let endPosition: CGPoint
    let delay: Double

    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size * 0.6)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                position = startPosition

                withAnimation(.linear(duration: 2).delay(delay)) {
                    position = endPosition
                    rotation = Double.random(in: 360 ... 720)
                    opacity = 0
                }
            }
    }
}

/// Streak milestone animation.
struct StreakMilestoneView: View {
    let streakCount: Int
    @State private var flameScale: CGFloat = 0.5
    @State private var numberScale: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Glow effect
                Image(systemName: "flame.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .blur(radius: 15)
                    .scaleEffect(flameScale * 1.2)

                // Main flame
                Image(systemName: "flame.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(flameScale)
            }

            Text("\(streakCount)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
                .scaleEffect(numberScale)

            Text("Day Streak!")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                flameScale = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                numberScale = 1.0
            }
        }
    }
}
