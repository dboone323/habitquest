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
                        self.errorView(message: errorMessage)
                    } else if self.viewModel.isLoading {
                        self.loadingView
                    } else if let data = viewModel.analyticsData {
                        self.timeframePicker
                        StreakAnalyticsOverviewView(data: data, timeframe: self.viewModel.selectedTimeframe)
                        StreakAnalyticsDistributionView(data: data.streakDistribution)
                        StreakAnalyticsTopPerformersView(topPerformers: data.topPerformingHabits)
                        StreakAnalyticsInsightsView(insights: data.consistencyInsights)
                        StreakAnalyticsWeeklyView(patterns: data.weeklyPatterns)
                        self.lastUpdatedView
                    } else {
                        self.emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Streak Analytics")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if self.viewModel.analyticsData != nil {
                        Menu {
                            Button("Export Data", systemImage: "square.and.arrow.up") {
                                Task { await self.viewModel.exportAnalytics() }
                            }
                            .accessibilityLabel("Export Data")

                            Button("Share Report", systemImage: "square.and.arrow.up.fill") {
                                self.viewModel.shareAnalyticsReport()
                            }
                            .accessibilityLabel("Share Report")

                            Divider()

                            Button("Refresh", systemImage: "arrow.clockwise") {
                                Task { await self.viewModel.refreshAnalytics() }
                            }
                            .accessibilityLabel("Refresh")
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .disabled(self.viewModel.isLoading)
                    } else {
                        Button("Refresh") {
                            Task { await self.viewModel.refreshAnalytics() }
                        }
                        .accessibilityLabel("Refresh")
                        .disabled(self.viewModel.isLoading)
                    }
                }
                #else
                ToolbarItem {
                    if self.viewModel.analyticsData != nil {
                        Menu {
                            Button("Export Data", systemImage: "square.and.arrow.up") {
                                Task { await self.viewModel.exportAnalytics() }
                            }
                            .accessibilityLabel("Export Data")

                            Button("Share Report", systemImage: "square.and.arrow.up.fill") {
                                self.viewModel.shareAnalyticsReport()
                            }
                            .accessibilityLabel("Share Report")

                            Divider()

                            Button("Refresh", systemImage: "arrow.clockwise") {
                                Task { await self.viewModel.refreshAnalytics() }
                            }
                            .accessibilityLabel("Refresh")
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .disabled(self.viewModel.isLoading)
                    } else {
                        Button("Refresh") {
                            Task { await self.viewModel.refreshAnalytics() }
                        }
                        .accessibilityLabel("Refresh")
                        .disabled(self.viewModel.isLoading)
                    }
                }
                #endif
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
        Picker("Timeframe", selection: self.$viewModel.selectedTimeframe) {
            ForEach(StreakAnalyticsViewModel.Timeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: self.viewModel.selectedTimeframe) { _, _ in
            Task { await self.viewModel.loadAnalytics() }
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
