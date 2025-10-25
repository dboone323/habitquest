//
//  DependencyAnalyzer.swift
//  Predictive Dependencies
//
//  Intelligent dependency analysis and prediction system that analyzes
//  code relationships, predicts future dependencies, and provides insights.
//

import Foundation
import SwiftParser
import SwiftSyntax

/// Intelligent dependency analyzer with predictive capabilities
@available(macOS 12.0, *)
public class DependencyAnalyzer {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private var analysisQueue = DispatchQueue(
        label: "com.quantum.dependency-analysis", qos: .userInitiated
    )

    private var dependencyGraph: DependencyGraph = .init()
    private var historicalDependencies: [Date: DependencySnapshot] = [:]

    /// Analysis configuration
    public struct Configuration {
        public var analysisDepth: Int = 3
        public var includeExternalDependencies: Bool = true
        public var enablePrediction: Bool = true
        public var confidenceThreshold: Double = 0.7
        public var maxHistoricalData: Int = 1000

        public init() {}
    }

    private var config: Configuration

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration
    }

    // MARK: - Public API

    /// Analyze dependencies for a Swift file
    public func analyzeFile(at path: String) async throws -> FileDependencies {
        let url = URL(fileURLWithPath: path)

        guard fileManager.fileExists(atPath: path) else {
            throw DependencyError.fileNotFound(path)
        }

        let source = try String(contentsOf: url, encoding: .utf8)
        return try await analyzeSource(source, filePath: path)
    }

    /// Analyze dependencies for an entire project
    public func analyzeProject(at path: String) async throws -> ProjectDependencies {
        guard fileManager.fileExists(atPath: path) else {
            throw DependencyError.directoryNotFound(path)
        }

        let swiftFiles = try findSwiftFiles(in: URL(fileURLWithPath: path))
        var fileDependencies: [String: FileDependencies] = [:]

        try await withThrowingTaskGroup(of: (String, FileDependencies).self) { group in
            for fileURL in swiftFiles {
                group.addTask {
                    let dependencies = try await self.analyzeFile(at: fileURL.path)
                    return (fileURL.path, dependencies)
                }
            }

            for try await (path, dependencies) in group {
                fileDependencies[path] = dependencies
            }
        }

        // Build project-wide dependency graph
        let projectGraph = try buildProjectDependencyGraph(fileDependencies)
        let circularDependencies = try detectCircularDependencies(in: projectGraph)
        let stronglyConnectedComponents = findStronglyConnectedComponents(in: projectGraph)

        return ProjectDependencies(
            fileDependencies: fileDependencies,
            projectGraph: projectGraph,
            circularDependencies: circularDependencies,
            stronglyConnectedComponents: stronglyConnectedComponents,
            analysisTimestamp: Date()
        )
    }

    /// Predict future dependencies based on current patterns
    public func predictDependencies(for filePath: String, horizon: TimeInterval = 7 * 24 * 3600)
        throws -> DependencyPrediction
    {
        guard config.enablePrediction else {
            throw DependencyError.predictionDisabled
        }

        let currentDependencies = dependencyGraph.getDependencies(for: filePath)
        let historicalPatterns = analyzeHistoricalPatterns(for: filePath)

        // Simple prediction based on historical patterns
        var predictedDependencies: [PredictedDependency] = []
        var confidence = 0.0

        for pattern in historicalPatterns {
            if pattern.frequency > 0.3 { // Dependencies that appear in more than 30% of historical snapshots
                let prediction = PredictedDependency(
                    dependency: pattern.dependency,
                    confidence: pattern.frequency,
                    reasoning: "Historical pattern analysis",
                    timeHorizon: horizon
                )
                predictedDependencies.append(prediction)
                confidence += pattern.frequency
            }
        }

        confidence = min(confidence / Double(predictedDependencies.count), 1.0)

        return DependencyPrediction(
            filePath: filePath,
            currentDependencies: currentDependencies,
            predictedDependencies: predictedDependencies,
            overallConfidence: confidence,
            predictionTimestamp: Date(),
            timeHorizon: horizon
        )
    }

    /// Analyze dependency impact of a change
    public func analyzeChangeImpact(changedFiles: [String], in project: ProjectDependencies) throws
        -> ChangeImpact
    {
        var affectedFiles: Set<String> = Set(changedFiles)
        var impactChain: [String: [String]] = [:]

        // Find all files that depend on changed files
        for changedFile in changedFiles {
            let dependents = project.projectGraph.getDependents(of: changedFile)
            affectedFiles.formUnion(dependents)

            impactChain[changedFile] = Array(dependents)
        }

        // Calculate impact metrics
        let directImpact = changedFiles.count
        let indirectImpact = affectedFiles.count - changedFiles.count
        let totalImpact = affectedFiles.count

        // Calculate risk score based on dependency complexity
        let riskScore = calculateRiskScore(for: Array(affectedFiles), in: project)

        return ChangeImpact(
            changedFiles: changedFiles,
            affectedFiles: Array(affectedFiles),
            impactChain: impactChain,
            directImpact: directImpact,
            indirectImpact: indirectImpact,
            totalImpact: totalImpact,
            riskScore: riskScore,
            analysisTimestamp: Date()
        )
    }

    /// Get dependency metrics for the project
    public func getDependencyMetrics(for project: ProjectDependencies) -> DependencyMetrics {
        let graph = project.projectGraph

        let totalDependencies = graph.allDependencies.count
        let averageDependenciesPerFile =
            Double(totalDependencies) / Double(project.fileDependencies.count)

        let maxDependencies =
            project.fileDependencies.values.map(\.dependencies.count).max() ?? 0
        let minDependencies =
            project.fileDependencies.values.map(\.dependencies.count).min() ?? 0

        // Calculate dependency density
        let totalPossibleDependencies =
            project.fileDependencies.count * (project.fileDependencies.count - 1)
        let dependencyDensity =
            totalPossibleDependencies > 0
                ? Double(totalDependencies) / Double(totalPossibleDependencies) : 0

        // Calculate modularity metrics
        let stronglyConnectedComponents = project.stronglyConnectedComponents
        let averageComponentSize =
            Double(project.fileDependencies.count) / Double(stronglyConnectedComponents.count)

        // Calculate stability metrics
        let unstableDependencies = graph.allDependencies.filter { dependency in
            // Dependencies on files that change frequently
            graph.getDependents(of: dependency.to).count > 5
        }.count

        let stabilityIndex =
            totalDependencies > 0
                ? 1.0 - Double(unstableDependencies) / Double(totalDependencies) : 1.0

        return DependencyMetrics(
            totalDependencies: totalDependencies,
            averageDependenciesPerFile: averageDependenciesPerFile,
            maxDependenciesPerFile: maxDependencies,
            minDependenciesPerFile: minDependencies,
            dependencyDensity: dependencyDensity,
            stronglyConnectedComponents: stronglyConnectedComponents.count,
            averageComponentSize: averageComponentSize,
            stabilityIndex: stabilityIndex,
            circularDependenciesCount: project.circularDependencies.count,
            analysisTimestamp: Date()
        )
    }

    /// Suggest dependency optimizations
    public func suggestOptimizations(for project: ProjectDependencies) -> [DependencyOptimization] {
        var suggestions: [DependencyOptimization] = []

        // Check for circular dependencies
        if !project.circularDependencies.isEmpty {
            suggestions.append(
                DependencyOptimization(
                    type: .breakCircularDependencies,
                    title: "Break Circular Dependencies",
                    description:
                    "Found \(project.circularDependencies.count) circular dependency cycles",
                    affectedFiles: project.circularDependencies.flatMap { $0 },
                    estimatedEffort: .high,
                    expectedBenefit: .high
                ))
        }

        // Check for over-coupled files
        let overCoupledFiles = project.fileDependencies.filter { $0.value.dependencies.count > 10 }
            .map(\.key)
        if !overCoupledFiles.isEmpty {
            suggestions.append(
                DependencyOptimization(
                    type: .reduceCoupling,
                    title: "Reduce High Coupling",
                    description:
                    "Found \(overCoupledFiles.count) files with high dependency counts",
                    affectedFiles: overCoupledFiles,
                    estimatedEffort: .medium,
                    expectedBenefit: .medium
                ))
        }

        // Check for unused dependencies
        let unusedDependencies = findUnusedDependencies(in: project)
        if !unusedDependencies.isEmpty {
            suggestions.append(
                DependencyOptimization(
                    type: .removeUnusedDependencies,
                    title: "Remove Unused Dependencies",
                    description:
                    "Found \(unusedDependencies.count) potentially unused dependencies",
                    affectedFiles: unusedDependencies.map(\.file),
                    estimatedEffort: .low,
                    expectedBenefit: .low
                ))
        }

        // Check for dependency inversion opportunities
        let inversionOpportunities = findDependencyInversionOpportunities(in: project)
        if !inversionOpportunities.isEmpty {
            suggestions.append(
                DependencyOptimization(
                    type: .applyDependencyInversion,
                    title: "Apply Dependency Inversion",
                    description:
                    "Found \(inversionOpportunities.count) opportunities for dependency inversion",
                    affectedFiles: inversionOpportunities,
                    estimatedEffort: .high,
                    expectedBenefit: .high
                ))
        }

        return suggestions
    }

    // MARK: - Private Methods

    private func analyzeSource(_ source: String, filePath: String) async throws -> FileDependencies {
        // Parse Swift syntax
        let sourceFile = try Parser.parse(source: source)

        // Analyze imports
        let imports = extractImports(from: sourceFile)

        // Analyze type dependencies
        let typeDependencies = extractTypeDependencies(from: sourceFile)

        // Analyze function call dependencies
        let functionDependencies = extractFunctionDependencies(from: sourceFile)

        // Combine all dependencies
        var allDependencies = Set<String>()
        allDependencies.formUnion(imports)
        allDependencies.formUnion(typeDependencies)
        allDependencies.formUnion(functionDependencies)

        // Categorize dependencies
        let internalDependencies = allDependencies.filter { isInternalDependency($0, in: filePath) }
        let externalDependencies = allDependencies.filter {
            !isInternalDependency($0, in: filePath)
        }

        // Calculate dependency metrics
        let dependencyCount = allDependencies.count
        let complexityScore = calculateDependencyComplexity(
            internalDependencies, externalDependencies
        )

        return FileDependencies(
            filePath: filePath,
            dependencies: Array(allDependencies),
            internalDependencies: Array(internalDependencies),
            externalDependencies: Array(externalDependencies),
            imports: imports,
            typeDependencies: typeDependencies,
            functionDependencies: functionDependencies,
            dependencyCount: dependencyCount,
            complexityScore: complexityScore,
            analysisTimestamp: Date()
        )
    }

    private func extractImports(from sourceFile: SourceFileSyntax) -> [String] {
        var imports: [String] = []

        for statement in sourceFile.statements {
            if let importDecl = statement.as(ImportDeclSyntax.self) {
                let moduleName = importDecl.path.description
                imports.append(moduleName)
            }
        }

        return imports
    }

    private func extractTypeDependencies(from sourceFile: SourceFileSyntax) -> [String] {
        var typeDependencies: [String] = []

        // Walk the syntax tree to find type references
        class TypeVisitor: SyntaxVisitor {
            var types: Set<String> = []

            override func visit(_ node: TypeSyntax) -> SyntaxVisitorContinueKind {
                types.insert(node.description)
                return .visitChildren
            }

            override func visit(_ node: IdentifierTypeSyntax) -> SyntaxVisitorContinueKind {
                types.insert(node.name.text)
                return .visitChildren
            }
        }

        let visitor = TypeVisitor()
        visitor.walk(sourceFile)

        return Array(visitor.types)
    }

    private func extractFunctionDependencies(from sourceFile: SourceFileSyntax) -> [String] {
        var functionDependencies: [String] = []

        // Walk the syntax tree to find function calls
        class FunctionCallVisitor: SyntaxVisitor {
            var functionCalls: Set<String> = []

            override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
                if let identifier = node.calledExpression.as(DeclReferenceExprSyntax.self) {
                    functionCalls.insert(identifier.baseName.text)
                }
                return .visitChildren
            }
        }

        let visitor = FunctionCallVisitor()
        visitor.walk(sourceFile)

        return Array(visitor.functionCalls)
    }

    private func buildProjectDependencyGraph(_ fileDependencies: [String: FileDependencies]) throws
        -> DependencyGraph
    {
        let graph = DependencyGraph()

        for (filePath, dependencies) in fileDependencies {
            for dependency in dependencies.internalDependencies {
                // Try to resolve the dependency to a file path
                if let resolvedPath = resolveDependencyPath(
                    dependency, from: filePath, in: fileDependencies
                ) {
                    graph.addDependency(from: filePath, to: resolvedPath)
                }
            }
        }

        return graph
    }

    private func resolveDependencyPath(
        _ dependency: String, from filePath: String, in fileDependencies: [String: FileDependencies]
    ) -> String? {
        // Simple resolution - look for files with matching names
        let fileName = URL(fileURLWithPath: filePath).deletingPathExtension().lastPathComponent

        // Check if dependency matches a file name
        for path in fileDependencies.keys {
            let depFileName = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
            if dependency.contains(depFileName) || depFileName.contains(dependency) {
                return path
            }
        }

        return nil
    }

    private func detectCircularDependencies(in graph: DependencyGraph) throws -> [[String]] {
        var circularDependencies: [[String]] = []
        var visited = Set<String>()
        var recursionStack = Set<String>()

        func dfs(node: String, path: [String]) {
            visited.insert(node)
            recursionStack.insert(node)

            for neighbor in graph.getDependencies(for: node) {
                if !visited.contains(neighbor) {
                    dfs(node: neighbor, path: path + [neighbor])
                } else if recursionStack.contains(neighbor) {
                    // Found a cycle
                    if let cycleStartIndex = path.firstIndex(of: neighbor) {
                        let cycle = Array(path[cycleStartIndex...]) + [neighbor]
                        circularDependencies.append(cycle)
                    }
                }
            }

            recursionStack.remove(node)
        }

        for node in graph.allNodes {
            if !visited.contains(node) {
                dfs(node: node, path: [node])
            }
        }

        return circularDependencies
    }

    private func findStronglyConnectedComponents(in graph: DependencyGraph) -> [[String]] {
        // Simplified SCC detection using Kosaraju's algorithm
        // In a full implementation, this would be more sophisticated
        var components: [[String]] = []

        // For now, return individual nodes as components
        // A complete implementation would find actual SCCs
        for node in graph.allNodes {
            components.append([node])
        }

        return components
    }

    private func isInternalDependency(_ dependency: String, in filePath: String) -> Bool {
        // Check if dependency is from the same module/project
        // This is a simplified check
        let projectRoot = URL(fileURLWithPath: filePath).deletingLastPathComponent()
            .deletingLastPathComponent()

        // Common external frameworks
        let externalFrameworks = ["Foundation", "UIKit", "SwiftUI", "Combine", "CoreData"]

        if externalFrameworks.contains(where: { dependency.hasPrefix($0) }) {
            return false
        }

        // If it looks like a local type (starts with capital letter), consider it internal
        return dependency.first?.isUppercase ?? false
    }

    private func calculateDependencyComplexity(_ internalDeps: [String], _ externalDeps: [String])
        -> Double
    {
        let internalCount = Double(internalDeps.count)
        let externalCount = Double(externalDeps.count)
        let totalCount = internalCount + externalCount

        if totalCount == 0 { return 0 }

        // Complexity increases with internal dependencies but decreases with external ones
        // This is a simplified metric
        return (internalCount * 0.7 + externalCount * 0.3) / totalCount
    }

    private func calculateRiskScore(for files: [String], in project: ProjectDependencies) -> Double {
        var totalRisk = 0.0

        for file in files {
            if let dependencies = project.fileDependencies[file] {
                // Risk increases with dependency count and complexity
                let dependencyRisk = Double(dependencies.dependencyCount) * 0.1
                let complexityRisk = dependencies.complexityScore * 0.3
                totalRisk += dependencyRisk + complexityRisk
            }
        }

        return min(totalRisk / Double(files.count), 1.0)
    }

    private func analyzeHistoricalPatterns(for filePath: String) -> [DependencyPattern] {
        var patterns: [String: Int] = [:]
        var totalSnapshots = 0

        for snapshot in historicalDependencies.values {
            if let fileDeps = snapshot.fileDependencies[filePath] {
                totalSnapshots += 1
                for dependency in fileDeps.dependencies {
                    patterns[dependency, default: 0] += 1
                }
            }
        }

        return patterns.map { dependency, count in
            DependencyPattern(
                dependency: dependency,
                frequency: Double(count) / Double(totalSnapshots),
                lastSeen: Date() // Simplified
            )
        }
    }

    private func findUnusedDependencies(in project: ProjectDependencies) -> [UnusedDependency] {
        // This would require more sophisticated analysis
        // For now, return empty array
        []
    }

    private func findDependencyInversionOpportunities(in project: ProjectDependencies) -> [String] {
        // This would analyze the dependency graph for DIP opportunities
        // For now, return empty array
        []
    }

    private func findSwiftFiles(in directory: URL) throws -> [URL] {
        let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil)!

        var swiftFiles: [URL] = []

        for case let url as URL in enumerator {
            if url.pathExtension == "swift" {
                swiftFiles.append(url)
            }
        }

        return swiftFiles
    }
}

