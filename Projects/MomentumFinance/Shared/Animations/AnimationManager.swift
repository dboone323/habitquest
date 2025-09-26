// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftUI

/// Centralized animation management for consistent app-wide animations
@MainActor
final class AnimationManager: ObservableObject {
    static let shared = AnimationManager()

    private init() {}

    // MARK: - Animation Configuration

    /// Standard animation durations
    enum Duration {
        static let ultraFast: Double = 0.1
        static let fast: Double = 0.2
        static let standard: Double = 0.3
        static let medium: Double = 0.5
        static let slow: Double = 0.8
        static let loading: Double = 1.5
    }

    /// Standard spring animations
    enum Springs {
        static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
        static let bouncy = Animation.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)
        static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0)
        static let smooth = Animation.spring(response: 0.4, dampingFraction: 1.0, blendDuration: 0)
    }

    /// Standard easing animations
    enum Easing {
        static let easeIn = Animation.easeIn(duration: Duration.standard)
        static let easeOut = Animation.easeOut(duration: Duration.standard)
        static let easeInOut = Animation.easeInOut(duration: Duration.standard)
        static let linear = Animation.linear(duration: Duration.standard)
    }

    // MARK: - Context-Specific Animations

    /// Card appearance animations
    static func cardEntry(delay: Double = 0) -> Animation {
        Springs.gentle.delay(delay)
    }

    /// Transaction list item animations
    static func transactionEntry(index: Int) -> Animation {
        Springs.snappy.delay(Double(index) * 0.05)
    }

    /// Button press animations
    static var buttonPress: Animation {
        Springs.snappy
    }

    /// Loading state animations
    static var loading: Animation {
        Animation.easeInOut(duration: Duration.loading).repeatForever(autoreverses: true)
    }

    /// Page transition animations
    static var pageTransition: Animation {
        Springs.smooth
    }

    /// Success feedback animation
    static var success: Animation {
        Springs.bouncy
    }

    /// Error feedback animation
    static var error: Animation {
        Animation.easeInOut(duration: Duration.fast).repeatCount(3, autoreverses: true)
    }

    /// Budget progress animation
    static var budgetProgress: Animation {
        Animation.easeInOut(duration: Duration.medium)
    }

    /// Goal achievement animation
    static var goalAchievement: Animation {
        Springs.bouncy.repeatCount(2, autoreverses: false)
    }

    /// Account balance update animation
    static var balanceUpdate: Animation {
        Springs.gentle
    }

    /// Search result animation
    static var searchResults: Animation {
        Springs.snappy
    }
}

// MARK: - Animation View Modifiers

extension View {
    /// Applies entrance animation for cards
    /// <#Description#>
    /// - Returns: <#description#>
    func cardEntrance(delay: Double = 0) -> some View {
        scaleEffect(0.95)
            .opacity(0)
            .onAppear {
                withAnimation(AnimationManager.cardEntry(delay: delay)) {
                    // Animation will be handled by the view state
                }
            }
    }

    /// Applies button press animation
    /// <#Description#>
    /// - Returns: <#description#>
    func buttonPressAnimation() -> some View {
        scaleEffect(1.0)
            .animation(AnimationManager.buttonPress, value: false)
    }

    /// Applies loading state animation
    /// <#Description#>
    /// - Returns: <#description#>
    func loadingAnimation() -> some View {
        opacity(0.6)
            .animation(AnimationManager.loading, value: true)
    }

    /// Applies success feedback animation
    /// <#Description#>
    /// - Returns: <#description#>
    func successFeedback() -> some View {
        scaleEffect(1.0)
            .animation(AnimationManager.success, value: false)
    }

    /// Applies error feedback animation
    /// <#Description#>
    /// - Returns: <#description#>
    func errorFeedback() -> some View {
        animation(AnimationManager.error, value: false)
    }

    /// Applies bounce animation for interactive elements
    /// <#Description#>
    /// - Returns: <#description#>
    func bounceAnimation(trigger: Bool) -> some View {
        scaleEffect(trigger ? 1.1 : 1.0)
            .animation(AnimationManager.Springs.bouncy, value: trigger)
    }

