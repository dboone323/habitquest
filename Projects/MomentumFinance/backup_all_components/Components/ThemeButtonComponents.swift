import SwiftUI

// MARK: - Button Components

/// Button component implementations with theme-aware styling
public struct ThemeButtonComponents: @unchecked Sendable {

    /// Primary action button style
    @MainActor
    func primaryButton(
        @ViewBuilder label: @escaping () -> some View
    ) -> some View {
        let theme = ColorTheme.shared
        return Button(action: {}, label: label)
            .buttonStyle(PrimaryButtonStyle(theme: theme))
    }

    /// Secondary action button style
    @MainActor
    func secondaryButton(
        @ViewBuilder label: @escaping () -> some View
    ) -> some View {
        let theme = ColorTheme.shared
        return Button(action: {}, label: label)
            .buttonStyle(SecondaryButtonStyle(theme: theme))
    }

    /// Text-only button style
    @MainActor
    func textButton(
        @ViewBuilder label: @escaping () -> some View
    ) -> some View {
        let theme = ColorTheme.shared
        return Button(action: {}, label: label)
            .buttonStyle(TextButtonStyle(theme: theme))
    }

    /// Destructive action button style
    @MainActor
    func destructiveButton(
        @ViewBuilder label: @escaping () -> some View
    ) -> some View {
        let theme = ColorTheme.shared
        return Button(action: {}, label: label)
            .buttonStyle(DestructiveButtonStyle(theme: theme))
    }
}

// MARK: - Button Styles

/// Primary button style with theme-aware colors
struct PrimaryButtonStyle: ButtonStyle {
    let theme: ColorTheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(theme.accentPrimary.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundStyle(Color.white)
            .font(.body.weight(.medium))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Secondary button style with theme-aware colors
struct SecondaryButtonStyle: ButtonStyle {
    let theme: ColorTheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(theme.secondaryBackground)
            .foregroundStyle(theme.accentPrimary)
            .font(.body.weight(.medium))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(theme.accentPrimary, lineWidth: 1)
            )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Text-only button style with theme-aware colors
struct TextButtonStyle: ButtonStyle {
    let theme: ColorTheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(theme.accentPrimary.opacity(configuration.isPressed ? 0.7 : 1.0))
            .font(.body.weight(.medium))
            .padding(.vertical, 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Destructive button style with theme-aware colors
struct DestructiveButtonStyle: ButtonStyle {
    let theme: ColorTheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(theme.critical.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundStyle(Color.white)
            .font(.body.weight(.medium))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
