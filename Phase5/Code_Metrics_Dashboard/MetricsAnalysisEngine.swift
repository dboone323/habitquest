//
//  MetricsAnalysisEngine.swift
//  Code Metrics Dashboard
//
//  Advanced analysis engine for predictive modeling, trend analysis,
//  and intelligent insights generation for code metrics.
//

import Combine
import CoreML
import CreateML
import Foundation

/// Advanced metrics analysis engine with predictive capabilities
@available(macOS 12.0, *)
public class MetricsAnalysisEngine {

    // MARK: - Properties

    private let metricsCollector: MetricsCollector
    private var analysisQueue = DispatchQueue(
        label: "com.quantum.metrics-analysis", qos: .userInitiated
    )

    private var historicalMetrics: [Date: AggregateMetrics] = [:]
    private var predictionModels: [String: MLModel] = [:]

    private var analysisResults: [AnalysisResult] = []
    private var insights: [MetricInsight] = []

    /// Analysis configuration
    public struct Configuration {
        public var predictionHorizon: TimeInterval = 7 * 24 * 3600 // 7 days
        public var confidenceThreshold: Double = 0.7
        public var enableMachineLearning: Bool = true
        public var analysisInterval: TimeInterval = 3600 // 1 hour
        public var maxHistoricalData: Int = 1000

        public init() {}
    }

    private var config: Configuration

    // MARK: - Initialization

    public init(collector: MetricsCollector, configuration: Configuration = Configuration()) {
        self.metricsCollector = collector
        self.config = configuration

        setupAnalysisPipeline()
    }

    // MARK: - Public API

    /// Perform comprehensive analysis
    public func performAnalysis() async throws -> AnalysisReport {
        try await analysisQueue.sync {
            // Collect current metrics
            let currentMetrics = metricsCollector.getAggregateMetrics()

            // Update historical data
            updateHistoricalData(currentMetrics)

            // Perform various analyses
            let trendAnalysis = try performTrendAnalysis()
            let predictiveAnalysis = try performPredictiveAnalysis()
            let anomalyDetection = try performAnomalyDetection()
            let correlationAnalysis = try performCorrelationAnalysis()
            let insights = try generateInsights()

            // Generate recommendations
            let recommendations = try generateRecommendations(
                trendAnalysis: trendAnalysis,
                predictiveAnalysis: predictiveAnalysis,
                anomalyDetection: anomalyDetection
            )

            return AnalysisReport(
                timestamp: Date(),
                currentMetrics: currentMetrics,
                trendAnalysis: trendAnalysis,
                predictiveAnalysis: predictiveAnalysis,
                anomalyDetection: anomalyDetection,
                correlationAnalysis: correlationAnalysis,
                insights: insights,
                recommendations: recommendations
            )
        }
    }

    /// Get analysis results for a specific time period
    public func getAnalysisResults(from startDate: Date, to endDate: Date) -> [AnalysisResult] {
        analysisQueue.sync {
            analysisResults.filter { result in
                result.timestamp >= startDate && result.timestamp <= endDate
            }
        }
    }

    /// Generate predictive models for metrics
    public func trainPredictiveModels() async throws {
        guard config.enableMachineLearning else { return }

        try await analysisQueue.sync {
            // Train complexity prediction model
            try trainComplexityPredictionModel()

            // Train quality prediction model
            try trainQualityPredictionModel()

            // Train performance prediction model
            try trainPerformancePredictionModel()
        }
    }

    /// Predict future metrics
    public func predictMetrics(for timeHorizon: TimeInterval) throws -> [MetricPrediction] {
        guard config.enableMachineLearning else {
            throw AnalysisError.machineLearningDisabled
        }

        return try analysisQueue.sync {
            var predictions: [MetricPrediction] = []

            // Predict complexity
            if let complexityModel = predictionModels["complexity"] {
                let complexityPrediction = try predictComplexity(
                    complexityModel, horizon: timeHorizon
                )
                predictions.append(complexityPrediction)
            }

            // Predict quality
            if let qualityModel = predictionModels["quality"] {
                let qualityPrediction = try predictQuality(qualityModel, horizon: timeHorizon)
                predictions.append(qualityPrediction)
            }

            // Predict performance
            if let performanceModel = predictionModels["performance"] {
                let performancePrediction = try predictPerformance(
                    performanceModel, horizon: timeHorizon
                )
                predictions.append(performancePrediction)
            }

            return predictions
        }
    }

