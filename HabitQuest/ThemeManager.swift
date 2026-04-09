import Combine
import SwiftUI

/// Enhancement #84: Dark Mode Manager
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    init() {
        isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
    }

    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    func toggleTheme() {
        isDarkMode.toggle()
    }

    var currentTheme: Theme {
        Theme(isDarkMode: isDarkMode)
    }
}

struct Theme {
    let isDarkMode: Bool

    var backgroundColor: Color {
        #if os(iOS)
            return isDarkMode ? Color(.systemBackground) : Color(.systemBackground)
        #else
            return Color(nsColor: .windowBackgroundColor)
        #endif
    }

    var primaryColor: Color {
        .blue
    }

    var textColor: Color {
        .primary
    }

    var secondaryTextColor: Color {
        .secondary
    }
}

/// Modifier for easy application
struct ThemeModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.colorScheme)
    }
}