// MARK: - Supporting Types

/// File dependencies
public struct FileDependencies {
    public let filePath: String
    public let dependencies: [String]
    public let internalDependencies: [String]
    public let externalDependencies: [String]
    public let imports: [String]
    public let typeDependencies: [String]
    public let functionDependencies: [String]
    public let dependencyCount: Int
    public let complexityScore: Double
    public let analysisTimestamp: Date
}

/// Project dependencies
public struct ProjectDependencies {
    public let fileDependencies: [String: FileDependencies]
    public let projectGraph: DependencyGraph
    public let circularDependencies: [[String]]
    public let stronglyConnectedComponents: [[String]]
    public let analysisTimestamp: Date
}

/// Dependency graph
public class DependencyGraph {
    private var adjacencyList: [String: Set<String>] = [:]
    private var reverseAdjacencyList: [String: Set<String>] = [:]

    public var allNodes: Set<String> {
        Set(adjacencyList.keys).union(reverseAdjacencyList.keys)
    }

    public var allDependencies: [(from: String, to: String)] {
        var deps: [(String, String)] = []
        for (from, tos) in adjacencyList {
            for to in tos {
                deps.append((from, to))
            }
        }
        return deps
    }

    public func addDependency(from: String, to: String) {
        adjacencyList[from, default: []].insert(to)
        reverseAdjacencyList[to, default: []].insert(from)
    }

