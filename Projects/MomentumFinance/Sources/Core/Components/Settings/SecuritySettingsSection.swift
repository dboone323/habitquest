import SwiftUI

public struct SecuritySettingsSection: View {
    @Binding var biometricEnabled: Bool
    @Binding var authenticationTimeout: Int

    var body: some View {
        Section(header: Text("Security")) {
            Toggle("Enable Biometric Authentication", isOn: self.$biometricEnabled)

            if self.biometricEnabled {
                Picker("Auto-lock after", selection: self.$authenticationTimeout) {
                    Text("1 minute").tag(1)
                    Text("5 minutes").tag(5)
                    Text("15 minutes").tag(15)
                    Text("1 hour").tag(60)
                    Text("Never").tag(0)
                }
            }
        }
    }
}