    /// Analyze code quality trends
    public func analyzeQualityTrends() -> QualityTrendAnalysis {
        analysisQueue.sync {
            let sortedMetrics = historicalMetrics.sorted(by: { $0.key < $1.key })

            var complexityTrend: [Date: Double] = [:]
            var maintainabilityTrend: [Date: Double] = [:]
            var coverageTrend: [Date: Double] = [:]

            for (date, metrics) in sortedMetrics {
                complexityTrend[date] = metrics.complexityScore
                maintainabilityTrend[date] = metrics.maintainabilityScore
                coverageTrend[date] = metrics.coverageScore
            }

            let complexitySlope = calculateTrendSlope(complexityTrend)
            let maintainabilitySlope = calculateTrendSlope(maintainabilityTrend)
            let coverageSlope = calculateTrendSlope(coverageTrend)

            return QualityTrendAnalysis(
                complexityTrend: complexityTrend,
                maintainabilityTrend: maintainabilityTrend,
                coverageTrend: coverageTrend,
                complexitySlope: complexitySlope,
                maintainabilitySlope: maintainabilitySlope,
                coverageSlope: coverageSlope,
                overallQualityDirection: determineQualityDirection(
                    complexitySlope: complexitySlope,
                    maintainabilitySlope: maintainabilitySlope,
                    coverageSlope: coverageSlope
                )
            )
        }
    }

    /// Detect anomalies in metrics
    public func detectAnomalies() -> [MetricAnomaly] {
        analysisQueue.sync {
            var anomalies: [MetricAnomaly] = []

            let currentMetrics = metricsCollector.getAggregateMetrics()
            let historicalData = Array(historicalMetrics.values)

            // Check for complexity anomalies
            if let complexityAnomaly = detectComplexityAnomaly(
                currentMetrics, historicalData: historicalData
            ) {
                anomalies.append(complexityAnomaly)
            }

            // Check for file size anomalies
            if let fileSizeAnomaly = detectFileSizeAnomaly(
                currentMetrics, historicalData: historicalData
            ) {
                anomalies.append(fileSizeAnomaly)
            }

            // Check for rapid changes
            if let changeAnomaly = detectRapidChangeAnomaly(
                currentMetrics, historicalData: historicalData
            ) {
                anomalies.append(changeAnomaly)
            }

            return anomalies
        }
    }

    // MARK: - Private Analysis Methods

    private func performTrendAnalysis() throws -> TrendAnalysis {
        let sortedData = historicalMetrics.sorted(by: { $0.key < $1.key })
        let values = sortedData.map(\.value)

        guard values.count >= 2 else {
            throw AnalysisError.insufficientData
        }

        // Calculate trends for key metrics
        let complexityTrend = calculateLinearTrend(values.map(\.complexityScore))
        let maintainabilityTrend = calculateLinearTrend(values.map(\.maintainabilityScore))
        let fileGrowthTrend = calculateLinearTrend(values.map { Double($0.totalFiles) })

        // Calculate volatility
        let complexityVolatility = calculateVolatility(values.map(\.complexityScore))
        let maintainabilityVolatility = calculateVolatility(values.map(\.maintainabilityScore))

        return TrendAnalysis(
            complexityTrend: complexityTrend,
            maintainabilityTrend: maintainabilityTrend,
            fileGrowthTrend: fileGrowthTrend,
            complexityVolatility: complexityVolatility,
            maintainabilityVolatility: maintainabilityVolatility,
            trendPeriod: sortedData.last!.key.timeIntervalSince(sortedData.first!.key)
        )
    }

