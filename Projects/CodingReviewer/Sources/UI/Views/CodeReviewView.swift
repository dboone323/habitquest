import SharedKit
import SwiftUI

@MainActor
struct CodeReviewView: View {
    @StateObject private var viewModel = CodeReviewViewModel()
    @State private var selectedFile: URL?
    @State private var showFilePicker = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Code Review")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: { showFilePicker = true }) {
                    Label("Select File", systemImage: "folder")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color.secondary.opacity(0.1).opacity(0.5))

            // Main Content
            if let fileURL = selectedFile {
                CodeReviewContentView(fileURL: fileURL, viewModel: viewModel)
            } else {
                EmptyStateView(showFilePicker: $showFilePicker)
            }
        }
        .background(.background)
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.swiftSource, .objectiveCSource, .cSource, .cHeader],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                selectedFile = urls.first
                if let url = urls.first {
                    Task { await viewModel.analyzeFile(at: url) }
                }
            case let .failure(error):
                viewModel.errorMessage = "Failed to select file: \(error.localizedDescription)"
            }
        }
    }
}

@MainActor
private struct CodeReviewContentView: View {
    let fileURL: URL
    @ObservedObject var viewModel: CodeReviewViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // File Info
                FileInfoCard(fileURL: fileURL)

                // Analysis Results
                if viewModel.isLoading {
                    ProgressView("Analyzing code...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let results = viewModel.analysisResults {
                    AnalysisResultsView(results: results)
                } else if let error = viewModel.errorMessage {
                    ErrorView(error: error)
                } else {
                    Text("Select a file to begin analysis")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .padding()
        }
    }
}

@MainActor
private struct FileInfoCard: View {
    let fileURL: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("File Information")
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                Label(fileURL.lastPathComponent, systemImage: "doc.text")
                    .foregroundColor(.secondary)
                Spacer()
                Text(fileURL.pathExtension.uppercased())
                    .font(.caption)
                    .padding(4)
                    .background(.blue.opacity(0.2))
                    .cornerRadius(4)
            }

            Text("Path: \(fileURL.deletingLastPathComponent().path)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

@MainActor
private struct AnalysisResultsView: View {
    let results: CodeAnalysisResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analysis Results")
                .font(.headline)
                .foregroundColor(.primary)

            // Issues Summary
            IssuesSummaryCard(results: results)

            // Detailed Issues
            if !results.issues.isEmpty {
                IssuesListView(issues: results.issues)
            }

            // Metrics
            MetricsCard(results: results)
        }
    }
}

@MainActor
private struct IssuesSummaryCard: View {
    let results: CodeAnalysisResult

