//
//  AnimatedButtonComponent.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

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
            case .primary:
                .accentColor
            case .secondary:
                .gray.opacity(0.2)
            case .destructive:
                .red
            case .ghost:
                .clear
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary:
                .white
            case .secondary:
                .primary
            case .destructive:
                .white
            case .ghost:
                .accentColor
            }
        }
    }

    init(
        action: @escaping () -> Void,
        style: ButtonStyle = .primary,
        @ViewBuilder content: () -> Content
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
                        .opacity(isPressed ? 0.8 : 1.0)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style == .ghost ? style.foregroundColor : .clear, lineWidth: 1)
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
            perform: {}
        )
    }

    private func handleAction() {
        #if os(iOS)
            HapticManager.shared.impact(.medium)
        #endif
        action()
    }
}
