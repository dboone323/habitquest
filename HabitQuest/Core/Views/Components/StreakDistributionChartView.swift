import SwiftUI

// MARK: - Streak Distribution Chart View

/// Animated distribution chart with smooth transitions
public struct StreakDistributionChartView: View {
    let data: [StreakDistributionData]
    @State private var animateChart = false

    public var body: some View {
        VStack(spacing: 16) {
            self.chartTitle
            self.chartBars
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                self.animateChart = true
            }
        }
    }

    private var chartTitle: some View {
        HStack {
            Text("Distribution")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Text("Habits by streak length")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var chartBars: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(Array(self.data.enumerated()), id: \.element.range) { index, item in
                VStack(spacing: 8) {
                    self.barColumn(for: item, index: index)
                    self.barLabel(for: item)
                }
            }
        }
        .frame(height: 180)
    }

    private func barColumn(for item: StreakDistributionData, index: Int) -> some View {
        let maxCount = self.data.map(\.count).max() ?? 1
        let normalizedHeight = max(0.1, Double(item.count) / Double(maxCount))
        let barHeight = self.animateChart ? normalizedHeight * 120 : 0

        return VStack {
            Spacer()

            RoundedRectangle(cornerRadius: 6)
                .fill(self.barGradient(for: index))
                .frame(height: barHeight)
                .overlay(
                    Text("\(item.count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .opacity(item.count > 0 ? 1 : 0)
                )
                .animation(
                    .spring(response: 0.8, dampingFraction: 0.8).delay(Double(index) * 0.1),
                    value: self.animateChart
                )
        }
    }

    private func barLabel(for item: StreakDistributionData) -> some View {
        Text(item.range)
            .font(.caption2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }

    private func barGradient(for index: Int) -> LinearGradient {
        let colors = [Color.blue, Color.green, Color.orange, Color.purple, Color.red]
        let color = colors[index % colors.count]

        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
