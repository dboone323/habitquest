//
//  FloatingActionButtonComponent.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

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
                            y: isPressed ? 4 : 8
                        )
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
