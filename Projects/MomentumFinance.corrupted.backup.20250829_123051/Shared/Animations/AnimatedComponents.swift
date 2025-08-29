// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftUI

<<<<<<< HEAD
// MARK: - Animated Card Component

/// An enhanced card view with smooth animations and interactions
struct AnimatedCard<Content: View>: View {
    let content: Content
    let shadowRadius: CGFloat
    let cornerRadius: CGFloat
    @State private var isPressed = false
    @State private var isVisible = false

    init(
        shadowRadius: CGFloat = 8,
        cornerRadius: CGFloat = 16,
        @ViewBuilder content: () -> Content,
        ) {
        self.shadowRadius = shadowRadius
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.regularMaterial)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: isPressed ? shadowRadius * 0.5 : shadowRadius,
                        x: 0,
                        y: isPressed ? 2 : 4,
                        ),
                )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .scaleEffect(isVisible ? 1.0 : 0.95)
            .opacity(isVisible ? 1.0 : 0)
            .animation(AnimationManager.Springs.snappy, value: isPressed)
            .animation(AnimationManager.Springs.gentle.delay(0.1), value: isVisible)
            .onAppear {
                isVisible = true
            }
            .onTapGesture {
                withAnimation(AnimationManager.Springs.snappy) {
                    isPressed = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(AnimationManager.Springs.snappy) {
                        isPressed = false
                    }
                }
            }
    }
}

// MARK: - Animated Button Component

/// An enhanced button with sophisticated animations and haptic feedback
struct AnimatedButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    let style: ButtonStyle
    @State private var isPressed = false
    @State private var isEnabled = true

    enum ButtonStyle {
        case primary, secondary, destructive, ghost

        var backgroundColor: Color {
            switch self {
            case .primary: .accentColor
            case .secondary: .gray.opacity(0.2)
            case .destructive: .red
            case .ghost: .clear
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary: .white
            case .secondary: .primary
            case .destructive: .white
            case .ghost: .accentColor
            }
        }
    }

    init(
        action: @escaping () -> Void,
        style: ButtonStyle = .primary,
        @ViewBuilder content: () -> Content,
        ) {
        self.action = action
        self.style = style
        self.content = content()
    }

    var body: some View {
        Button(action: handleAction) {
            content
                .foregroundColor(style.foregroundColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(style.backgroundColor)
                        .opacity(isPressed ? 0.8 : 1.0),
                    )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style == .ghost ? style.foregroundColor : .clear, lineWidth: 1),
                    )
                .scaleEffect(isPressed ? 0.96 : 1.0)
                .animation(AnimationManager.Springs.snappy, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(AnimationManager.Springs.snappy) {
                    isPressed = pressing
                }
            },
            perform: {},
            )
    }

    private func handleAction() {
        #if os(iOS)
        HapticManager.shared.impact(.medium)
        #endif
        action()
    }
}

// MARK: - Animated Transaction Item

