//
//  DependencyPredictor.swift
//  Predictive Dependencies
//
//  Machine learning-based dependency prediction system that analyzes
//  code patterns and predicts future dependencies using CoreML.
//

import Combine
import CoreML
import CreateML
import Foundation
import SwiftSyntax

/// Machine learning-based dependency predictor
@available(macOS 12.0, *)
public class DependencyPredictor {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private var predictionQueue = DispatchQueue(
        label: "com.quantum.dependency-prediction", qos: .userInitiated
    )

    /// Prediction model
    private var predictionModel: MLModel?

    /// Training data
    private var trainingData: [DependencyTrainingSample] = []

    /// Model configuration
    public struct ModelConfiguration {
        public var modelType: ModelType = .neuralNetwork
        public var trainingIterations: Int = 1000
        public var learningRate: Double = 0.01
        public var validationSplit: Double = 0.2
        public var minConfidenceThreshold: Double = 0.6

        public init() {}
    }

    public enum ModelType {
        case linearRegression
        case neuralNetwork
        case randomForest
        case custom(String)
    }

    private var config: ModelConfiguration

    // MARK: - Initialization

    public init(configuration: ModelConfiguration = ModelConfiguration()) {
        self.config = configuration
        loadExistingModel()
    }

    // MARK: - Public API

    /// Train the prediction model with historical dependency data
    public func trainModel(with trainingData: [DependencyTrainingSample]) async throws {
        self.trainingData = trainingData

        guard !trainingData.isEmpty else {
            throw PredictionError.insufficientTrainingData
        }

        try await predictionQueue.async {
            do {
                switch self.config.modelType {
                case .linearRegression:
                    try await self.trainLinearRegressionModel()
                case .neuralNetwork:
                    try await self.trainNeuralNetworkModel()
                case .randomForest:
                    try await self.trainRandomForestModel()
                case let .custom(modelName):
                    try await self.trainCustomModel(named: modelName)
                }
            } catch {
                throw PredictionError.trainingFailed(error.localizedDescription)
            }
        }
    }

    /// Predict dependencies for a file
    public func predictDependencies(for file: FileDependencies, context: PredictionContext)
        async throws -> [DependencyPrediction]
    {
        guard let model = predictionModel else {
            throw PredictionError.modelNotTrained
        }

        return try await predictionQueue.async {
            var predictions: [DependencyPrediction] = []

            // Extract features from the file
            let features = self.extractFeatures(from: file, context: context)

            // Get potential dependencies to predict
            let candidateDependencies = self.getCandidateDependencies(for: file, context: context)

            for candidate in candidateDependencies {
                do {
                    let prediction = try self.predictSingleDependency(
                        candidate, features: features, using: model
                    )
                    if prediction.confidence >= self.config.minConfidenceThreshold {
                        predictions.append(prediction)
                    }
                } catch {
                    // Skip failed predictions
                    continue
                }
            }

            // Sort by confidence
            return predictions.sorted { $0.confidence > $1.confidence }
        }
    }

    /// Predict dependencies for an entire project
    public func predictProjectDependencies(
        for project: ProjectDependencies, context: PredictionContext
    ) async throws -> [String: [DependencyPrediction]] {
        var projectPredictions: [String: [DependencyPrediction]] = [:]

        try await withThrowingTaskGroup(of: (String, [DependencyPrediction]).self) { group in
            for (filePath, fileDeps) in project.fileDependencies {
                group.addTask {
                    let predictions = try await self.predictDependencies(
                        for: fileDeps, context: context
                    )
                    return (filePath, predictions)
                }
            }

            for try await (filePath, predictions) in group {
                projectPredictions[filePath] = predictions
            }
        }

        return projectPredictions
    }

