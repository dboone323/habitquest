//
//  CodeReviewView.swift
//  CodingReviewer
//
//  Main code review interface with editor and results panel
//

import SwiftUI

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
            // Header
            HStack {
                Text(self.fileURL.lastPathComponent)
                    .font(.headline)
                Spacer()

                switch self.currentView {
                case .analysis:
                    Button(action: { Task { await self.onAnalyze() } }) {
                        Label("Analyze", systemImage: "play.fill")
                    }
                    .disabled(self.isAnalyzing || self.codeContent.isEmpty)
                case .documentation:
                    Button(action: { Task { await self.onGenerateDocumentation() } }) {
                        Label("Generate Docs", systemImage: "doc.text")
                    }
                    .disabled(self.isAnalyzing || self.codeContent.isEmpty)
                case .tests:
                    Button(action: { Task { await self.onGenerateTests() } }) {
                        Label("Generate Tests", systemImage: "testtube.2")
                    }
                    .disabled(self.isAnalyzing || self.codeContent.isEmpty)
                }
            }
            .padding()

            Divider()

            // Main content
            HSplitView {
                // Code editor
                ScrollView {
                    TextEditor(text: self.$codeContent)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                }
                .frame(minWidth: 400)

                // Results panel
                ResultsPanel(
                    currentView: self.currentView,
                    analysisResult: self.analysisResult,
                    documentationResult: self.documentationResult,
                    testResult: self.testResult,
                    isAnalyzing: self.isAnalyzing
                )
                .frame(minWidth: 300)
            }
        }
    }
}

public struct ResultsPanel: View {
    let currentView: ContentViewType
    let analysisResult: CodeAnalysisResult?
    let documentationResult: DocumentationResult?
    let testResult: TestGenerationResult?
    let isAnalyzing: Bool

    private var presenter: ResultsPanelPresenter {
        ResultsPanelPresenter(currentView: self.currentView, isAnalyzing: self.isAnalyzing)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Results header
            HStack {
                Text(self.presenter.title)
                    .font(.headline)
                Spacer()
                if self.isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .padding()

            Divider()

            // Results content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch self.currentView {
                    case .analysis:
                        if let result = analysisResult {
                            AnalysisResultsView(result: result)
                        } else if let message = presenter.emptyStateMessage(hasResult: analysisResult != nil) {
                            Text(message)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    case .documentation:
                        if let result = documentationResult {
                            DocumentationResultsView(result: result)
                        } else if let message = presenter.emptyStateMessage(hasResult: documentationResult != nil) {
                            Text(message)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    case .tests:
                        if let result = testResult {
                            TestResultsView(result: result)
                        } else if let message = presenter.emptyStateMessage(hasResult: testResult != nil) {
                            Text(message)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct ResultsPanelPresenter {
    let currentView: ContentViewType
    let isAnalyzing: Bool

    var title: String {
        switch self.currentView {
        case .analysis: "Analysis Results"
        case .documentation: "Documentation"
        case .tests: "Generated Tests"
        }
    }

    func emptyStateMessage(hasResult: Bool) -> String? {
        guard !hasResult, !self.isAnalyzing else { return nil }

        switch self.currentView {
        case .analysis:
            return "Click Analyze to start code analysis"
        case .documentation:
            return "Click Generate Docs to create documentation"
        case .tests:
            return "Click Generate Tests to create unit tests"
        }
    }
}
