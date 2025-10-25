//
//  DependencyMonitor.swift
//  Predictive Dependencies
//
//  Real-time monitoring and alerting system for dependency changes,
//  violations, and predictive insights.
//

import Combine
import Foundation
import SwiftUI

/// Real-time dependency monitoring and alerting system
@available(macOS 12.0, *)
public class DependencyMonitor: ObservableObject {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private var monitoringQueue = DispatchQueue(
        label: "com.quantum.dependency-monitor", qos: .background
    )

    /// Published properties for SwiftUI
    @Published public var alerts: [DependencyAlert] = []
    @Published public var metrics: DependencyMetrics?
    @Published public var isMonitoringActive: Bool = false

    /// Monitoring configuration
    public struct MonitoringConfig {
        public var monitoringInterval: TimeInterval = 30.0 // seconds
        public var enableRealTimeAlerts: Bool = true
        public var alertThresholds: AlertThresholds = .init()
        public var notificationEnabled: Bool = true
        public var maxStoredAlerts: Int = 1000

        public init() {}
    }

    public struct AlertThresholds {
        public var circularDependencyThreshold: Int = 0
        public var highCouplingThreshold: Int = 10
        public var stabilityThreshold: Double = 0.7
        public var predictionConfidenceThreshold: Double = 0.8

        public init() {}
    }

    private var config: MonitoringConfig
    private var analyzer: DependencyAnalyzer?
    private var predictor: DependencyPredictor?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // Historical data for trend analysis
    private var historicalMetrics: [Date: DependencyMetrics] = [:]
    private var baselineMetrics: DependencyMetrics?

    // MARK: - Initialization

    public init(config: MonitoringConfig = MonitoringConfig()) {
        self.config = config
        setupNotifications()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public API

    /// Start monitoring with analyzer and predictor
    public func startMonitoring(
        analyzer: DependencyAnalyzer, predictor: DependencyPredictor, projectPath: String
    ) {
        self.analyzer = analyzer
        self.predictor = predictor

        isMonitoringActive = true

        // Initial analysis
        performMonitoringCycle(for: projectPath)

        // Start timer for periodic monitoring
        timer = Timer.scheduledTimer(withTimeInterval: config.monitoringInterval, repeats: true) {
            [weak self] _ in
            self?.performMonitoringCycle(for: projectPath)
        }
    }

    /// Stop monitoring
    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoringActive = false
    }

    /// Manually trigger monitoring cycle
    public func triggerMonitoringCycle(for projectPath: String) {
        performMonitoringCycle(for: projectPath)
    }

    /// Get monitoring status
    public func getMonitoringStatus() -> MonitoringStatus {
        let activeAlerts = alerts.filter { !$0.isResolved }
        let recentAlerts = alerts.filter { Date().timeIntervalSince($0.timestamp) < 3600 } // Last hour

        return MonitoringStatus(
            isActive: isMonitoringActive,
            activeAlerts: activeAlerts.count,
            recentAlerts: recentAlerts.count,
            totalAlerts: alerts.count,
            lastUpdate: Date(),
            monitoringInterval: config.monitoringInterval
        )
    }

    /// Clear resolved alerts
    public func clearResolvedAlerts() {
        alerts = alerts.filter { !$0.isResolved }
    }

    /// Get alert trends
    public func getAlertTrends(hours: Int = 24) -> AlertTrends {
        let cutoffDate = Date().addingTimeInterval(-Double(hours) * 3600)
        let recentAlerts = alerts.filter { $0.timestamp > cutoffDate }

        let alertsByType = Dictionary(grouping: recentAlerts, by: { $0.type })
        let trendsByType = alertsByType.mapValues { alerts in
            let resolved = alerts.filter(\.isResolved).count
            let unresolved = alerts.filter { !$0.isResolved }.count
            return AlertTypeTrend(count: alerts.count, resolved: resolved, unresolved: unresolved)
        }

        return AlertTrends(
            periodHours: hours,
            totalAlerts: recentAlerts.count,
            trendsByType: trendsByType,
            generatedAt: Date()
        )
    }