    public func getDependencies(for node: String) -> Set<String> {
        adjacencyList[node] ?? []
    }

    public func getDependents(of node: String) -> Set<String> {
        reverseAdjacencyList[node] ?? []
    }

    public func hasPath(from: String, to: String) -> Bool {
        var visited = Set<String>()
        var queue = [from]

        while !queue.isEmpty {
            let current = queue.removeFirst()
            if current == to { return true }

            if visited.contains(current) { continue }
            visited.insert(current)

            queue.append(contentsOf: getDependencies(for: current))
        }

        return false
    }
}

/// Dependency prediction
public struct DependencyPrediction {
    public let filePath: String
    public let currentDependencies: Set<String>
    public let predictedDependencies: [PredictedDependency]
    public let overallConfidence: Double
    public let predictionTimestamp: Date
    public let timeHorizon: TimeInterval
}

/// Predicted dependency
public struct PredictedDependency {
    public let dependency: String
    public let confidence: Double
    public let reasoning: String
    public let timeHorizon: TimeInterval
}

/// Change impact analysis
public struct ChangeImpact {
    public let changedFiles: [String]
    public let affectedFiles: [String]
    public let impactChain: [String: [String]]
    public let directImpact: Int
    public let indirectImpact: Int
    public let totalImpact: Int
    public let riskScore: Double
    public let analysisTimestamp: Date
}

