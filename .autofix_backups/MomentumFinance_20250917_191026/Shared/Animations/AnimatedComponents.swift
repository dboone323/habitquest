// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftUI

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

enum AnimationComponents {
    /// Creates a staggered delay for list animations
    static func staggeredDelay(for index: Int, base: Double = 0.1) -> Double {
        Double(index) * base
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
    }
}