    /// Export monitoring data
    public func exportMonitoringData(to path: String) throws {
        let exportData = MonitoringExportData(
            alerts: alerts,
            historicalMetrics: historicalMetrics,
            baselineMetrics: baselineMetrics,
            monitoringStatus: getMonitoringStatus(),
            exportTimestamp: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(exportData)

        try data.write(to: URL(fileURLWithPath: path))
    }

    /// Configure monitoring settings
    public func updateConfiguration(_ newConfig: MonitoringConfig) {
        config = newConfig
        if isMonitoringActive {
            // Restart monitoring with new config
            let wasActive = isMonitoringActive
            stopMonitoring()
            if wasActive {
                // Note: Would need to restart with project path
                // This is a simplified version
            }
        }
    }

    // MARK: - Private Methods

    private func performMonitoringCycle(for projectPath: String) {
        guard let analyzer else { return }

        Task {
            do {
                // Analyze current project state
                let project = try await analyzer.analyzeProject(at: projectPath)
                let metrics = analyzer.getDependencyMetrics(for: project)

                await MainActor.run {
                    self.metrics = metrics
                }

                // Store historical data
                historicalMetrics[Date()] = metrics

                // Set baseline if not set
                if baselineMetrics == nil {
                    baselineMetrics = metrics
                }

                // Check for alerts
                let newAlerts = try await checkForAlerts(project: project, metrics: metrics)

                await MainActor.run {
                    self.alerts.append(contentsOf: newAlerts)
                    self.pruneOldAlerts()
                }

                // Send notifications for critical alerts
                if config.notificationEnabled {
                    sendNotifications(for: newAlerts.filter { $0.severity == .critical })
                }

            } catch {
                print("Monitoring cycle failed: \(error)")
                let errorAlert = DependencyAlert(
                    id: UUID(),
                    type: .monitoringError,
                    title: "Monitoring Error",
                    message: "Failed to perform monitoring cycle: \(error.localizedDescription)",
                    severity: .high,
                    affectedFiles: [],
                    suggestedActions: ["Check project configuration", "Verify file permissions"],
                    timestamp: Date(),
                    isResolved: false
                )

                await MainActor.run {
                    self.alerts.append(errorAlert)
                }
            }
        }
    }

    private func checkForAlerts(project: ProjectDependencies, metrics: DependencyMetrics)
        async throws -> [DependencyAlert]
    {
        var newAlerts: [DependencyAlert] = []

        // Check for circular dependencies
        if !project.circularDependencies.isEmpty
            && project.circularDependencies.count
            > config.alertThresholds.circularDependencyThreshold
        {
            let alert = DependencyAlert(
                id: UUID(),
                type: .circularDependency,
                title: "Circular Dependencies Detected",
                message: "Found \(project.circularDependencies.count) circular dependency cycles",
                severity: .high,
                affectedFiles: project.circularDependencies.flatMap { $0 },
                suggestedActions: [
                    "Review dependency cycles",
                    "Consider introducing abstractions",
                    "Apply dependency inversion principle",
                ],
                timestamp: Date(),
                isResolved: false
            )
            newAlerts.append(alert)
        }

        // Check for high coupling
        let overCoupledFiles = project.fileDependencies.filter {
            $0.value.dependencyCount > config.alertThresholds.highCouplingThreshold
        }
        if !overCoupledFiles.isEmpty {
            let alert = DependencyAlert(
                id: UUID(),
                type: .highCoupling,
                title: "High Coupling Detected",
                message: "Found \(overCoupledFiles.count) files with high dependency counts",
                severity: .medium,
                affectedFiles: Array(overCoupledFiles.keys),
                suggestedActions: [
                    "Consider breaking down complex files",
                    "Extract common functionality",
                    "Apply single responsibility principle",
                ],
                timestamp: Date(),
                isResolved: false
            )
            newAlerts.append(alert)
        }

        // Check stability degradation
        if let baseline = baselineMetrics,
           metrics.stabilityIndex < config.alertThresholds.stabilityThreshold
        {
            let degradation = baseline.stabilityIndex - metrics.stabilityIndex
            let alert = DependencyAlert(
                id: UUID(),
                type: .stabilityDegradation,
                title: "Stability Degradation",
                message: String(
                    format: "Stability index decreased by %.2f (current: %.2f)", degradation,
                    metrics.stabilityIndex
                ),
                severity: degradation > 0.2 ? .high : .medium,
                affectedFiles: [],
                suggestedActions: [
                    "Review recent changes",
                    "Consider reverting unstable changes",
                    "Improve test coverage",
                ],
                timestamp: Date(),
                isResolved: false
            )
            newAlerts.append(alert)
        }

        // Check for prediction opportunities
        if let predictor {
            let context = PredictionContext(projectSize: project.fileDependencies.count)
            let predictions = try await predictor.predictProjectDependencies(
                for: project, context: context
            )

            let highConfidencePredictions = predictions.values.flatMap { $0 }.filter {
                $0.confidence > config.alertThresholds.predictionConfidenceThreshold
            }

            if !highConfidencePredictions.isEmpty {
                let alert = DependencyAlert(
                    id: UUID(),
                    type: .predictionOpportunity,
                    title: "Dependency Prediction Opportunity",
                    message:
                    "Found \(highConfidencePredictions.count) high-confidence dependency predictions",
                    severity: .low,
                    affectedFiles: [],
                    suggestedActions: [
                        "Review dependency predictions",
                        "Consider adding predicted dependencies",
                        "Update dependency management strategy",
                    ],
                    timestamp: Date(),
                    isResolved: false
                )
                newAlerts.append(alert)
            }
        }

        // Check for trend anomalies
        let trendAlerts = checkTrendAnomalies()
        newAlerts.append(contentsOf: trendAlerts)

        return newAlerts
    }

    private func checkTrendAnomalies() -> [DependencyAlert] {
        var alerts: [DependencyAlert] = []

        // Check for sudden spikes in dependencies
        let recentMetrics = historicalMetrics.sorted(by: { $0.key > $1.key }).prefix(10)

        if recentMetrics.count >= 2 {
            let latest = recentMetrics.first!.value
            let previous = recentMetrics.dropFirst().first!.value

            let dependencyIncrease =
                Double(latest.totalDependencies) / Double(max(previous.totalDependencies, 1)) - 1.0

            if dependencyIncrease > 0.5 { // 50% increase
                let alert = DependencyAlert(
                    id: UUID(),
                    type: .dependencySpike,
                    title: "Dependency Spike Detected",
                    message: String(
                        format: "Dependencies increased by %.1f%% in recent monitoring cycle",
                        dependencyIncrease * 100
                    ),
                    severity: .medium,
                    affectedFiles: [],
                    suggestedActions: [
                        "Review recent code changes",
                        "Consider refactoring to reduce dependencies",
                        "Update dependency documentation",
                    ],
                    timestamp: Date(),
                    isResolved: false
                )
                alerts.append(alert)
            }
        }

        return alerts
    }

    private func pruneOldAlerts() {
        // Keep only the most recent alerts
        if alerts.count > config.maxStoredAlerts {
            alerts = Array(
                alerts.sorted(by: { $0.timestamp > $1.timestamp }).prefix(config.maxStoredAlerts))
        }

        // Mark old alerts as resolved if they're older than a week
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 3600)
        for index in alerts.indices {
            if alerts[index].timestamp < weekAgo && !alerts[index].isResolved {
                alerts[index].isResolved = true
            }
        }
    }

