//
//  ReportGenerator.swift
//  Performance Benchmarking
//
//  Comprehensive report generation system for performance analysis,
//  trend visualization, and automated documentation.
//

import Charts
import Foundation
import SwiftUI

/// Comprehensive report generation system
@available(macOS 12.0, *)
public class ReportGenerator {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private var reportQueue = DispatchQueue(
        label: "com.quantum.report-generation", qos: .userInitiated
    )

    /// Report configuration
    public struct ReportConfig {
        public var includeCharts: Bool = true
        public var includeRawData: Bool = false
        public var includeRecommendations: Bool = true
        public var maxChartDataPoints: Int = 50
        public var chartWidth: CGFloat = 800
        public var chartHeight: CGFloat = 600
        public var enableInteractiveCharts: Bool = true
        public var includeExecutiveSummary: Bool = true

        public init() {}
    }

    private var config: ReportConfig

    // MARK: - Initialization

    public init(config: ReportConfig = ReportConfig()) {
        self.config = config
    }

    // MARK: - Public API

    /// Generate comprehensive performance report
    public func generatePerformanceReport(
        analysis: PerformanceAnalysis,
        trends: [TrendAnalysis]? = nil,
        comparison: VersionComparison? = nil,
        anomalies: [PerformanceAnomaly]? = nil,
        insights: [PerformanceInsight]? = nil
    ) async throws -> PerformanceReport {
        try await reportQueue.async {
            let reportId = UUID().uuidString
            let generationTimestamp = Date()

            // Generate executive summary
            let executiveSummary = self.generateExecutiveSummary(analysis, comparison)

            // Generate detailed sections
            let benchmarkSection = try self.generateBenchmarkSection(analysis)
            let correlationSection = try self.generateCorrelationSection(analysis.correlations)
            let bottleneckSection = try self.generateBottleneckSection(analysis.bottlenecks)
            let optimizationSection = try self.generateOptimizationSection(
                analysis.optimizationOpportunities)

            // Generate trend analysis section
            let trendSection = trends.map { try self.generateTrendSection($0) }

            // Generate comparison section
            let comparisonSection = comparison.map { try self.generateComparisonSection($0) }

            // Generate anomaly section
            let anomalySection = anomalies.map { try self.generateAnomalySection($0) }

            // Generate insights section
            let insightsSection = insights.map { try self.generateInsightsSection($0) }

            // Generate recommendations
            let recommendations = self.generateRecommendations(
                analysis, trends, comparison, anomalies, insights
            )

            // Generate charts
            let charts = try self.generateCharts(analysis, trends, comparison)

            return PerformanceReport(
                id: reportId,
                title: "Performance Analysis Report",
                executiveSummary: executiveSummary,
                benchmarkSection: benchmarkSection,
                correlationSection: correlationSection,
                bottleneckSection: bottleneckSection,
                optimizationSection: optimizationSection,
                trendSection: trendSection,
                comparisonSection: comparisonSection,
                anomalySection: anomalySection,
                insightsSection: insightsSection,
                recommendations: recommendations,
                charts: charts,
                generationTimestamp: generationTimestamp,
                config: self.config
            )
        }
    }

    /// Generate trend analysis report
    public func generateTrendReport(_ trends: [TrendAnalysis]) async throws -> TrendReport {
        try await reportQueue.async {
            let reportId = UUID().uuidString
            let generationTimestamp = Date()

            var trendSummaries: [TrendSummary] = []
            var charts: [ChartData] = []

            for trend in trends {
                let summary = try self.generateTrendSummary(trend)
                trendSummaries.append(summary)

                if config.includeCharts {
                    let chart = try self.generateTrendChart(trend)
                    charts.append(chart)
                }
            }

            // Overall trend assessment
            let overallAssessment = self.assessOverallTrends(trendSummaries)

            return TrendReport(
                id: reportId,
                title: "Performance Trend Analysis Report",
                trendSummaries: trendSummaries,
                overallAssessment: overallAssessment,
                charts: charts,
                generationTimestamp: generationTimestamp,
                config: self.config
            )
        }
    }

