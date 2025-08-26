// Momentum Finance - Insights View
// Copyright © 2025 Momentum Finance. All rights reserved.

import Charts
import SwiftData
import SwiftUI

<<<<<<< HEAD
=======
// Use canonical `FinancialInsight`, `InsightPriority`, and `InsightType` from
// `Shared/Intelligence/Components/FinancialInsightModels.swift`.

>>>>>>> 1cf3938 (Create working state for recovery)
/// View that displays financial insights and recommendations
struct InsightsView: View {
    @StateObject private var intelligenceService = FinancialIntelligenceService.shared
    @Environment(\.modelContext) private var modelContext

    @State private var selectedInsight: FinancialInsight?
    @State private var filterPriority: InsightPriority?
    @State private var filterType: InsightType?

    var body: some View {
        Group {
            #if os(macOS)
<<<<<<< HEAD
            NavigationStack {
                VStack(spacing: 0) {
                    // Filter Bar
                    filterBar

                    // Insights List
                    if intelligenceService.isAnalyzing {
                        loadingView
                    } else if intelligenceService.insights.isEmpty {
                        emptyStateView
                    } else {
                        insightsList
                    }
                }
                .navigationTitle("Financial Insights")
                .toolbar {
                    ToolbarItem {
                        Button("Refresh") {
                            Task {
                                await intelligenceService.analyzeFinancialData(modelContext: modelContext)
                            }
                        }
                        .disabled(intelligenceService.isAnalyzing)
                    }
                }
            }
            #else
            NavigationView {
                VStack(spacing: 0) {
                    // Filter Bar
                    filterBar

                    // Insights List
                    if intelligenceService.isAnalyzing {
                        loadingView
                    } else if intelligenceService.insights.isEmpty {
                        emptyStateView
                    } else {
                        insightsList
                    }
                }
                .navigationTitle("Financial Insights")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Refresh") {
                            Task {
                                await intelligenceService.analyzeFinancialData(modelContext: modelContext)
                            }
                        }
                        .disabled(intelligenceService.isAnalyzing)
                    }
                }
            }
=======
                NavigationStack {
                    VStack(spacing: 0) {
                        // Filter Bar
                        InsightsFilterBar(
                            filterPriority: $filterPriority,
                            filterType: $filterType
                        )

                        // Insights Content
                        insightsContent
                    }
                    .navigationTitle("Financial Insights")
                    .toolbar {
                        ToolbarItem {
                            Button("Refresh") {
                                Task {
                                    await intelligenceService.analyzeFinancialData(
                                        modelContext: modelContext)
                                }
                            }
                            .disabled(intelligenceService.isAnalyzing)
                        }
                    }
                }
            #else
                NavigationView {
                    VStack(spacing: 0) {
                        // Filter Bar
                        InsightsFilterBar(
                            filterPriority: $filterPriority,
                            filterType: $filterType
                        )

                        // Insights Content
                        insightsContent
                    }
                    .navigationTitle("Financial Insights")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Refresh") {
                                Task {
                                    await intelligenceService.analyzeFinancialData(
                                        modelContext: modelContext)
                                }
                            }
                            .disabled(intelligenceService.isAnalyzing)
                        }
                    }
                }
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }
        .sheet(item: $selectedInsight) { insight in
            InsightDetailView(insight: insight)
        }
        .onAppear {
            Task {
                if intelligenceService.insights.isEmpty {
                    await intelligenceService.analyzeFinancialData(modelContext: modelContext)
                }
            }
        }
    }

<<<<<<< HEAD
    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack {
            // Priority Filter
            Menu {
                Button("All Priorities") {
                    filterPriority = nil
                }

                ForEach(InsightPriority.allCases, id: \.self) { priority in
                    Button(priority.rawValue.capitalized) {
                        filterPriority = priority
                    }
                }
            } label: {
                HStack {
                    Text(filterPriority?.rawValue.capitalized ?? "All Priorities")
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }

            // Type Filter
            Menu {
                Button("All Types") {
                    filterType = nil
                }

                ForEach(InsightType.allCases, id: \.self) { type in
                    Button(type.rawValue.capitalized) {
                        filterType = type
                    }
                }
            } label: {
                HStack {
                    Text(filterType?.rawValue.capitalized ?? "All Types")
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Insights List

=======
    @ViewBuilder
    private var insightsContent: some View {
        if intelligenceService.isAnalyzing {
            InsightsLoadingView()
        } else if intelligenceService.insights.isEmpty {
            InsightsEmptyStateView()
        } else {
            insightsList
        }
    }

>>>>>>> 1cf3938 (Create working state for recovery)
    private var insightsList: some View {
        List {
            ForEach(filteredInsights) { insight in
                InsightRowView(insight: insight) {
                    selectedInsight = insight
                }
            }
        }
        .listStyle(PlainListStyle())
    }

<<<<<<< HEAD
    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Analyzing your financial data...")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("This may take a moment")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lightbulb")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Insights Available")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add some transactions and accounts to get personalized financial insights.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Computed Properties

=======
>>>>>>> 1cf3938 (Create working state for recovery)
    private var filteredInsights: [FinancialInsight] {
        intelligenceService.insights
            .filter { insight in
                if let priority = filterPriority, insight.priority != priority {
                    return false
                }
                if let type = filterType, insight.type != type {
                    return false
                }
                return true
            }
<<<<<<< HEAD
            .sorted { $0.priority > $1.priority } // Sort by priority (critical first)
    }
}

// MARK: - Insight Row View

struct InsightRowView: View {
    let insight: FinancialInsight
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Priority Icon
                Image(systemName: insight.priority.icon)
                    .foregroundColor(insight.priority.color)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(insight.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    // Description
                    Text(insight.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Type Badge
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

                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Insight Detail View

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

                        // Data Visualization
                        if !insight.data.isEmpty {
                            dataVisualization
                        }

                        // Action Buttons
                        actionButtons

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

                        // Data Visualization
                        if !insight.data.isEmpty {
                            dataVisualization
                        }

                        // Action Buttons
                        actionButtons

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

    // MARK: - Data Visualization

    @ViewBuilder
    private var dataVisualization: some View {
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
                    y: .value("Amount", data.1),
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
                    y: .value("Amount", data.1),
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

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Priority-specific actions
            switch insight.priority {
            case .critical:
                Button("Take Action Now") {
                    // Handle critical action
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

            case .high:
                Button("Review & Act") {
                    // Handle high priority action
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

            case .medium:
                Button("Learn More") {
                    // Handle medium priority action
                }
                .buttonStyle(.bordered)

            case .low:
                Button("Dismiss") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }

            // Generic actions
            Button("Share Insight") {
                // Handle sharing
            }
            .buttonStyle(.bordered)
        }
=======
            .sorted { $0.priority > $1.priority }  // Sort by priority (critical first)
>>>>>>> 1cf3938 (Create working state for recovery)
    }
}

// MARK: - Preview

#Preview {
    InsightsView()
<<<<<<< HEAD
        .modelContainer(for: [
            FinancialAccount.self,
            FinancialTransaction.self,
            Budget.self,
            ExpenseCategory.self
        ], inMemory: true)
=======
        .modelContainer(
            for: [
                FinancialAccount.self,
                FinancialTransaction.self,
                Budget.self,
                ExpenseCategory.self,
            ], inMemory: true)
>>>>>>> 1cf3938 (Create working state for recovery)
}