    private func setupNotifications() {
        // Set up notification center for system notifications
        // This would integrate with NSUserNotificationCenter on macOS
    }

    private func sendNotifications(for alerts: [DependencyAlert]) {
        for alert in alerts {
            // Send system notification
            print("🚨 CRITICAL ALERT: \(alert.title) - \(alert.message)")
            // In a real implementation, this would use NSUserNotificationCenter
        }
    }
}

// MARK: - Supporting Types

/// Dependency alert
public struct DependencyAlert: Identifiable, Codable {
    public let id: UUID
    public let type: AlertType
    public let title: String
    public let message: String
    public let severity: AlertSeverity
    public let affectedFiles: [String]
    public let suggestedActions: [String]
    public let timestamp: Date
    public var isResolved: Bool

    public enum AlertType: String, Codable {
        case circularDependency
        case highCoupling
        case stabilityDegradation
        case predictionOpportunity
        case dependencySpike
        case monitoringError
    }

    public enum AlertSeverity: String, Codable {
        case low, medium, high, critical
    }
}

/// Monitoring status
public struct MonitoringStatus: Codable {
    public let isActive: Bool
    public let activeAlerts: Int
    public let recentAlerts: Int
    public let totalAlerts: Int
    public let lastUpdate: Date
    public let monitoringInterval: TimeInterval
}

