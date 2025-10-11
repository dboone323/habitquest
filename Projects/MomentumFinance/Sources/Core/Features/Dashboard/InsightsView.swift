import Foundation
import Charts
import SwiftData
import SwiftUI

// Momentum Finance - Insights View
// Copyright © 2025 Momentum Finance. All rights reserved.

// Import the canonical financial insight models
/// View that displays financial insights and recommendations
public struct InsightsView: View {
    @StateObject private var intelligenceService = FinancialIntelligenceService.shared
    @Environment(\.modelContext) private var modelContext

    @State private var selectedInsight: FinancialInsight?
    @State private var filterPriority: InsightPriority?
    @State private var filterType: InsightType?

    var body: some View {
        Group {
            #if os(macOS)
            NavigationStack {
                VStack(spacing: 0) {
                    // Filter Bar
                    InsightsFilterBar(
                        filterPriority: self.$filterPriority,
                        filterType: self.$filterType
                    )

                    // Insights Content
                    self.insightsContent
                }
                .navigationTitle("Financial Insights")
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button("Refresh").accessibilityLabel("Button").accessibilityLabel("Button") {
                            Task {
                                await self.intelligenceService.analyzeFinancialData(
                                    modelContext: self.modelContext
                                )
                            }
                        }
                        .disabled(self.intelligenceService.isAnalyzing)
                    }
                }
            }
            #else
            NavigationView {
                VStack(spacing: 0) {
                    // Filter Bar
                    InsightsFilterBar(
                        filterPriority: self.$filterPriority,
                        filterType: self.$filterType
                    )

                    // Insights Content
                    self.insightsContent
                }
                .navigationTitle("Financial Insights")
                .navigationBarItems(
                    trailing:
                    Button("Refresh").accessibilityLabel("Button") {
                        Task {
                            await self.intelligenceService.analyzeFinancialData(
                                modelContext: self.modelContext
                            )
                        }
                    }
                    .disabled(self.intelligenceService.isAnalyzing)
                    .accessibilityLabel("Button")
                )
            }
            #endif
        }
        .sheet(item: self.$selectedInsight) { insight in
            InsightDetailView(insight: insight)
        }
        .onAppear {
            Task {
                if self.intelligenceService.insights.isEmpty {
                    await self.intelligenceService.analyzeFinancialData(modelContext: self.modelContext)
                }
            }
        }
    }

    @ViewBuilder
    private var insightsContent: some View {
        if self.intelligenceService.isAnalyzing {
            InsightsLoadingView()
        } else if self.intelligenceService.insights.isEmpty {
            InsightsEmptyStateView()
        } else {
            self.insightsList
        }
    }

    private var insightsList: some View {
        List {
            ForEach(self.filteredInsights) { insight in
                InsightRowView(insight: insight) {
                    self.selectedInsight = insight
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    private var filteredInsights: [FinancialInsight] {
        self.intelligenceService.insights
            .filter { insight in
                if let priority = filterPriority, insight.priority != priority {
                    return false
                }
                if let type = filterType, insight.type != type {
                    return false
                }
                return true
            }
            .sorted { $0.priority > $1.priority } // Sort by priority (critical first)
    }
}

// MARK: - Preview

#Preview {
    InsightsView()
        .modelContainer(
            for: [
                FinancialAccount.self,
                FinancialTransaction.self,
                Budget.self,
                ExpenseCategory.self,
            ], inMemory: true
        )
}
