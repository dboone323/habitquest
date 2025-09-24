import Foundation
import SwiftUI

// MARK: - Button Styles

public struct PrimaryButtonStyle: ButtonStyle {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

public struct TextButtonStyle: ButtonStyle {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal)
            .foregroundColor(.blue)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

public struct DestructiveButtonStyle: ButtonStyle {
    public let theme: Any?

    public init(theme: Any? = nil) {
        self.theme = theme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
