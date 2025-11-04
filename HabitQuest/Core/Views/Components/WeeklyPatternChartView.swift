import SwiftUI

// MARK: - Weekly Pattern Chart View

/// Animated weekly pattern visualization
public struct WeeklyPatternChartView: View {
    let patterns: [WeeklyPattern]
    @State private var animatePattern = false

    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(self.patterns.enumerated()), id: \.element.day) { index, pattern in
                VStack(spacing: 6) {
                    self.patternBar(for: pattern, index: index)
                    self.dayLabel(pattern.day)
                }
            }
        }
        .frame(height: 100)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                self.animatePattern = true
            }
        }
    }

    private func patternBar(for pattern: WeeklyPattern, index: Int) -> some View {
        let barHeight = self.animatePattern ? pattern.completionRate * 70 : 0

        return VStack {
            Spacer()

            RoundedRectangle(cornerRadius: 4)
                .fill(self.barColor(for: pattern.completionRate))
                .frame(height: barHeight)
                .animation(
                    .spring(response: 0.7, dampingFraction: 0.8).delay(Double(index) * 0.05),
                    value: self.animatePattern
                )
        }
    }

    private func dayLabel(_ day: String) -> some View {
        Text(day)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
    }

    private func barColor(for rate: Double) -> LinearGradient {
        let color = rate > 0.7 ? Color.green : rate > 0.4 ? Color.orange : Color.red
        return LinearGradient(
            colors: [color, color.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
