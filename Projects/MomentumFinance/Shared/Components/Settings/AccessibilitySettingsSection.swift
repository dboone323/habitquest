import SwiftUI

public struct AccessibilitySettingsSection: View {
    @Binding var hapticFeedbackEnabled: Bool
    @Binding var reducedMotion: Bool

    var body: some View {
        Section(header: Text("Accessibility")) {
            Toggle("Haptic Feedback", isOn: self.$hapticFeedbackEnabled)

            Toggle("Reduce Motion", isOn: self.$reducedMotion)
        }
    }
}
