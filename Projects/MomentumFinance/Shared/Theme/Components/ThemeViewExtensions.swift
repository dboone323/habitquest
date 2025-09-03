import SwiftUI

// MARK: - Environment Extensions

/// Add theme components to the environment
private struct ThemeComponentsKey: EnvironmentKey {
    static let defaultValue = ThemeComponents()
}

extension EnvironmentValues {
    var themeComponents: ThemeComponents {
        get { self[ThemeComponentsKey.self] }
        set { self[ThemeComponentsKey.self] = newValue }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply the themed card style to a view
    func themedCard() -> some View {
        @Environment(\.themeComponents) var components
        return components.card { self }
    }

    /// Apply the themed card with header style to a view
    func themedCardWithHeader(title: String) -> some View {
        @Environment(\.themeComponents) var components
        return components.cardWithHeader(title: title) { self }
    }

    /// Apply the themed section style to a view
    func themedSection(title: String? = nil) -> some View {
        @Environment(\.themeComponents) var components
        return components.section(title: title) { self }
    }

    /// Apply a theme-aware background color to the view
    func themedBackground() -> some View {
        self.background(ColorTheme.shared.background)
    }
}
