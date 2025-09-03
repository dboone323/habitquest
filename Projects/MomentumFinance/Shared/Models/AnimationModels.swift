//
//  AnimationModels.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-01-27.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

// MARK: - Animated Card Component

/// Card component with animation support
public struct AnimatedCardComponent: @unchecked Sendable {
    public init() {}

    @MainActor
    public func card(
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        content()
            .transition(.scale.combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: true)
    }
}

// MARK: - Animated Button Component

/// Button component with animation support
public struct AnimatedButtonComponent: @unchecked Sendable {
    public init() {}

    @MainActor
    public func button(
        @ViewBuilder label: @escaping () -> some View,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            label()
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: true)
    }
}

// MARK: - Animated Transaction Component

/// Transaction component with animation support
public struct AnimatedTransactionComponent: @unchecked Sendable {
    public init() {}

    @MainActor
    public func transactionRow(
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        content()
            .transition(.slide.combined(with: .opacity))
            .animation(.easeInOut(duration: 0.4), value: true)
    }
}

// MARK: - Animated Progress Components

/// Progress components with animation support
public struct AnimatedProgressComponents: @unchecked Sendable {
    public init() {}

    @MainActor
    public func progressBar(progress: Double) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                    .cornerRadius(4)

                Rectangle()
                    .fill(LinearGradient(
                        colors: [.blue, .green],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: geometry.size.width * progress, height: 8)
                    .cornerRadius(4)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: 8)
    }

    @MainActor
    public func circularProgress(progress: Double) -> some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                LinearGradient(
                    colors: [.blue, .green],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 0.5), value: progress)
    }
}

// MARK: - Floating Action Button Component

/// Floating action button with animation support
public struct FloatingActionButtonComponent: @unchecked Sendable {
    public init() {}

    @MainActor
    public func floatingButton(
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: true)
    }
}
