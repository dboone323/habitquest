//
//  AnimationTypes.swift
//  MomentumFinance - Animation component types
//
//  Created for build compatibility
//

import SwiftUI

// MARK: - Animation Component Types

public enum AnimatedCardComponent {
    public struct AnimatedCard: View {
        let content: AnyView

        public init(content: AnyView) {
            self.content = content
        }

        public var body: some View {
            self.content
                .transition(.scale.combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: UUID())
        }
    }
}

public enum AnimatedButtonComponent {
    public struct AnimatedButton: View {
        let title: String
        let action: () -> Void

        public init(title: String, action: @escaping () -> Void) {
            self.title = title
            self.action = action
        }

        public var body: some View {
            Button(self.title, action: self.action).accessibilityLabel("Button").accessibilityLabel("Button")
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.2), value: UUID())
        }
    }
}

public enum AnimatedTransactionComponent {
    public struct AnimatedTransactionItem: View {
        let title: String

        public init(title: String) {
            self.title = title
        }

        public var body: some View {
            Text(self.title)
                .transition(.slide)
                .animation(.easeInOut(duration: 0.3), value: UUID())
        }
    }
}

public enum AnimatedProgressComponents {
    public struct AnimatedBudgetProgress: View {
        let progress: Double

        public init(progress: Double) {
            self.progress = progress
        }

        public var body: some View {
            ProgressView(value: self.progress)
                .animation(.easeInOut(duration: 0.5), value: self.progress)
        }
    }

    public struct AnimatedCounter: View {
        let count: Int

        public init(count: Int) {
            self.count = count
        }

        public var body: some View {
            Text("\(self.count)")
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: self.count)
        }
    }
}

public enum FloatingActionButtonComponent {
    public struct FloatingActionButton: View {
        let action: () -> Void

        public init(action: @escaping () -> Void) {
            self.action = action
        }

        public var body: some View {
            Button(action: self.action).accessibilityLabel("Button").accessibilityLabel("Button") {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .frame(width: 56, height: 56)
            .background(Color.accentColor)
            .clipShape(Circle())
            .shadow(radius: 4)
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: UUID())
        }
    }
}
