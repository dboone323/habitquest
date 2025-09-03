import Charts
import SwiftUI

struct InsightDataVisualization: View {
    let insight: FinancialInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data")
                .font(.headline)

            if let visualizationType = insight.visualizationType {
                switch visualizationType {
                case .barChart:
                    barChart
                case .lineChart:
                    lineChart
                case .progressBar:
                    progressBars
                case .pieChart:
                    // Pie chart implementation would go here
                    dataTable
                case .boxPlot:
                    // Box plot implementation would go here
                    dataTable
                }
            } else {
                dataTable
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    private var barChart: some View {
        Chart {
            ForEach(Array(insight.data.enumerated()), id: \.offset) { _, data in
                BarMark(
                    x: .value("Category", data.0),
                    y: .value("Amount", data.1)
                )
                .foregroundStyle(.blue)
            }
        }
        .frame(height: 200)
    }

    private var lineChart: some View {
        Chart {
            ForEach(Array(insight.data.enumerated()), id: \.offset) { _, data in
                LineMark(
                    x: .value("Period", data.0),
                    y: .value("Amount", data.1)
                )
                .foregroundStyle(.blue)
            }
        }
        .frame(height: 200)
    }

    private var progressBars: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(insight.data.enumerated()), id: \.offset) { _, data in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(data.0)
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(data.1.formatted(.currency(code: "USD")))
                            .font(.caption)
                            .fontWeight(.medium)
                    }

                    ProgressView(value: data.1 / insight.data.map(\.1).max()!)
                        .tint(.blue)
                }
            }
        }
    }

    private var dataTable: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(insight.data.enumerated()), id: \.offset) { index, data in
                HStack {
                    Text(data.0)
                        .font(.body)
                        .fontWeight(.medium)

                    Spacer()

                    Text(data.1.formatted(.currency(code: "USD")))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                if index < insight.data.count - 1 {
                    Divider()
                }
            }
        }
    }
}

#Preview {
    InsightDataVisualization(
        insight: FinancialInsight(
            id: UUID(),
            title: "Spending Analysis",
            description: "Your monthly spending breakdown",
            type: .spending,
            priority: .medium,
            data: [
                ("Groceries", 400.0),
                ("Dining", 250.0),
                ("Entertainment", 150.0),
                ("Transport", 200.0),
            ]
        )
    )
}
