//
//  MetricsDashboard.swift
//  Code Metrics Dashboard
//
//  Real-time visualization and monitoring dashboard for code metrics,
//  providing interactive charts, alerts, and trend analysis.
//

import Charts
import Combine
import Foundation
import SwiftUI

/// Interactive metrics dashboard with real-time visualization
@available(macOS 12.0, *)
public struct MetricsDashboard: View {

    // MARK: - Properties

    @StateObject private var viewModel: MetricsDashboardViewModel
    @State private var selectedTimeRange: TimeRange = .last24Hours
    @State private var selectedMetricType: MetricType = .complexity
    @State private var showAlerts = true
    @State private var autoRefresh = true

    /// Time range for metrics display
    public enum TimeRange: String, CaseIterable {
        case lastHour = "Last Hour"
        case last24Hours = "Last 24 Hours"
        case lastWeek = "Last Week"
        case lastMonth = "Last Month"
        case allTime = "All Time"
    }

    /// Metric type for detailed analysis
    public enum MetricType: String, CaseIterable {
        case complexity = "Complexity"
        case coverage = "Coverage"
        case performance = "Performance"
        case quality = "Quality"
        case size = "Size"
    }

    // MARK: - Initialization

    public init(collector: MetricsCollector) {
        _viewModel = StateObject(wrappedValue: MetricsDashboardViewModel(collector: collector))
    }

    // MARK: - Body

    public var body: some View {
        NavigationView {
            sidebar
            mainContent
        }
        .navigationTitle("Code Metrics Dashboard")
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.menu)

                Toggle("Auto Refresh", isOn: $autoRefresh)
                    .toggleStyle(.switch)