    private func performPredictiveAnalysis() throws -> PredictiveAnalysis {
        let predictions = try predictMetrics(for: config.predictionHorizon)

        // Analyze prediction confidence
        let averageConfidence =
            predictions.map(\.confidence).reduce(0, +) / Double(predictions.count)

        // Identify risk areas
        let highRiskPredictions = predictions.filter {
            $0.confidence > 0.8 && $0.predictedValue > $0.currentValue * 1.2
        }

        return PredictiveAnalysis(
            predictions: predictions,
            averageConfidence: averageConfidence,
            highRiskAreas: highRiskPredictions.map(\.metricType),
            predictionHorizon: config.predictionHorizon
        )
    }

    private func performAnomalyDetection() throws -> AnomalyDetection {
        let anomalies = detectAnomalies()

        let anomalyScore = Double(anomalies.count) / Double(max(historicalMetrics.count, 1))
        let criticalAnomalies = anomalies.filter { $0.severity == .critical }

        return AnomalyDetection(
            anomalies: anomalies,
            anomalyScore: anomalyScore,
            criticalAnomalies: criticalAnomalies,
            detectionTimestamp: Date()
        )
    }

    private func performCorrelationAnalysis() throws -> CorrelationAnalysis {
        let metrics = Array(historicalMetrics.values)

        guard metrics.count >= 10 else {
            throw AnalysisError.insufficientData
        }

        // Calculate correlations between metrics
        let complexityMaintainabilityCorr = calculateCorrelation(
            metrics.map(\.complexityScore),
            metrics.map(\.maintainabilityScore)
        )

        let fileSizeComplexityCorr = calculateCorrelation(
            metrics.map { Double($0.totalFiles) },
            metrics.map(\.complexityScore)
        )

        let linesCodeQualityCorr = calculateCorrelation(
            metrics.map { Double($0.totalLinesOfCode) },
            metrics.map(\.maintainabilityScore)
        )

        return CorrelationAnalysis(
            complexityMaintainabilityCorrelation: complexityMaintainabilityCorr,
            fileSizeComplexityCorrelation: fileSizeComplexityCorr,
            linesCodeQualityCorrelation: linesCodeQualityCorr,
            significantCorrelations: [
                ("Complexity vs Maintainability", complexityMaintainabilityCorr),
                ("File Size vs Complexity", fileSizeComplexityCorr),
                ("Lines of Code vs Quality", linesCodeQualityCorr),
            ].filter { abs($0.1) > 0.5 }
        )
    }

    private func generateInsights() throws -> [MetricInsight] {
        var insights: [MetricInsight] = []

        let currentMetrics = metricsCollector.getAggregateMetrics()
        let trendAnalysis = try performTrendAnalysis()

        // Complexity insights
        if currentMetrics.complexityScore < 0.6 {
            insights.append(
                MetricInsight(
                    type: .complexity,
                    title: "High Code Complexity",
                    description: "Code complexity is above recommended thresholds",
                    severity: .high,
                    suggestions: [
                        "Consider breaking down complex functions",
                        "Review and refactor high-complexity methods",
                        "Implement design patterns to reduce coupling",
                    ]
                ))
        }

        // Trend insights
        if trendAnalysis.complexityTrend.slope > 0.1 {
            insights.append(
                MetricInsight(
                    type: .trend,
                    title: "Increasing Complexity Trend",
                    description: "Code complexity is trending upward over time",
                    severity: .medium,
                    suggestions: [
                        "Implement regular code reviews",
                        "Set up complexity monitoring alerts",
                        "Consider refactoring sprints",
                    ]
                ))
        }

        // File size insights
        if currentMetrics.largeFiles.count > 10 {
            insights.append(
                MetricInsight(
                    type: .size,
                    title: "Large Files Detected",
                    description:
                    "\(currentMetrics.largeFiles.count) files exceed recommended size limits",
                    severity: .medium,
                    suggestions: [
                        "Split large files into smaller modules",
                        "Extract common functionality into shared components",
                        "Review file organization and architecture",
                    ]
                ))
        }

        return insights
    }

