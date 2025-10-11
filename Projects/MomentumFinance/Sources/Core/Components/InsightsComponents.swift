import Foundation
import SwiftUI
import enum Shared.FinancialIntelligenceModels.InsightPriority
import struct Shared.FinancialIntelligenceModels.FinancialInsight

// Import insight types
public struct InsightsLoadingView: View {
    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading insights...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    public init() {}
}

public struct InsightsEmptyStateView: View {
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text("No Insights Available")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Add some transactions to see personalized insights about your spending patterns.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    public init() {}
}

public struct InsightRowView: View {
    public let insight: FinancialInsight
    public let action: () -> Void

    public var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            Circle()
                .fill(self.priorityColor(self.insight.priority))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(self.insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                Text(self.insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            Spacer()

            // Show confidence as percentage
            Text("\(Int(self.insight.confidence * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: self.action)
    }

    private func priorityColor(_ priority: InsightPriority) -> Color {
        switch priority {
        case .low: .gray
        case .medium: .yellow
        case .high: .orange
        case .urgent: .red
        }
    }

    public init(insight: FinancialInsight, action: @escaping () -> Void) {
        self.insight = insight
        self.action = action
    }
}

public struct InsightsFilterBar: View {
    @Binding public var filterPriority: InsightPriority?
    @Binding public var filterType: InsightType?

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(title: "All", isSelected: self.filterPriority == nil && self.filterType == nil) {
                    self.filterPriority = nil
                    self.filterType = nil
                }

                FilterChip(title: "High Priority", isSelected: self.filterPriority == .high) {
                    self.filterPriority = self.filterPriority == .high ? nil : .high
                }

                FilterChip(title: "Urgent", isSelected: self.filterPriority == .urgent) {
                    self.filterPriority = self.filterPriority == .urgent ? nil : .urgent
                }

                FilterChip(title: "Spending", isSelected: self.filterType == .spendingPattern) {
                    self.filterType = self.filterType == .spendingPattern ? nil : .spendingPattern
                }

                FilterChip(title: "Budget", isSelected: self.filterType == .budgetAlert) {
                    self.filterType = self.filterType == .budgetAlert ? nil : .budgetAlert
                }
            }
            .padding(.horizontal)
        }
    }

    public init(filterPriority: Binding<InsightPriority?>, filterType: Binding<InsightType?>) {
        _filterPriority = filterPriority
        _filterType = filterType
    }
}

public struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    public var body: some View {
        Button(action: self.action) {
            Text(self.title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(self.isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(self.isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .accessibilityLabel("Filter by \(self.title)")
    }

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
}

public struct InsightDetailView: View {
    public let insight: FinancialInsight
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .fill(self.priorityColor(self.insight.priority))
                                .frame(width: 12, height: 12)

                            Text(self.priorityText(self.insight.priority))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }

                        Text(self.insight.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    // Confidence
                    Text("Confidence: \(Int(self.insight.confidence * 100))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    // Description
                    Text(self.insight.description)
                        .font(.body)
                        .foregroundColor(.secondary)

                    // Type info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Insight Type")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Text(self.insight.type.displayName)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Insight Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            self.dismiss()
                        }
                        .accessibilityLabel("Done")
                    }
                }
        }
    }

    private func priorityColor(_ priority: InsightPriority) -> Color {
        switch priority {
        case .low: .gray
        case .medium: .yellow
        case .high: .orange
        case .urgent: .red
        }
    }

    private func priorityText(_ priority: InsightPriority) -> String {
        switch priority {
        case .low: "Low Priority"
        case .medium: "Medium Priority"
        case .high: "High Priority"
        case .urgent: "Urgent"
        }
    }

    public init(insight: FinancialInsight) {
        self.insight = insight
    }
}
