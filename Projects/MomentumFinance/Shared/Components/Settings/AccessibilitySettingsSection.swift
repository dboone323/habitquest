import SwiftUI

struct AccessibilitySettingsSection: View {
    @Binding var hapticFeedbackEnabled: Bool
    @Binding var reducedMotion: Bool

    var body: some View {
        Section(header: Text("Accessibility")) {
            Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)

            Toggle("Reduce Motion", isOn: $reducedMotion)
        }
    }
}
