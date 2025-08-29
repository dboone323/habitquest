//
//  ThemeComponents.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// Common UI components with theme-aware styling
<<<<<<< HEAD
struct ThemeComponents: @unchecked Sendable {
    // MARK: - Card Components

    /// Creates a themed card view with proper shadows and background
    @MainActor
    func card(
        @ViewBuilder content: @escaping () -> some View,
        ) -> some View {
=======
/// 
/// This main coordinator delegates to focused component implementations:
/// - ThemeCardComponents: Card containers and sections
/// - ThemeButtonComponents: Button styles and implementations
/// - ThemeFinancialComponents: Currency and financial data displays
/// - ThemeProgressComponents: Progress bars and indicators
/// - ThemeViewExtensions: SwiftUI view extensions
/// - ThemeComponentsPreview: Preview and development tools
struct ThemeComponents: @unchecked Sendable {
    
    // MARK: - Component Delegates
    
    // Use the canonical, public implementations from `Shared/Theme/Components`.
    // We'll implement a thin, inline adapter that mirrors the canonical
    // component behavior so this aggregator compiles reliably.
    
    public init() {}
    
    // MARK: - Card Components
    
    @MainActor
    func card(@ViewBuilder content: @escaping () -> some View) -> some View {
>>>>>>> 1cf3938 (Create working state for recovery)
        let theme = ColorTheme.shared
        return content()
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }
<<<<<<< HEAD

    /// Creates a card with a header and content
    @MainActor
    func cardWithHeader(
        title: String,
        @ViewBuilder content: @escaping () -> some View,
        ) -> some View {
=======
    
    @MainActor
    func cardWithHeader(title: String, @ViewBuilder content: @escaping () -> some View) -> some View {
>>>>>>> 1cf3938 (Create working state for recovery)
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
<<<<<<< HEAD

    // MARK: - Button Styles

    /// Primary action button style
    @MainActor
    func primaryButton(
        @ViewBuilder label: @escaping () -> some View,
        ) -> some View {
=======
    
    @MainActor
    func section(title: String? = nil, @ViewBuilder content: @escaping () -> some View) -> some View {
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
    
    @MainActor
    func listRow(icon: String, title: String, @ViewBuilder trailing: @escaping () -> some View) -> some View {
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
    
    // MARK: - Button Components
    
    @MainActor
    func primaryButton(@ViewBuilder label: @escaping () -> some View) -> some View {
>>>>>>> 1cf3938 (Create working state for recovery)
        let theme = ColorTheme.shared
        return Button(action: {}, label: label)
            .buttonStyle(PrimaryButtonStyle(theme: theme))
    }
<<<<<<< HEAD

    /// Secondary action button style
    @MainActor
    func secondaryButton(
        @ViewBuilder label: @escaping () -> some View,
        ) -> some View {
=======
    
    @MainActor
    func secondaryButton(@ViewBuilder label: @escaping () -> some View) -> some View {
>>>>>>> 1cf3938 (Create working state for recovery)
        let theme = ColorTheme.shared
        return Button(action: {}, label: label)
            .buttonStyle(SecondaryButtonStyle(theme: theme))
    }
<<<<<<< HEAD

    /// Text-only button style
    @MainActor
    func textButton(
        @ViewBuilder label: @escaping () -> some View,
        ) -> some View {
=======
    
    @MainActor
    func textButton(@ViewBuilder label: @escaping () -> some View) -> some View {
>>>>>>> 1cf3938 (Create working state for recovery)
        let theme = ColorTheme.shared
        return Button(action: {}, label: label)
            .buttonStyle(TextButtonStyle(theme: theme))
    }
<<<<<<< HEAD

    /// Destructive action button style
    @MainActor
    func destructiveButton(
        @ViewBuilder label: @escaping () -> some View,
        ) -> some View {
=======
    
    @MainActor
    func destructiveButton(@ViewBuilder label: @escaping () -> some View) -> some View {
>>>>>>> 1cf3938 (Create working state for recovery)
        let theme = ColorTheme.shared
        return Button(action: {}, label: label)
            .buttonStyle(DestructiveButtonStyle(theme: theme))
    }
<<<<<<< HEAD

    // MARK: - Financial Data Display

    /// Styled currency value display
=======
    
    // MARK: - Financial Components
    
>>>>>>> 1cf3938 (Create working state for recovery)
    @MainActor
    func currencyDisplay(
        amount: Decimal,
        isPositive: Bool? = nil,
        showSign: Bool = false,
<<<<<<< HEAD
        font: Font = .body,
        ) -> some View {
        let theme = ColorTheme.shared
        let isValuePositive = isPositive ?? (amount >= 0)
        let color: Color = if showSign {
            isValuePositive ? theme.income : theme.expense
        } else {
            theme.primaryText
=======
        font: Font = .body
    ) -> some View {
        // Inline currency display (mirrors ThemeFinancialComponents.formatCurrency)
        let theme = ColorTheme.shared
        let isValuePositive = isPositive ?? (amount >= 0)
        let color: Color = (showSign ? (isValuePositive ? theme.income : theme.expense) : theme.primaryText)

        func formatCurrency(_ amount: Decimal, showSign: Bool = false) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 2

            if showSign && amount > 0 {
                return "+" + (formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00")
            }

            return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
>>>>>>> 1cf3938 (Create working state for recovery)
        }

        let formattedValue = formatCurrency(amount, showSign: showSign)

        return Text(formattedValue)
            .font(font)
            .foregroundStyle(color)
    }
<<<<<<< HEAD

    /// Format currency with locale settings
    private func formatCurrency(_ amount: Decimal, showSign: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2

        if showSign && amount > 0 {
            return "+" + (formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00")
        }

        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }

    // MARK: - Progress Indicators

    /// Budget progress bar with color indication based on status
    @MainActor
    /// <#Description#>
    /// - Returns: <#description#>
    func budgetProgressBar(spent: Decimal, total: Decimal) -> some View {
        let theme = ColorTheme.shared
        let progress = min(1.0, (spent / total).isNaN ? 0 : Double(NSDecimalNumber(decimal: spent / total).doubleValue))
        let color: Color = switch progress {
        case 0 ..< 0.8:
            theme.budgetUnder
        case 0.8 ..< 1.0:
            theme.budgetNear
        default:
            theme.budgetOver
        }
=======
    
    // MARK: - Progress Components
    
    @MainActor
    func budgetProgressBar(spent: Decimal, total: Decimal) -> some View {
        let theme = ColorTheme.shared
        let ratio = (total == 0) ? Decimal(0) : (spent / total)
        let progress = min(1.0, Double(NSDecimalNumber(decimal: ratio).doubleValue))
        let color: Color = {
            switch progress {
            case 0 ..< 0.8:
                return theme.budgetUnder
            case 0.8 ..< 1.0:
                return theme.budgetNear
            default:
                return theme.budgetOver
            }
        }()
>>>>>>> 1cf3938 (Create working state for recovery)

        return VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(theme.secondaryBackground)
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)

                Spacer()

<<<<<<< HEAD
                Text("\(formatCurrency(spent)) of \(formatCurrency(total))")
=======
                Text("\(formatCurrency(Double(truncating: spent as NSNumber))) of \(formatCurrency(Double(truncating: total as NSNumber)))")
>>>>>>> 1cf3938 (Create working state for recovery)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
        }
    }
<<<<<<< HEAD

    /// Goal progress circle indicator
    @MainActor
    /// <#Description#>
    /// - Returns: <#description#>
=======
    
    @MainActor
>>>>>>> 1cf3938 (Create working state for recovery)
    func goalProgressCircle(progress: Double, diameter: CGFloat = 80) -> some View {
        let theme = ColorTheme.shared
        let adjustedProgress = min(1.0, max(0.0, progress))

        return ZStack {
            Circle()
                .stroke(
                    theme.secondaryBackground,
<<<<<<< HEAD
                    lineWidth: 8,
                    )
=======
                    lineWidth: 8
                )
>>>>>>> 1cf3938 (Create working state for recovery)

            Circle()
                .trim(from: 0, to: adjustedProgress)
                .stroke(
                    theme.savings,
                    style: StrokeStyle(
                        lineWidth: 8,
<<<<<<< HEAD
                        lineCap: .round,
                        ),
                    )
=======
                        lineCap: .round
                    )
                )
>>>>>>> 1cf3938 (Create working state for recovery)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: adjustedProgress)

            Text("\(Int(adjustedProgress * 100))%")
                .font(.system(.body, design: .rounded))
                .bold()
                .foregroundStyle(theme.primaryText)
        }
        .frame(width: diameter, height: diameter)
    }
<<<<<<< HEAD

    // MARK: - Content Containers

    /// Section container with optional header
    @MainActor
    func section(
        title: String? = nil,
        @ViewBuilder content: @escaping () -> some View,
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
        @ViewBuilder trailing: @escaping () -> some View,
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

// MARK: - Button Styles

/// Primary button style with theme-aware colors
struct PrimaryButtonStyle: ButtonStyle {
    let theme: ColorTheme

    /// <#Description#>
    /// - Returns: <#description#>
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

    /// <#Description#>
    /// - Returns: <#description#>
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
                    .strokeBorder(theme.accentPrimary, lineWidth: 1),
                )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Text-only button style with theme-aware colors
struct TextButtonStyle: ButtonStyle {
    let theme: ColorTheme

    /// <#Description#>
    /// - Returns: <#description#>
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

    /// <#Description#>
    /// - Returns: <#description#>
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

// MARK: - Environment Values

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
    /// <#Description#>
    /// - Returns: <#description#>
    func themedCard() -> some View {
        @Environment(\.themeComponents) var components
        return components.card { self }
    }

    /// Apply the themed card with header style to a view
    /// <#Description#>
    /// - Returns: <#description#>
    func themedCardWithHeader(title: String) -> some View {
        @Environment(\.themeComponents) var components
        return components.cardWithHeader(title: title) { self }
    }

    /// Apply the themed section style to a view
    /// <#Description#>
    /// - Returns: <#description#>
    func themedSection(title: String? = nil) -> some View {
        @Environment(\.themeComponents) var components
        return components.section(title: title) { self }
    }

    /// Apply a theme-aware background color to the view
    /// <#Description#>
    /// - Returns: <#description#>
    func themedBackground() -> some View {
        self.background(ColorTheme.shared.background)
    }
}

// MARK: - Preview

#if DEBUG
struct ThemeComponentsPreview: View {
    @State private var showDarkMode = false
    @State private var sliderValue = 0.7
    let amounts: [Decimal] = [145.50, 1_250.00, -85.75, 5_234.89, -350.25]

    var theme: ColorTheme {
        showDarkMode ? ColorTheme.previewDark : ColorTheme.preview
    }

    var components: ThemeComponents {
        ThemeComponents()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Toggle("Dark Mode", isOn: $showDarkMode)
                        .padding()
                        .background(theme.cardBackground)
                        .cornerRadius(8)

                    previewCards
                    previewButtons
                    previewFinancialItems
                    previewProgress
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("Theme Components")
            .preferredColorScheme(showDarkMode ? .dark : .light)
        }
    }

    private var previewCards: some View {
        VStack(spacing: 16) {
            Text("Cards")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            components.card {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Simple Card")
                        .font(.headline)

                    Text("Cards provide a container for content with proper background and shadows.")
                        .font(.body)
                        .foregroundStyle(theme.secondaryText)
                }
            }

            components.cardWithHeader(title: "Card With Header") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("This card includes a title header with a divider.")
                        .font(.body)
                        .foregroundStyle(theme.secondaryText)

                    Text("Perfect for content sections.")
                        .font(.callout)
                        .foregroundStyle(theme.secondaryText)
                }
            }

            components.section(title: "Section Container") {
                Text("Sections are lighter containers with optional headers.")
                    .font(.body)
                    .foregroundStyle(theme.secondaryText)
            }
        }
    }

    private var previewButtons: some View {
        VStack(spacing: 16) {
            Text("Buttons")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            components.primaryButton {
                Text("Primary Button")
            }

            components.secondaryButton {
                Text("Secondary Button")
            }

            components.destructiveButton {
                Text("Destructive Button")
            }

            components.textButton {
                Text("Text Button")
            }
        }
    }

    private var previewFinancialItems: some View {
        components.cardWithHeader(title: "Financial Displays") {
            VStack(spacing: 16) {
                ForEach(amounts, id: \.self) { amount in
                    HStack {
                        Text("Amount:")
                        Spacer()
                        components.currencyDisplay(
                            amount: amount,
                            showSign: true,
                            font: .body.weight(.medium),
                            )
                    }
                    .padding(.vertical, 4)

                    if amount != amounts.last {
                        Divider()
                    }
                }
            }
        }
    }

    private var previewProgress: some View {
        VStack(spacing: 16) {
            Text("Progress Indicators")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                components.cardWithHeader(title: "Budget Progress") {
                    VStack(spacing: 16) {
                        components.budgetProgressBar(spent: 800, total: 1_000)
                        components.budgetProgressBar(spent: 950, total: 1_000)
                        components.budgetProgressBar(spent: 1_100, total: 1_000)
                    }
                }

                HStack(spacing: 20) {
                    components.goalProgressCircle(progress: 0.25)
                    components.goalProgressCircle(progress: 0.5)
                    components.goalProgressCircle(progress: 0.85)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.cardBackground)
                .cornerRadius(12)

                VStack(spacing: 8) {
                    Text("Interactive Progress")
                        .font(.headline)

                    components.goalProgressCircle(progress: sliderValue)

                    Slider(value: $sliderValue, in: 0 ... 1)
                }
                .padding()
                .background(theme.cardBackground)
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    ThemeComponentsPreview()
}
#endif
=======
}
>>>>>>> 1cf3938 (Create working state for recovery)
