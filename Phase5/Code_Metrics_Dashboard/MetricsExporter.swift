//
//  MetricsExporter.swift
//  Code Metrics Dashboard
//
//  Comprehensive metrics export system supporting multiple formats
//  and integration with external monitoring and reporting tools.
//

import Charts
import Foundation
import SwiftUI

/// Comprehensive metrics exporter with multiple format support
@available(macOS 12.0, *)
public class MetricsExporter {

    // MARK: - Properties

    private let collector: MetricsCollector
    private let analysisEngine: MetricsAnalysisEngine
    private var exportQueue = DispatchQueue(label: "com.quantum.metrics-export", qos: .utility)

    /// Export configuration
    public struct Configuration {
        public var defaultFormat: ExportFormat = .json
        public var includeHistoricalData: Bool = true
        public var maxHistoricalPoints: Int = 100
        public var compressionEnabled: Bool = true
        public var exportDirectory: URL?

        public init() {
            exportDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("MetricsExports")
        }
    }

    private var config: Configuration

    // MARK: - Initialization

    public init(
        collector: MetricsCollector, analysisEngine: MetricsAnalysisEngine,
        configuration: Configuration = Configuration()
    ) {
        self.collector = collector
        self.analysisEngine = analysisEngine
        self.config = configuration

        // Create export directory if needed
        if let directory = config.exportDirectory {
            try? FileManager.default.createDirectory(
                at: directory, withIntermediateDirectories: true
            )
        }
    }

    // MARK: - Public API

    /// Export current metrics in specified format
    public func exportCurrentMetrics(format: ExportFormat = .json, filename: String? = nil)
        async throws -> URL
    {
        let metrics = collector.getAggregateMetrics()
        let analysis = try await analysisEngine.performAnalysis()

        let exportData = ExportData(
            timestamp: Date(),
            metrics: metrics,
            analysis: analysis,
            historicalData: config.includeHistoricalData ? getHistoricalData() : nil
        )

        return try await exportQueue.sync {
            try exportDataToFile(exportData, format: format, filename: filename)
        }
    }

    /// Export metrics dashboard as image
    public func exportDashboardImage(
        dashboard: MetricsDashboard, size: CGSize = CGSize(width: 1200, height: 800)
    ) async throws -> URL {
        // This would capture the SwiftUI view as an image
        // For now, return a placeholder
        throw ExportError.featureNotImplemented("Dashboard image export")
    }

    /// Export trend analysis report
    public func exportTrendReport(timeRange: DateInterval, format: ExportFormat = .pdf) async throws
        -> URL
    {
        let analysisResults = analysisEngine.getAnalysisResults(
            from: timeRange.start, to: timeRange.end
        )
        let trendAnalysis = analysisEngine.analyzeQualityTrends()

        let report = TrendReport(
            timeRange: timeRange,
            analysisResults: analysisResults,
            trendAnalysis: trendAnalysis,
            generatedAt: Date()
        )

        return try await exportQueue.sync {
            try exportReportToFile(report, format: format)
        }
    }

    /// Export anomaly report
    public func exportAnomalyReport(timeRange: DateInterval, format: ExportFormat = .html)
        async throws -> URL
    {
        let anomalies = analysisEngine.detectAnomalies()
        let analysis = try await analysisEngine.performAnalysis()

        let report = AnomalyReport(
            timeRange: timeRange,
            anomalies: anomalies,
            analysis: analysis,
            generatedAt: Date()
        )

        return try await exportQueue.sync {
            try exportReportToFile(report, format: format)
        }
    }

    /// Export comprehensive project health report
    public func exportHealthReport(format: ExportFormat = .html) async throws -> URL {
        let currentMetrics = collector.getAggregateMetrics()
        let analysis = try await analysisEngine.performAnalysis()
        let predictions = try analysisEngine.predictMetrics(for: 7 * 24 * 3600) // 7 days

        let healthScore = calculateHealthScore(metrics: currentMetrics, analysis: analysis)
        let healthReport = HealthReport(
            healthScore: healthScore,
            metrics: currentMetrics,
            analysis: analysis,
            predictions: predictions,
            recommendations: analysis.recommendations,
            generatedAt: Date()
        )

        return try await exportQueue.sync {
            try exportReportToFile(healthReport, format: format)
        }
    }