    /// Evaluate model performance
    public func evaluateModel(with testData: [DependencyTrainingSample]) async throws
        -> ModelPerformance
    {
        guard let model = predictionModel else {
            throw PredictionError.modelNotTrained
        }

        return try await predictionQueue.async {
            var truePositives = 0
            var falsePositives = 0
            var trueNegatives = 0
            var falseNegatives = 0

            for sample in testData {
                let features = self.extractFeatures(
                    from: sample.fileDependencies, context: sample.context
                )
                let candidateDependencies = self.getCandidateDependencies(
                    for: sample.fileDependencies, context: sample.context
                )

                for candidate in candidateDependencies {
                    do {
                        let prediction = try self.predictSingleDependency(
                            candidate, features: features, using: model
                        )
                        let actualDependency = sample.actualDependencies.contains(candidate)

                        if prediction.confidence >= self.config.minConfidenceThreshold {
                            if actualDependency {
                                truePositives += 1
                            } else {
                                falsePositives += 1
                            }
                        } else {
                            if actualDependency {
                                falseNegatives += 1
                            } else {
                                trueNegatives += 1
                            }
                        }
                    } catch {
                        continue
                    }
                }
            }

            let precision = Double(truePositives) / Double(truePositives + falsePositives)
            let recall = Double(truePositives) / Double(truePositives + falseNegatives)
            let f1Score = 2 * (precision * recall) / (precision + recall)
            let accuracy = Double(truePositives + trueNegatives) / Double(testData.count)

            return ModelPerformance(
                precision: precision.isNaN ? 0 : precision,
                recall: recall.isNaN ? 0 : recall,
                f1Score: f1Score.isNaN ? 0 : f1Score,
                accuracy: accuracy.isNaN ? 0 : accuracy,
                evaluationTimestamp: Date()
            )
        }
    }

    /// Update model with new training data
    public func updateModel(with newData: [DependencyTrainingSample]) async throws {
        trainingData.append(contentsOf: newData)

        // Retrain model with updated data
        try await trainModel(with: trainingData)
    }

    /// Save the trained model
    public func saveModel(to path: String) throws {
        guard let model = predictionModel else {
            throw PredictionError.modelNotTrained
        }

        let modelURL = URL(fileURLWithPath: path)
        try model.write(to: modelURL)
    }

    /// Load a saved model
    public func loadModel(from path: String) throws {
        let modelURL = URL(fileURLWithPath: path)
        predictionModel = try MLModel(contentsOf: modelURL)
    }

    /// Get model insights and statistics
    public func getModelInsights() -> ModelInsights {
        let trainingSamples = trainingData.count
        let featuresUsed = 15 // Number of features we extract
        let modelType = config.modelType
        let lastTrained = trainingData.last?.timestamp ?? Date.distantPast
        let performanceMetrics = getPerformanceMetrics()

        return ModelInsights(
            modelType: modelType,
            trainingSamples: trainingSamples,
            featuresUsed: featuresUsed,
            lastTrained: lastTrained,
            performanceMetrics: performanceMetrics,
            insightsTimestamp: Date()
        )
    }

    // MARK: - Private Methods

    private func loadExistingModel() {
        let modelPath = getModelPath()
        if fileManager.fileExists(atPath: modelPath) {
            do {
                try loadModel(from: modelPath)
            } catch {
                // Model couldn't be loaded, will need to train a new one
                print("Warning: Could not load existing model: \(error)")
            }
        }
    }

    private func getModelPath() -> String {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
        let quantumDir = appSupport.appendingPathComponent("Quantum")
        let modelDir = quantumDir.appendingPathComponent("Models")
        try? fileManager.createDirectory(at: modelDir, withIntermediateDirectories: true)

        return modelDir.appendingPathComponent("DependencyPredictor.mlmodel").path
    }

    private func trainLinearRegressionModel() async throws {
        // Convert training data to MLDataTable
        var dataRows: [[String: MLDataValueConvertible]] = []

        for sample in trainingData {
            let features = extractFeatures(from: sample.fileDependencies, context: sample.context)
            let candidateDeps = getCandidateDependencies(
                for: sample.fileDependencies, context: sample.context
            )

            for candidate in candidateDeps {
                var row = features
                row["dependency"] = candidate
                row["will_use"] = sample.actualDependencies.contains(candidate) ? 1.0 : 0.0
                dataRows.append(row)
            }
        }

        let dataTable = try MLDataTable(dictionary: dataRows)

        // Create and train linear regressor
        let regressor = try MLLinearRegressor(
            trainingData: dataTable,
            targetColumn: "will_use"
        )

        predictionModel = try regressor.model()
    }

    private func trainNeuralNetworkModel() async throws {
        // Convert training data to MLDataTable
        var dataRows: [[String: MLDataValueConvertible]] = []

        for sample in trainingData {
            let features = extractFeatures(from: sample.fileDependencies, context: sample.context)
            let candidateDeps = getCandidateDependencies(
                for: sample.fileDependencies, context: sample.context
            )

            for candidate in candidateDeps {
                var row = features
                row["dependency"] = candidate
                row["will_use"] = sample.actualDependencies.contains(candidate) ? 1.0 : 0.0
                dataRows.append(row)
            }
        }

        let dataTable = try MLDataTable(dictionary: dataRows)

        // Create and train neural network classifier
        let classifier = try MLNeuralNetworkClassifier(
            trainingData: dataTable,
            targetColumn: "will_use",
            featureColumns: Array(dataTable.columnNames.filter { $0 != "will_use" }),
            hiddenLayerCount: 2,
            hiddenLayerNodeCount: 10
        )

        predictionModel = try classifier.model()
    }

