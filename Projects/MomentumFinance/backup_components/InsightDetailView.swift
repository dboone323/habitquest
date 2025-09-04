import SwiftUI

struct InsightDetailView: View {
    let insight: FinancialInsight
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            #if os(macOS)
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            InsightDetailHeader(insight: insight)

                            // Data Visualization
                            if !insight.data.isEmpty {
                                InsightDataVisualization(insight: insight)
                            }

                            // Action Buttons
                            InsightActionButtons(insight: insight) {
                                dismiss()
                            }

                            Spacer()
                        }
                        .padding()
                    }
                    .navigationTitle("Insight Details")
                    .toolbar {
                        ToolbarItem {
                            Button("Done") {
                                dismiss()
                            }
                        }
                    }
                }
                .frame(minWidth: 500, minHeight: 500)
            #else
                NavigationView {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            InsightDetailHeader(insight: insight)

                            // Data Visualization
                            if !insight.data.isEmpty {
                                InsightDataVisualization(insight: insight)
                            }

                            // Action Buttons
                            InsightActionButtons(insight: insight) {
                                dismiss()
                            }

                            Spacer()
                        }
                        .padding()
                    }
                    .navigationTitle("Insight Details")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                dismiss()
                            }
                        }
                    }
                }
            #endif
        }
    }
}

struct InsightDetailHeader: View {
    let insight: FinancialInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.priority.icon)
                    .foregroundColor(insight.priority.color)
                    .font(.title)

                VStack(alignment: .leading) {
                    Text(insight.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack {
                        Image(systemName: insight.type.icon)
                            .font(.caption)
                        Text(insight.type.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                }

                Spacer()
            }

            Text(insight.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    InsightDetailView(
        insight: FinancialInsight(
            id: UUID(),
            title: "High Spending Alert",
            description: "Your dining out spending is significantly above your usual patterns.",
            type: .spending,
            priority: .high,
            data: [("This Month", 450.0), ("Average", 280.0)]
        )
    )
}
