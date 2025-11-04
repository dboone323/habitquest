import SwiftData
import SwiftUI

/// Advanced analytics dashboard for streak insights and patterns
public struct StreakAnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: StreakAnalyticsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: StreakAnalyticsViewModel())
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if let errorMessage = viewModel.errorMessage {
                        errorView(message: errorMessage)
                    } else if viewModel.isLoading {
                        loadingView
                    } else if let data = viewModel.analyticsData {
                        timeframePicker
                        StreakAnalyticsOverviewView(data: data, timeframe: viewModel.selectedTimeframe)
                        StreakAnalyticsDistributionView(data: data.streakDistribution)
                        StreakAnalyticsTopPerformersView(topPerformers: data.topPerformingHabits)
                        StreakAnalyticsInsightsView(insights: data.consistencyInsights)
                        StreakAnalyticsWeeklyView(patterns: data.weeklyPatterns)
                        lastUpdatedView
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Streak Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if viewModel.analyticsData != nil {
                        Menu {
                            Button("Export Data", systemImage: "square.and.arrow.up") {
                                Task { await viewModel.exportAnalytics() }
                            }
                            .accessibilityLabel("Export Data")

                            Button("Share Report", systemImage: "square.and.arrow.up.fill") {
                                viewModel.shareAnalyticsReport()
                            }
                            .accessibilityLabel("Share Report")

                            Divider()

                            Button("Refresh", systemImage: "arrow.clockwise") {
                                Task { await viewModel.refreshAnalytics() }
                            }
                            .accessibilityLabel("Refresh")
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .disabled(viewModel.isLoading)
                    } else {
                        Button("Refresh") {
                            Task { await viewModel.refreshAnalytics() }
                        }
                        .accessibilityLabel("Refresh")
                        .disabled(viewModel.isLoading)
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Analyzing your streak patterns...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Analytics Data")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Complete some habits to see your streak analytics")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("Error Loading Analytics")
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }

    private var timeframePicker: some View {
        Picker("Timeframe", selection: $viewModel.selectedTimeframe) {
            ForEach(StreakAnalyticsViewModel.Timeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedTimeframe) { _, _ in
            Task { await viewModel.loadAnalytics() }
        }
    }

    private var lastUpdatedView: some View {
        HStack {
            Spacer()

            Text("Last updated: Just now")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding(.horizontal)
    }
}