    private func trainRandomForestModel() async throws {
        // Convert training data to MLDataTable
        var dataRows: [[String: MLDataValueConvertible]] = []

        for sample in trainingData {
            let features = extractFeatures(from: sample.fileDependencies, context: sample.context)
            let candidateDeps = getCandidateDependencies(
                for: sample.fileDependencies, context: sample.context
            )

            for candidate in candidateDeps {
                var row = features
                row["dependency"] = candidate
                row["will_use"] = sample.actualDependencies.contains(candidate) ? 1.0 : 0.0
                dataRows.append(row)
            }
        }

        let dataTable = try MLDataTable(dictionary: dataRows)

        // Create and train random forest classifier
        let classifier = try MLRandomForestClassifier(
            trainingData: dataTable,
            targetColumn: "will_use"
        )

        predictionModel = try classifier.model()
    }

    private func trainCustomModel(named modelName: String) async throws {
        // For custom models, we'd load a pre-trained model
        // This is a placeholder for custom model training
        throw PredictionError.unsupportedModelType(modelName)
    }

    private func extractFeatures(from file: FileDependencies, context: PredictionContext)
        -> [String: MLDataValueConvertible]
    {
        [
            "dependency_count": Double(file.dependencyCount),
            "complexity_score": file.complexityScore,
            "internal_deps_ratio": file.internalDependencies.isEmpty
                ? 0 : Double(file.internalDependencies.count) / Double(file.dependencyCount),
            "external_deps_ratio": file.externalDependencies.isEmpty
                ? 0 : Double(file.externalDependencies.count) / Double(file.dependencyCount),
            "import_count": Double(file.imports.count),
            "type_deps_count": Double(file.typeDependencies.count),
            "function_deps_count": Double(file.functionDependencies.count),
            "file_size_kb": Double(context.fileSize) / 1024.0,
            "lines_of_code": Double(context.linesOfCode),
            "cyclomatic_complexity": context.cyclomaticComplexity,
            "project_size": Double(context.projectSize),
            "similar_files_count": Double(context.similarFiles.count),
            "historical_usage": context.historicalUsage,
            "recent_changes": Double(context.recentChanges),
            "team_size": Double(context.teamSize),
        ]
    }

    private func getCandidateDependencies(for file: FileDependencies, context: PredictionContext)
        -> [String]
    {
        var candidates: Set<String> = []

        // Add dependencies from similar files
        for similarFile in context.similarFiles {
            if let similarDeps = context.projectDependencies?.fileDependencies[similarFile]?
                .dependencies
            {
                candidates.formUnion(similarDeps)
            }
        }

        // Add commonly used dependencies from the project
        if let projectDeps = context.projectDependencies {
            let allDeps = projectDeps.fileDependencies.values.flatMap(\.dependencies)
            let commonDeps = Dictionary(grouping: allDeps, by: { $0 }).filter { $0.value.count > 2 }
                .keys
            candidates.formUnion(commonDeps)
        }

        // Add dependencies from historical usage
        candidates.formUnion(context.historicalDependencies)

        return Array(candidates).filter { !file.dependencies.contains($0) }
    }

    private func predictSingleDependency(
        _ dependency: String, features: [String: MLDataValueConvertible], using model: MLModel
    ) throws -> DependencyPrediction {
        // Create input for the model
        var modelInput = features
        modelInput["dependency"] = dependency

        let input = try MLDictionaryFeatureProvider(dictionary: modelInput)
        let prediction = try model.prediction(from: input)

        // Extract prediction value
        guard let probability = prediction.featureValue(for: "will_use")?.doubleValue else {
            throw PredictionError.predictionFailed("Could not extract prediction value")
        }

        return DependencyPrediction(
            dependency: dependency,
            confidence: probability,
            reasoning: generateReasoning(
                for: dependency, confidence: probability, features: features
            ),
            features: features,
            predictionTimestamp: Date()
        )
    }

