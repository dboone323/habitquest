import SwiftUI

//
//  CodeReviewView.swift
//  CodingReviewer
//
//  Main code review display component
//

public struct CodeReviewView: View {
    let fileURL: URL
    @Binding var codeContent: String
    @Binding var analysisResult: CodeAnalysisResult?
    @Binding var documentationResult: DocumentationResult?
    @Binding var testResult: TestGenerationResult?
    @Binding var isAnalyzing: Bool
    let selectedAnalysisType: AnalysisType
    let currentView: ContentViewType
    let onAnalyze: () async -> Void
    let onGenerateDocumentation: () async -> Void
    let onGenerateTests: () async -> Void

    public var body: some View {
        VStack(spacing: 0) {
            // Header with file info and action buttons
            HStack {
                VStack(alignment: .leading) {
                    Text(fileURL.lastPathComponent)
                        .font(.headline)
                    Text("Size: \(codeContent.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Action buttons
                HStack(spacing: 8) {
                    if currentView == .analysis {
                        Button(action: { Task { await onAnalyze() } }) {
                            HStack {
                                Image(systemName: isAnalyzing ? "hourglass" : "magnifyingglass")
                                Text(isAnalyzing ? "Analyzing..." : "Analyze")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isAnalyzing)
                    } else if currentView == .documentation {
                        Button(action: { Task { await onGenerateDocumentation() } }) {
                            HStack {
                                Image(systemName: isAnalyzing ? "hourglass" : "doc.text")
                                Text(isAnalyzing ? "Generating..." : "Generate Docs")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isAnalyzing)
                    } else if currentView == .tests {
                        Button(action: { Task { await onGenerateTests() } }) {
                            HStack {
                                Image(systemName: isAnalyzing ? "hourglass" : "testtube.2")
                                Text(isAnalyzing ? "Generating..." : "Generate Tests")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isAnalyzing)
                    }
                }
            }
            .padding()
            .background(Color(.windowBackgroundColor))

            Divider()

            // Main content area
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Code display
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Source Code")
                            .font(.title3)
                            .fontWeight(.semibold)

                        ScrollView(.horizontal) {
                            Text(codeContent)
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color(.textBackgroundColor).opacity(0.5))
                        .cornerRadius(8)
                        .frame(height: 200)
                    }

                    // Results display based on current view
                    if currentView == .analysis {
                        analysisResultsView
                    } else if currentView == .documentation {
                        documentationResultsView
                    } else if currentView == .tests {
                        testResultsView
                    }
                }
                .padding()
            }
        }
    }

    private var analysisResultsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analysis Results")
                .font(.title3)
                .fontWeight(.semibold)

            if let result = analysisResult {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Issues Found: \(result.issues.count)")
                        .font(.headline)

                    ForEach(result.issues.prefix(10), id: \.description) { issue in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(issue.description)
                                .font(.body)
                            Text("Severity: \(issue.severity.rawValue)")
                                .font(.caption)
                                .foregroundColor(severityColor(issue.severity))
                        }
                        .padding()
                        .background(Color(.windowBackgroundColor))
                        .cornerRadius(8)
                    }

                    if result.issues.count > 10 {
                        Text("... and \(result.issues.count - 10) more issues")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else if !isAnalyzing {
                Text("No analysis results yet. Click 'Analyze' to begin.")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }

    private var documentationResultsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Documentation Results")
                .font(.title3)
                .fontWeight(.semibold)

            if let result = documentationResult {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.headline)
                    Text(result.overview)
                        .font(.body)

                    if !result.documentedCode.isEmpty {
                        Text("Documented Code")
                            .font(.headline)
                            .padding(.top)
                        ScrollView {
                            Text(result.documentedCode)
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                        }
                        .frame(height: 150)
                        .background(Color(.textBackgroundColor).opacity(0.5))
                        .cornerRadius(8)
                    }

                    if !result.examples.isEmpty {
                        Text("Examples")
                            .font(.headline)
                            .padding(.top)
                        ForEach(result.examples, id: \.self) { example in
                            Text(example)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .background(Color(.textBackgroundColor).opacity(0.5))
                                .cornerRadius(8)
                        }
                    }
                }
            } else if !isAnalyzing {
                Text("No documentation generated yet. Click 'Generate Docs' to begin.")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }

    private var testResultsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test Generation Results")
                .font(.title3)
                .fontWeight(.semibold)

            if let result = testResult {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Language: \(result.language)")
                        Spacer()
                        Text("Framework: \(result.testFramework)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    Text("Coverage: \(Int(result.coverage * 100))%")
                        .font(.headline)

                    Text("Generated Tests")
                        .font(.headline)
                        .padding(.top)

                    ScrollView {
                        Text(result.testCode)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                    }
                    .frame(height: 200)
                    .background(Color(.textBackgroundColor).opacity(0.5))
                    .cornerRadius(8)
                }
            } else if !isAnalyzing {
                Text("No tests generated yet. Click 'Generate Tests' to begin.")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }

    private func severityColor(_ severity: IssueSeverity) -> Color {
        switch severity {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}

// MARK: - Preview

public struct CodeReviewView_Previews: PreviewProvider {
    public static var previews: some View {
        CodeReviewView(
            fileURL: URL(fileURLWithPath: "/example/file.swift"),
            codeContent: .constant("// Example Swift code\nfunc hello() {\n    print(\"Hello, World!\")\n}"),
            analysisResult: .constant(nil),
            documentationResult: .constant(nil),
            testResult: .constant(nil),
            isAnalyzing: .constant(false),
            selectedAnalysisType: .comprehensive,
            currentView: .analysis,
            onAnalyze: {},
            onGenerateDocumentation: {},
            onGenerateTests: {}
        )
    }
}
