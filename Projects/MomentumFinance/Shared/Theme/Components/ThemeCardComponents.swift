import SwiftUI

// MARK: - Card Components

/// Card component implementations with theme-aware styling
public struct ThemeCardComponents: @unchecked Sendable {

    /// Creates a themed card view with proper shadows and background
    @MainActor
    func card(
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        let theme = ColorTheme.shared
        return content()
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }

    /// Creates a card with a header and content
    @MainActor
    func cardWithHeader(
        title: String,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        let theme = ColorTheme.shared
        return VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            content()
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }

    /// Section container with optional header
    @MainActor
    func section(
        title: String? = nil,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        let theme = ColorTheme.shared
        return VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(theme.primaryText)
            }

            content()
        }
        .padding()
        .background(theme.secondaryBackground)
        .cornerRadius(8)
    }

    /// List row with leading icon
    @MainActor
    func listRow(
        icon: String,
        title: String,
        @ViewBuilder trailing: @escaping () -> some View
    ) -> some View {
        let theme = ColorTheme.shared
        return HStack {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundStyle(theme.accentPrimary)

            Text(title)
                .foregroundStyle(theme.primaryText)

            Spacer()

            trailing()
        }
        .padding(.vertical, 8)
    }
}
