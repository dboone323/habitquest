import SwiftUI

struct ThemeSelectorCard: View {
    @Binding var selectedThemeMode: ThemeMode
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Theme Mode")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            HStack(spacing: 12) {
                ForEach(ThemeMode.allCases) { mode in
                    themeModeButton(mode)
                }
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    private func themeModeButton(_ mode: ThemeMode) -> some View {
        Button(action: {
            selectedThemeMode = mode
            theme.setThemeMode(mode)
            // If we had access to ThemePersistence, we would save here
            // ThemePersistence.saveThemePreference(mode)
        }) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundStyle(
                        selectedThemeMode == mode ? theme.accentPrimary : theme.secondaryText)

                Text(mode.displayName)
                    .font(.caption)
                    .foregroundStyle(
                        selectedThemeMode == mode ? theme.primaryText : theme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        selectedThemeMode == mode
                            ? theme.accentPrimary.opacity(0.1) : theme.secondaryBackground),
            )
        }
    }
}

#Preview {
    ThemeSelectorCard(
        selectedThemeMode: .constant(.system),
        theme: ColorTheme.shared
    )
}