    private func generateReasoning(
        for dependency: String, confidence: Double, features: [String: MLDataValueConvertible]
    ) -> String {
        var reasons: [String] = []

        if confidence > 0.8 {
            reasons.append("High confidence based on similar file patterns")
        } else if confidence > 0.6 {
            reasons.append("Moderate confidence from historical usage")
        }

        if let similarFiles = features["similar_files_count"] as? Double, similarFiles > 0 {
            reasons.append("Similar files in project use this dependency")
        }

        if let historicalUsage = features["historical_usage"] as? Double, historicalUsage > 0.5 {
            reasons.append("Frequently used in project history")
        }

        if let complexity = features["complexity_score"] as? Double, complexity > 0.7 {
            reasons.append("Complex file may benefit from this dependency")
        }

        return reasons.isEmpty ? "Pattern-based prediction" : reasons.joined(separator: "; ")
    }

    private func getPerformanceMetrics() -> ModelPerformance? {
        // This would return cached performance metrics
        // For now, return nil
        nil
    }
}

// MARK: - Supporting Types

/// Training sample for dependency prediction
public struct DependencyTrainingSample {
    public let fileDependencies: FileDependencies
    public let context: PredictionContext
    public let actualDependencies: Set<String>
    public let timestamp: Date

    public init(
        fileDependencies: FileDependencies, context: PredictionContext,
        actualDependencies: Set<String>, timestamp: Date = Date()
    ) {
        self.fileDependencies = fileDependencies
        self.context = context
        self.actualDependencies = actualDependencies
        self.timestamp = timestamp
    }
}

/// Prediction context
public struct PredictionContext {
    public let fileSize: Int
    public let linesOfCode: Int
    public let cyclomaticComplexity: Double
    public let projectSize: Int
    public let similarFiles: [String]
    public let historicalDependencies: Set<String>
    public let historicalUsage: Double
    public let recentChanges: Int
    public let teamSize: Int
    public let projectDependencies: ProjectDependencies?

    public init(
        fileSize: Int = 0,
        linesOfCode: Int = 0,
        cyclomaticComplexity: Double = 0,
        projectSize: Int = 0,
        similarFiles: [String] = [],
        historicalDependencies: Set<String> = [],
        historicalUsage: Double = 0,
        recentChanges: Int = 0,
        teamSize: Int = 1,
        projectDependencies: ProjectDependencies? = nil
    ) {
        self.fileSize = fileSize
        self.linesOfCode = linesOfCode
        self.cyclomaticComplexity = cyclomaticComplexity
        self.projectSize = projectSize
        self.similarFiles = similarFiles
        self.historicalDependencies = historicalDependencies
        self.historicalUsage = historicalUsage
        self.recentChanges = recentChanges
        self.teamSize = teamSize
        self.projectDependencies = projectDependencies
    }
}

/// Dependency prediction result
public struct DependencyPrediction {
    public let dependency: String
    public let confidence: Double
    public let reasoning: String
    public let features: [String: MLDataValueConvertible]
    public let predictionTimestamp: Date
}

/// Model performance metrics
public struct ModelPerformance {
    public let precision: Double
    public let recall: Double
    public let f1Score: Double
    public let accuracy: Double
    public let evaluationTimestamp: Date
}

/// Model insights
public struct ModelInsights {
    public let modelType: DependencyPredictor.ModelType
    public let trainingSamples: Int
    public let featuresUsed: Int
    public let lastTrained: Date
    public let performanceMetrics: ModelPerformance?
    public let insightsTimestamp: Date
}

/// Prediction errors
public enum PredictionError: Error {
    case insufficientTrainingData
    case modelNotTrained
    case trainingFailed(String)
    case predictionFailed(String)
    case unsupportedModelType(String)
    case invalidFeatures(String)
}

// MARK: - Extensions

extension DependencyPrediction: CustomStringConvertible {
    public var description: String {
        "\(dependency): \(String(format: "%.2f", confidence)) - \(reasoning)"
    }
}

extension ModelPerformance: CustomStringConvertible {
    public var description: String {
        """
        Model Performance:
        - Precision: \(String(format: "%.3f", precision))
        - Recall: \(String(format: "%.3f", recall))
        - F1 Score: \(String(format: "%.3f", f1Score))
        - Accuracy: \(String(format: "%.3f", accuracy))
        """
    }
}

extension ModelInsights: CustomStringConvertible {
    public var description: String {
        """
        Model Insights:
        - Type: \(modelType)
        - Training Samples: \(trainingSamples)
        - Features Used: \(featuresUsed)
        - Last Trained: \(lastTrained.formatted())
        - Performance: \(performanceMetrics?.description ?? "Not evaluated")
        """
    }
}
