import SwiftUI

/// Heat map visualization for habit streaks
struct StreakHeatMap: View {
    let completions: [Date]
    let columns = 7 // Days of week
    let weeksToShow = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Habit Streaks")
                .font(.headline)

            // Day labels
            HStack(spacing: 4) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .frame(width: 20)
                        .foregroundColor(.secondary)
                }
            }

            // Grid
            VStack(spacing: 4) {
                ForEach(0..<weeksToShow, id: \.self) { week in
                    HStack(spacing: 4) {
                        ForEach(0..<columns, id: \.self) { day in
                            let date = dateFor(week: week, day: day)
                            let intensity = getIntensity(for: date)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(colorFor(intensity: intensity))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }

            // Legend
            HStack {
                Text("Less")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                HStack(spacing: 2) {
                    ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { intensity in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorFor(intensity: intensity))
                            .frame(width: 12, height: 12)
                    }
                }

                Text("More")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
        .padding()
    }

    private func dateFor(week: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let daysAgo = (weeksToShow - week - 1) * 7 + (columns - day - 1)
        return calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
    }

    private func getIntensity(for date: Date) -> Double {
        let calendar = Calendar.current
        let count = completions.count(where: {
            calendar.isDate($0, inSameDayAs: date)
        })

        // Intensity based on completion count (0-4+)
        return min(1.0, Double(count) / 4.0)
    }

    private func colorFor(intensity: Double) -> Color {
        if intensity == 0 {
            Color.gray.opacity(0.1)
        } else if intensity < 0.25 {
            Color.green.opacity(0.3)
        } else if intensity < 0.5 {
            Color.green.opacity(0.5)
        } else if intensity < 0.75 {
            Color.green.opacity(0.7)
        } else {
            Color.green
        }
    }
}

#Preview {
    StreakHeatMap(completions: [Date(), Date().addingTimeInterval(-86400)])
}