                Button(action: { viewModel.refreshMetrics() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh Metrics")
            }
        }
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
        .onChange(of: selectedTimeRange) { _ in
            viewModel.updateTimeRange(selectedTimeRange)
        }
        .onChange(of: autoRefresh) { newValue in
            if newValue {
                viewModel.startAutoRefresh()
            } else {
                viewModel.stopAutoRefresh()
            }
        }
    }

    // MARK: - Subviews

    private var sidebar: some View {
        List {
            Section("Overview") {
                MetricCard(
                    title: "Total Files",
                    value: "\(viewModel.aggregateMetrics.totalFiles)",
                    trend: viewModel.calculateTrend(for: \.totalFiles),
                    icon: "doc.on.doc"
                )

                MetricCard(
                    title: "Lines of Code",
                    value: "\(viewModel.aggregateMetrics.totalLinesOfCode)",
                    trend: viewModel.calculateTrend(for: \.totalLinesOfCode),
                    icon: "text.alignleft"
                )

                MetricCard(
                    title: "Complexity Score",
                    value: String(format: "%.2f", viewModel.aggregateMetrics.complexityScore),
                    trend: viewModel.calculateComplexityTrend(),
                    icon: "brain",
                    color: colorForScore(viewModel.aggregateMetrics.complexityScore)
                )

                MetricCard(
                    title: "Maintainability",
                    value: String(format: "%.2f", viewModel.aggregateMetrics.maintainabilityScore),
                    trend: viewModel.calculateMaintainabilityTrend(),
                    icon: "wrench.and.screwdriver",
                    color: colorForScore(viewModel.aggregateMetrics.maintainabilityScore)
                )
            }

            Section("Alerts") {
                if showAlerts {
                    ForEach(viewModel.activeAlerts) { alert in
                        AlertRow(alert: alert)
                    }
                }

                Button(action: { showAlerts.toggle() }) {
                    Label(
                        showAlerts ? "Hide Alerts" : "Show Alerts",
                        systemImage: showAlerts ? "eye.slash" : "eye"
                    )
                }
            }

            Section("Hotspots") {
                NavigationLink(destination: ComplexityHotspotsView(viewModel: viewModel)) {
                    Label("Complexity Hotspots", systemImage: "flame")
                        .badge(viewModel.aggregateMetrics.complexityHotspots.count)
                }

                NavigationLink(destination: LargeFilesView(viewModel: viewModel)) {
                    Label("Large Files", systemImage: "doc.text")
                        .badge(viewModel.aggregateMetrics.largeFiles.count)
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 250)
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Metric selector
            Picker("Metric Type", selection: $selectedMetricType) {
                ForEach(MetricType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Main chart area
            ScrollView {
                VStack(spacing: 20) {
                    mainChart
                    detailedMetrics
                    trendAnalysis
                }
                .padding()
            }
        }
    }

    private var mainChart: some View {
        VStack(alignment: .leading) {
            Text("Metrics Over Time")
                .font(.title2)
                .bold()

            Chart {
                ForEach(viewModel.chartData) { dataPoint in
                    LineMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value("Value", dataPoint.value)
                    )
                    .foregroundStyle(by: .value("Metric", dataPoint.metric))
                }
            }
            .frame(height: 300)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour))
            }
            .chartYAxis {
                AxisMarks()
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 2)
    }

    private var detailedMetrics: some View {
        VStack(alignment: .leading) {
            Text("Detailed Analysis")
                .font(.title2)
                .bold()

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                ForEach(viewModel.detailedMetrics) { metric in
                    DetailedMetricCard(metric: metric)
                }
            }
        }
    }

    private var trendAnalysis: some View {
        VStack(alignment: .leading) {
            Text("Trend Analysis")
                .font(.title2)
                .bold()

            HStack(spacing: 20) {
                TrendIndicator(
                    title: "Complexity Trend",
                    trend: viewModel.calculateComplexityTrend(),
                    description: "7-day average"
                )

                TrendIndicator(
                    title: "File Growth",
                    trend: viewModel.calculateFileGrowthTrend(),
                    description: "Files added/removed"
                )

                TrendIndicator(
                    title: "Quality Score",
                    trend: viewModel.calculateQualityTrend(),
                    description: "Overall quality"
                )
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 2)
    }

    // MARK: - Helper Methods

    private func colorForScore(_ score: Double) -> Color {
        switch score {
        case 0.8...: return .green
        case 0.6 ..< 0.8: return .yellow
        case 0.4 ..< 0.6: return .orange
        default: return .red
        }
    }
}

// MARK: - Supporting Views

