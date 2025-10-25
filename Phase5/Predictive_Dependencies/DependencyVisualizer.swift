//
//  DependencyVisualizer.swift
//  Predictive Dependencies
//
//  Interactive visualization system for dependency graphs, predictions,
//  and impact analysis using SwiftUI and Charts.
//

import Charts
import Foundation
import SwiftUI

/// Interactive dependency visualizer
@available(macOS 12.0, *)
public struct DependencyVisualizer {

    // MARK: - Properties

    private let fileManager = FileManager.default

    /// Visualization configuration
    public struct VisualizationConfig {
        public var graphLayout: GraphLayout = .forceDirected
        public var showPredictions: Bool = true
        public var showImpactAnalysis: Bool = true
        public var colorScheme: ColorScheme = .adaptive
        public var animationEnabled: Bool = true
        public var maxNodesDisplayed: Int = 100

        public init() {}
    }

    public enum GraphLayout {
        case hierarchical
        case circular
        case forceDirected
        case grid
    }

    public enum ColorScheme {
        case adaptive
        case highContrast
        case colorBlind
        case custom([String: Color])
    }

    private var config: VisualizationConfig

    // MARK: - Initialization

    public init(config: VisualizationConfig = VisualizationConfig()) {
        self.config = config
    }

    // MARK: - Public API

    /// Create a dependency graph view
    public func createDependencyGraphView(for project: ProjectDependencies) -> some View {
        DependencyGraphView(project: project, config: config)
    }

    /// Create a prediction visualization view
    public func createPredictionView(for predictions: [String: [DependencyPrediction]]) -> some View {
        PredictionVisualizationView(predictions: predictions, config: config)
    }

    /// Create an impact analysis view
    public func createImpactAnalysisView(for impact: ChangeImpact) -> some View {
        ImpactAnalysisView(impact: impact, config: config)
    }

    /// Create a metrics dashboard view
    public func createMetricsDashboardView(for metrics: DependencyMetrics) -> some View {
        MetricsDashboardView(metrics: metrics, config: config)
    }

    /// Create a combined analysis view
    public func createCombinedAnalysisView(
        project: ProjectDependencies,
        predictions: [String: [DependencyPrediction]],
        impact: ChangeImpact?,
        metrics: DependencyMetrics
    ) -> some View {
        CombinedAnalysisView(
            project: project,
            predictions: predictions,
            impact: impact,
            metrics: metrics,
            config: config
        )
    }

    /// Export visualization as image
    public func exportVisualization(
        _ view: some View, to path: String, size: CGSize = CGSize(width: 1200, height: 800)
    ) async throws {
        // This would use SwiftUI's ImageRenderer in iOS 16+ / macOS 13+
        // For now, this is a placeholder
        print("Visualization export not implemented in this version")
    }