    /// Applies slide-in animation from specified edge
    /// <#Description#>
    /// - Returns: <#description#>
    func slideIn(from edge: Edge, delay: Double = 0) -> some View {
        transition(.asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal: .move(edge: edge.opposite).combined(with: .opacity),
        ))
        .animation(AnimationManager.Springs.smooth.delay(delay), value: true)
    }

    /// Applies fade-in animation
    /// <#Description#>
    /// - Returns: <#description#>
    func fadeIn(delay: Double = 0) -> some View {
        opacity(0)
            .onAppear {
                withAnimation(AnimationManager.Easing.easeIn.delay(delay)) {
                    // Animation will be handled by the view state
                }
            }
    }

    /// Applies shimmer loading effect
    /// <#Description#>
    /// - Returns: <#description#>
    func shimmerLoading() -> some View {
        overlay(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.4),
                            Color.clear,
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing,
                    ),
                )
                .offset(x: -100)
                .animation(
                    Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: true,
                ),
        )
        .clipped()
    }
}

// MARK: - Edge Extension

extension Edge {
    var opposite: Edge {
        switch self {
        case .top: .bottom
        case .bottom: .top
        case .leading: .trailing
        case .trailing: .leading
        }
    }
}

// MARK: - Custom Transition Styles

extension AnyTransition {
    /// Smooth scale and fade transition
    static var scaleAndFade: AnyTransition {
        .asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity),
        )
    }

    /// Slide and fade from bottom
    static var slideAndFadeFromBottom: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity),
        )
    }

    /// Card flip transition
    static var cardFlip: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: CardFlipModifier(rotation: 90),
                identity: CardFlipModifier(rotation: 0),
            ),
            removal: .modifier(
                active: CardFlipModifier(rotation: -90),
                identity: CardFlipModifier(rotation: 0),
            ),
        )
    }

    /// Push transition for navigation
    static var push: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading),
        )
    }
}

// MARK: - Custom View Modifier for Card Flip

public struct CardFlipModifier: ViewModifier {
    let rotation: Double

    /// <#Description#>
    /// - Returns: <#description#>
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(self.rotation),
                axis: (x: 0, y: 1, z: 0),
            )
    }
}

// MARK: - Animated Components

/// A loading indicator with customizable animation
public struct LoadingIndicator: View {
    @State private var isAnimating = false
    let style: Style

    enum Style {
        case dots, spinner, pulse
    }

    var body: some View {
        Group {
            switch self.style {
            case .dots:
                HStack(spacing: 4) {
                    ForEach(0 ..< 3, id: \.self) { index in
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 8, height: 8)
                            .scaleEffect(self.isAnimating ? 1.2 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: self.isAnimating,
                            )
                    }
                }

            case .spinner:
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.accentColor, lineWidth: 3)
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(self.isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1).repeatForever(autoreverses: false),
                        value: self.isAnimating,
                    )

            case .pulse:
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 20, height: 20)
                    .scaleEffect(self.isAnimating ? 1.2 : 0.8)
                    .opacity(self.isAnimating ? 0.5 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1).repeatForever(autoreverses: true),
                        value: self.isAnimating,
                    )
            }
        }
        .onAppear {
            self.isAnimating = true
        }
        .onDisappear {
            self.isAnimating = false
        }
    }
}

/// An animated progress bar
public struct AnimatedProgressBar: View {
    let progress: Double
    let color: Color
    let height: CGFloat
    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(self.color.opacity(0.2))
                    .frame(height: self.height)

                Rectangle()
                    .fill(self.color)
                    .frame(width: geometry.size.width * self.animatedProgress, height: self.height)
                    .animation(AnimationManager.Springs.gentle, value: self.animatedProgress)
            }
        }
        .frame(height: self.height)
        .clipShape(RoundedRectangle(cornerRadius: self.height / 2))
        .onAppear {
            withAnimation(AnimationManager.budgetProgress.delay(0.3)) {
                self.animatedProgress = min(max(self.progress, 0), 1)
            }
        }
        .onChange(of: self.progress) { _, newValue in
            withAnimation(AnimationManager.budgetProgress) {
                self.animatedProgress = min(max(newValue, 0), 1)
            }
        }
    }
}

// MARK: - Object Pooling

/// Object pool for performance optimization
private var objectPool: [Any] = []
private let maxPoolSize = 50

/// Get an object from the pool or create new one
private func getPooledObject<T>() -> T? {
    if let pooled = objectPool.popLast() as? T {
        return pooled
    }
    return nil
}

/// Return an object to the pool
private func returnToPool(_ object: Any) {
    if objectPool.count < maxPoolSize {
        objectPool.append(object)
    }
}