    private func generateRecommendations(
        trendAnalysis: TrendAnalysis,
        predictiveAnalysis: PredictiveAnalysis,
        anomalyDetection: AnomalyDetection
    ) throws -> [Recommendation] {

        var recommendations: [Recommendation] = []

        // Trend-based recommendations
        if trendAnalysis.complexityTrend.slope > 0 {
            recommendations.append(
                Recommendation(
                    priority: .high,
                    category: .refactoring,
                    title: "Address Complexity Growth",
                    description: "Code complexity is increasing. Implement refactoring practices.",
                    actions: [
                        "Schedule regular refactoring sessions",
                        "Implement complexity monitoring",
                        "Review architecture for potential improvements",
                    ],
                    expectedImpact: .high
                ))
        }

        // Predictive recommendations
        if predictiveAnalysis.highRiskAreas.contains(.complexity) {
            recommendations.append(
                Recommendation(
                    priority: .high,
                    category: .monitoring,
                    title: "Monitor Complexity Predictions",
                    description: "Complexity is predicted to increase significantly",
                    actions: [
                        "Set up alerts for complexity thresholds",
                        "Plan preventive refactoring",
                        "Monitor development velocity vs complexity",
                    ],
                    expectedImpact: .high
                ))
        }

        // Anomaly-based recommendations
        if !anomalyDetection.criticalAnomalies.isEmpty {
            recommendations.append(
                Recommendation(
                    priority: .critical,
                    category: .investigation,
                    title: "Investigate Critical Anomalies",
                    description:
                    "\(anomalyDetection.criticalAnomalies.count) critical anomalies detected",
                    actions: [
                        "Review recent code changes",
                        "Analyze anomaly causes",
                        "Implement corrective measures",
                    ],
                    expectedImpact: .critical
                ))
        }

        return recommendations.sorted(by: { $0.priority.rawValue > $1.priority.rawValue })
    }

    // MARK: - Machine Learning Methods

    private func trainComplexityPredictionModel() throws {
        let trainingData = prepareTrainingData(for: \.complexityScore)

        // Create and train a simple linear regression model
        // In a real implementation, this would use CreateML or similar
        let model = try createLinearRegressionModel(from: trainingData)
        predictionModels["complexity"] = model
    }

    private func trainQualityPredictionModel() throws {
        let trainingData = prepareTrainingData(for: \.maintainabilityScore)

        let model = try createLinearRegressionModel(from: trainingData)
        predictionModels["quality"] = model
    }

    private func trainPerformancePredictionModel() throws {
        let trainingData = prepareTrainingData(for: \.coverageScore)

        let model = try createLinearRegressionModel(from: trainingData)
        predictionModels["performance"] = model
    }

    private func predictComplexity(_ model: MLModel, horizon: TimeInterval) throws
        -> MetricPrediction
    {
        // Simplified prediction - in reality would use the ML model
        let currentMetrics = metricsCollector.getAggregateMetrics()
        let predictedValue = currentMetrics.complexityScore * 1.05 // 5% increase prediction

        return MetricPrediction(
            metricType: .complexity,
            currentValue: currentMetrics.complexityScore,
            predictedValue: predictedValue,
            confidence: 0.75,
            timeHorizon: horizon
        )
    }

    private func predictQuality(_ model: MLModel, horizon: TimeInterval) throws -> MetricPrediction {
        let currentMetrics = metricsCollector.getAggregateMetrics()
        let predictedValue = min(1.0, currentMetrics.maintainabilityScore * 1.02)

        return MetricPrediction(
            metricType: .quality,
            currentValue: currentMetrics.maintainabilityScore,
            predictedValue: predictedValue,
            confidence: 0.8,
            timeHorizon: horizon
        )
    }

    private func predictPerformance(_ model: MLModel, horizon: TimeInterval) throws
        -> MetricPrediction
    {
        let currentMetrics = metricsCollector.getAggregateMetrics()
        let predictedValue = min(1.0, currentMetrics.coverageScore * 1.1)

        return MetricPrediction(
            metricType: .performance,
            currentValue: currentMetrics.coverageScore,
            predictedValue: predictedValue,
            confidence: 0.7,
            timeHorizon: horizon
        )
    }

