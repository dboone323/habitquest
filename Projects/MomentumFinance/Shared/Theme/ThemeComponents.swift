//
//  ThemeComponents.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// Common UI components with theme-aware styling
///
/// This main coordinator delegates to focused component implementations:
/// - ThemeCardComponents: Card containers and sections
/// - ThemeButtonComponents: Button styles and implementations
/// - ThemeFinancialComponents: Currency and financial data displays
/// - ThemeProgressComponents: Progress bars and indicators
/// - ThemeViewExtensions: SwiftUI view extensions
/// - ThemeComponentsPreview: Preview and development tools
public struct ThemeComponents: @unchecked Sendable {
    // MARK: - Card Components

    @MainActor
    func card(@ViewBuilder content: @escaping () -> some View) -> some View {
        let theme = ColorTheme.shared
        return content()
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }

    @MainActor
    func cardWithHeader(title: String, @ViewBuilder content: @escaping () -> some View) -> some View {
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
    func listRow(icon: String, title: String, @ViewBuilder trailing: @escaping () -> some View)
        -> some View {
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
    func primaryButton(@ViewBuilder label: ().accessibilityLabel("Button") -> some View) -> some View {
        let theme = ColorTheme.shared
        return Button(action: {}, label: label).accessibilityLabel("Button").accessibilityLabel("Button")
            .buttonStyle(PrimaryButtonStyle(theme: theme))
    }

    @MainActor
    func secondaryButton(@ViewBuilder label: ().accessibilityLabel("Button") -> some View) -> some View {
        let theme = ColorTheme.shared
        return Button(action: {}, label: label).accessibilityLabel("Button").accessibilityLabel("Button")
            .buttonStyle(SecondaryButtonStyle(theme: theme))
    }

    @MainActor
    func textButton(@ViewBuilder label: ().accessibilityLabel("Button") -> some View) -> some View {
        let theme = ColorTheme.shared
        return Button(action: {}, label: label).accessibilityLabel("Button").accessibilityLabel("Button")
            .buttonStyle(TextButtonStyle(theme: theme))
    }

    @MainActor
    func destructiveButton(@ViewBuilder label: ().accessibilityLabel("Button") -> some View) -> some View {
        let theme = ColorTheme.shared
        return Button(action: {}, label: label).accessibilityLabel("Button").accessibilityLabel("Button")
            .buttonStyle(DestructiveButtonStyle(theme: theme))
    }

    // MARK: - Financial Components

    @MainActor
    func currencyDisplay(
        amount: Decimal,
        isPositive: Bool? = nil,
        showSign: Bool = false,
        font: Font = .body
    ) -> some View {
        // Inline currency display (mirrors ThemeFinancialComponents.formatCurrency)
        let theme = ColorTheme.shared
        let isValuePositive = isPositive ?? (amount >= 0)
        let color: Color =
            (showSign ? (isValuePositive ? theme.income : theme.expense) : theme.primaryText)

        func formatCurrency(_ amount: Decimal, showSign: Bool = false) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 2

            if showSign, amount > 0 {
                return "+" + (formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00")
            }

            return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
        }

        let formattedValue = formatCurrency(amount, showSign: showSign)

        return Text(formattedValue)
            .font(font)
            .foregroundStyle(color)
    }

    // MARK: - Progress Components

    @MainActor
    func budgetProgressBar(spent: Decimal, total: Decimal) -> some View {
        let theme = ColorTheme.shared
        let ratio = (total == 0) ? Decimal(0) : (spent / total)
        let progress = min(1.0, Double(NSDecimalNumber(decimal: ratio).doubleValue))
        let color: Color = switch progress {
        case 0 ..< 0.8:
            theme.budgetUnder
        case 0.8 ..< 1.0:
            theme.budgetNear
        default:
            theme.budgetOver
        }

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

                Text(
                    "\(formatCurrency(Double(truncating: spent as NSNumber))) of \(formatCurrency(Double(truncating: total as NSNumber)))"
                )
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
            }
        }
    }

    @MainActor
    func goalProgressCircle(progress: Double, diameter: CGFloat = 80) -> some View {
        let theme = ColorTheme.shared
        let adjustedProgress = min(1.0, max(0.0, progress))

        return ZStack {
            Circle()
                .stroke(
                    theme.secondaryBackground,
                    lineWidth: 8
                )

            Circle()
                .trim(from: 0, to: adjustedProgress)
                .stroke(
                    theme.savings,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: adjustedProgress)

            Text("\(Int(adjustedProgress * 100))%")
                .font(.system(.body, design: .rounded))
                .bold()
                .foregroundStyle(theme.primaryText)
        }
        .frame(width: diameter, height: diameter)
    }
}
