import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

// Momentum Finance - Haptic Feedback Manager
// Copyright © 2025 Momentum Finance. All rights reserved.

#if os(iOS)
#endif
/// Centralized haptic feedback management for enhanced user experience
@MainActor
class HapticManager: ObservableObject {
    static let shared = HapticManager()

    @Published var isEnabled: Bool = true

    #if os(iOS)
        private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
        private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    #endif

    private init() {
        #if os(iOS)
            // Prepare generators for better responsiveness
            impactFeedbackGenerator.prepare()
            notificationFeedbackGenerator.prepare()
            selectionFeedbackGenerator.prepare()
        #endif
    }

    // MARK: - Impact Feedback

    /// Provides impact haptic feedback with varying intensity
    #if os(iOS)
    /// <#Description#>
    /// - Returns: <#description#>
        func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
            guard isEnabled else { return }

            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    #else
    /// <#Description#>
    /// - Returns: <#description#>
        func impact(_ style: Any) {
            // No haptic feedback on macOS
        }
    #endif

    /// Light impact feedback for subtle interactions
    /// <#Description#>
    /// - Returns: <#description#>
    func lightImpact() {
        #if os(iOS)
            impact(.light)
        #else
            impact(())
        #endif
    }

    /// Medium impact feedback for moderate interactions
    /// <#Description#>
    /// - Returns: <#description#>
    func mediumImpact() {
        #if os(iOS)
            impact(.medium)
        #else
            impact(())
        #endif
    }

    /// Heavy impact feedback for significant interactions
    /// <#Description#>
    /// - Returns: <#description#>
    func heavyImpact() {
        #if os(iOS)
            impact(.heavy)
        #else
            impact(())
        #endif
    }

    // MARK: - Notification Feedback

    /// Success notification feedback
    /// <#Description#>
    /// - Returns: <#description#>
    func success() {
        #if os(iOS)
            guard isEnabled else { return }
            notificationFeedbackGenerator.notificationOccurred(.success)
        #endif
    }

    /// Warning notification feedback
    /// <#Description#>
    /// - Returns: <#description#>
    func warning() {
        #if os(iOS)
            guard isEnabled else { return }
            notificationFeedbackGenerator.notificationOccurred(.warning)
        #endif
    }

    /// Error notification feedback
    /// <#Description#>
    /// - Returns: <#description#>
    func error() {
        #if os(iOS)
            guard isEnabled else { return }
            notificationFeedbackGenerator.notificationOccurred(.error)
        #endif
    }

    // MARK: - Selection Feedback

    /// Selection feedback for picker and segmented control interactions
    /// <#Description#>
    /// - Returns: <#description#>
    func selection() {
        #if os(iOS)
            guard isEnabled else { return }
            selectionFeedbackGenerator.selectionChanged()
        #endif
    }

    // MARK: - Context-Specific Feedback

    /// Feedback for transaction-related actions
    /// <#Description#>
    /// - Returns: <#description#>
    func transactionFeedback(for transactionType: TransactionType) {
        switch transactionType {
        case .income:
            success()
        case .expense:
            lightImpact()
        }
    }

    /// Feedback for budget-related actions
    /// <#Description#>
    /// - Returns: <#description#>
    func budgetFeedback(isOverBudget: Bool) {
        if isOverBudget {
            warning()
        } else {
            lightImpact()
        }
    }

    /// Feedback for goal achievement
    /// <#Description#>
    /// - Returns: <#description#>
    func goalAchievement() {
        // Celebratory pattern
        DispatchQueue.main.async {
            self.success()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lightImpact()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.lightImpact()
        }
    }

    /// Feedback for deletion actions
    /// <#Description#>
    /// - Returns: <#description#>
    func deletion() {
        heavyImpact()
    }

    /// Feedback for navigation actions
    /// <#Description#>
    /// - Returns: <#description#>
    func navigation() {
        lightImpact()
    }

    /// Feedback for data refresh
    /// <#Description#>
    /// - Returns: <#description#>
    func refresh() {
        mediumImpact()
    }

    /// Feedback for authentication success
    /// <#Description#>
    /// - Returns: <#description#>
    func authenticationSuccess() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lightImpact()
        }
    }

    /// Feedback for authentication failure
    /// <#Description#>
    /// - Returns: <#description#>
    func authenticationFailure() {
        error()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.lightImpact()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.lightImpact()
        }
    }
}

// MARK: - View Modifiers

struct HapticFeedbackModifier: ViewModifier {
    #if os(iOS)
        let style: UIImpactFeedbackGenerator.FeedbackStyle
    #endif
    let trigger: Bool

    #if os(iOS)
        init(style: UIImpactFeedbackGenerator.FeedbackStyle, trigger: Bool) {
            self.style = style
            self.trigger = trigger
        }
    #else
        init(trigger: Bool) {
            self.trigger = trigger
        }
    #endif

    /// <#Description#>
    /// - Returns: <#description#>
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, _ in
                #if os(iOS)
                    HapticManager.shared.impact(style)
                #endif
            }
    }
}

struct SelectionHapticModifier: ViewModifier {
    let trigger: Bool

    /// <#Description#>
    /// - Returns: <#description#>
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, _ in
                HapticManager.shared.selection()
            }
    }
}

struct SuccessHapticModifier: ViewModifier {
    let trigger: Bool

    /// <#Description#>
    /// - Returns: <#description#>
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, _ in
                HapticManager.shared.success()
            }
    }
}

extension View {
    /// Adds haptic feedback when the trigger value changes
    #if os(iOS)
    /// <#Description#>
    /// - Returns: <#description#>
        func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle, trigger: Bool) -> some View {
            modifier(HapticFeedbackModifier(style: style, trigger: trigger))
        }
    #else
    /// <#Description#>
    /// - Returns: <#description#>
        func hapticFeedback(_ style: Any, trigger: Bool) -> some View {
            modifier(HapticFeedbackModifier(trigger: trigger))
        }
    #endif

    /// Adds selection haptic feedback when the trigger value changes
    /// <#Description#>
    /// - Returns: <#description#>
    func selectionHaptic(trigger: Bool) -> some View {
        modifier(SelectionHapticModifier(trigger: trigger))
    }

    /// Adds success haptic feedback when the trigger value changes
    /// <#Description#>
    /// - Returns: <#description#>
    func successHaptic(trigger: Bool) -> some View {
        modifier(SuccessHapticModifier(trigger: trigger))
    }

    /// Adds tap haptic feedback to any view
    #if os(iOS)
    /// <#Description#>
    /// - Returns: <#description#>
        func hapticTap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
            onTapGesture {
                HapticManager.shared.impact(style)
            }
        }
    #else
    /// <#Description#>
    /// - Returns: <#description#>
        func hapticTap(_ style: Any = Any.self) -> some View {
            onTapGesture {
                // No haptic feedback on macOS
            }
        }
    #endif
}