/// Enhanced transaction list item with smooth animations
struct AnimatedTransactionItem: View {
    let transaction: FinancialTransaction
    let index: Int
    @State private var isVisible = false
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 16) {
            // Transaction type icon with animation
            ZStack {
                Circle()
                    .fill(transaction.transactionType == .income ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: transaction.transactionType == .income ? "arrow.down.left" : "arrow.up.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(transaction.transactionType == .income ? .green : .red)
                    .rotationEffect(.degrees(isVisible ? 0 : 180))
                    .animation(AnimationManager.Springs.bouncy.delay(Double(index) * 0.05), value: isVisible)
            }

            // Transaction details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                    .lineLimit(1)
                    .opacity(isVisible ? 1.0 : 0)
                    .offset(x: isVisible ? 0 : -20)
                    .animation(AnimationManager.Springs.gentle.delay(Double(index) * 0.1), value: isVisible)

                if let categoryName = transaction.category?.name {
                    Text(categoryName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(isVisible ? 1.0 : 0)
                        .offset(x: isVisible ? 0 : -15)
                        .animation(AnimationManager.Springs.gentle.delay(Double(index) * 0.15), value: isVisible)
                }

                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .opacity(isVisible ? 1.0 : 0)
                    .offset(x: isVisible ? 0 : -10)
                    .animation(AnimationManager.Springs.gentle.delay(Double(index) * 0.2), value: isVisible)
            }

            Spacer()

            // Amount with slide-in animation
            Text(transaction.amount.formatted(.currency(code: "USD")))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.transactionType == .income ? .green : .red)
                .opacity(isVisible ? 1.0 : 0)
                .offset(x: isVisible ? 0 : 30)
                .animation(AnimationManager.Springs.smooth.delay(Double(index) * 0.1), value: isVisible)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .opacity(isPressed ? 1.0 : 0)
                .animation(AnimationManager.Springs.snappy, value: isPressed),
            )
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0)
        .animation(AnimationManager.transactionEntry(index: index), value: isVisible)
        .onAppear {
            isVisible = true
        }
        .onTapGesture {
            withAnimation(AnimationManager.Springs.snappy) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(AnimationManager.Springs.snappy) {
                    isPressed = false
                }
            }

            #if os(iOS)
            HapticManager.shared.selection()
            #endif
        }
    }
}

// MARK: - Animated Budget Progress

/// Enhanced budget progress indicator with smooth animations
struct AnimatedBudgetProgress: View {
    let budget: Budget
    @State private var animatedProgress: Double = 0
    @State private var isVisible = false

    private var progress: Double {
        guard budget.limitAmount > 0 else { return 0 }
        return min(budget.spentAmount / budget.limitAmount, 1.0)
    }

    private var progressColor: Color {
        if progress < 0.7 { .green } else if progress < 0.9 { .orange } else { .red }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Budget header
            HStack {
                Text(budget.name)
                    .font(.headline)
                    .opacity(isVisible ? 1.0 : 0)
                    .offset(x: isVisible ? 0 : -20)
                    .animation(AnimationManager.Springs.gentle, value: isVisible)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(budget.spentAmount.formatted(.currency(code: "USD")))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(progressColor)
                        .opacity(isVisible ? 1.0 : 0)
                        .offset(x: isVisible ? 0 : 20)
                        .animation(AnimationManager.Springs.gentle.delay(0.1), value: isVisible)

                    Text("of \(budget.limitAmount.formatted(.currency(code: "USD")))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(isVisible ? 1.0 : 0)
                        .offset(x: isVisible ? 0 : 15)
                        .animation(AnimationManager.Springs.gentle.delay(0.15), value: isVisible)
                }
            }

            // Animated progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressColor.opacity(0.2))
                        .frame(height: 12)
                        .scaleEffect(x: isVisible ? 1.0 : 0, anchor: .leading)
                        .animation(AnimationManager.Springs.gentle.delay(0.2), value: isVisible)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * animatedProgress, height: 12)
                        .animation(AnimationManager.budgetProgress.delay(0.5), value: animatedProgress)