    /// Generate HTML report
    public func generateHTMLReport(
        project: ProjectDependencies,
        predictions: [String: [DependencyPrediction]],
        impact: ChangeImpact?,
        metrics: DependencyMetrics
    ) -> String {
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Dependency Analysis Report</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; }
                .section { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
                .metric { display: inline-block; margin: 10px; padding: 10px; background: #f0f0f0; border-radius: 4px; }
                .warning { color: #d73a49; }
                .success { color: #28a745; }
                table { border-collapse: collapse; width: 100%; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
            </style>
        </head>
        <body>
            <h1>Dependency Analysis Report</h1>
            <p>Generated on \(Date().formatted())</p>
        """

        // Project Overview
        html += """
            <div class="section">
                <h2>Project Overview</h2>
                <div class="metric">Files: \(project.fileDependencies.count)</div>
                <div class="metric">Total Dependencies: \(project.projectGraph.allDependencies.count)</div>
                <div class="metric">Circular Dependencies: \(project.circularDependencies.count)</div>
            </div>
        """

        // Metrics
        html += """
            <div class="section">
                <h2>Dependency Metrics</h2>
                <div class="metric">Average Dependencies/File: \(String(format: "%.1f", metrics.averageDependenciesPerFile))</div>
                <div class="metric">Dependency Density: \(String(format: "%.3f", metrics.dependencyDensity))</div>
                <div class="metric">Stability Index: \(String(format: "%.2f", metrics.stabilityIndex))</div>
            </div>
        """

        // Circular Dependencies
        if !project.circularDependencies.isEmpty {
            html += """
                <div class="section">
                    <h2 class="warning">Circular Dependencies</h2>
                    <table>
                        <tr><th>Cycle</th><th>Files</th></tr>
            """

            for (index, cycle) in project.circularDependencies.enumerated() {
                html += "<tr><td>\(index + 1)</td><td>\(cycle.joined(separator: " → "))</td></tr>"
            }

            html += "</table></div>"
        }

        // Predictions
        let highConfidencePredictions = predictions.values.flatMap { $0 }.filter {
            $0.confidence > 0.7
        }
        if !highConfidencePredictions.isEmpty {
            html += """
                <div class="section">
                    <h2>High Confidence Predictions</h2>
                    <table>
                        <tr><th>Dependency</th><th>Confidence</th><th>Reasoning</th></tr>
            """

            for prediction in highConfidencePredictions.sorted(by: { $0.confidence > $1.confidence }
            ) {
                html += """
                    <tr>
                        <td>\(prediction.dependency)</td>
                        <td>\(String(format: "%.2f", prediction.confidence))</td>
                        <td>\(prediction.reasoning)</td>
                    </tr>
                """
            }

            html += "</table></div>"
        }

        // Impact Analysis
        if let impact {
            html += """
                <div class="section">
                    <h2>Change Impact Analysis</h2>
                    <div class="metric">Direct Impact: \(impact.directImpact)</div>
                    <div class="metric">Indirect Impact: \(impact.indirectImpact)</div>
                    <div class="metric">Total Impact: \(impact.totalImpact)</div>
                    <div class="metric">Risk Score: \(String(format: "%.2f", impact.riskScore))</div>
                </div>
            """
        }

        html += "</body></html>"
        return html
    }
}

// MARK: - SwiftUI Views

/// Dependency graph visualization view
@available(macOS 12.0, *)
struct DependencyGraphView: View {
    let project: ProjectDependencies
    let config: DependencyVisualizer.VisualizationConfig

    @State private var selectedNode: String?
    @State private var zoom: CGFloat = 1.0

    var body: some View {
        VStack {
            HStack {
                Text("Dependency Graph")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { zoom = min(zoom * 1.2, 3.0) }) {
                    Image(systemName: "plus.magnifyingglass")
                }
                Button(action: { zoom = max(zoom * 0.8, 0.5) }) {
                    Image(systemName: "minus.magnifyingglass")
                }
            }
            .padding()

            ZStack {
                ForEach(project.projectGraph.allNodes, id: \.self) { node in
                    DependencyNodeView(
                        node: node,
                        isSelected: selectedNode == node,
                        dependencies: project.projectGraph.getDependencies(for: node),
                        dependents: project.projectGraph.getDependents(of: node)
                    )
                    .position(getNodePosition(for: node))
                    .scaleEffect(selectedNode == node ? 1.2 : 1.0)
                    .onTapGesture {
                        withAnimation {
                            selectedNode = selectedNode == node ? nil : node
                        }
                    }
                }

                ForEach(project.projectGraph.allDependencies, id: \.from) { dependency in
                    DependencyEdgeView(
                        from: getNodePosition(for: dependency.from),
                        to: getNodePosition(for: dependency.to),
                        isHighlighted: selectedNode == dependency.from
                            || selectedNode == dependency.to
                    )
                }
            }
            .scaleEffect(zoom)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        zoom = value
                    }
            )

            if let selectedNode {
                NodeDetailView(node: selectedNode, project: project)
                    .padding()
                    .background(Color(.windowBackgroundColor).opacity(0.9))
                    .cornerRadius(8)
                    .shadow(radius: 4)
            }
        }
    }

    private func getNodePosition(for node: String) -> CGPoint {
        // Simple circular layout for demonstration
        let nodes = Array(project.projectGraph.allNodes)
        guard let index = nodes.firstIndex(of: node) else { return .zero }

        let angle = (2 * .pi * Double(index)) / Double(nodes.count)
        let radius: CGFloat = 200
        let center = CGPoint(x: 400, y: 300)

        return CGPoint(
            x: center.x + radius * cos(CGFloat(angle)),
            y: center.y + radius * sin(CGFloat(angle))
        )
    }
}

/// Individual dependency node view
@available(macOS 12.0, *)
struct DependencyNodeView: View {
    let node: String
    let isSelected: Bool
    let dependencies: Set<String>
    let dependents: Set<String>

    var body: some View {
        ZStack {
            Circle()
                .fill(nodeColor)
                .frame(width: nodeSize, height: nodeSize)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray, lineWidth: isSelected ? 3 : 1)
                )

            Text(node.split(separator: "/").last ?? node)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(width: nodeSize - 8, height: nodeSize - 8)
        }
    }

    private var nodeSize: CGFloat {
        let baseSize: CGFloat = 40
        let scale = min(1.0 + Double(dependencies.count + dependents.count) * 0.1, 2.0)
        return baseSize * CGFloat(scale)
    }

    private var nodeColor: Color {
        if dependencies.count > 5 {
            return .red // High outgoing dependencies
        } else if dependents.count > 5 {
            return .orange // High incoming dependencies
        } else {
            return .blue // Normal dependencies
        }
    }
}

/// Dependency edge view
@available(macOS 12.0, *)
struct DependencyEdgeView: View {
    let from: CGPoint
    let to: CGPoint
    let isHighlighted: Bool

    var body: some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(
            isHighlighted ? Color.blue : Color.gray.opacity(0.5), lineWidth: isHighlighted ? 2 : 1
        )
    }
}

/// Node detail view
@available(macOS 12.0, *)
struct NodeDetailView: View {
    let node: String
    let project: ProjectDependencies

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(node)
                .font(.headline)

            if let fileDeps = project.fileDependencies[node] {
                Text("Dependencies: \(fileDeps.dependencyCount)")
                    .font(.subheadline)

                Text("Internal: \(fileDeps.internalDependencies.count)")
                Text("External: \(fileDeps.externalDependencies.count)")
                Text("Complexity: \(String(format: "%.2f", fileDeps.complexityScore))")
            }

            let outgoing = project.projectGraph.getDependencies(for: node)
            let incoming = project.projectGraph.getDependents(of: node)

            if !outgoing.isEmpty {
                Text("Depends on: \(outgoing.count)")
                    .font(.subheadline)
                ForEach(Array(outgoing).prefix(5), id: \.self) { dep in
                    Text("• \(dep)")
                        .font(.caption)
                }
            }

            if !incoming.isEmpty {
                Text("Used by: \(incoming.count)")
                    .font(.subheadline)
                ForEach(Array(incoming).prefix(5), id: \.self) { dep in
                    Text("• \(dep)")
                        .font(.caption)
                }
            }
        }
        .frame(width: 250)
    }
}

/// Prediction visualization view
@available(macOS 12.0, *)
struct PredictionVisualizationView: View {
    let predictions: [String: [DependencyPrediction]]
    let config: DependencyVisualizer.VisualizationConfig

    @State private var selectedFile: String?

    var body: some View {
        VStack {
            Text("Dependency Predictions")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Picker("File", selection: $selectedFile) {
                Text("All Files").tag(String?.none)
                ForEach(predictions.keys.sorted(), id: \.self) { file in
                    Text(URL(fileURLWithPath: file).lastPathComponent).tag(file as String?)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)

            if let selectedFile, let filePredictions = predictions[selectedFile] {
                PredictionChartView(predictions: filePredictions)
            } else {
                // Show aggregated predictions
                let allPredictions = predictions.values.flatMap { $0 }
                PredictionChartView(predictions: allPredictions)
            }
        }
    }
}

/// Prediction chart view
@available(macOS 12.0, *)
struct PredictionChartView: View {
    let predictions: [DependencyPrediction]

    var body: some View {
        Chart(predictions.sorted(by: { $0.confidence > $1.confidence }).prefix(20)) { prediction in
            BarMark(
                x: .value("Dependency", prediction.dependency),
                y: .value("Confidence", prediction.confidence)
            )
            .foregroundStyle(
                prediction.confidence > 0.7
                    ? Color.green : prediction.confidence > 0.5 ? Color.yellow : Color.red)
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.caption)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 300)
        .padding()
    }
}

/// Impact analysis view
@available(macOS 12.0, *)
struct ImpactAnalysisView: View {
    let impact: ChangeImpact
    let config: DependencyVisualizer.VisualizationConfig

    var body: some View {
        VStack {
            Text("Change Impact Analysis")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            HStack(spacing: 20) {
                ImpactMetricView(title: "Direct Impact", value: impact.directImpact, color: .red)
                ImpactMetricView(
                    title: "Indirect Impact", value: impact.indirectImpact, color: .orange
                )
                ImpactMetricView(title: "Total Impact", value: impact.totalImpact, color: .blue)
                ImpactMetricView(
                    title: "Risk Score", value: Int(impact.riskScore * 100), color: .purple,
                    isPercentage: true
                )
            }
            .padding()

            if !impact.affectedFiles.isEmpty {
                Text("Affected Files")
                    .font(.headline)
                    .padding(.top)

                List(impact.affectedFiles.sorted(), id: \.self) { file in
                    Text(URL(fileURLWithPath: file).lastPathComponent)
                        .font(.caption)
                }
                .frame(height: 200)
            }
        }
    }
}

/// Impact metric view
@available(macOS 12.0, *)
struct ImpactMetricView: View {
    let title: String
    let value: Int
    let color: Color
    var isPercentage: Bool = false

    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(isPercentage ? "\(value)%" : "\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

/// Metrics dashboard view
@available(macOS 12.0, *)
struct MetricsDashboardView: View {
    let metrics: DependencyMetrics
    let config: DependencyVisualizer.VisualizationConfig

    var body: some View {
        VStack {
            Text("Dependency Metrics")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                MetricCardView(
                    title: "Total Dependencies", value: "\(metrics.totalDependencies)", color: .blue
                )
                MetricCardView(
                    title: "Average per File",
                    value: String(format: "%.1f", metrics.averageDependenciesPerFile), color: .green
                )
                MetricCardView(
                    title: "Dependency Density",
                    value: String(format: "%.3f", metrics.dependencyDensity), color: .orange
                )
                MetricCardView(
                    title: "Stability Index", value: String(format: "%.2f", metrics.stabilityIndex),
                    color: .purple
                )
                MetricCardView(
                    title: "Circular Dependencies", value: "\(metrics.circularDependenciesCount)",
                    color: .red
                )
                MetricCardView(
                    title: "Strongly Connected Components",
                    value: "\(metrics.stronglyConnectedComponents)", color: .teal
                )
            }
            .padding()
        }
    }
}

/// Metric card view
@available(macOS 12.0, *)
struct MetricCardView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

/// Combined analysis view
@available(macOS 12.0, *)
struct CombinedAnalysisView: View {
    let project: ProjectDependencies
    let predictions: [String: [DependencyPrediction]]
    let impact: ChangeImpact?
    let metrics: DependencyMetrics
    let config: DependencyVisualizer.VisualizationConfig

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DependencyGraphView(project: project, config: config)
                .tabItem {
                    Label("Graph", systemImage: "network")
                }
                .tag(0)

            PredictionVisualizationView(predictions: predictions, config: config)
                .tabItem {
                    Label("Predictions", systemImage: "chart.bar")
                }
                .tag(1)

            MetricsDashboardView(metrics: metrics, config: config)
                .tabItem {
                    Label("Metrics", systemImage: "chart.pie")
                }
                .tag(2)

            if let impact {
                ImpactAnalysisView(impact: impact, config: config)
                    .tabItem {
                        Label("Impact", systemImage: "exclamationmark.triangle")
                    }
                    .tag(3)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

// MARK: - Preview Provider

@available(macOS 12.0, *)
struct DependencyVisualizer_Previews: PreviewProvider {
    static var previews: some View {
        // Create sample data for preview
        let sampleProject = createSampleProject()
        let samplePredictions = createSamplePredictions()
        let sampleMetrics = createSampleMetrics()

        return DependencyVisualizer().createCombinedAnalysisView(
            project: sampleProject,
            predictions: samplePredictions,
            impact: nil,
            metrics: sampleMetrics
        )
    }

    static func createSampleProject() -> ProjectDependencies {
        // Create sample project data
        var fileDeps: [String: FileDependencies] = [:]

        let file1 = FileDependencies(
            filePath: "/Project/File1.swift",
            dependencies: ["Foundation", "UIKit"],
            internalDependencies: ["UIKit"],
            externalDependencies: ["Foundation"],
            imports: ["Foundation", "UIKit"],
            typeDependencies: ["UIView"],
            functionDependencies: ["print"],
            dependencyCount: 2,
            complexityScore: 0.3,
            analysisTimestamp: Date()
        )

        let file2 = FileDependencies(
            filePath: "/Project/File2.swift",
            dependencies: ["Foundation", "File1"],
            internalDependencies: ["File1"],
            externalDependencies: ["Foundation"],
            imports: ["Foundation"],
            typeDependencies: [],
            functionDependencies: [],
            dependencyCount: 2,
            complexityScore: 0.2,
            analysisTimestamp: Date()
        )

        fileDeps[file1.filePath] = file1
        fileDeps[file2.filePath] = file2

        let graph = DependencyGraph()
        graph.addDependency(from: file2.filePath, to: file1.filePath)

        return ProjectDependencies(
            fileDependencies: fileDeps,
            projectGraph: graph,
            circularDependencies: [],
            stronglyConnectedComponents: [[file1.filePath], [file2.filePath]],
            analysisTimestamp: Date()
        )
    }

    static func createSamplePredictions() -> [String: [DependencyPrediction]] {
        let prediction = DependencyPrediction(
            dependency: "Combine",
            confidence: 0.8,
            reasoning: "Similar files use reactive programming",
            features: [:],
            predictionTimestamp: Date()
        )

        return ["/Project/File1.swift": [prediction]]
    }

    static func createSampleMetrics() -> DependencyMetrics {
        DependencyMetrics(
            totalDependencies: 3,
            averageDependenciesPerFile: 1.5,
            maxDependenciesPerFile: 2,
            minDependenciesPerFile: 1,
            dependencyDensity: 0.5,
            stronglyConnectedComponents: 2,
            averageComponentSize: 1.0,
            stabilityIndex: 0.8,
            circularDependenciesCount: 0,
            analysisTimestamp: Date()
        )
    }
}