    // MARK: - Statistical Methods

    private func calculateLinearTrend(_ values: [Double]) -> LinearTrend {
        guard values.count >= 2 else {
            return LinearTrend(slope: 0, intercept: 0, rSquared: 0)
        }

        let n = Double(values.count)
        let sumX = (0 ..< values.count).map { Double($0) }.reduce(0, +)
        let sumY = values.reduce(0, +)
        let sumXY = (0 ..< values.count).map { Double($0) * values[$0] }.reduce(0, +)
        let sumXX = (0 ..< values.count).map { Double($0) * Double($0) }.reduce(0, +)
        let sumYY = values.map { $0 * $0 }.reduce(0, +)

        let slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n

        let rSquared = calculateRSquared(values: values, slope: slope, intercept: intercept)

        return LinearTrend(slope: slope, intercept: intercept, rSquared: rSquared)
    }

    private func calculateVolatility(_ values: [Double]) -> Double {
        guard values.count >= 2 else { return 0 }

        let returns = (1 ..< values.count).map { (values[$0] - values[$0 - 1]) / values[$0 - 1] }
        let mean = returns.reduce(0, +) / Double(returns.count)
        let variance = returns.map { pow($0 - mean, 2) }.reduce(0, +) / Double(returns.count)

        return sqrt(variance)
    }

