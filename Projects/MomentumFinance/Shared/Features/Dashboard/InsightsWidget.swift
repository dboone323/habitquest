// Momentum Finance - Insights Widget
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

/// Compact widget showing key financial insights for the dashboard
struct InsightsWidget: View {
    @StateObject private var intelligenceService = FinancialIntelligenceService.shared
    @Environment(\.modelContext) private var modelContext

    @State private var showAllInsights = false

    private var topInsights: [FinancialInsight] {
        intelligenceService.insights
            .sorted { $0.priority > $1.priority }
            .prefix(3)
            .compactMap(\.self)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("Financial Insights", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if intelligenceService.isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !intelligenceService.insights.isEmpty {
                    Button("View All") {
                        showAllInsights = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            // Content
            if intelligenceService.isAnalyzing {
                loadingContent
            } else if topInsights.isEmpty {
                emptyContent
            } else {
                insightsContent
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showAllInsights) {
            InsightsView()
        }
        .onAppear {
            Task {
                if intelligenceService.insights.isEmpty {
                    await intelligenceService.analyzeFinancialData(modelContext: modelContext)
                }
            }
        }
    }

    // MARK: - Loading Content

    private var loadingContent: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)

            Text("Analyzing your finances...")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    // MARK: - Empty Content

    private var emptyContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("No insights yet")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text("Add transactions to get personalized insights")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Insights Content

    private var insightsContent: some View {
        VStack(spacing: 12) {
            ForEach(topInsights) { insight in
                CompactInsightRow(insight: insight)
            }

            if intelligenceService.insights.count > 3 {
                HStack {
                    Text("\(intelligenceService.insights.count - 3) more insights available")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button("View All") {
                        showAllInsights = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Compact Insight Row

struct CompactInsightRow: View {
    let insight: FinancialInsight
    @State private var showDetail = false

    var body: some View {
        Button(action: { showDetail = true }) {
            HStack(spacing: 12) {
                // Priority indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(insight.priority.color)
                    .frame(width: 4, height: 40)

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(insight.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(insight.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Type icon
                Image(systemName: insight.type.icon)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            InsightDetailView(insight: insight)
        }
    }
}

// MARK: - Preview

#Preview("Insights Widget") {
    VStack(spacing: 20) {
        InsightsWidget()
        // InsightsSummaryWidget is defined in InsightsSummaryWidget.swift
    }
    .padding()
    .modelContainer(for: [
        FinancialAccount.self,
        FinancialTransaction.self,
        Budget.self,
<<<<<<< HEAD
        ExpenseCategory.self
=======
        ExpenseCategory.self,
>>>>>>> 1cf3938 (Create working state for recovery)
    ], inMemory: true)
}
