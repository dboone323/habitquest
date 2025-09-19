import SwiftUI

public struct InsightDetailView: View {
    let insight: FinancialInsight

    public init(insight: FinancialInsight) {
        self.insight = insight
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(self.insight.title)
                            .font(.title)
                            .fontWeight(.bold)

                        Spacer()

                        PriorityBadge(priority: self.insight.priority)
                    }

                    Text(self.insight.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                // Type and Category
                HStack(spacing: 16) {
                    Label(self.insight.type.rawValue, systemImage: "tag")
                        .foregroundColor(.secondary)

                    if let categoryId = insight.relatedCategoryId {
                        Label("Category: \(categoryId)", systemImage: "folder")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.subheadline)

                Divider()

                // Insight Details
                VStack(alignment: .leading, spacing: 16) {
                    // Related IDs
                    if self.insight.relatedAccountId != nil || self.insight.relatedTransactionId != nil ||
                        self.insight.relatedCategoryId != nil || self.insight.relatedBudgetId != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Related Items")
                                .font(.headline)

                            if let accountId = insight.relatedAccountId {
                                Text("Account: \(accountId)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }

                            if let transactionId = insight.relatedTransactionId {
                                Text("Transaction: \(transactionId)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }

                            if let categoryId = insight.relatedCategoryId {
                                Text("Category: \(categoryId)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }

                            if let budgetId = insight.relatedBudgetId {
                                Text("Budget: \(budgetId)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // Data visualization info
                    if let visualizationType = insight.visualizationType {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Visualization")
                                .font(.headline)

                            Text("Type: \(String(describing: visualizationType))")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Data points
                    if !self.insight.data.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Data Points")
                                .font(.headline)

                            ForEach(self.insight.data, id: \.0) { key, value in
                                HStack {
                                    Text(key)
                                        .font(.body)
                                    Spacer()
                                    Text(String(format: "%.2f", value))
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Insight Details")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

private struct PriorityBadge: View {
    let priority: InsightPriority

    var body: some View {
        Text(self.priority.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(self.priorityColor.opacity(0.2))
            .foregroundColor(self.priorityColor)
            .cornerRadius(8)
    }

    private var priorityColor: Color {
        switch self.priority {
        case .critical: .red
        case .high: .orange
        case .medium: .yellow
        case .low: .green
        }
    }
}
