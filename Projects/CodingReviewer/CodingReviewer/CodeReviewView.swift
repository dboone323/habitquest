//
//  CodeReviewView.swift
//  CodingReviewer
//
//  Main code review interface with editor and results panel
//

import SwiftUI

struct CodeReviewView: View {
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

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(fileURL.lastPathComponent)
                    .font(.headline)
                Spacer()

                switch currentView {
                case .analysis:
                    Button(action: { Task { await onAnalyze() } }) {
                        Label("Analyze", systemImage: "play.fill")
                    }
                    .disabled(isAnalyzing || codeContent.isEmpty)
                case .documentation:
                    Button(action: { Task { await onGenerateDocumentation() } }) {
                        Label("Generate Docs", systemImage: "doc.text")
                    }
                    .disabled(isAnalyzing || codeContent.isEmpty)
                case .tests:
                    Button(action: { Task { await onGenerateTests() } }) {
                        Label("Generate Tests", systemImage: "testtube.2")
                    }
                    .disabled(isAnalyzing || codeContent.isEmpty)
                }
            }
            .padding()

            Divider()

            // Main content
            HSplitView {
                // Code editor
                ScrollView {
                    TextEditor(text: $codeContent)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                }
                .frame(minWidth: 400)

                // Results panel
                ResultsPanel(
                    currentView: currentView,
                    analysisResult: analysisResult,
                    documentationResult: documentationResult,
                    testResult: testResult,
                    isAnalyzing: isAnalyzing
                )
                .frame(minWidth: 300)
            }
        }
    }
}

struct ResultsPanel: View {
    let currentView: ContentViewType
    let analysisResult: CodeAnalysisResult?
    let documentationResult: DocumentationResult?
    let testResult: TestGenerationResult?
    let isAnalyzing: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Results header
            HStack {
                Text(resultsTitle)
                    .font(.headline)
                Spacer()
                if isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .padding()

            Divider()

            // Results content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch currentView {
                    case .analysis:
                        if let result = analysisResult {
                            AnalysisResultsView(result: result)
                        } else if !isAnalyzing {
                            Text("Click Analyze to start code analysis")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    case .documentation:
                        if let result = documentationResult {
                            DocumentationResultsView(result: result)
                        } else if !isAnalyzing {
                            Text("Click Generate Docs to create documentation")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    case .tests:
                        if let result = testResult {
                            TestResultsView(result: result)
                        } else if !isAnalyzing {
                            Text("Click Generate Tests to create unit tests")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                }
                .padding()
            }
        }
    }

    private var resultsTitle: String {
        switch currentView {
        case .analysis: return "Analysis Results"
        case .documentation: return "Documentation"
        case .tests: return "Generated Tests"
        }
    }
}
