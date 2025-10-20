//
// HapticManager.swift
// AvoidObstaclesGame
//
// Manages haptic feedback for game events and UI interactions.
//

import Foundation
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Manages haptic feedback across the game
@MainActor
public class HapticManager {
    // MARK: - Properties

    /// Shared singleton instance
    public static let shared = HapticManager()

    /// Whether haptic feedback is enabled
    private var isHapticEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "hapticEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "hapticEnabled") }
    }

    /// Haptic intensity level (0.0 to 1.0)
    private var hapticIntensity: Float {
        get { UserDefaults.standard.float(forKey: "hapticIntensity") }
        set { UserDefaults.standard.set(newValue, forKey: "hapticIntensity") }
    }

    // MARK: - Initialization

    private init() {
        // Set default values if not already set
        if UserDefaults.standard.object(forKey: "hapticEnabled") == nil {
            isHapticEnabled = true
        }
        if UserDefaults.standard.object(forKey: "hapticIntensity") == nil {
            hapticIntensity = 1.0
        }
    }

    // MARK: - Public Methods

    /// Enables or disables haptic feedback
    /// - Parameter enabled: Whether haptic feedback should be enabled
    public func setHapticEnabled(_ enabled: Bool) {
        isHapticEnabled = enabled
    }

    /// Sets the haptic intensity level
    /// - Parameter intensity: Intensity level from 0.0 to 1.0
    public func setHapticIntensity(_ intensity: Float) {
        hapticIntensity = max(0.0, min(1.0, intensity))
    }

    /// Gets the current haptic enabled state
    /// - Returns: Whether haptic feedback is enabled
    public func getHapticEnabled() -> Bool {
        isHapticEnabled
    }

    /// Gets the current haptic intensity
    /// - Returns: Current intensity level
    public func getHapticIntensity() -> Float {
        hapticIntensity
    }

    // MARK: - Game Event Haptics

    /// Plays haptic feedback for player collision
    public func playCollisionHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred(intensity: CGFloat(hapticIntensity))
        #endif
    }

    /// Plays haptic feedback for power-up collection
    public func playPowerUpHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred(intensity: CGFloat(hapticIntensity))
        #endif
    }

    /// Plays haptic feedback for score increase
    public func playScoreIncreaseHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: CGFloat(hapticIntensity * 0.7))
        #endif
    }

    /// Plays haptic feedback for level up/difficulty increase
    public func playLevelUpHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        #endif
    }

    /// Plays haptic feedback for game over
    public func playGameOverHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        #endif
    }

    /// Plays haptic feedback for achievement unlock
    public func playAchievementHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        #endif
    }

    /// Plays haptic feedback for boss battle start
    public func playBossBattleStartHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            // Create a sequence of heavy impacts for dramatic effect
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred(intensity: CGFloat(hapticIntensity))

            // Add a second impact after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                generator.impactOccurred(intensity: CGFloat(self.hapticIntensity * 0.8))
            }
        #endif
    }

    /// Plays haptic feedback for boss attack
    public func playBossAttackHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred(intensity: CGFloat(hapticIntensity * 0.9))
        #endif
    }

    /// Plays haptic feedback for boss defeat
    public func playBossDefeatHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // Add celebration impacts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let impactGen = UIImpactFeedbackGenerator(style: .medium)
                impactGen.impactOccurred(intensity: CGFloat(self.hapticIntensity))
            }
        #endif
    }

    /// Plays a victory haptic pattern
    public func playVictoryPattern() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            // Create a victory celebration pattern
            let pattern: [(delay: TimeInterval, intensity: CGFloat)] = [
                (0.0, 0.9),
                (0.15, 1.0),
                (0.3, 0.95),
                (0.45, 1.0),
                (0.6, 0.9),
                (0.75, 1.0),
            ]
            playCustomPattern(pattern, style: .heavy)
        #endif
    }

    // MARK: - UI Interaction Haptics

    /// Plays haptic feedback for button tap
    public func playButtonTapHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: CGFloat(hapticIntensity * 0.5))
        #endif
    }

    /// Plays haptic feedback for selection change
    public func playSelectionChangeHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        #endif
    }

    /// Plays haptic feedback for menu navigation
    public func playMenuNavigationHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: CGFloat(hapticIntensity * 0.3))
        #endif
    }

    // MARK: - Environmental Haptics

    /// Plays haptic feedback for environmental hazards
    public func playHazardHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred(intensity: CGFloat(hapticIntensity * 0.6))
        #endif
    }

    /// Plays haptic feedback for weather effects
    public func playWeatherHaptic() {
        guard isHapticEnabled else { return }
        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred(intensity: CGFloat(hapticIntensity * 0.4))
        #endif
    }

    // MARK: - Custom Haptics

    /// Plays a custom haptic pattern
    /// - Parameters:
    ///   - pattern: Array of delays and intensities
    ///   - style: The impact style to use
    #if os(iOS) || os(tvOS)
        public func playCustomPattern(_ pattern: [(delay: TimeInterval, intensity: CGFloat)], style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
            guard isHapticEnabled else { return }
            for (index, item) in pattern.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + item.delay) {
                    let generator = UIImpactFeedbackGenerator(style: style)
                    generator.impactOccurred(intensity: item.intensity * CGFloat(self.hapticIntensity))
                }
            }
        }
    #else
        public func playCustomPattern(_ pattern: [(delay: TimeInterval, intensity: CGFloat)], style: Any = ()) {
            // No-op on platforms without haptic support
        }
    #endif

    /// Plays a celebration haptic pattern
    public func playCelebrationHaptic() {
        guard isHapticEnabled else { return }
        let pattern: [(delay: TimeInterval, intensity: CGFloat)] = [
            (0.0, 0.8),
            (0.1, 1.0),
            (0.2, 0.9),
            (0.3, 1.0),
            (0.4, 0.8),
        ]
        #if os(iOS) || os(tvOS)
            playCustomPattern(pattern, style: .medium)
        #else
            playCustomPattern(pattern)
        #endif
    }

    /// Plays a warning haptic pattern
    public func playWarningHaptic() {
        guard isHapticEnabled else { return }
        let pattern: [(delay: TimeInterval, intensity: CGFloat)] = [
            (0.0, 0.6),
            (0.15, 0.8),
            (0.3, 0.6),
        ]
        #if os(iOS) || os(tvOS)
            playCustomPattern(pattern, style: .heavy)
        #else
            playCustomPattern(pattern)
        #endif
    }
}