/// Dependency metrics
public struct DependencyMetrics {
    public let totalDependencies: Int
    public let averageDependenciesPerFile: Double
    public let maxDependenciesPerFile: Int
    public let minDependenciesPerFile: Int
    public let dependencyDensity: Double
    public let stronglyConnectedComponents: Int
    public let averageComponentSize: Double
    public let stabilityIndex: Double
    public let circularDependenciesCount: Int
    public let analysisTimestamp: Date
}

/// Dependency optimization suggestion
public struct DependencyOptimization {
    public let type: OptimizationType
    public let title: String
    public let description: String
    public let affectedFiles: [String]
    public let estimatedEffort: EffortLevel
    public let expectedBenefit: BenefitLevel

    public enum OptimizationType {
        case breakCircularDependencies
        case reduceCoupling
        case removeUnusedDependencies
        case applyDependencyInversion
    }

    public enum EffortLevel {
        case low, medium, high
    }

    public enum BenefitLevel {
        case low, medium, high
    }
}

/// Dependency pattern from historical analysis
private struct DependencyPattern {
    let dependency: String
    let frequency: Double
    let lastSeen: Date
}

/// Dependency snapshot for historical tracking
private struct DependencySnapshot {
    let timestamp: Date
    let fileDependencies: [String: FileDependencies]
}