/// Alert trends
public struct AlertTrends: Codable {
    public let periodHours: Int
    public let totalAlerts: Int
    public let trendsByType: [DependencyAlert.AlertType: AlertTypeTrend]
    public let generatedAt: Date
}

/// Alert type trend
public struct AlertTypeTrend: Codable {
    public let count: Int
    public let resolved: Int
    public let unresolved: Int
}

/// Monitoring export data
public struct MonitoringExportData: Codable {
    public let alerts: [DependencyAlert]
    public let historicalMetrics: [Date: DependencyMetrics]
    public let baselineMetrics: DependencyMetrics?
    public let monitoringStatus: MonitoringStatus
    public let exportTimestamp: Date

    private enum CodingKeys: String, CodingKey {
        case alerts, historicalMetrics, baselineMetrics, monitoringStatus, exportTimestamp
    }

    public init(
        alerts: [DependencyAlert], historicalMetrics: [Date: DependencyMetrics],
        baselineMetrics: DependencyMetrics?, monitoringStatus: MonitoringStatus,
        exportTimestamp: Date
    ) {
        self.alerts = alerts
        self.historicalMetrics = historicalMetrics
        self.baselineMetrics = baselineMetrics
        self.monitoringStatus = monitoringStatus
        self.exportTimestamp = exportTimestamp
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alerts = try container.decode([DependencyAlert].self, forKey: .alerts)
        baselineMetrics = try container.decodeIfPresent(
            DependencyMetrics.self, forKey: .baselineMetrics
        )
        monitoringStatus = try container.decode(MonitoringStatus.self, forKey: .monitoringStatus)
        exportTimestamp = try container.decode(Date.self, forKey: .exportTimestamp)

        // Handle date-keyed dictionary
        let metricsContainer = try container.nestedContainer(
            keyedBy: DateCodingKey.self, forKey: .historicalMetrics
        )
        var metrics: [Date: DependencyMetrics] = [:]
        for key in metricsContainer.allKeys {
            let metric = try metricsContainer.decode(DependencyMetrics.self, forKey: key)
            metrics[key.date] = metric
        }
        historicalMetrics = metrics
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alerts, forKey: .alerts)
        try container.encode(baselineMetrics, forKey: .baselineMetrics)
        try container.encode(monitoringStatus, forKey: .monitoringStatus)
        try container.encode(exportTimestamp, forKey: .exportTimestamp)

        var metricsContainer = container.nestedContainer(
            keyedBy: DateCodingKey.self, forKey: .historicalMetrics
        )
        for (date, metric) in historicalMetrics {
            try metricsContainer.encode(metric, forKey: DateCodingKey(date: date))
        }
    }
}

/// Date coding key for dictionary encoding
private struct DateCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    let date: Date

    init(date: Date) {
        self.date = date
        self.stringValue = ISO8601DateFormatter().string(from: date)
    }

    init(stringValue: String) {
        self.stringValue = stringValue
        self.date = ISO8601DateFormatter().date(from: stringValue) ?? Date()
    }

    init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
        self.date = Date()
    }
}

// MARK: - SwiftUI Views

/// Monitoring dashboard view
@available(macOS 12.0, *)
public struct MonitoringDashboardView: View {
    @ObservedObject var monitor: DependencyMonitor

    @State private var selectedTimeRange = 24
    @State private var showResolvedAlerts = false

