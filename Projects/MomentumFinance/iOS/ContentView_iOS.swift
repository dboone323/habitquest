// Momentum Finance - iOS-specific ContentView enhancements
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftUI

extension ContentView {
    /// iOS-specific view modifiers and optimizations
    var iOSOptimizations: some View {
        preferredColorScheme(.automatic)
            .tint(.blue)
    }
}

#if os(iOS)
// iOS-specific UI components and helpers
enum iOSSpecificViews {
    /// iOS navigation bar configuration
    static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    /// iOS tab bar configuration
    static func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// iOS-specific view extensions
extension View {
    /// Add iOS-specific keyboard handling
    /// <#Description#>
    /// - Returns: <#description#>
    func iOSKeyboardHandling() -> some View {
        ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil,
                )
            }
    }

    /// iOS-specific sheet presentation
    /// <#Description#>
    /// - Returns: <#description#>
    func iOSSheetPresentation() -> some View {
        if #available(iOS 16.0, *) {
            return self.presentationDetents([.medium, .large])
        } else {
            return self
        }
    }
}
#endif
