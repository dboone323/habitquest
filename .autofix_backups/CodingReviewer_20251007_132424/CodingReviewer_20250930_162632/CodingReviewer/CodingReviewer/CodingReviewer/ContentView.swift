//
//  ContentView.swift
//  CodingReviewer
//
//  Main content view for the CodingReviewer application
//

import os
import SwiftUI
import UniformTypeIdentifiers

enum ContentViewType {
    case analysis, documentation, tests
}

public struct ContentView: View {
    private let logger = Logger(subsystem: "com.quantum.codingreviewer", category: "ContentView")

    // Service layer
    private let codeReviewService = CodeReviewService()
    private let languageDetector = LanguageDetector()

    @State private var selectedFileURL: URL?
    @State private var codeContent: String = ""
    @State private var analysisResult: CodeAnalysisResult?
    @State private var documentationResult: DocumentationResult?
    @State private var testResult: TestGenerationResult?
    @State private var isAnalyzing = false
    @State private var showFilePicker = false
    @State private var selectedAnalysisType: AnalysisType = .comprehensive
    @State private var currentView: ContentViewType = .analysis

    public var body: some View {
        NavigationSplitView {
            // Sidebar with file browser and analysis tools
            SidebarView(
                selectedFileURL: self.$selectedFileURL,
                showFilePicker: self.$showFilePicker,
                selectedAnalysisType: self.$selectedAnalysisType,
                currentView: self.$currentView
            )
        } detail: {
            // Main content area
            ZStack {
                if let fileURL = selectedFileURL {
                    CodeReviewView(
                        fileURL: fileURL,
                        codeContent: self.$codeContent,
                        analysisResult: self.$analysisResult,
                        documentationResult: self.$documentationResult,
                        testResult: self.$testResult,
                        isAnalyzing: self.$isAnalyzing,
                        selectedAnalysisType: self.selectedAnalysisType,
                        currentView: self.currentView,
                        onAnalyze: { await self.analyzeCode() },
                        onGenerateDocumentation: { await self.generateDocumentation() },
                        onGenerateTests: { await self.generateTests() }
                    )
                } else {
                    WelcomeView(showFilePicker: self.$showFilePicker)
                }
            }
        }
        .fileImporter(
            isPresented: self.$showFilePicker,
            allowedContentTypes: [.swiftSource, .objectiveCSource, .cSource, .cHeader],
            allowsMultipleSelection: false
        ) { result in
            self.handleFileSelection(result)
        }
        .onAppear {
            self.logger.info("ContentView appeared")
        }
    }

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            if let url = urls.first {
                self.selectedFileURL = url
                self.loadFileContent(from: url)
            }
        case let .failure(error):
            self.logger.error("File selection failed: \(error.localizedDescription)")
            // TODO: Handle error properly
        }
    }

    private func loadFileContent(from url: URL) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            self.codeContent = content
            self.logger.info("Loaded file content from: \(url.lastPathComponent)")
        } catch {
            self.logger.error("Failed to load file content: \(error.localizedDescription)")
            // TODO: Handle error properly
        }
    }

    private func analyzeCode() async {
        guard !self.codeContent.isEmpty else { return }

        self.isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            let language = self.languageDetector.detectLanguage(from: self.selectedFileURL)
            let result = try await codeReviewService.analyzeCode(
                self.codeContent,
                language: language,
                analysisType: self.selectedAnalysisType
            )
            self.analysisResult = result
            self.logger.info("Code analysis completed successfully")
        } catch {
            self.logger.error("Code analysis failed: \(error.localizedDescription)")
            // TODO: Handle error properly
        }
    }

    private func generateDocumentation() async {
        guard !self.codeContent.isEmpty else { return }

        self.isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            let language = self.languageDetector.detectLanguage(from: self.selectedFileURL)
            let result = try await codeReviewService.generateDocumentation(self.codeContent, language: language, includeExamples: true)
            self.documentationResult = result
            self.logger.info("Documentation generation completed successfully")
        } catch {
            self.logger.error("Documentation generation failed: \(error.localizedDescription)")
            // TODO: Handle error properly
        }
    }

    private func generateTests() async {
        guard !self.codeContent.isEmpty else { return }

        self.isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            let language = self.languageDetector.detectLanguage(from: self.selectedFileURL)
            let result = try await codeReviewService.generateTests(self.codeContent, language: language, testFramework: "XCTest")
            self.testResult = result
            self.logger.info("Test generation completed successfully")
        } catch {
            self.logger.error("Test generation failed: \(error.localizedDescription)")
            // TODO: Handle error properly
        }
    }
}

// MARK: - Preview

public struct ContentView_Previews: PreviewProvider {
    public static var previews: some View {
        ContentView()
    }
}
