//
//  ButtonStyles.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

// MARK: - Button Styles

/// Primary button style with theme-aware colors
public struct PrimaryButtonStyle: ButtonStyle {
    let theme: ColorTheme

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(self.theme.accentPrimary.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundStyle(Color.white)
            .font(.body.weight(.medium))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Secondary button style with theme-aware colors
public struct SecondaryButtonStyle: ButtonStyle {
    let theme: ColorTheme

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(self.theme.secondaryBackground)
            .foregroundStyle(self.theme.accentPrimary)
            .font(.body.weight(.medium))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(self.theme.accentPrimary, lineWidth: 1)
            )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Text-only button style with theme-aware colors
public struct TextButtonStyle: ButtonStyle {
    let theme: ColorTheme

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(self.theme.accentPrimary.opacity(configuration.isPressed ? 0.7 : 1.0))
            .font(.body.weight(.medium))
            .padding(.vertical, 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Destructive button style with theme-aware colors
public struct DestructiveButtonStyle: ButtonStyle {
    let theme: ColorTheme

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(self.theme.critical.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundStyle(Color.white)
            .font(.body.weight(.medium))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