    /// Generate comparison report
    public func generateComparisonReport(_ comparison: VersionComparison) async throws
        -> ComparisonReport
    {
        try await reportQueue.async {
            let reportId = UUID().uuidString
            let generationTimestamp = Date()

            let summary = try self.generateComparisonSummary(comparison)
            let detailedComparisons = try self.generateDetailedComparisons(comparison)
            let charts = try self.generateComparisonCharts(comparison)
            let assessment = self.assessComparisonResults(comparison)

            return ComparisonReport(
                id: reportId,
                title: "Version Comparison Report",
                summary: summary,
                detailedComparisons: detailedComparisons,
                assessment: assessment,
                charts: charts,
                generationTimestamp: generationTimestamp,
                config: self.config
            )
        }
    }

    /// Export report to multiple formats
    public func exportReport(
        _ report: PerformanceReport, to directory: String, formats: [ExportFormat] = [.html, .json]
    ) async throws {
        try await reportQueue.async {
            let baseURL = URL(fileURLWithPath: directory)
            try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)

            for format in formats {
                switch format {
                case .html:
                    let htmlContent = try self.generateHTMLReport(report)
                    let htmlURL = baseURL.appendingPathComponent("performance_report.html")
                    try htmlContent.write(to: htmlURL, atomically: true, encoding: .utf8)

                case .json:
                    let jsonData = try self.generateJSONReport(report)
                    let jsonURL = baseURL.appendingPathComponent("performance_report.json")
                    try jsonData.write(to: jsonURL)

                case .markdown:
                    let markdownContent = try self.generateMarkdownReport(report)
                    let markdownURL = baseURL.appendingPathComponent("performance_report.md")
                    try markdownContent.write(to: markdownURL, atomically: true, encoding: .utf8)

                case .pdf:
                    // PDF generation would require additional framework
                    // For now, generate HTML and note PDF export capability
                    break
                }
            }

            // Export charts as separate files
            if config.includeCharts {
                try self.exportCharts(report.charts, to: baseURL.appendingPathComponent("charts"))
            }
        }
    }

    /// Generate HTML dashboard
    public func generateHTMLDashboard(
        analysis: PerformanceAnalysis,
        trends: [TrendAnalysis]? = nil,
        comparison: VersionComparison? = nil
    ) async throws -> String {
        try await reportQueue.async {
            let report = try await self.generatePerformanceReport(analysis, trends, comparison)

            var html = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Performance Dashboard</title>
                <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
                <style>
                    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
                    .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px 8px 0 0; }
                    .section { padding: 30px; border-bottom: 1px solid #eee; }
                    .metric-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 20px 0; }
                    .metric-card { background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #667eea; }
                    .metric-value { font-size: 2em; font-weight: bold; color: #333; }
                    .metric-label { color: #666; margin-top: 5px; }
                    .chart-container { margin: 20px 0; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
                    .status-good { color: #28a745; }
                    .status-warning { color: #ffc107; }
                    .status-danger { color: #dc3545; }
                    table { width: 100%; border-collapse: collapse; margin: 20px 0; }
                    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
                    th { background: #f8f9fa; font-weight: 600; }
                    .recommendations { background: #e3f2fd; padding: 20px; border-radius: 8px; margin: 20px 0; }
                    .recommendation-item { margin: 10px 0; padding: 10px; background: white; border-radius: 4px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🚀 Performance Dashboard</h1>
                        <p>Generated on \(self.formatDate(report.generationTimestamp))</p>
                    </div>

                    <div class="section">
                        <h2>📊 Executive Summary</h2>
                        <div class="metric-grid">
                            <div class="metric-card">
                                <div class="metric-value">\(String(format: "%.1f", analysis.overallScore))</div>
                                <div class="metric-label">Overall Score</div>
                            </div>
                            <div class="metric-card">
                                <div class="metric-value \(self.getGradeClass(analysis.performanceGrade))">\(analysis.performanceGrade.rawValue)</div>
                                <div class="metric-label">Performance Grade</div>
                            </div>
                            <div class="metric-card">
                                <div class="metric-value">\(analysis.benchmarkAnalyses.count)</div>
                                <div class="metric-label">Benchmarks Analyzed</div>
                            </div>
                            <div class="metric-card">
                                <div class="metric-value">\(analysis.bottlenecks.count)</div>
                                <div class="metric-label">Bottlenecks Found</div>
                            </div>
                        </div>
                        <p>\(report.executiveSummary)</p>
                    </div>
            """

            // Add benchmark details
            html += """
                    <div class="section">
                        <h2>📈 Benchmark Results</h2>
                        <table>
                            <thead>
                                <tr>
                                    <th>Benchmark</th>
                                    <th>Average Time</th>
                                    <th>Performance Class</th>
                                    <th>Stability</th>
                                    <th>Memory Usage</th>
                                </tr>
                            </thead>
                            <tbody>
            """

            for (id, analysis) in analysis.benchmarkAnalyses {
                let memoryUsage =
                    analysis.memoryAnalysis.map { "\($0.peakUsage / 1024 / 1024)MB" } ?? "N/A"
                html += """
                                <tr>
                                    <td>\(id)</td>
                                    <td>\(String(format: "%.6f", analysis.timeStats.mean))s</td>
                                    <td>\(analysis.performanceClass)</td>
                                    <td>\(analysis.stability)</td>
                                    <td>\(memoryUsage)</td>
                                </tr>
                """
            }

            html += """
                            </tbody>
                        </table>
                    </div>
            """

            // Add recommendations
            if !report.recommendations.isEmpty {
                html += """
                        <div class="section">
                            <h2>💡 Recommendations</h2>
                            <div class="recommendations">
                """

                for recommendation in report.recommendations {
                    html += """
                                <div class="recommendation-item">
                                    <strong>\(recommendation.priority.rawValue.capitalized): </strong>\(recommendation.description)
                                </div>
                    """
                }

                html += """
                            </div>
                        </div>
                """
            }

            // Add charts placeholder
            if config.includeCharts {
                html += """
                        <div class="section">
                            <h2>📊 Performance Charts</h2>
                            <div id="charts-container">
                                <p>Charts will be rendered here when JavaScript loads.</p>
                            </div>
                        </div>
                """
            }

            html += """
                </div>
                <script>
                    // Chart.js integration would go here
                    console.log('Performance Dashboard loaded');
                </script>
            </body>
            </html>
            """

            return html
        }
    }

    // MARK: - Private Methods

    private func generateExecutiveSummary(
        _ analysis: PerformanceAnalysis, _ comparison: VersionComparison?
    ) -> String {
        var summary =
            "Performance analysis completed with an overall score of \(String(format: "%.1f", analysis.overallScore)) and grade \(analysis.performanceGrade.rawValue). "

        summary +=
            "Analyzed \(analysis.benchmarkAnalyses.count) benchmarks, identifying \(analysis.bottlenecks.count) performance bottlenecks and \(analysis.optimizationOpportunities.count) optimization opportunities."

        if let comparison {
            let changeDesc = comparison.averageTimeChange >= 0 ? "increase" : "decrease"
            summary +=
                " Compared to baseline, performance shows a \(String(format: "%.1f", abs(comparison.averageTimeChange)))% \(changeDesc) in execution time."
        }

        return summary
    }

    private func generateBenchmarkSection(_ analysis: PerformanceAnalysis) throws -> ReportSection {
        var content = "# Benchmark Analysis\n\n"

        for (id, benchmarkAnalysis) in analysis.benchmarkAnalyses {
            content += "## \(id)\n\n"
            content += "- **Performance Class**: \(benchmarkAnalysis.performanceClass)\n"
            content +=
                "- **Average Time**: \(String(format: "%.6f", benchmarkAnalysis.timeStats.mean))s\n"
            content += "- **Stability**: \(benchmarkAnalysis.stability)\n"

            if let memory = benchmarkAnalysis.memoryAnalysis {
                content += "- **Peak Memory**: \(memory.peakUsage / 1024 / 1024)MB\n"
                content +=
                    "- **Memory Efficiency**: \(String(format: "%.1f", memory.efficiency * 100))%\n"
            }

            if let threading = benchmarkAnalysis.threadingAnalysis {
                content += "- **Peak Threads**: \(threading.peakThreadCount)\n"
                content +=
                    "- **Thread Efficiency**: \(String(format: "%.1f", threading.threadEfficiency * 100))%\n"
            }

            content += "\n"
        }

        return ReportSection(title: "Benchmark Analysis", content: content, type: .analysis)
    }

    private func generateCorrelationSection(_ correlations: [BenchmarkCorrelation]) throws
        -> ReportSection
    {
        var content = "# Performance Correlations\n\n"

        if correlations.isEmpty {
            content += "No significant correlations found between benchmarks.\n"
        } else {
            content += "Found \(correlations.count) benchmark correlations:\n\n"

            for correlation in correlations {
                let strength =
                    abs(correlation.coefficient) > 0.7
                        ? "Strong" : abs(correlation.coefficient) > 0.5 ? "Moderate" : "Weak"
                content +=
                    "- **\(correlation.benchmarkA)** ↔ **\(correlation.benchmarkB)**: \(strength) correlation (\(String(format: "%.2f", correlation.coefficient)))\n"
            }
        }

        return ReportSection(title: "Performance Correlations", content: content, type: .analysis)
    }

    private func generateBottleneckSection(_ bottlenecks: [PerformanceBottleneck]) throws
        -> ReportSection
    {
        var content = "# Performance Bottlenecks\n\n"

        if bottlenecks.isEmpty {
            content += "No significant performance bottlenecks detected.\n"
        } else {
            content += "Identified \(bottlenecks.count) performance bottlenecks:\n\n"

            for bottleneck in bottlenecks {
                let severityEmoji =
                    bottleneck.severity == .critical
                        ? "🚨" : bottleneck.severity == .high ? "⚠️" : "ℹ️"
                content += "## \(severityEmoji) \(bottleneck.benchmarkId)\n\n"
                content +=
                    "- **Average Time**: \(String(format: "%.6f", bottleneck.averageTime))s\n"
                content += "- **Threshold**: \(String(format: "%.6f", bottleneck.threshold))s\n"
                content += "- **Severity**: \(bottleneck.severity.rawValue.capitalized)\n\n"
            }
        }

        return ReportSection(title: "Performance Bottlenecks", content: content, type: .issues)
    }

    private func generateOptimizationSection(_ opportunities: [OptimizationOpportunity]) throws
        -> ReportSection
    {
        var content = "# Optimization Opportunities\n\n"

        if opportunities.isEmpty {
            content += "No optimization opportunities identified.\n"
        } else {
            content += "Found \(opportunities.count) optimization opportunities:\n\n"

            for opportunity in opportunities {
                content += "## \(opportunity.type) Optimization\n\n"
                content += "**Description**: \(opportunity.description)\n\n"
                content +=
                    "**Affected Benchmarks**: \(opportunity.affectedBenchmarks.joined(separator: ", "))\n\n"
                content += "**Suggested Actions**:\n"
                for action in opportunity.suggestedActions {
                    content += "- \(action)\n"
                }
                content += "\n"
            }
        }

        return ReportSection(
            title: "Optimization Opportunities", content: content, type: .recommendations
        )
    }

    private func generateTrendSection(_ trends: [TrendAnalysis]) throws -> ReportSection {
        var content = "# Performance Trends\n\n"

        for trend in trends {
            content += "## \(trend.benchmarkId)\n\n"
            content += "- **Data Points**: \(trend.dataPoints)\n"
            content += "- **Time Trend**: \(trend.timeSeries.trendType)\n"

            if let memoryTrend = trend.memorySeries {
                content += "- **Memory Trend**: \(memoryTrend.trendType)\n"
            }

            content +=
                "- **Anomalies Detected**: \(trend.timeSeries.anomalies.count + (trend.memorySeries?.anomalies.count ?? 0))\n\n"
        }

        return ReportSection(title: "Performance Trends", content: content, type: .analysis)
    }

    private func generateComparisonSection(_ comparison: VersionComparison) throws -> ReportSection {
        var content = "# Version Comparison\n\n"

        content += "## Summary\n\n"
        content += "- **Benchmarks Compared**: \(comparison.comparisons.count)\n"
        content +=
            "- **Average Time Change**: \(String(format: "%+.1f%%", comparison.averageTimeChange))\n"
        content +=
            "- **Average Memory Change**: \(String(format: "%+.1f%%", comparison.averageMemoryChange))\n"
        content += "- **Significant Regressions**: \(comparison.significantRegressions)\n"
        content += "- **Significant Improvements**: \(comparison.significantImprovements)\n"
        content += "- **Overall Change**: \(comparison.overallChange)\n\n"

        content += "## Detailed Comparisons\n\n"

        for (id, comp) in comparison.comparisons {
            content += "### \(id)\n\n"
            content += "- **Time Change**: \(String(format: "%+.1f%%", comp.timeChangePercent))\n"
            if let memoryChange = comp.memoryChangePercent {
                content += "- **Memory Change**: \(String(format: "%+.1f%%", memoryChange))\n"
            }
            content += "- **Change Type**: \(comp.changeType.rawValue.capitalized)\n"
            content += "- **Significant**: \(comp.isSignificantTimeChange ? "Yes" : "No")\n\n"
        }

        return ReportSection(title: "Version Comparison", content: content, type: .comparison)
    }

    private func generateAnomalySection(_ anomalies: [PerformanceAnomaly]) throws -> ReportSection {
        var content = "# Performance Anomalies\n\n"

        if anomalies.isEmpty {
            content += "No performance anomalies detected.\n"
        } else {
            content += "Detected \(anomalies.count) performance anomalies:\n\n"

            for anomaly in anomalies {
                let severityEmoji =
                    anomaly.severity == .critical ? "🚨" : anomaly.severity == .high ? "⚠️" : "ℹ️"
                content += "## \(severityEmoji) \(anomaly.benchmarkId)\n\n"
                content += "- **Type**: \(anomaly.type)\n"
                content += "- **Description**: \(anomaly.description)\n"
                content += "- **Severity**: \(anomaly.severity.rawValue.capitalized)\n"
                content += "- **Timestamp**: \(formatDate(anomaly.timestamp))\n\n"
            }
        }

        return ReportSection(title: "Performance Anomalies", content: content, type: .issues)
    }

    private func generateInsightsSection(_ insights: [PerformanceInsight]) throws -> ReportSection {
        var content = "# Performance Insights\n\n"

        if insights.isEmpty {
            content += "No specific insights generated.\n"
        } else {
            content += "Generated \(insights.count) performance insights:\n\n"

            for insight in insights {
                let severityEmoji =
                    insight.severity == .critical ? "🚨" : insight.severity == .high ? "⚠️" : "ℹ️"
                content += "## \(severityEmoji) \(insight.title)\n\n"
                content += "**Description**: \(insight.description)\n\n"
                content +=
                    "**Affected Benchmarks**: \(insight.affectedBenchmarks.joined(separator: ", "))\n\n"
                content += "**Suggested Actions**:\n"
                for action in insight.suggestedActions {
                    content += "- \(action)\n"
                }
                content += "\n"
            }
        }

        return ReportSection(title: "Performance Insights", content: content, type: .insights)
    }

    private func generateRecommendations(
        _ analysis: PerformanceAnalysis,
        _ trends: [TrendAnalysis]?,
        _ comparison: VersionComparison?,
        _ anomalies: [PerformanceAnomaly]?,
        _ insights: [PerformanceInsight]?
    ) -> [Recommendation] {
        var recommendations: [Recommendation] = []

        // Grade-based recommendations
        switch analysis.performanceGrade {
        case .a:
            recommendations.append(
                Recommendation(
                    priority: .low,
                    category: .maintenance,
                    description:
                    "Maintain current performance standards and monitor for regressions"
                ))
        case .b:
            recommendations.append(
                Recommendation(
                    priority: .medium,
                    category: .optimization,
                    description: "Look for minor optimizations and monitor performance trends"
                ))
        case .c:
            recommendations.append(
                Recommendation(
                    priority: .high,
                    category: .optimization,
                    description:
                    "Identify performance bottlenecks and implement targeted optimizations"
                ))
        case .d:
            recommendations.append(
                Recommendation(
                    priority: .high,
                    category: .optimization,
                    description:
                    "Conduct comprehensive performance audit and implement major optimizations"
                ))
        case .f:
            recommendations.append(
                Recommendation(
                    priority: .critical,
                    category: .architecture,
                    description:
                    "Immediate performance investigation required - consider architectural changes"
                ))
        }

        // Bottleneck-based recommendations
        for bottleneck in analysis.bottlenecks {
            recommendations.append(
                Recommendation(
                    priority: bottleneck.severity == .critical ? .critical : .high,
                    category: .optimization,
                    description:
                    "Address \(bottleneck.severity.rawValue) bottleneck in \(bottleneck.benchmarkId)"
                ))
        }

        // Trend-based recommendations
        if let trends {
            for trend in trends {
                if trend.timeSeries.trendType == .increasing {
                    recommendations.append(
                        Recommendation(
                            priority: .medium,
                            category: .monitoring,
                            description:
                            "Monitor increasing performance trend for \(trend.benchmarkId)"
                        ))
                }
            }
        }

        // Comparison-based recommendations
        if let comparison, comparison.overallChange == .regression {
            recommendations.append(
                Recommendation(
                    priority: .high,
                    category: .investigation,
                    description: "Investigate performance regression compared to baseline version"
                ))
        }

        return recommendations.sorted(by: { $0.priority.rawValue > $1.priority.rawValue })
    }

    private func generateCharts(
        _ analysis: PerformanceAnalysis,
        _ trends: [TrendAnalysis]?,
        _ comparison: VersionComparison?
    ) throws -> [ChartData] {
        var charts: [ChartData] = []

        if config.includeCharts {
            // Performance overview chart
            let overviewChart = try generatePerformanceOverviewChart(analysis)
            charts.append(overviewChart)

            // Benchmark comparison chart
            let benchmarkChart = try generateBenchmarkComparisonChart(analysis)
            charts.append(benchmarkChart)

            // Trend charts
            if let trends {
                for trend in trends {
                    let trendChart = try generateTrendChart(trend)
                    charts.append(trendChart)
                }
            }

            // Comparison chart
            if let comparison {
                let comparisonChart = try generateComparisonChart(comparison)
                charts.append(comparisonChart)
            }
        }

        return charts
    }

    private func generatePerformanceOverviewChart(_ analysis: PerformanceAnalysis) throws
        -> ChartData
    {
        let data = analysis.benchmarkAnalyses.map { (id: $0.key, time: $0.value.timeStats.mean) }
            .sorted(by: { $0.time > $1.time })

        return ChartData(
            id: "performance_overview",
            title: "Performance Overview",
            type: .bar,
            data: data,
            xAxisLabel: "Benchmark",
            yAxisLabel: "Execution Time (s)",
            config: ChartConfig(width: config.chartWidth, height: config.chartHeight)
        )
    }

    private func generateBenchmarkComparisonChart(_ analysis: PerformanceAnalysis) throws
        -> ChartData
    {
        let data = analysis.benchmarkAnalyses.map {
            (id: $0.key, score: calculateBenchmarkScore($0.value))
        }

        return ChartData(
            id: "benchmark_scores",
            title: "Benchmark Performance Scores",
            type: .radar,
            data: data,
            xAxisLabel: "Benchmark",
            yAxisLabel: "Score",
            config: ChartConfig(width: config.chartWidth, height: config.chartHeight)
        )
    }

    private func generateTrendChart(_ trend: TrendAnalysis) throws -> ChartData {
        let timeData = zip(trend.timeSeries.timestamps, trend.timeSeries.values).map {
            (timestamp: $0, value: $1)
        }

        return ChartData(
            id: "trend_\(trend.benchmarkId)",
            title: "Performance Trend - \(trend.benchmarkId)",
            type: .line,
            data: timeData,
            xAxisLabel: "Time",
            yAxisLabel: "Execution Time (s)",
            config: ChartConfig(width: config.chartWidth, height: config.chartHeight)
        )
    }

    private func generateComparisonChart(_ comparison: VersionComparison) throws -> ChartData {
        let data = comparison.comparisons.map { (id: $0.key, change: $0.value.timeChangePercent) }

        return ChartData(
            id: "version_comparison",
            title: "Version Performance Comparison",
            type: .bar,
            data: data,
            xAxisLabel: "Benchmark",
            yAxisLabel: "Time Change (%)",
            config: ChartConfig(width: config.chartWidth, height: config.chartHeight)
        )
    }

    private func generateTrendSummary(_ trend: TrendAnalysis) throws -> TrendSummary {
        TrendSummary(
            benchmarkId: trend.benchmarkId,
            trendType: trend.timeSeries.trendType,
            slope: trend.timeSeries.trend.slope,
            rSquared: trend.timeSeries.trend.rSquared,
            anomalyCount: trend.timeSeries.anomalies.count
                + (trend.memorySeries?.anomalies.count ?? 0),
            dataPoints: trend.dataPoints
        )
    }

    private func assessOverallTrends(_ summaries: [TrendSummary]) -> String {
        let increasing = summaries.filter { $0.trendType == .increasing }.count
        let decreasing = summaries.filter { $0.trendType == .decreasing }.count
        let stable = summaries.filter { $0.trendType == .stable }.count

        var assessment = "Performance trends analysis: "
        assessment += "\(stable) stable, \(increasing) increasing, \(decreasing) decreasing trends."

        if decreasing > increasing {
            assessment += " Overall performance is trending downward - investigation recommended."
        } else if increasing > decreasing {
            assessment += " Overall performance is improving."
        } else {
            assessment += " Performance is generally stable."
        }

        return assessment
    }

    private func generateComparisonSummary(_ comparison: VersionComparison) throws
        -> ComparisonSummary
    {
        ComparisonSummary(
            benchmarkCount: comparison.comparisons.count,
            averageTimeChange: comparison.averageTimeChange,
            averageMemoryChange: comparison.averageMemoryChange,
            significantRegressions: comparison.significantRegressions,
            significantImprovements: comparison.significantImprovements,
            overallChange: comparison.overallChange
        )
    }

    private func generateDetailedComparisons(_ comparison: VersionComparison) throws
        -> [DetailedComparison]
    {
        comparison.comparisons.map { id, comp in
            DetailedComparison(
                benchmarkId: id,
                timeChangePercent: comp.timeChangePercent,
                memoryChangePercent: comp.memoryChangePercent,
                changeType: comp.changeType,
                isSignificant: comp.isSignificantTimeChange
            )
        }
    }

    private func generateComparisonCharts(_ comparison: VersionComparison) throws -> [ChartData] {
        var charts: [ChartData] = []

        if config.includeCharts {
            let timeChangeChart = try generateComparisonChart(comparison)
            charts.append(timeChangeChart)
        }

        return charts
    }

    private func assessComparisonResults(_ comparison: VersionComparison) -> String {
        var assessment = "Version comparison assessment: "

        if comparison.overallChange == .improvement {
            assessment += "Performance has improved compared to baseline."
        } else if comparison.overallChange == .regression {
            assessment += "Performance has regressed compared to baseline."
        } else {
            assessment += "Performance is comparable to baseline."
        }

        if comparison.significantRegressions > 0 {
            assessment += " \(comparison.significantRegressions) significant regressions detected."
        }

        if comparison.significantImprovements > 0 {
            assessment +=
                " \(comparison.significantImprovements) significant improvements detected."
        }

        return assessment
    }

    private func generateHTMLReport(_ report: PerformanceReport) throws -> String {
        // HTML generation logic would be extensive
        // For now, return a placeholder
        "<html><body><h1>Performance Report</h1><p>Report generation completed.</p></body></html>"
    }

    private func generateJSONReport(_ report: PerformanceReport) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(report)
    }

    private func generateMarkdownReport(_ report: PerformanceReport) throws -> String {
        var markdown = "# \(report.title)\n\n"
        markdown += "Generated on: \(formatDate(report.generationTimestamp))\n\n"

        markdown += "## Executive Summary\n\n"
        markdown += "\(report.executiveSummary)\n\n"

        // Add sections
        if let benchmarkSection = report.benchmarkSection {
            markdown += benchmarkSection.content + "\n"
        }

        if let correlationSection = report.correlationSection {
            markdown += correlationSection.content + "\n"
        }

        if let bottleneckSection = report.bottleneckSection {
            markdown += bottleneckSection.content + "\n"
        }

        if let optimizationSection = report.optimizationSection {
            markdown += optimizationSection.content + "\n"
        }

        return markdown
    }

    private func exportCharts(_ charts: [ChartData], to directory: URL) throws {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        for chart in charts {
            // Export chart data as JSON for external rendering
            let chartData = try JSONEncoder().encode(chart)
            let chartURL = directory.appendingPathComponent("\(chart.id).json")
            try chartData.write(to: chartURL)
        }
    }

    private func calculateBenchmarkScore(_ analysis: BenchmarkAnalysis) -> Double {
        // Simplified scoring logic
        let timeScore = max(0, 100 - analysis.timeStats.mean * 1000) // Rough approximation
        let stabilityScore =
            analysis.stability == .excellent ? 100 : analysis.stability == .good ? 80 : 60
        return (timeScore + Double(stabilityScore)) / 2
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    private func getGradeClass(_ grade: PerformanceGrade) -> String {
        switch grade {
        case .a: return "status-good"
        case .b: return "status-good"
        case .c: return "status-warning"
        case .d: return "status-danger"
        case .f: return "status-danger"
        }
    }
}

// MARK: - Supporting Types

/// Performance report
public struct PerformanceReport {
    public let id: String
    public let title: String
    public let executiveSummary: String
    public let benchmarkSection: ReportSection?
    public let correlationSection: ReportSection?
    public let bottleneckSection: ReportSection?
    public let optimizationSection: ReportSection?
    public let trendSection: ReportSection?
    public let comparisonSection: ReportSection?
    public let anomalySection: ReportSection?
    public let insightsSection: ReportSection?
    public let recommendations: [Recommendation]
    public let charts: [ChartData]
    public let generationTimestamp: Date
    public let config: ReportGenerator.ReportConfig
}

/// Report section
public struct ReportSection {
    public let title: String
    public let content: String
    public let type: SectionType

    public enum SectionType {
        case analysis, issues, recommendations, comparison, insights
    }
}

/// Recommendation
public struct Recommendation {
    public let priority: Priority
    public let category: Category
    public let description: String

    public enum Priority: Int {
        case low = 1
        case medium = 2
        case high = 3
        case critical = 4
    }

    public enum Category {
        case maintenance, optimization, monitoring, investigation, architecture
    }
}

/// Chart data
public struct ChartData {
    public let id: String
    public let title: String
    public let type: ChartType
    public let data: [(String, Double)] // Simplified data structure
    public let xAxisLabel: String
    public let yAxisLabel: String
    public let config: ChartConfig

    public enum ChartType {
        case line, bar, radar, pie
    }
}

/// Chart configuration
public struct ChartConfig {
    public let width: CGFloat
    public let height: CGFloat
}

/// Trend report
public struct TrendReport {
    public let id: String
    public let title: String
    public let trendSummaries: [TrendSummary]
    public let overallAssessment: String
    public let charts: [ChartData]
    public let generationTimestamp: Date
    public let config: ReportGenerator.ReportConfig
}

/// Trend summary
public struct TrendSummary {
    public let benchmarkId: String
    public let trendType: TrendType
    public let slope: Double
    public let rSquared: Double
    public let anomalyCount: Int
    public let dataPoints: Int
}

/// Comparison report
public struct ComparisonReport {
    public let id: String
    public let title: String
    public let summary: ComparisonSummary
    public let detailedComparisons: [DetailedComparison]
    public let assessment: String
    public let charts: [ChartData]
    public let generationTimestamp: Date
    public let config: ReportGenerator.ReportConfig
}

/// Comparison summary
public struct ComparisonSummary {
    public let benchmarkCount: Int
    public let averageTimeChange: Double
    public let averageMemoryChange: Double
    public let significantRegressions: Int
    public let significantImprovements: Int
    public let overallChange: VersionChange
}

/// Detailed comparison
public struct DetailedComparison {
    public let benchmarkId: String
    public let timeChangePercent: Double
    public let memoryChangePercent: Double?
    public let changeType: BenchmarkComparison.ChangeType
    public let isSignificant: Bool
}

/// Export formats
public enum ExportFormat {
    case html, json, markdown, pdf
}

// MARK: - Extensions

extension PerformanceReport: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, title, executiveSummary, recommendations, charts, generationTimestamp, config
        // Note: Sections are not directly codable due to complexity
    }
}

extension ReportGenerator.ReportConfig: Codable {}
extension ReportGenerator.ReportConfig: CustomStringConvertible {
    public var description: String {
        "ReportConfig(includeCharts: \(includeCharts), includeRawData: \(includeRawData), includeRecommendations: \(includeRecommendations))"
    }
}

extension Recommendation: CustomStringConvertible {
    public var description: String {
        "[\(priority.rawValue.capitalized)] \(category): \(description)"
    }
}

extension ChartData: Codable {}
extension ChartConfig: Codable {}

extension TrendReport: Codable {}
extension TrendSummary: Codable {}

extension ComparisonReport: Codable {}
extension ComparisonSummary: Codable {}
extension DetailedComparison: Codable {}
