import SwiftUI

public final class ColorTheme: ObservableObject {
    public enum ThemeMode {
        case system
        case light
        case dark
    }

    @Published public private(set) var currentThemeMode: ThemeMode

    public init(initialMode: ThemeMode = .system) {
        self.currentThemeMode = initialMode
    }

    public func setThemeMode(_ mode: ThemeMode) {
        self.currentThemeMode = mode
    }
}

public protocol ThemedButtonStyle: ButtonStyle {
    var theme: ColorTheme { get }
}

public struct PrimaryButtonStyle: ThemedButtonStyle {
    public let theme: ColorTheme

    public init(theme: ColorTheme) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(self.theme.currentThemeMode == .dark ? Color.white.opacity(0.15) : Color.accentColor)
            .foregroundColor(self.theme.currentThemeMode == .dark ? .white : .black)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

public struct SecondaryButtonStyle: ThemedButtonStyle {
    public let theme: ColorTheme

    public init(theme: ColorTheme) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.gray.opacity(self.theme.currentThemeMode == .dark ? 0.5 : 0.2))
            .foregroundColor(self.theme.currentThemeMode == .dark ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

public struct TextButtonStyle: ThemedButtonStyle {
    public let theme: ColorTheme

    public init(theme: ColorTheme) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(self.theme.currentThemeMode == .dark ? .white : .accentColor)
            .underline(configuration.isPressed, color: .accentColor)
    }
}

public struct DestructiveButtonStyle: ThemedButtonStyle {
    public let theme: ColorTheme

    public init(theme: ColorTheme) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(self.theme.currentThemeMode == .dark ? 0.7 : 0.2))
            .foregroundColor(.red)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}
