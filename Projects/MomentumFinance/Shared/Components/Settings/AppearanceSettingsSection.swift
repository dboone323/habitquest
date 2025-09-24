import SwiftUI

public struct AppearanceSettingsSection: View {
    var darkModePreference: DarkModePreference

    var body: some View {
        Section(header: Text("Appearance")) {
            Picker("Theme", selection: .constant(self.darkModePreference)) {
                ForEach(DarkModePreference.allCases, id: \.self) { preference in
                    Text(preference.displayName).tag(preference)
                }
            }
            .pickerStyle(.menu)
            .disabled(true) // For now, just display current preference
        }
    }
}