    /// Schedule automated exports
    public func scheduleAutomatedExport(
        format: ExportFormat, frequency: ExportFrequency, filename: String? = nil
    ) {
        let timerInterval: TimeInterval

        switch frequency {
        case .hourly:
            timerInterval = 3600
        case .daily:
            timerInterval = 24 * 3600
        case .weekly:
            timerInterval = 7 * 24 * 3600
        }

        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            Task {
                do {
                    _ = try await self?.exportCurrentMetrics(format: format, filename: filename)
                } catch {
                    print("Automated export failed: \(error)")
                }
            }
        }
    }

    /// Export metrics to external monitoring system
    public func exportToMonitoringSystem(system: MonitoringSystem, endpoint: URL) async throws {
        let metrics = collector.getAggregateMetrics()
        let analysis = try await analysisEngine.performAnalysis()

        let payload = MonitoringPayload(
            projectId: "quantum-workspace",
            timestamp: Date(),
            metrics: metrics,
            analysis: analysis
        )

        try await sendToMonitoringSystem(payload, system: system, endpoint: endpoint)
    }

    /// Get list of exported files
    public func getExportedFiles() throws -> [URL] {
        guard let directory = config.exportDirectory else {
            return []
        }

        let contents = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        )

        return contents.sorted(by: { url1, url2 in
            let date1 =
                (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate
                    ?? Date.distantPast
            let date2 =
                (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate
                    ?? Date.distantPast
            return date1 > date2
        })
    }

    /// Clean up old exports
    public func cleanupOldExports(olderThan days: Int) throws {
        guard let directory = config.exportDirectory else { return }

        let cutoffDate = Date().addingTimeInterval(-Double(days) * 24 * 3600)
        let contents = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        )

        for url in contents {
            if let creationDate = (try? url.resourceValues(forKeys: [.creationDateKey]))?
                .creationDate,
                creationDate < cutoffDate
            {
                try FileManager.default.removeItem(at: url)
            }
        }
    }

    // MARK: - Private Methods

    private func exportDataToFile(_ data: ExportData, format: ExportFormat, filename: String?)
        throws -> URL
    {
        let filename = filename ?? generateFilename(prefix: "metrics", format: format)
        let url =
            config.exportDirectory?.appendingPathComponent(filename)
                ?? FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        switch format {
        case .json:
            try exportAsJSON(data, to: url)
        case .csv:
            try exportAsCSV(data, to: url)
        case .xml:
            try exportAsXML(data, to: url)
        case .html:
            try exportAsHTML(data, to: url)
        case .pdf:
            try exportAsPDF(data, to: url)
        }

        return url
    }

    private func exportReportToFile(_ report: any ExportableReport, format: ExportFormat) throws
        -> URL
    {
        let filename = generateFilename(prefix: report.reportType, format: format)
        let url =
            config.exportDirectory?.appendingPathComponent(filename)
                ?? FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        switch format {
        case .json:
            try exportReportAsJSON(report, to: url)
        case .html:
            try exportReportAsHTML(report, to: url)
        case .pdf:
            try exportReportAsPDF(report, to: url)
        default:
            throw ExportError.unsupportedFormat(format)
        }

        return url
    }

    private func exportAsJSON(_ data: ExportData, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let jsonData = try encoder.encode(data)
        try jsonData.write(to: url, options: .atomic)
    }

    private func exportAsCSV(_ data: ExportData, to url: URL) throws {
        var csv = "Timestamp,Metric,Value\n"

        // Current metrics
        let timestamp = ISO8601DateFormatter().string(from: data.timestamp)
        csv += "\(timestamp),total_files,\(data.metrics.totalFiles)\n"
        csv += "\(timestamp),total_lines,\(data.metrics.totalLinesOfCode)\n"
        csv += "\(timestamp),complexity_score,\(data.metrics.complexityScore)\n"
        csv += "\(timestamp),maintainability_score,\(data.metrics.maintainabilityScore)\n"

        // Historical data
        if let historical = data.historicalData {
            for (date, metrics) in historical {
                let dateStr = ISO8601DateFormatter().string(from: date)
                csv += "\(dateStr),historical_complexity,\(metrics.complexityScore)\n"
                csv += "\(dateStr),historical_maintainability,\(metrics.maintainabilityScore)\n"
            }
        }

        try csv.write(to: url, atomically: true, encoding: .utf8)
    }

    private func exportAsXML(_ data: ExportData, to url: URL) throws {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<metrics-export timestamp=\"\(data.timestamp.ISO8601Format())\">\n"

        xml += "  <current-metrics>\n"
        xml += "    <total-files>\(data.metrics.totalFiles)</total-files>\n"
        xml += "    <total-lines>\(data.metrics.totalLinesOfCode)</total-lines>\n"
        xml += "    <complexity-score>\(data.metrics.complexityScore)</complexity-score>\n"
        xml +=
            "    <maintainability-score>\(data.metrics.maintainabilityScore)</maintainability-score>\n"
        xml += "  </current-metrics>\n"

        if let historical = data.historicalData {
            xml += "  <historical-data>\n"
            for (date, metrics) in historical {
                xml += "    <entry date=\"\(date.ISO8601Format())\">\n"
                xml += "      <complexity-score>\(metrics.complexityScore)</complexity-score>\n"
                xml +=
                    "      <maintainability-score>\(metrics.maintainabilityScore)</maintainability-score>\n"
                xml += "    </entry>\n"
            }
            xml += "  </historical-data>\n"
        }

        xml += "</metrics-export>\n"

        try xml.write(to: url, atomically: true, encoding: .utf8)
    }

    private func exportAsHTML(_ data: ExportData, to url: URL) throws {
        let html = generateHTMLReport(for: data)
        try html.write(to: url, atomically: true, encoding: .utf8)
    }

    private func exportAsPDF(_ data: ExportData, to url: URL) throws {
        // PDF export would require additional libraries
        // For now, export as HTML and note that PDF conversion would be needed
        try exportAsHTML(data, to: url)
    }

    private func exportReportAsJSON(_ report: any ExportableReport, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let jsonData = try encoder.encode(report)
        try jsonData.write(to: url, options: .atomic)
    }

    private func exportReportAsHTML(_ report: any ExportableReport, to url: URL) throws {
        let html = report.generateHTML()
        try html.write(to: url, atomically: true, encoding: .utf8)
    }

    private func exportReportAsPDF(_ report: any ExportableReport, to url: URL) throws {
        // Similar to data PDF export
        try exportReportAsHTML(report, to: url)
    }

    private func generateHTMLReport(for data: ExportData) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Metrics Export Report</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; }
                .header { background: #f5f5f5; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
                .metric-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin: 20px 0; }
                .metric-card { background: white; padding: 16px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
                .metric-value { font-size: 24px; font-weight: bold; color: #007AFF; }
                .metric-label { color: #666; font-size: 14px; }
                .insights { margin: 20px 0; }
                .insight { background: #e8f4f8; padding: 12px; border-radius: 6px; margin: 8px 0; border-left: 4px solid #007AFF; }
                table { width: 100%; border-collapse: collapse; margin: 20px 0; }
                th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
                th { background: #f5f5f5; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>Code Metrics Export Report</h1>
                <p>Generated on \(data.timestamp.formatted(date: .long, time: .shortened))</p>
            </div>

            <div class="metric-grid">
                <div class="metric-card">
                    <div class="metric-value">\(data.metrics.totalFiles)</div>
                    <div class="metric-label">Total Files</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">\(data.metrics.totalLinesOfCode)</div>
                    <div class="metric-label">Lines of Code</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">\(String(format: "%.2f", data.metrics.complexityScore))</div>
                    <div class="metric-label">Complexity Score</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">\(String(format: "%.2f", data.metrics.maintainabilityScore))</div>
                    <div class="metric-label">Maintainability</div>
                </div>
            </div>

            <h2>Analysis Insights</h2>
            <div class="insights">
                \(data.analysis.insights.map { insight in
                    "<div class=\"insight\"><strong>\(insight.title)</strong><br>\(insight.description)</div>"
                }.joined())
            </div>

            <h2>Recommendations</h2>
            <table>
                <tr><th>Priority</th><th>Category</th><th>Title</th><th>Description</th></tr>
                \(data.analysis.recommendations.map { rec in
                    "<tr><td>\(rec.priority.rawValue)</td><td>\(rec.category.rawValue)</td><td>\(rec.title)</td><td>\(rec.description)</td></tr>"
                }.joined())
            </table>
        </body>
        </html>
        """
    }

    private func sendToMonitoringSystem(
        _ payload: MonitoringPayload, system: MonitoringSystem, endpoint: URL
    ) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(payload)

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add system-specific headers
        switch system {
        case .datadog:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .newRelic:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .prometheus:
            request.httpMethod = "PUT"
        case .grafana:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
           !(200 ... 299).contains(httpResponse.statusCode)
        {
            throw ExportError.monitoringSystemError(httpResponse.statusCode)
        }
    }

    private func generateFilename(prefix: String, format: ExportFormat) -> String {
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(
            of: ":", with: "-"
        )
        return "\(prefix)_\(timestamp).\(format.fileExtension)"
    }

    private func getHistoricalData() -> [Date: AggregateMetrics]? {
        // This would collect historical data from the analysis engine
        // For now, return nil
        nil
    }

    private func calculateHealthScore(metrics: AggregateMetrics, analysis: AnalysisReport) -> Double {
        var score = 0.0
        var weights = 0.0

        // Complexity score (30% weight)
        score += metrics.complexityScore * 0.3
        weights += 0.3

        // Maintainability score (30% weight)
        score += metrics.maintainabilityScore * 0.3
        weights += 0.3

        // Anomaly score (inverse - 20% weight)
        let anomalyPenalty = min(analysis.anomalyDetection.anomalyScore, 1.0)
        score += (1.0 - anomalyPenalty) * 0.2
        weights += 0.2

        // Trend direction (20% weight)
        let trendBonus =
            analysis.trendAnalysis.complexityTrend.slope < 0
                ? 1.0 : analysis.trendAnalysis.complexityTrend.slope > 0.1 ? 0.5 : 0.8
        score += trendBonus * 0.2
        weights += 0.2

        return weights > 0 ? score / weights : 0.0
    }
}

// MARK: - Supporting Types

/// Export format
public enum ExportFormat {
    case json, csv, xml, html, pdf

    var fileExtension: String {
        switch self {
        case .json: return "json"
        case .csv: return "csv"
        case .xml: return "xml"
        case .html: return "html"
        case .pdf: return "pdf"
        }
    }
}

/// Export frequency
public enum ExportFrequency {
    case hourly, daily, weekly
}

/// Monitoring system
public enum MonitoringSystem {
    case datadog, newRelic, prometheus, grafana
}

/// Export data
public struct ExportData: Codable {
    public let timestamp: Date
    public let metrics: AggregateMetrics
    public let analysis: AnalysisReport
    public let historicalData: [Date: AggregateMetrics]?
}

/// Monitoring payload
public struct MonitoringPayload: Codable {
    public let projectId: String
    public let timestamp: Date
    public let metrics: AggregateMetrics
    public let analysis: AnalysisReport
}

/// Protocol for exportable reports
public protocol ExportableReport: Codable {
    var reportType: String { get }
    var generatedAt: Date { get }
    func generateHTML() -> String
}

/// Trend report
public struct TrendReport: ExportableReport {
    public let reportType = "trend"
    public let timeRange: DateInterval
    public let analysisResults: [AnalysisResult]
    public let trendAnalysis: QualityTrendAnalysis
    public let generatedAt: Date

    public func generateHTML() -> String {
        // Generate HTML for trend report
        """
        <!DOCTYPE html>
        <html>
        <head><title>Trend Analysis Report</title></head>
        <body>
        <h1>Trend Analysis Report</h1>
        <p>Period: \(timeRange.start.formatted()) - \(timeRange.end.formatted())</p>
        <p>Generated: \(generatedAt.formatted())</p>
        <!-- Trend analysis content would go here -->
        </body>
        </html>
        """
    }
}

/// Anomaly report
public struct AnomalyReport: ExportableReport {
    public let reportType = "anomaly"
    public let timeRange: DateInterval
    public let anomalies: [MetricAnomaly]
    public let analysis: AnalysisReport
    public let generatedAt: Date

    public func generateHTML() -> String {
        // Generate HTML for anomaly report
        """
        <!DOCTYPE html>
        <html>
        <head><title>Anomaly Detection Report</title></head>
        <body>
        <h1>Anomaly Detection Report</h1>
        <p>Period: \(timeRange.start.formatted()) - \(timeRange.end.formatted())</p>
        <p>Generated: \(generatedAt.formatted())</p>
        <p>Anomalies Found: \(anomalies.count)</p>
        <!-- Anomaly details would go here -->
        </body>
        </html>
        """
    }
}

/// Health report
public struct HealthReport: ExportableReport {
    public let reportType = "health"
    public let healthScore: Double
    public let metrics: AggregateMetrics
    public let analysis: AnalysisReport
    public let predictions: [MetricPrediction]
    public let recommendations: [Recommendation]
    public let generatedAt: Date

    public func generateHTML() -> String {
        // Generate HTML for health report
        """
        <!DOCTYPE html>
        <html>
        <head><title>Project Health Report</title></head>
        <body>
        <h1>Project Health Report</h1>
        <p>Health Score: \(String(format: "%.2f", healthScore))</p>
        <p>Generated: \(generatedAt.formatted())</p>
        <!-- Health report content would go here -->
        </body>
        </html>
        """
    }
}

/// Export errors
public enum ExportError: Error {
    case featureNotImplemented(String)
    case unsupportedFormat(ExportFormat)
    case monitoringSystemError(Int)
    case networkError(Error)
}

// MARK: - Extensions

extension Date {
    func ISO8601Format() -> String {
        ISO8601DateFormatter().string(from: self)
    }
}
