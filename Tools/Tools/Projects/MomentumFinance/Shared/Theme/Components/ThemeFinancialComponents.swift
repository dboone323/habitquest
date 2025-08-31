import SwiftUI

// MARK: - Financial Display Components

/// Financial data display components with theme-aware styling
public struct ThemeFinancialComponents: @unchecked Sendable {

    /// Styled currency value display
    @MainActor
    func currencyDisplay(
        amount: Decimal,
        isPositive: Bool? = nil,
        showSign: Bool = false,
        font: Font = .body
    ) -> some View {
        let theme = ColorTheme.shared
        let isValuePositive = isPositive ?? (amount >= 0)
        let color: Color = if showSign {
            isValuePositive ? theme.income : theme.expense
        } else {
            theme.primaryText
        }

        let formattedValue = formatCurrency(amount, showSign: showSign)

        return Text(formattedValue)
            .font(font)
            .foregroundStyle(color)
    }

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
}
