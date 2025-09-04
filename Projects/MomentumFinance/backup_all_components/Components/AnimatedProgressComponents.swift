//
//  AnimatedProgressComponents.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

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
        if progress < 0.7 {
            .green
        } else if progress < 0.9 {
            .orange
        } else {
            .red
        }
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
                                        Color.white.opacity(0),
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 30, height: 12)
                            .offset(x: -30)
                            .animation(
                                Animation.linear(duration: 1.5).delay(1.0),
                                value: isVisible
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
                .animation(AnimationManager.Springs.gentle.delay(0.3), value: isVisible)
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
