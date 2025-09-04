import SwiftUI

// MARK: - Progress Components

/// Progress indicator components with theme-aware styling
public struct ThemeProgressComponents: @unchecked Sendable {

    /// Budget progress bar with color indication based on status
    @MainActor
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

                Text("\(formatCurrency(spent)) of \(formatCurrency(total))")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
        }
    }

    /// Goal progress circle indicator
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
