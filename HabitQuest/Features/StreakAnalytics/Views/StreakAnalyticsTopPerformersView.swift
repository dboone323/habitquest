import SwiftUI

/// Top performers section
public struct StreakAnalyticsTopPerformersView: View {
    let topPerformers: [TopPerformer]

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Performers")
                .font(.title3)
                .fontWeight(.semibold)

            ForEach(self.topPerformers.prefix(5), id: \.habit.id) { performer in
                TopPerformerRow(performer: performer)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}
