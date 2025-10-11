// Momentum Finance - Insights Widget
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

/// Compact widget showing key financial insights for the dashboard
public struct InsightsWidget: View {
    @StateObject private var intelligenceService = FinancialIntelligenceService.shared
    @Environment(\.modelContext) private var modelContext

    @State private var showAllInsights = false

    private var topInsights: [FinancialInsight] {
        Array(
            self.intelligenceService.insights
                .sorted { $0.priority > $1.priority }
                .prefix(3)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("Financial Insights", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if self.intelligenceService.isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !self.intelligenceService.insights.isEmpty {
                    Button(action: { self.showAllInsights = true }).accessibilityLabel("Button") {
                        Text("View All")
                            .accessibilityLabel("View All Insights")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            // Content
            if self.intelligenceService.isAnalyzing {
                self.loadingContent
            } else if self.topInsights.isEmpty {
                self.emptyContent
            } else {
                self.insightsContent
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .sheet(isPresented: self.$showAllInsights) {
            InsightsView()
        }
        .onAppear {
            Task {
                if self.intelligenceService.insights.isEmpty {
                    await self.intelligenceService.analyzeFinancialData(modelContext: self.modelContext)
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
            ForEach(self.topInsights) { insight in
                CompactInsightRow(insight: insight)
            }

            if self.intelligenceService.insights.count > 3 {
                HStack {
                    Text("\(self.intelligenceService.insights.count - 3) more insights available")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button(action: { self.showAllInsights = true }).accessibilityLabel("Button") {
                        Text("View All")
                            .accessibilityLabel("View All Insights")
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

public struct CompactInsightRow: View {
    let insight: FinancialInsight
    @State private var showDetail = false

    var body: some View {
        Button(action: { self.showDetail = true }).accessibilityLabel("Button") {
            HStack(spacing: 12) {
                // Priority indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(self.insight.priority.color)
                    .frame(width: 4, height: 40)

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(self.insight.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(self.insight.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Type icon
                Image(systemName: self.insight.type.icon)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("View insight details for \(self.insight.title)")
        .sheet(isPresented: self.$showDetail) {
            InsightDetailView(insight: self.insight)
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
    .modelContainer(
        for: [
            FinancialAccount.self,
            FinancialTransaction.self,
            Budget.self,
            ExpenseCategory.self,
        ], inMemory: true
    )
}