    var body: some View {
        HStack(spacing: 20) {
            IssueCountView(count: results.issues.filter { $0.severity == .error }.count,
                           label: "Errors",
                           color: .red)

            IssueCountView(count: results.issues.filter { $0.severity == .warning }.count,
                           label: "Warnings",
                           color: .orange)

            IssueCountView(count: results.issues.filter { $0.severity == .info }.count,
                           label: "Info",
                           color: .blue)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

@MainActor
private struct IssueCountView: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

@MainActor
private struct IssuesListView: View {
    let issues: [CodeIssue]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Issues")
                .font(.subheadline)
                .foregroundColor(.primary)

            ForEach(issues) { issue in
                IssueRowView(issue: issue)
            }
        }
    }
}

@MainActor
private struct IssueRowView: View {
    let issue: CodeIssue

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(severityColor(for: issue.severity))
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(issue.message)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                if let suggestion = issue.suggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Line \(issue.line)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let column = issue.column {
                        Text("Col \(column)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.secondary.opacity(0.1).opacity(0.5))
        .cornerRadius(6)
    }

    private func severityColor(for severity: IssueSeverity) -> Color {
        switch severity {
        case .critical: return .red.opacity(0.9)
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

@MainActor
private struct MetricsCard: View {
    let results: CodeAnalysisResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Code Metrics")
                .font(.subheadline)
                .foregroundColor(.primary)

            HStack(spacing: 20) {
                MetricView(label: "Lines", value: "\(results.metrics.linesOfCode)")
                MetricView(label: "Functions", value: "\(results.metrics.functionCount)")
                MetricView(label: "Complexity", value: "\(results.metrics.complexity)")
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

@MainActor
private struct MetricView: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

@MainActor
private struct ErrorView: View {
    let error: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text("Analysis Error")
                .font(.headline)
                .foregroundColor(.primary)

            Text(error)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

@MainActor
private struct EmptyStateView: View {
    @Binding var showFilePicker: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.5))

            Text("No File Selected")
                .font(.title2)
                .foregroundColor(.primary)

            Text("Choose a source code file to begin analysis")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button(action: { showFilePicker = true }) {
                Label("Select File", systemImage: "folder")
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@MainActor
class CodeReviewViewModel: ObservableObject, BaseViewModel {
    typealias State = CodeReviewState
    typealias Action = CodeReviewAction

    @Published var state: State = .idle
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var analysisResults: CodeAnalysisResult?

    func handle(_ action: CodeReviewAction) async {
        switch action {
        case let .analyzeFile(url):
            await analyzeFile(at: url)
        case .clearResults:
            clearResults()
        }
    }

    func analyzeFile(at url: URL) async {
        let auditLogger = AuditLogger.shared
        let securityMonitor = SecurityMonitor.shared
        let privacyManager = PrivacyManager.shared

        isLoading = true
        errorMessage = nil
        state = .analyzing

        // Audit log the start of analysis
        auditLogger.logFileAnalysisStarted(fileURL: url, analysisType: "code_quality")

        // Monitor file analysis
        securityMonitor.monitorFileAnalysis(fileURL: url, analysisType: "code_quality")

        do {
            // Simulate analysis delay
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

            // Mock analysis results
            let mockResults = CodeAnalysisResult(
                fileURL: url,
                issues: [
                    CodeIssue(
                        id: "1",
                        message: "Variable name should be more descriptive",
                        severity: .warning,
                        line: 15,
                        column: 5,
                        suggestion: "Consider renaming 'x' to 'userCount'"
                    ),
                    CodeIssue(
                        id: "2",
                        message: "Force unwrap may cause runtime crash",
                        severity: .error,
                        line: 23,
                        column: 12,
                        suggestion: "Use optional binding instead of force unwrap"
                    ),
                ],
                metrics: CodeMetrics(
                    linesOfCode: 150,
                    functionCount: 8,
                    complexity: 12
                ),
                analysisType: .codeQuality,
                timestamp: Date(),
                language: .swift
            )

            analysisResults = mockResults
            state = .completed

            // Audit log successful completion
            auditLogger.logFileAnalysisCompleted(
                fileURL: url,
                analysisType: "code_quality",
                issueCount: mockResults.issues.count
            )

            // Monitor data access
            securityMonitor.monitorDataAccess(
                operation: "analyze",
                dataType: "code_analysis_result",
                recordCount: 1
            )

            // Record privacy compliance
            privacyManager.recordDataProcessing(
                dataType: "code_analysis_result",
                operation: "analysis",
                purpose: "Code quality assessment and issue detection"
            )

            isLoading = false

        } catch {
            // Audit log the failure
            auditLogger.logFileAnalysisFailed(
                fileURL: url,
                analysisType: "code_quality",
                error: error
            )

            errorMessage = error.localizedDescription
            state = .error(error.localizedDescription)
            isLoading = false
        }
    }

    private func clearResults() {
        analysisResults = nil
        errorMessage = nil
        state = .idle
    }

    func resetError() {
        errorMessage = nil
    }

    func validateState() -> Bool {
        // Basic validation - could be expanded
        true
    }
}

enum CodeReviewState {
    case idle
    case analyzing
    case completed
    case error(String)
}

enum CodeReviewAction {
    case analyzeFile(URL)
    case clearResults
}
