//
//  AccessibilitySettingsSection.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// Accessibility settings section for enhanced user experience
struct AccessibilitySettingsSection: View {
    @Binding var hapticFeedbackEnabled: Bool
    @Binding var reducedMotion: Bool
    @Binding var highContrastMode: Bool
    @Binding var animationsEnabled: Bool

    var body: some View {
        Section {
            Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                .accessibilityHint("Enables vibration feedback for interactions")
                .onChange(of: hapticFeedbackEnabled) { _, _ in
                    HapticManager.shared.isEnabled = hapticFeedbackEnabled
                    if hapticFeedbackEnabled {
                        HapticManager.shared.success()
                    }
                }

            Toggle("Reduce Motion", isOn: $reducedMotion)
                .accessibilityHint("Reduces animations throughout the app")
                .onChange(of: reducedMotion) { _, _ in
                    if hapticFeedbackEnabled {
                        #if os(iOS)
                            HapticManager.shared.impact(.light)
                        #endif
                    }
                }

            Toggle("High Contrast Mode", isOn: $highContrastMode)
                .accessibilityHint("Increases contrast for better visibility")
                .onChange(of: highContrastMode) { _, _ in
                    if hapticFeedbackEnabled {
                        #if os(iOS)
                            HapticManager.shared.impact(.light)
                        #endif
                    }
                }

            Toggle("Enhanced Animations", isOn: $animationsEnabled)
                .disabled(reducedMotion)
                .accessibilityHint("Enables smooth transitions and animations")
                .onChange(of: animationsEnabled) { _, _ in
                    if hapticFeedbackEnabled {
                        #if os(iOS)
                            HapticManager.shared.impact(.light)
                        #endif
                    }
                }
        } header: {
            Text("Accessibility")
        } footer: {
            Text("These settings help make the app more accessible and comfortable to use.")
        }
    }
}
