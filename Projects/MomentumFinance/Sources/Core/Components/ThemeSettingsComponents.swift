import Foundation
import SwiftUI

// MARK: - Theme Settings Components

public struct ThemeBudgetProgress: View {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public var body: some View {
        Text("Budget Progress")
    }
}

public struct ThemeSubscriptionsList: View {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public var body: some View {
        Text("Subscriptions List")
    }
}

public struct ThemeTypographyShowcase: View {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public var body: some View {
        Text("Typography Showcase")
    }
}

public struct ThemeButtonStylesShowcase: View {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public var body: some View {
        Text("Button Styles Showcase")
    }
}

public struct ThemeSettingsSheet: View {
    @Binding public var selectedThemeMode: ThemeMode
    @Binding public var sliderValue: Double
    @Binding public var showSheet: Bool
    public let theme: Any?

    public init(
        selectedThemeMode: Binding<ThemeMode>, sliderValue: Binding<Double>,
        showSheet: Binding<Bool>, theme: Any? = nil
    ) {
        _selectedThemeMode = selectedThemeMode
        _sliderValue = sliderValue
        _showSheet = showSheet
        self.theme = theme
    }

    public var body: some View {
        NavigationView {
            VStack {
                Text("Theme Settings")
                Slider(value: self.$sliderValue, in: 0 ... 1)
                Button("Close") {
                    self.showSheet = false
                }
                .accessibilityLabel("Close")
            }
            .navigationTitle("Settings")
        }
    }
}