    private func calculateCorrelation(_ x: [Double], _ y: [Double]) -> Double {
        guard x.count == y.count && x.count >= 2 else { return 0 }

        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = (0 ..< x.count).map { x[$0] * y[$0] }.reduce(0, +)
        let sumXX = x.map { $0 * $0 }.reduce(0, +)
        let sumYY = y.map { $0 * $0 }.reduce(0, +)

        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumXX - sumX * sumX) * (n * sumYY - sumY * sumY))

        return denominator == 0 ? 0 : numerator / denominator
    }

    private func calculateRSquared(values: [Double], slope: Double, intercept: Double) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let totalSumSquares = values.map { pow($0 - mean, 2) }.reduce(0, +)
        let residualSumSquares = (0 ..< values.count).map { index in
            let predicted = slope * Double(index) + intercept
            return pow(values[index] - predicted, 2)
        }.reduce(0, +)

        return totalSumSquares == 0 ? 0 : 1 - (residualSumSquares / totalSumSquares)
    }

    private func calculateTrendSlope(_ trend: [Date: Double]) -> Double {
        let sortedEntries = trend.sorted(by: { $0.key < $1.key })
        let values = sortedEntries.map(\.value)
        return calculateLinearTrend(values).slope
    }

    // MARK: - Anomaly Detection Methods

    private func detectComplexityAnomaly(
        _ current: AggregateMetrics, historicalData: [AggregateMetrics]
    ) -> MetricAnomaly? {
        let historicalComplexities = historicalData.map(\.complexityScore)
        guard let mean = historicalComplexities.mean(),
              let stdDev = historicalComplexities.standardDeviation()
        else {
            return nil
        }

        let threshold = mean - 2 * stdDev // 2 standard deviations below mean
        if current.complexityScore < threshold {
            return MetricAnomaly(
                type: .complexity,
                description: "Complexity score is abnormally low",
                severity: .medium,
                detectedValue: current.complexityScore,
                expectedRange: mean ± (2 * stdDev),
                timestamp: Date()
            )
        }

        return nil
    }

    private func detectFileSizeAnomaly(
        _ current: AggregateMetrics, historicalData: [AggregateMetrics]
    ) -> MetricAnomaly? {
        let historicalFileCounts = historicalData.map { Double($0.totalFiles) }
        guard let mean = historicalFileCounts.mean(),
              let stdDev = historicalFileCounts.standardDeviation()
        else {
            return nil
        }

        let threshold = mean + 3 * stdDev // 3 standard deviations above mean
        if Double(current.totalFiles) > threshold {
            return MetricAnomaly(
                type: .fileSize,
                description: "Unusual spike in number of files",
                severity: .high,
                detectedValue: Double(current.totalFiles),
                expectedRange: mean ± (3 * stdDev),
                timestamp: Date()
            )
        }

        return nil
    }

    private func detectRapidChangeAnomaly(
        _ current: AggregateMetrics, historicalData: [AggregateMetrics]
    ) -> MetricAnomaly? {
        guard historicalData.count >= 2 else { return nil }

        let recent = historicalData.suffix(3)
        let older = historicalData.prefix(historicalData.count - 3)

        guard let recentAvg = recent.map(\.complexityScore).mean(),
              let olderAvg = older.map(\.complexityScore).mean()
        else {
            return nil
        }

        let change = abs(recentAvg - olderAvg) / olderAvg
        if change > 0.5 { // 50% change
            return MetricAnomaly(
                type: .rapidChange,
                description: "Rapid change in complexity metrics detected",
                severity: .high,
                detectedValue: change,
                expectedRange: 0.0 ... 0.2,
                timestamp: Date()
            )
        }

        return nil
    }

    // MARK: - Helper Methods

    private func setupAnalysisPipeline() {
        // Set up periodic analysis
        Timer.scheduledTimer(withTimeInterval: config.analysisInterval, repeats: true) {
            [weak self] _ in
            Task {
                do {
                    let result = try await self?.performAnalysis()
                    if let result {
                        self?.analysisResults.append(
                            AnalysisResult(
                                timestamp: result.timestamp,
                                summary: result.insights.map(\.title).joined(separator: ", "),
                                keyMetrics: [
                                    "complexity": result.currentMetrics.complexityScore,
                                    "maintainability": result.currentMetrics.maintainabilityScore,
                                    "files": Double(result.currentMetrics.totalFiles),
                                ]
                            ))
                    }
                } catch {
                    print("Analysis failed: \(error)")
                }
            }
        }
    }

    private func updateHistoricalData(_ metrics: AggregateMetrics) {
        historicalMetrics[Date()] = metrics

        // Limit historical data
        if historicalMetrics.count > config.maxHistoricalData {
            let sortedKeys = historicalMetrics.keys.sorted()
            let keysToRemove = sortedKeys.prefix(historicalMetrics.count - config.maxHistoricalData)
            for key in keysToRemove {
                historicalMetrics.removeValue(forKey: key)
            }
        }
    }

    private func prepareTrainingData(for keyPath: KeyPath<AggregateMetrics, Double>) -> [(
        x: Double, y: Double
    )] {
        let sortedData = historicalMetrics.sorted(by: { $0.key < $1.key })
        return sortedData.enumerated().map { index, element in
            (x: Double(index), y: element.value[keyPath: keyPath])
        }
    }

    private func createLinearRegressionModel(from data: [(x: Double, y: Double)]) throws -> MLModel {
        // Simplified model creation - in reality would use CreateML
        // This is a placeholder implementation
        try MLModel()
    }

    private func determineQualityDirection(
        complexitySlope: Double, maintainabilitySlope: Double, coverageSlope: Double
    ) -> QualityDirection {
        let positiveFactors = [maintainabilitySlope, coverageSlope].filter { $0 > 0 }.count
        let negativeFactors = [complexitySlope].filter { $0 > 0 }.count

        if positiveFactors > negativeFactors {
            return .improving
        } else if negativeFactors > positiveFactors {
            return .declining
        } else {
            return .stable
        }
    }
}

// MARK: - Supporting Types

/// Analysis report
public struct AnalysisReport {
    public let timestamp: Date
    public let currentMetrics: AggregateMetrics
    public let trendAnalysis: TrendAnalysis
    public let predictiveAnalysis: PredictiveAnalysis
    public let anomalyDetection: AnomalyDetection
    public let correlationAnalysis: CorrelationAnalysis
    public let insights: [MetricInsight]
    public let recommendations: [Recommendation]
}

