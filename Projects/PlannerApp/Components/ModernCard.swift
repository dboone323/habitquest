//
//  ModernCard.swift
//  PlannerApp
//
//  Enhanced card component for better visual design
//

import SwiftUI

struct ModernCard<Content: View>: View {
    let content: Content
    @EnvironmentObject var themeManager: ThemeManager

    var shadowRadius: CGFloat = 8
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16

    init(
        shadowRadius: CGFloat = 8,
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.shadowRadius = shadowRadius
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        self.content
            .padding(self.padding)
            .background(
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .fill(self.themeManager.currentTheme.secondaryBackgroundColor)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: self.shadowRadius,
                        x: 0,
                        y: 2
                    )
            )
    }
}

public struct ModernButton: View {
    let title: String
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var style: ButtonStyle = .primary
    var size: ButtonSize = .medium
    var isDestructive: Bool = false
    var isDisabled: Bool = false

    enum ButtonStyle {
        case primary, secondary, tertiary
    }

    enum ButtonSize {
        case small, medium, large

        var height: CGFloat {
            switch self {
            case .small: 32
            case .medium: 44
            case .large: 56
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .small: 14
            case .medium: 16
            case .large: 18
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: 12
            case .medium: 16
            case .large: 20
            }
        }
    }

    public var body: some View {
        Button(action: self.action) {
            Text(self.title)
                .font(.system(size: self.size.fontSize, weight: .medium))
                .foregroundColor(self.textColor)
                .frame(maxWidth: .infinity)
                .frame(height: self.size.height)
                .padding(.horizontal, self.size.padding)
        }
        .accessibilityLabel("Button")
        .background(self.backgroundColor)
        .cornerRadius(12)
        .disabled(self.isDisabled)
        .opacity(self.isDisabled ? 0.6 : 1.0)
    }

    private var backgroundColor: Color {
        if self.isDisabled {
            return self.themeManager.currentTheme.secondaryTextColor.opacity(0.3)
        }

        if self.isDestructive {
            return self.themeManager.currentTheme.destructiveColor
        }

        switch self.style {
        case .primary:
            return self.themeManager.currentTheme.primaryAccentColor
        case .secondary:
            return self.themeManager.currentTheme.secondaryAccentColor
        case .tertiary:
            return Color.clear
        }
    }

    private var textColor: Color {
        if self.isDestructive || self.style == .primary {
            return Color.white
        }

        switch self.style {
        case .secondary:
            return self.themeManager.currentTheme.primaryTextColor
        case .tertiary:
            return self.themeManager.currentTheme.primaryAccentColor
        default:
            return Color.white
        }
    }
}

// Progress indicator component
public struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0
    @EnvironmentObject var themeManager: ThemeManager

    var height: CGFloat = 8
    var showPercentage: Bool = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if self.showPercentage {
                HStack {
                    Spacer()
                    Text("\(Int(self.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: self.height / 2)
                        .fill(self.themeManager.currentTheme.secondaryAccentColor.opacity(0.3))
                        .frame(height: self.height)

                    RoundedRectangle(cornerRadius: self.height / 2)
                        .fill(self.themeManager.currentTheme.primaryAccentColor)
                        .frame(width: geometry.size.width * CGFloat(self.progress), height: self.height)
                        .animation(.easeInOut(duration: 0.3), value: self.progress)
                }
            }
            .frame(height: self.height)
        }
    }
}

// Enhanced input field
public struct ModernTextField: View {
    @Binding var text: String
    let placeholder: String
    @EnvironmentObject var themeManager: ThemeManager

    var isSecure: Bool = false
    #if os(iOS)
        var keyboardType: UIKeyboardType = .default
    #endif

    public var body: some View {
        Group {
            if self.isSecure {
                SecureField(self.placeholder, text: self.$text)
            } else {
                TextField(self.placeholder, text: self.$text).accessibilityLabel("Text Field")
                #if os(iOS)
                    .keyboardType(self.keyboardType)
                #endif
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(self.themeManager.currentTheme.secondaryBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            self.themeManager.currentTheme.secondaryAccentColor.opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
        .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
    }
}

#Preview {
    VStack(spacing: 20) {
        ModernCard {
            VStack(alignment: .leading) {
                Text("Sample Card")
                    .font(.headline)
                Text("This is a sample card with modern styling")
                    .font(.subheadline)
            }
        }

        ModernButton(title: "Primary Button", action: {})

        ModernButton(title: "Secondary Button", action: {})

        ProgressBar(progress: 0.7, showPercentage: true)

        ModernTextField(text: Binding.constant(""), placeholder: "Enter text")
            .accessibilityLabel("Text Field")
    }
    .padding()
    .environmentObject(ThemeManager())
}