    var body: some View {
        VStack {
            HStack {
                Text("Dependency Monitor")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                HStack {
                    Circle()
                        .fill(monitor.isMonitoringActive ? Color.green : Color.red)
                        .frame(width: 12, height: 12)

                    Text(monitor.isMonitoringActive ? "Active" : "Inactive")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            // Status cards
            let status = monitor.getMonitoringStatus()
            HStack(spacing: 16) {
                StatusCardView(title: "Active Alerts", value: "\(status.activeAlerts)", color: .red)
                StatusCardView(
                    title: "Recent Alerts", value: "\(status.recentAlerts)", color: .orange
                )
                StatusCardView(title: "Total Alerts", value: "\(status.totalAlerts)", color: .blue)
                StatusCardView(
                    title: "Interval", value: "\(Int(status.monitoringInterval))s", color: .green
                )
            }
            .padding(.horizontal)

            // Controls
            HStack {
                Picker("Time Range", selection: $selectedTimeRange) {
                    Text("1 Hour").tag(1)
                    Text("24 Hours").tag(24)
                    Text("7 Days").tag(168)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)

                Toggle("Show Resolved", isOn: $showResolvedAlerts)
                    .toggleStyle(.switch)

                Spacer()

                Button("Clear Resolved") {
                    monitor.clearResolvedAlerts()
                }
                .disabled(monitor.alerts.filter(\.isResolved).isEmpty)
            }
            .padding(.horizontal)

            // Alerts list
            let filteredAlerts = monitor.alerts.filter { showResolvedAlerts || !$0.isResolved }
                .filter {
                    Date().timeIntervalSince($0.timestamp) < Double(selectedTimeRange) * 3600
                }
                .sorted(by: { $0.timestamp > $1.timestamp })

            List(filteredAlerts) { alert in
                AlertRowView(alert: alert)
                    .onTapGesture {
                        // Could show alert details
                    }
            }
            .frame(height: 300)

            // Trends
            let trends = monitor.getAlertTrends(hours: selectedTimeRange)
            AlertTrendsView(trends: trends)
        }
        .frame(minWidth: 600, minHeight: 500)
    }
}

/// Status card view
@available(macOS 12.0, *)
struct StatusCardView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

/// Alert row view
@available(macOS 12.0, *)
struct AlertRowView: View {
    let alert: DependencyAlert

    var body: some View {
        HStack {
            Circle()
                .fill(severityColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading) {
                Text(alert.title)
                    .font(.headline)

                Text(alert.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Text(alert.type.rawValue.capitalized)
                        .font(.caption)
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)

                    Text(alert.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if alert.isResolved {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }

    private var severityColor: Color {
        switch alert.severity {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

/// Alert trends view
@available(macOS 12.0, *)
struct AlertTrendsView: View {
    let trends: AlertTrends

    var body: some View {
        VStack(alignment: .leading) {
            Text("Alert Trends (\(trends.periodHours) hours)")
                .font(.headline)
                .padding(.bottom, 8)

            if trends.trendsByType.isEmpty {
                Text("No alerts in selected period")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(
                    trends.trendsByType.sorted(by: { $0.value.count > $1.value.count }), id: \.key
                ) { type, trend in
                    HStack {
                        Text(type.rawValue.capitalized)
                            .frame(width: 150, alignment: .leading)

                        HStack(spacing: 4) {
                            Text("Total: \(trend.count)")
                            Text("Resolved: \(trend.resolved)")
                                .foregroundColor(.green)
                            Text("Unresolved: \(trend.unresolved)")
                                .foregroundColor(.red)
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Extensions

extension DependencyAlert: Equatable {
    public static func == (lhs: DependencyAlert, rhs: DependencyAlert) -> Bool {
        lhs.id == rhs.id
    }
}

extension DependencyAlert: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension MonitoringStatus: CustomStringConvertible {
    public var description: String {
        """
        Monitoring Status:
        - Active: \(isActive)
        - Active Alerts: \(activeAlerts)
        - Recent Alerts: \(recentAlerts)
        - Total Alerts: \(totalAlerts)
        - Last Update: \(lastUpdate.formatted())
        - Interval: \(monitoringInterval)s
        """
    }
}

extension AlertTrends: CustomStringConvertible {
    public var description: String {
        """
        Alert Trends (\(periodHours) hours):
        - Total Alerts: \(totalAlerts)
        - Types: \(trendsByType.count)
        """
    }
}
