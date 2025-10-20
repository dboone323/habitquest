//
//  AccessibilityManager.swift
//  AvoidObstaclesGame
//
//  Manages accessibility features including VoiceOver, dynamic text sizing, and high contrast mode
//

import Foundation
import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Manages accessibility settings and features for the game
@MainActor
class AccessibilityManager {
    // MARK: - Properties

    /// Whether VoiceOver is currently running
    private(set) var isVoiceOverEnabled: Bool = false

    /// Whether the user prefers larger text
    private(set) var prefersDynamicType: Bool = false

    /// Whether the user prefers reduced motion
    private(set) var prefersReducedMotion: Bool = false

    /// Whether the user prefers high contrast colors
    private(set) var prefersHighContrast: Bool = false

    /// Current content size category (for dynamic type)
    private(set) var contentSizeCategory: String = "medium"

    /// Delegate for accessibility setting changes
    weak var delegate: AccessibilityManagerDelegate?

    // MARK: - Initialization

    init() {
        self.updateAccessibilitySettings()

        #if os(iOS) || os(tvOS)
            // Listen for accessibility changes on iOS/tvOS
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(accessibilitySettingsChanged),
                name: UIAccessibility.voiceOverStatusDidChangeNotification,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(accessibilitySettingsChanged),
                name: UIContentSizeCategory.didChangeNotification,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(accessibilitySettingsChanged),
                name: UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(accessibilitySettingsChanged),
                name: UIAccessibility.reduceMotionStatusDidChangeNotification,
                object: nil
            )
        #endif
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Settings Updates

    @objc private func accessibilitySettingsChanged() {
        let oldSettings = AccessibilitySettings(
            isVoiceOverEnabled: self.isVoiceOverEnabled,
            prefersDynamicType: self.prefersDynamicType,
            prefersReducedMotion: self.prefersReducedMotion,
            prefersHighContrast: self.prefersHighContrast,
            contentSizeCategory: self.contentSizeCategory
        )

        self.updateAccessibilitySettings()

        let newSettings = AccessibilitySettings(
            isVoiceOverEnabled: self.isVoiceOverEnabled,
            prefersDynamicType: self.prefersDynamicType,
            prefersReducedMotion: self.prefersReducedMotion,
            prefersHighContrast: self.prefersHighContrast,
            contentSizeCategory: self.contentSizeCategory
        )

        // Notify delegate if settings changed
        if oldSettings != newSettings {
            self.delegate?.accessibilitySettingsDidChange(from: oldSettings, to: newSettings)
        }
    }

    private func updateAccessibilitySettings() {
        #if os(iOS) || os(tvOS)
            self.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
            self.prefersReducedMotion = UIAccessibility.isReduceMotionEnabled
            self.prefersHighContrast = UIAccessibility.isDarkerSystemColorsEnabled

            let category = UIApplication.shared.preferredContentSizeCategory
            self.prefersDynamicType = category.isAccessibilityCategory
            self.contentSizeCategory = category.rawValue
        #else
            // For macOS and other platforms, use defaults or disable features
            self.isVoiceOverEnabled = false
            self.prefersDynamicType = false
            self.prefersReducedMotion = false
            self.prefersHighContrast = false
            self.contentSizeCategory = "medium"
        #endif
    }

    // MARK: - Dynamic Type Support

    /// Returns the appropriate font size based on accessibility settings
    /// - Parameters:
    ///   - baseSize: The standard font size
    ///   - style: The text style (headline, body, caption, etc.)
    /// - Returns: The adjusted font size
    func dynamicFontSize(baseSize: CGFloat, style: TextStyle = .body) -> CGFloat {
        guard self.prefersDynamicType else { return baseSize }

        let multiplier: CGFloat
        switch style {
        case .title:
            multiplier = 1.4
        case .headline:
            multiplier = 1.3
        case .subheadline:
            multiplier = 1.2
        case .body:
            multiplier = 1.1
        case .caption:
            multiplier = 1.0 // Captions stay smaller
        }

        return min(baseSize * multiplier, baseSize * 1.5) // Cap at 1.5x to prevent excessive sizing
    }

    /// Text style enumeration for dynamic sizing
    enum TextStyle {
        case title
        case headline
        case subheadline
        case body
        case caption
    }

    // MARK: - High Contrast Support

    /// Returns high contrast color if enabled, otherwise returns the standard color
    /// - Parameters:
    ///   - standardColor: The normal color
    ///   - highContrastColor: The high contrast alternative
    /// - Returns: The appropriate color based on settings
    func highContrastColor(standardColor: SKColor, highContrastColor: SKColor) -> SKColor {
        self.prefersHighContrast ? highContrastColor : standardColor
    }

    /// Returns high contrast colors for common UI elements
    func uiColors() -> UIColors {
        if self.prefersHighContrast {
            return UIColors(
                textColor: .white,
                backgroundColor: .black,
                accentColor: .yellow,
                secondaryTextColor: .gray,
                borderColor: .white
            )
        } else {
            return UIColors(
                textColor: .black,
                backgroundColor: .white,
                accentColor: .blue,
                secondaryTextColor: .darkGray,
                borderColor: .lightGray
            )
        }
    }

    // MARK: - VoiceOver Support

    /// Announces a message to VoiceOver
    /// - Parameter message: The message to announce
    func announce(_ message: String) {
        guard self.isVoiceOverEnabled else { return }

        #if os(iOS) || os(tvOS)
            UIAccessibility.post(notification: .announcement, argument: message)
        #endif
    }

    /// Announces a screen change to VoiceOver
    /// - Parameter screenName: The name of the new screen
    func announceScreenChange(_ screenName: String) {
        guard self.isVoiceOverEnabled else { return }

        #if os(iOS) || os(tvOS)
            UIAccessibility.post(notification: .screenChanged, argument: screenName)
        #endif
    }

    // MARK: - Reduced Motion Support

    /// Returns whether animations should be reduced
    var shouldReduceMotion: Bool {
        self.prefersReducedMotion
    }

    /// Returns an appropriate animation duration based on motion preferences
    /// - Parameter standardDuration: The normal animation duration
    /// - Returns: The adjusted duration
    func animationDuration(_ standardDuration: TimeInterval) -> TimeInterval {
        self.prefersReducedMotion ? 0.0 : standardDuration
    }
}

/// Delegate protocol for accessibility setting changes
protocol AccessibilityManagerDelegate: AnyObject {
    @MainActor func accessibilitySettingsDidChange(from oldSettings: AccessibilitySettings, to newSettings: AccessibilitySettings)
}

/// Struct representing accessibility settings for comparison
struct AccessibilitySettings: Equatable {
    let isVoiceOverEnabled: Bool
    let prefersDynamicType: Bool
    let prefersReducedMotion: Bool
    let prefersHighContrast: Bool
    let contentSizeCategory: String
}

/// Struct containing UI colors for high contrast support
struct UIColors {
    let textColor: SKColor
    let backgroundColor: SKColor
    let accentColor: SKColor
    let secondaryTextColor: SKColor
    let borderColor: SKColor
}
