//
//  AnimatedCardComponent.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

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
        @ViewBuilder content: () -> Content
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
                        y: isPressed ? 2 : 4
                    )
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
