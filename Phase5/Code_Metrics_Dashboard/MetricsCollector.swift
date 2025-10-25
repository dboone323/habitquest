//
//  MetricsCollector.swift
//  Code Metrics Dashboard
//
//  Real-time collection and analysis of code metrics
//  including complexity, coverage, performance, and quality indicators.
//

import Combine
import Foundation
import SwiftParser
import SwiftSyntax

/// Comprehensive metrics collector for code analysis
@available(macOS 12.0, *)
public class MetricsCollector {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private let metricsQueue = DispatchQueue(
        label: "com.quantum.metrics-collector", qos: .userInitiated
    )

    private var collectedMetrics: [String: CodeMetrics] = [:]
    private var metricHistory: [String: [Date: CodeMetrics]] = [:]

    private var analysisTasks: [UUID: Task<Void, Error>] = [:]
    private var cancellables = Set<AnyCancellable>()

    /// Configuration for metrics collection
    public struct Configuration {
        public var analysisInterval: TimeInterval = 30.0 // 30 seconds
        public var enableRealTimeAnalysis: Bool = true
        public var maxHistorySize: Int = 100
        public var analysisTimeout: TimeInterval = 60.0
        public var enableIncrementalAnalysis: Bool = true
        public var complexityThresholds: ComplexityThresholds = .default

        public init() {}
    }

    private var config: Configuration

    /// Complexity thresholds for analysis
    public struct ComplexityThresholds {
        public var maxCyclomaticComplexity: Int = 10
        public var maxCognitiveComplexity: Int = 15
        public var maxFunctionLength: Int = 50
        public var maxFileLength: Int = 500
        public var maxNestingDepth: Int = 4

        public static let `default` = ComplexityThresholds()
        public static let strict = ComplexityThresholds(
            maxCyclomaticComplexity: 5,
            maxCognitiveComplexity: 8,
            maxFunctionLength: 30,
            maxFileLength: 300,
            maxNestingDepth: 3
        )
    }

    // MARK: - Public Properties

    public var analysisInProgress: Bool {
        !analysisTasks.isEmpty
    }

    public var totalFilesAnalyzed: Int {
        collectedMetrics.count
    }

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration

        if config.enableRealTimeAnalysis {
            startRealTimeAnalysis()
        }
    }

    deinit {
        stopRealTimeAnalysis()
    }

    // MARK: - Public API

    /// Analyze a single file
    public func analyzeFile(at path: String) async throws -> CodeMetrics {
        let url = URL(fileURLWithPath: path)

        guard fileManager.fileExists(atPath: path) else {
            throw MetricsError.fileNotFound(path)
        }

        let source = try String(contentsOf: url, encoding: .utf8)
        return try await analyzeSource(source, filePath: path)
    }

    /// Analyze all files in a directory
    public func analyzeDirectory(at path: String, fileExtensions: [String] = ["swift"]) async throws
        -> [String: CodeMetrics]
    {
        guard fileManager.fileExists(atPath: path) else {
            throw MetricsError.directoryNotFound(path)
        }

        let urls = try findFiles(in: URL(fileURLWithPath: path), withExtensions: fileExtensions)
        var results: [String: CodeMetrics] = [:]

        try await withThrowingTaskGroup(of: (String, CodeMetrics).self) { group in
            for url in urls {
                group.addTask {
                    let metrics = try await self.analyzeFile(at: url.path)
                    return (url.path, metrics)
                }
            }

            for try await (path, metrics) in group {
                results[path] = metrics
            }
        }

        // Update collected metrics
        await metricsQueue.sync {
            for (path, metrics) in results {
                collectedMetrics[path] = metrics
                updateMetricHistory(for: path, metrics: metrics)
            }
        }

        return results
    }

    /// Start real-time analysis for a workspace
    public func startRealTimeAnalysis(for workspacePath: String) {
        guard config.enableRealTimeAnalysis else { return }

        let workspaceURL = URL(fileURLWithPath: workspacePath)

        // Monitor file system changes
        let monitor = FileSystemMonitor(url: workspaceURL) { [weak self] changes in
            Task {
                await self?.handleFileSystemChanges(changes)
            }
        }

        // Start periodic analysis
        Timer.publish(every: config.analysisInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    try? await self?.performPeriodicAnalysis(for: workspacePath)
                }
            }
            .store(in: &cancellables)
    }

    /// Stop real-time analysis
    public func stopRealTimeAnalysis() {
        cancellables.removeAll()
        analysisTasks.values.forEach { $0.cancel() }
        analysisTasks.removeAll()
    }

    /// Get current metrics for a file
    public func getMetrics(for filePath: String) -> CodeMetrics? {
        metricsQueue.sync { collectedMetrics[filePath] }
    }

    /// Get metrics history for a file
    public func getMetricsHistory(for filePath: String) -> [Date: CodeMetrics] {
        metricsQueue.sync { metricHistory[filePath] ?? [:] }
    }

    /// Get aggregate metrics for the entire codebase
    public func getAggregateMetrics() -> AggregateMetrics {
        metricsQueue.sync {
            let allMetrics = Array(collectedMetrics.values)

            guard !allMetrics.isEmpty else {
                return AggregateMetrics.empty
            }

            let totalLines = allMetrics.reduce(0) { $0 + $1.linesOfCode }
            let totalFunctions = allMetrics.reduce(0) { $0 + $1.functionCount }
            let totalClasses = allMetrics.reduce(0) { $0 + $1.classCount }
            let totalComplexity = allMetrics.reduce(0) { $0 + $1.averageComplexity }

            let averageComplexity = Double(totalComplexity) / Double(allMetrics.count)
            let averageLinesPerFunction =
                totalFunctions > 0 ? Double(totalLines) / Double(totalFunctions) : 0

            // Calculate quality scores
            let complexityScore = calculateComplexityScore(allMetrics)
            let coverageScore = 0.0 // Would be calculated from test coverage data
            let maintainabilityScore = calculateMaintainabilityScore(allMetrics)

            // Identify hotspots
            let complexityHotspots =
                allMetrics
                    .filter {
                        $0.averageComplexity
                            > Double(config.complexityThresholds.maxCyclomaticComplexity)
                    }
                    .map(\.filePath)

            let largeFiles =
                allMetrics
                    .filter { $0.linesOfCode > config.complexityThresholds.maxFileLength }
                    .map(\.filePath)

            return AggregateMetrics(
                totalFiles: allMetrics.count,
                totalLinesOfCode: totalLines,
                totalFunctions: totalFunctions,
                totalClasses: totalClasses,
                averageComplexity: averageComplexity,
                averageLinesPerFunction: averageLinesPerFunction,
                complexityScore: complexityScore,
                coverageScore: coverageScore,
                maintainabilityScore: maintainabilityScore,
                complexityHotspots: complexityHotspots,
                largeFiles: largeFiles,
                analysisTimestamp: Date()
            )
        }
    }

    /// Export metrics to various formats
    public func exportMetrics(to format: ExportFormat, at path: String) throws {
        let aggregateMetrics = getAggregateMetrics()

        switch format {
        case .json:
            try exportAsJSON(aggregateMetrics, to: path)
        case .csv:
            try exportAsCSV(aggregateMetrics, to: path)
        case .html:
            try exportAsHTML(aggregateMetrics, to: path)
        }
    }

    // MARK: - Private Methods

    private func analyzeSource(_ source: String, filePath: String) async throws -> CodeMetrics {
        // Parse Swift syntax
        let sourceFile = try Parser.parse(source: source)

        // Analyze syntax tree
        let analyzer = SyntaxAnalyzer()
        let analysis = analyzer.analyze(sourceFile)

        // Calculate metrics
        let linesOfCode = source.components(separatedBy: .newlines).count
        let functionCount = analysis.functions.count
        let classCount = analysis.classes.count
        let structCount = analysis.structs.count

        // Calculate complexity metrics
        let cyclomaticComplexity = calculateCyclomaticComplexity(analysis.functions)
        let cognitiveComplexity = calculateCognitiveComplexity(analysis.functions)

        // Calculate quality metrics
        let duplicationPercentage = calculateCodeDuplication(source)
        let commentRatio = calculateCommentRatio(source)

        // Check against thresholds
        let complexityViolations = checkComplexityViolations(analysis.functions)
        let styleViolations = checkStyleViolations(source)

        return CodeMetrics(
            filePath: filePath,
            linesOfCode: linesOfCode,
            functionCount: functionCount,
            classCount: classCount,
            structCount: structCount,
            averageComplexity: Double(cyclomaticComplexity) / Double(max(functionCount, 1)),
            maxComplexity: cyclomaticComplexity.max() ?? 0,
            cognitiveComplexity: cognitiveComplexity,
            commentRatio: commentRatio,
            duplicationPercentage: duplicationPercentage,
            complexityViolations: complexityViolations,
            styleViolations: styleViolations,
            analysisTimestamp: Date()
        )
    }

    private func calculateCyclomaticComplexity(_ functions: [FunctionInfo]) -> [Int] {
        functions.map { function in
            var complexity = 1 // Base complexity

            // Count control flow statements
            let controlFlowKeywords = [
                "if", "else", "for", "while", "repeat", "switch", "case", "catch", "guard",
            ]
            for keyword in controlFlowKeywords {
                complexity += (function.body.range(of: keyword) != nil ? 1 : 0)
            }

            // Count logical operators
            let logicalOperators = ["&&", "||", "??"]
            for op in logicalOperators {
                complexity += function.body.components(separatedBy: op).count - 1
            }

            return complexity
        }
    }

    private func calculateCognitiveComplexity(_ functions: [FunctionInfo]) -> Int {
        // Simplified cognitive complexity calculation
        // In a real implementation, this would use more sophisticated analysis
        var totalComplexity = 0

        for function in functions {
            var complexity = 0

            // Nesting increases complexity
            let nestingLevel = function.body.components(separatedBy: "{").count - 1
            complexity += nestingLevel

            // Control structures add complexity
            complexity += function.body.components(separatedBy: "if ").count - 1
            complexity += function.body.components(separatedBy: "else").count - 1
            complexity += function.body.components(separatedBy: "for ").count - 1
            complexity += function.body.components(separatedBy: "while ").count - 1

            totalComplexity += complexity
        }

        return totalComplexity
    }

    private func calculateCodeDuplication(_ source: String) -> Double {
        // Simplified duplication detection
        // In a real implementation, this would use more sophisticated algorithms
        let lines = source.components(separatedBy: .newlines)
        var duplicateLines = 0

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.count > 10 { // Only check substantial lines
                for otherIndex in (index + 1) ..< lines.count {
                    if lines[otherIndex].trimmingCharacters(in: .whitespaces) == trimmed {
                        duplicateLines += 1
                        break
                    }
                }
            }
        }

        return Double(duplicateLines) / Double(max(lines.count, 1))
    }

    private func calculateCommentRatio(_ source: String) -> Double {
        let lines = source.components(separatedBy: .newlines)
        let commentLines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("//") || trimmed.hasPrefix("/*") || trimmed.hasPrefix("*")
        }.count

        return Double(commentLines) / Double(max(lines.count, 1))
    }

    private func checkComplexityViolations(_ functions: [FunctionInfo]) -> [ComplexityViolation] {
        var violations: [ComplexityViolation] = []

        for function in functions {
            let complexity = calculateCyclomaticComplexity([function]).first ?? 0

            if complexity > config.complexityThresholds.maxCyclomaticComplexity {
                violations.append(
                    ComplexityViolation(
                        type: .cyclomaticComplexity,
                        functionName: function.name,
                        value: complexity,
                        threshold: config.complexityThresholds.maxCyclomaticComplexity
                    ))
            }

            if function.body.components(separatedBy: .newlines).count
                > config.complexityThresholds.maxFunctionLength
            {
                violations.append(
                    ComplexityViolation(
                        type: .functionLength,
                        functionName: function.name,
                        value: function.body.components(separatedBy: .newlines).count,
                        threshold: config.complexityThresholds.maxFunctionLength
                    ))
            }
        }

        return violations
    }

    private func checkStyleViolations(_ source: String) -> [StyleViolation] {
        var violations: [StyleViolation] = []

        let lines = source.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            // Check line length
            if line.count > 120 {
                violations.append(
                    StyleViolation(
                        type: .lineLength,
                        line: index + 1,
                        message: "Line exceeds 120 characters"
                    ))
            }

            // Check trailing whitespace
            if line.hasSuffix(" ") || line.hasSuffix("\t") {
                violations.append(
                    StyleViolation(
                        type: .trailingWhitespace,
                        line: index + 1,
                        message: "Line has trailing whitespace"
                    ))
            }
        }

        return violations
    }

    private func calculateComplexityScore(_ metrics: [CodeMetrics]) -> Double {
        let violations = metrics.flatMap(\.complexityViolations)
        let totalViolations = violations.count
        let maxExpectedViolations = metrics.count * 2 // Allow 2 violations per file

        if maxExpectedViolations == 0 { return 1.0 }

        let score = 1.0 - Double(totalViolations) / Double(maxExpectedViolations)
        return max(0.0, min(1.0, score))
    }

    private func calculateMaintainabilityScore(_ metrics: [CodeMetrics]) -> Double {
        let averageComplexity =
            metrics.map(\.averageComplexity).reduce(0, +) / Double(metrics.count)
        let averageCommentRatio =
            metrics.map(\.commentRatio).reduce(0, +) / Double(metrics.count)

        // Maintainability index formula (simplified)
        let complexityFactor = max(0, 1.0 - averageComplexity / 20.0)
        let commentFactor = averageCommentRatio

        return (complexityFactor + commentFactor) / 2.0
    }

    private func findFiles(in directory: URL, withExtensions extensions: [String]) throws -> [URL] {
        let resourceKeys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey]
        let enumerator = fileManager.enumerator(
            at: directory, includingPropertiesForKeys: resourceKeys
        )!

        var files: [URL] = []

        for case let url as URL in enumerator {
            let resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))

            guard resourceValues.isRegularFile == true else { continue }

            if extensions.contains(url.pathExtension) {
                files.append(url)
            }
        }

        return files
    }

    private func handleFileSystemChanges(_ changes: [FileSystemChange]) {
        // Handle incremental analysis for changed files
        for change in changes {
            switch change.type {
            case .modified, .created:
                let taskId = UUID()
                let task = Task {
                    try await self.analyzeFile(at: change.path)
                }
                analysisTasks[taskId] = task
            case .deleted:
                metricsQueue.sync {
                    collectedMetrics.removeValue(forKey: change.path)
                }
            }
        }
    }

    private func performPeriodicAnalysis(for workspacePath: String) async throws {
        try await analyzeDirectory(at: workspacePath)
    }

    private func updateMetricHistory(for filePath: String, metrics: CodeMetrics) {
        if metricHistory[filePath] == nil {
            metricHistory[filePath] = [:]
        }

        metricHistory[filePath]?[Date()] = metrics

        // Limit history size
        if let history = metricHistory[filePath], history.count > config.maxHistorySize {
            let sortedKeys = history.keys.sorted()
            let keysToRemove = sortedKeys.prefix(history.count - config.maxHistorySize)
            for key in keysToRemove {
                metricHistory[filePath]?.removeValue(forKey: key)
            }
        }
    }

    private func exportAsJSON(_ metrics: AggregateMetrics, to path: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(metrics)
        try data.write(to: URL(fileURLWithPath: path))
    }

    private func exportAsCSV(_ metrics: AggregateMetrics, to path: String) throws {
        var csv = "Metric,Value\n"
        csv += "Total Files,\(metrics.totalFiles)\n"
        csv += "Total Lines of Code,\(metrics.totalLinesOfCode)\n"
        csv += "Total Functions,\(metrics.totalFunctions)\n"
        csv += "Total Classes,\(metrics.totalClasses)\n"
        csv += "Average Complexity,\(String(format: "%.2f", metrics.averageComplexity))\n"
        csv += "Complexity Score,\(String(format: "%.2f", metrics.complexityScore))\n"
        csv += "Maintainability Score,\(String(format: "%.2f", metrics.maintainabilityScore))\n"

        try csv.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
    }

    private func exportAsHTML(_ metrics: AggregateMetrics, to path: String) throws {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Code Metrics Dashboard</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                .metric { margin: 10px 0; padding: 10px; border: 1px solid #ddd; }
                .score { font-weight: bold; }
                .good { color: green; }
                .warning { color: orange; }
                .bad { color: red; }
            </style>
        </head>
        <body>
            <h1>Code Metrics Dashboard</h1>
            <p>Analysis Timestamp: \(metrics.analysisTimestamp)</p>

            <div class="metric">
                <h3>Overview</h3>
                <p>Total Files: \(metrics.totalFiles)</p>
                <p>Total Lines of Code: \(metrics.totalLinesOfCode)</p>
                <p>Total Functions: \(metrics.totalFunctions)</p>
                <p>Total Classes: \(metrics.totalClasses)</p>
            </div>

            <div class="metric">
                <h3>Complexity Analysis</h3>
                <p>Average Complexity: \(String(format: "%.2f", metrics.averageComplexity))</p>
                <p>Complexity Score: <span class="score \(metrics.complexityScore > 0.7 ? "good" : metrics.complexityScore > 0.4 ? "warning" : "bad")">\(String(format: "%.2f", metrics.complexityScore))</span></p>
            </div>

            <div class="metric">
                <h3>Quality Metrics</h3>
                <p>Maintainability Score: <span class="score \(metrics.maintainabilityScore > 0.7 ? "good" : metrics.maintainabilityScore > 0.4 ? "warning" : "bad")">\(String(format: "%.2f", metrics.maintainabilityScore))</span></p>
            </div>

            <div class="metric">
                <h3>Hotspots</h3>
                <p>Complexity Hotspots: \(metrics.complexityHotspots.count)</p>
                <p>Large Files: \(metrics.largeFiles.count)</p>
            </div>
        </body>
        </html>
        """

        try html.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
    }
}

// MARK: - Supporting Types

/// Code metrics for a single file
public struct CodeMetrics: Codable {
    public let filePath: String
    public let linesOfCode: Int
    public let functionCount: Int
    public let classCount: Int
    public let structCount: Int
    public let averageComplexity: Double
    public let maxComplexity: Int
    public let cognitiveComplexity: Int
    public let commentRatio: Double
    public let duplicationPercentage: Double
    public let complexityViolations: [ComplexityViolation]
    public let styleViolations: [StyleViolation]
    public let analysisTimestamp: Date
}

/// Aggregate metrics for the entire codebase
public struct AggregateMetrics: Codable {
    public let totalFiles: Int
    public let totalLinesOfCode: Int
    public let totalFunctions: Int
    public let totalClasses: Int
    public let averageComplexity: Double
    public let averageLinesPerFunction: Double
    public let complexityScore: Double
    public let coverageScore: Double
    public let maintainabilityScore: Double
    public let complexityHotspots: [String]
    public let largeFiles: [String]
    public let analysisTimestamp: Date

    public static let empty = AggregateMetrics(
        totalFiles: 0,
        totalLinesOfCode: 0,
        totalFunctions: 0,
        totalClasses: 0,
        averageComplexity: 0,
        averageLinesPerFunction: 0,
        complexityScore: 0,
        coverageScore: 0,
        maintainabilityScore: 0,
        complexityHotspots: [],
        largeFiles: [],
        analysisTimestamp: Date()
    )
}

/// Complexity violation
public struct ComplexityViolation: Codable {
    public let type: ViolationType
    public let functionName: String
    public let value: Int
    public let threshold: Int

    public enum ViolationType: String, Codable {
        case cyclomaticComplexity
        case functionLength
        case nestingDepth
    }
}

/// Style violation
public struct StyleViolation: Codable {
    public let type: StyleViolationType
    public let line: Int
    public let message: String

    public enum StyleViolationType: String, Codable {
        case lineLength
        case trailingWhitespace
        case indentation
    }
}

/// Export format
public enum ExportFormat {
    case json
    case csv
    case html
}

/// File system change
public struct FileSystemChange {
    public let path: String
    public let type: ChangeType

    public enum ChangeType {
        case created
        case modified
        case deleted
    }
}

/// Function information from syntax analysis
private struct FunctionInfo {
    let name: String
    let body: String
}

/// Syntax analyzer using SwiftSyntax
private class SyntaxAnalyzer {
    struct AnalysisResult {
        let functions: [FunctionInfo]
        let classes: [String]
        let structs: [String]
    }

    func analyze(_ sourceFile: SourceFileSyntax) -> AnalysisResult {
        var functions: [FunctionInfo] = []
        var classes: [String] = []
        var structs: [String] = []

        // Walk the syntax tree to find declarations
        for member in sourceFile.statements {
            analyzeSyntax(member, functions: &functions, classes: &classes, structs: &structs)
        }

        return AnalysisResult(functions: functions, classes: classes, structs: structs)
    }

    private func analyzeSyntax(
        _ syntax: Syntax, functions: inout [FunctionInfo], classes: inout [String],
        structs: inout [String]
    ) {
        if let functionDecl = syntax.as(FunctionDeclSyntax.self) {
            let name = functionDecl.name.text
            let body = functionDecl.body?.description ?? ""
            functions.append(FunctionInfo(name: name, body: body))
        } else if let classDecl = syntax.as(ClassDeclSyntax.self) {
            classes.append(classDecl.name.text)
        } else if let structDecl = syntax.as(StructDeclSyntax.self) {
            structs.append(structDecl.name.text)
        }

        // Recursively analyze child nodes
        for child in syntax.children(viewMode: .sourceAccurate) {
            analyzeSyntax(child, functions: &functions, classes: &classes, structs: &structs)
        }
    }
}

/// File system monitor for real-time analysis
private class FileSystemMonitor {
    private var monitoredURL: URL
    private var changeHandler: ([FileSystemChange]) -> Void
    private var source: DispatchSourceFileSystemObject?

    init(url: URL, changeHandler: @escaping ([FileSystemChange]) -> Void) {
        self.monitoredURL = url
        self.changeHandler = changeHandler

        // In a real implementation, this would use FSEvents or similar
        // For now, it's a placeholder
    }
}

/// Metrics collection errors
public enum MetricsError: Error {
    case fileNotFound(String)
    case directoryNotFound(String)
    case analysisTimeout
    case parsingFailed(String)
}

// MARK: - Extensions

extension CodeMetrics: CustomStringConvertible {
    public var description: String {
        """
        Code Metrics for \(URL(fileURLWithPath: filePath).lastPathComponent):
        - Lines of Code: \(linesOfCode)
        - Functions: \(functionCount)
        - Classes: \(classCount)
        - Average Complexity: \(String(format: "%.2f", averageComplexity))
        - Max Complexity: \(maxComplexity)
        - Comment Ratio: \(String(format: "%.1f%%", commentRatio * 100))
        - Complexity Violations: \(complexityViolations.count)
        - Style Violations: \(styleViolations.count)
        """
    }
}

extension AggregateMetrics: CustomStringConvertible {
    public var description: String {
        """
        Aggregate Code Metrics:
        - Total Files: \(totalFiles)
        - Total Lines of Code: \(totalLinesOfCode)
        - Average Complexity: \(String(format: "%.2f", averageComplexity))
        - Complexity Score: \(String(format: "%.2f", complexityScore))
        - Maintainability Score: \(String(format: "%.2f", maintainabilityScore))
        - Complexity Hotspots: \(complexityHotspots.count)
        - Large Files: \(largeFiles.count)
        """
    }
}