/// Trend analysis
public struct TrendAnalysis {
    public let complexityTrend: LinearTrend
    public let maintainabilityTrend: LinearTrend
    public let fileGrowthTrend: LinearTrend
    public let complexityVolatility: Double
    public let maintainabilityVolatility: Double
    public let trendPeriod: TimeInterval
}

/// Linear trend
public struct LinearTrend {
    public let slope: Double
    public let intercept: Double
    public let rSquared: Double
}

/// Predictive analysis
public struct PredictiveAnalysis {
    public let predictions: [MetricPrediction]
    public let averageConfidence: Double
    public let highRiskAreas: [MetricType]
    public let predictionHorizon: TimeInterval
}

/// Metric prediction
public struct MetricPrediction {
    public let metricType: MetricType
    public let currentValue: Double
    public let predictedValue: Double
    public let confidence: Double
    public let timeHorizon: TimeInterval
}

/// Anomaly detection
public struct AnomalyDetection {
    public let anomalies: [MetricAnomaly]
    public let anomalyScore: Double
    public let criticalAnomalies: [MetricAnomaly]
    public let detectionTimestamp: Date
}

/// Metric anomaly
public struct MetricAnomaly {
    public let type: AnomalyType
    public let description: String
    public let severity: AnomalySeverity
    public let detectedValue: Double
    public let expectedRange: ClosedRange<Double>
    public let timestamp: Date

    public enum AnomalyType {
        case complexity, fileSize, rapidChange
    }

    public enum AnomalySeverity {
        case low, medium, high, critical
    }
}

/// Correlation analysis
public struct CorrelationAnalysis {
    public let complexityMaintainabilityCorrelation: Double
    public let fileSizeComplexityCorrelation: Double
    public let linesCodeQualityCorrelation: Double
    public let significantCorrelations: [(String, Double)]
}

/// Metric insight
public struct MetricInsight {
    public let type: InsightType
    public let title: String
    public let description: String
    public let severity: InsightSeverity
    public let suggestions: [String]

    public enum InsightType {
        case complexity, trend, size, quality, performance
    }

    public enum InsightSeverity {
        case low, medium, high, critical
    }
}

/// Recommendation
public struct Recommendation {
    public let priority: RecommendationPriority
    public let category: RecommendationCategory
    public let title: String
    public let description: String
    public let actions: [String]
    public let expectedImpact: ImpactLevel

    public enum RecommendationPriority {
        case low, medium, high, critical
    }

    public enum RecommendationCategory {
        case refactoring, monitoring, investigation, architecture
    }

    public enum ImpactLevel {
        case low, medium, high, critical
    }
}

/// Quality trend analysis
public struct QualityTrendAnalysis {
    public let complexityTrend: [Date: Double]
    public let maintainabilityTrend: [Date: Double]
    public let coverageTrend: [Date: Double]
    public let complexitySlope: Double
    public let maintainabilitySlope: Double
    public let coverageSlope: Double
    public let overallQualityDirection: QualityDirection
}

/// Quality direction
public enum QualityDirection {
    case improving, stable, declining
}

/// Metric type
public enum MetricType {
    case complexity, quality, performance, size
}

/// Analysis result
public struct AnalysisResult {
    public let timestamp: Date
    public let summary: String
    public let keyMetrics: [String: Double]
}

/// Analysis errors
public enum AnalysisError: Error {
    case insufficientData
    case machineLearningDisabled
    case modelTrainingFailed
    case predictionFailed
}

// MARK: - Extensions

extension [Double] {
    func mean() -> Double? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Double(count)
    }

    func standardDeviation() -> Double? {
        guard count > 1 else { return nil }
        guard let mean = mean() else { return nil }

        let variance = map { pow($0 - mean, 2) }.reduce(0, +) / Double(count - 1)
        return sqrt(variance)
    }
}

extension ClosedRange where Bound == Double {
    static func ± (lhs: Double, rhs: Double) -> ClosedRange<Double> {
        (lhs - rhs) ... (lhs + rhs)
    }
}