                    // Shine effect
                    if animatedProgress > 0 {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0),
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing,
                                    ),
                                )
                            .frame(width: 30, height: 12)
                            .offset(x: -30)
                            .animation(
                                Animation.linear(duration: 1.5).delay(1.0),
                                value: isVisible,
                                )
                    }
                }
            }
            .frame(height: 12)

            // Progress percentage
            HStack {
                Text("\(Int(progress * 100))% used")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(isVisible ? 1.0 : 0)
                    .offset(y: isVisible ? 0 : 10)
                    .animation(AnimationManager.Springs.gentle.delay(0.6), value: isVisible)

                Spacer()

                let remaining = budget.limitAmount - budget.spentAmount
                Text("\(remaining.formatted(.currency(code: "USD"))) remaining")
                    .font(.caption)
                    .foregroundColor(remaining > 0 ? .green : .red)
                    .fontWeight(.medium)
                    .opacity(isVisible ? 1.0 : 0)
                    .offset(y: isVisible ? 0 : 10)
                    .animation(AnimationManager.Springs.gentle.delay(0.65), value: isVisible)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .scaleEffect(isVisible ? 1.0 : 0.95)
                .opacity(isVisible ? 1.0 : 0)
                .animation(AnimationManager.Springs.gentle.delay(0.3), value: isVisible),
            )
        .onAppear {
            isVisible = true
            withAnimation(AnimationManager.budgetProgress.delay(0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(AnimationManager.budgetProgress) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Animated Number Counter

/// A number that animates when changing values
struct AnimatedCounter: View {
    let value: Double
    let formatter: NumberFormatter
    @State private var animatedValue: Double = 0

    init(value: Double, formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        return f
    }()) {
        self.value = value
        self.formatter = formatter
    }

    var body: some View {
        Text(formatter.string(from: NSNumber(value: animatedValue)) ?? "")
            .contentTransition(.numericText(countsDown: animatedValue > value))
            .animation(AnimationManager.Springs.smooth, value: animatedValue)
            .onAppear {
                animatedValue = value
            }
            .onChange(of: value) { _, newValue in
                withAnimation(AnimationManager.Springs.smooth) {
                    animatedValue = newValue
                }
            }
    }
}

// MARK: - Floating Action Button

/// A floating action button with sophisticated animations
struct FloatingActionButton: View {
    let action: () -> Void
    let icon: String
    @State private var isPressed = false
    @State private var isVisible = false

    var body: some View {
        Button(action: handleAction) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.accentColor)
                        .shadow(
                            color: Color.accentColor.opacity(0.3),
                            radius: isPressed ? 8 : 12,
                            x: 0,
                            y: isPressed ? 4 : 8,
                            ),
                    )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .scaleEffect(isVisible ? 1.0 : 0)
                .rotationEffect(.degrees(isVisible ? 0 : 180))
                .animation(AnimationManager.Springs.bouncy, value: isPressed)
                .animation(AnimationManager.Springs.gentle.delay(0.5), value: isVisible)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            isVisible = true
        }
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(AnimationManager.Springs.snappy) {
                    isPressed = pressing
                }
            },
            perform: {},
            )
    }

    private func handleAction() {
        #if os(iOS)
        HapticManager.shared.impact(.medium)
        #endif
        action()
=======
// MARK: - Animation Components Coordinator
// This file coordinates the various animation components used throughout the app.
// Each component is extracted into focused modules for better maintainability.

// MARK: - Component Re-exports
// Re-export all animation components for centralized access

/// Interactive card component with press animations
typealias AnimatedCard = AnimatedCardComponent.AnimatedCard

/// Sophisticated button with haptic feedback and style variants
typealias AnimatedButton = AnimatedButtonComponent.AnimatedButton

/// Staggered transaction list item animations
typealias AnimatedTransactionItem = AnimatedTransactionComponent.AnimatedTransactionItem

/// Progress indicators with shine effects and counters
typealias AnimatedBudgetProgress = AnimatedProgressComponents.AnimatedBudgetProgress
typealias AnimatedCounter = AnimatedProgressComponents.AnimatedCounter

/// Floating action button with sophisticated entrance animations
typealias FloatingActionButton = FloatingActionButtonComponent.FloatingActionButton

// MARK: - Animation Utilities
struct AnimationComponents {
    /// Creates a staggered delay for list animations
    static func staggeredDelay(for index: Int, base: Double = 0.1) -> Double {
        return Double(index) * base
    }
    
    /// Standard card animation configuration
    static func cardAnimation(pressed: Bool) -> Animation {
        pressed ? AnimationManager.Springs.snappy : AnimationManager.Springs.bouncy
    }
    
    /// Progress animation with delay
    static func progressAnimation(delay: Double = 0.3) -> Animation {
        AnimationManager.Springs.bouncy.delay(delay)
    }
    
    /// Entrance animation for floating elements
    static func floatingEntranceAnimation(delay: Double = 0.5) -> Animation {
        AnimationManager.Springs.gentle.delay(delay)
>>>>>>> 1cf3938 (Create working state for recovery)
    }
}