/// Dependency errors
public enum DependencyError: Error {
    case fileNotFound(String)
    case directoryNotFound(String)
    case parsingFailed(String)
    case predictionDisabled
    case analysisFailed(String)
}

// MARK: - Extensions

extension FileDependencies: CustomStringConvertible {
    public var description: String {
        """
        Dependencies for \(URL(fileURLWithPath: filePath).lastPathComponent):
        - Total Dependencies: \(dependencyCount)
        - Internal: \(internalDependencies.count)
        - External: \(externalDependencies.count)
        - Complexity Score: \(String(format: "%.2f", complexityScore))
        """
    }
}

extension ProjectDependencies: CustomStringConvertible {
    public var description: String {
        """
        Project Dependencies:
        - Files Analyzed: \(fileDependencies.count)
        - Total Dependencies: \(projectGraph.allDependencies.count)
        - Circular Dependencies: \(circularDependencies.count)
        - Strongly Connected Components: \(stronglyConnectedComponents.count)
        """
    }
}

extension DependencyMetrics: CustomStringConvertible {
    public var description: String {
        """
        Dependency Metrics:
        - Total Dependencies: \(totalDependencies)
        - Average per File: \(String(format: "%.1f", averageDependenciesPerFile))
        - Dependency Density: \(String(format: "%.3f", dependencyDensity))
        - Stability Index: \(String(format: "%.2f", stabilityIndex))
        - Circular Dependencies: \(circularDependenciesCount)
        """
    }
}