/// Metric card for sidebar
struct MetricCard: View {
    let title: String
    let value: String
    let trend: Double?
    let icon: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.title3)
                    .bold()
            }

            Spacer()

            if let trend {
                TrendArrow(trend: trend)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Trend arrow indicator
struct TrendArrow: View {
    let trend: Double

    var body: some View {
        Image(systemName: trend > 0 ? "arrow.up" : trend < 0 ? "arrow.down" : "minus")
            .foregroundColor(trend > 0 ? .red : trend < 0 ? .green : .secondary)
            .font(.caption)
    }
}

/// Alert row
struct AlertRow: View {
    let alert: MetricAlert

    var body: some View {
        HStack {
            Image(systemName: alert.severity.icon)
                .foregroundColor(alert.severity.color)

            VStack(alignment: .leading) {
                Text(alert.title)
                    .font(.caption)
                    .bold()

                Text(alert.message)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Text(alert.timestamp, style: .relative)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

/// Detailed metric card
struct DetailedMetricCard: View {
    let metric: DetailedMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(metric.title)
                .font(.headline)

            Text(String(format: "%.2f", metric.value))
                .font(.title)
                .bold()

            if let change = metric.change {
                HStack {
                    Image(systemName: change > 0 ? "arrow.up" : "arrow.down")
                    Text(String(format: "%.1f%%", abs(change)))
                        .font(.caption)
                }
                .foregroundColor(change > 0 ? .red : .green)
            }

            Text(metric.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

/// Trend indicator
struct TrendIndicator: View {
    let title: String
    let trend: Double?
    let description: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)

            if let trend {
                HStack {
                    Text(String(format: "%.1f%%", trend))
                        .font(.title2)
                        .bold()
                        .foregroundColor(trend > 0 ? .red : trend < 0 ? .green : .secondary)

                    TrendArrow(trend: trend)
                }
            } else {
                Text("--")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Complexity hotspots view
struct ComplexityHotspotsView: View {
    @ObservedObject var viewModel: MetricsDashboardViewModel

    var body: some View {
        List(viewModel.aggregateMetrics.complexityHotspots, id: \.self) { filePath in
            VStack(alignment: .leading) {
                Text(URL(fileURLWithPath: filePath).lastPathComponent)
                    .font(.headline)

                Text(filePath)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let metrics = viewModel.getMetrics(for: filePath) {
                    Text("Complexity: \(String(format: "%.1f", metrics.averageComplexity))")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .navigationTitle("Complexity Hotspots")
    }
}

/// Large files view
struct LargeFilesView: View {
    @ObservedObject var viewModel: MetricsDashboardViewModel

    var body: some View {
        List(viewModel.aggregateMetrics.largeFiles, id: \.self) { filePath in
            VStack(alignment: .leading) {
                Text(URL(fileURLWithPath: filePath).lastPathComponent)
                    .font(.headline)

                Text(filePath)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let metrics = viewModel.getMetrics(for: filePath) {
                    Text("\(metrics.linesOfCode) lines")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Large Files")
    }
}

// MARK: - View Model

@available(macOS 12.0, *)
class MetricsDashboardViewModel: ObservableObject {

    // MARK: - Properties

    private let collector: MetricsCollector
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?

    @Published var aggregateMetrics = AggregateMetrics.empty
    @Published var activeAlerts: [MetricAlert] = []
    @Published var chartData: [ChartDataPoint] = []
    @Published var detailedMetrics: [DetailedMetric] = []

    private var historicalData: [Date: AggregateMetrics] = [:]

    // MARK: - Initialization

    init(collector: MetricsCollector) {
        self.collector = collector
        setupInitialData()
    }

    deinit {
        stopAutoRefresh()
    }

    // MARK: - Public Methods

    func startMonitoring() {
        // Set up real-time updates
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshMetrics()
            }
            .store(in: &cancellables)
    }

    func stopMonitoring() {
        cancellables.removeAll()
    }

    func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refreshMetrics()
        }
    }

    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func refreshMetrics() {
        aggregateMetrics = collector.getAggregateMetrics()
        updateChartData()
        updateDetailedMetrics()
        checkForAlerts()
        storeHistoricalData()
    }

    func updateTimeRange(_ timeRange: MetricsDashboard.TimeRange) {
        // Update chart data based on time range
        updateChartData()
    }

    func getMetrics(for filePath: String) -> CodeMetrics? {
        collector.getMetrics(for: filePath)
    }

    // MARK: - Trend Calculations

    func calculateTrend(for keyPath: KeyPath<AggregateMetrics, Int>) -> Double? {
        let values = Array(
            historicalData.values.sorted(by: { $0.analysisTimestamp < $1.analysisTimestamp })
        )
        .suffix(10) // Last 10 data points
        .map { Double($0[keyPath: keyPath]) }

        guard values.count >= 2 else { return nil }

        let recent = values.suffix(5).reduce(0, +) / Double(values.suffix(5).count)
        let previous =
            values.prefix(values.count - 5).reduce(0, +)
                / Double(values.prefix(values.count - 5).count)

        if previous == 0 { return nil }

        return ((recent - previous) / previous) * 100
    }

    func calculateComplexityTrend() -> Double? {
        calculateTrend(for: \.totalFunctions) // Simplified - would use actual complexity data
    }

    func calculateMaintainabilityTrend() -> Double? {
        // Would calculate based on maintainability score history
        nil // Placeholder
    }

    func calculateFileGrowthTrend() -> Double? {
        calculateTrend(for: \.totalFiles)
    }

    func calculateQualityTrend() -> Double? {
        // Would calculate based on quality metrics history
        nil // Placeholder
    }

    // MARK: - Private Methods

    private func setupInitialData() {
        refreshMetrics()
    }

    private func updateChartData() {
        // Generate chart data from historical metrics
        chartData = historicalData.map { timestamp, metrics in
            ChartDataPoint(
                timestamp: timestamp,
                metric: "Complexity",
                value: metrics.averageComplexity
            )
        }.sorted(by: { $0.timestamp < $1.timestamp })
    }

    private func updateDetailedMetrics() {
        detailedMetrics = [
            DetailedMetric(
                title: "Average Complexity",
                value: aggregateMetrics.averageComplexity,
                change: calculateComplexityTrend(),
                description: "Cyclomatic complexity per function"
            ),
            DetailedMetric(
                title: "Code Coverage",
                value: aggregateMetrics.coverageScore * 100,
                change: nil, // Would calculate from coverage history
                description: "Test coverage percentage"
            ),
            DetailedMetric(
                title: "Lines per Function",
                value: aggregateMetrics.averageLinesPerFunction,
                change: calculateTrend(for: \.totalLinesOfCode),
                description: "Average function size"
            ),
        ]
    }

    private func checkForAlerts() {
        var alerts: [MetricAlert] = []

        // Complexity alerts
        if aggregateMetrics.complexityScore < 0.5 {
            alerts.append(
                MetricAlert(
                    id: UUID(),
                    title: "High Complexity",
                    message: "Code complexity score is below acceptable threshold",
                    severity: .high,
                    timestamp: Date()
                ))
        }

        // Large files alert
        if aggregateMetrics.largeFiles.count > 5 {
            alerts.append(
                MetricAlert(
                    id: UUID(),
                    title: "Large Files Detected",
                    message: "\(aggregateMetrics.largeFiles.count) files exceed size limits",
                    severity: .medium,
                    timestamp: Date()
                ))
        }

        // Complexity hotspots alert
        if aggregateMetrics.complexityHotspots.count > 3 {
            alerts.append(
                MetricAlert(
                    id: UUID(),
                    title: "Complexity Hotspots",
                    message:
                    "\(aggregateMetrics.complexityHotspots.count) files have high complexity",
                    severity: .medium,
                    timestamp: Date()
                ))
        }

        activeAlerts = alerts
    }

    private func storeHistoricalData() {
        historicalData[Date()] = aggregateMetrics

        // Limit historical data to last 100 entries
        if historicalData.count > 100 {
            let sortedKeys = historicalData.keys.sorted()
            let keysToRemove = sortedKeys.prefix(historicalData.count - 100)
            for key in keysToRemove {
                historicalData.removeValue(forKey: key)
            }
        }
    }
}

// MARK: - Supporting Types

/// Chart data point
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let metric: String
    let value: Double
}

/// Detailed metric for display
struct DetailedMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: Double
    let change: Double?
    let description: String
}

/// Metric alert
struct MetricAlert: Identifiable {
    let id: UUID
    let title: String
    let message: String
    let severity: AlertSeverity
    let timestamp: Date

    enum AlertSeverity {
        case low, medium, high, critical

        var icon: String {
            switch self {
            case .low: return "info.circle"
            case .medium: return "exclamationmark.triangle"
            case .high: return "exclamationmark.triangle.fill"
            case .critical: return "exclamationmark.octagon.fill"
            }
        }

        var color: Color {
            switch self {
            case .low: return .blue
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }
}

// MARK: - Preview

struct MetricsDashboard_Previews: PreviewProvider {
    static var previews: some View {
        // Would need a mock collector for preview
        Text("Metrics Dashboard Preview")
    }
}
