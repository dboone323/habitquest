//
//  TestResultsView.swift
//  CodingReviewer
//
//  View for displaying generated test code
//

import SwiftUI

public struct TestResultsView: View {
    let result: TestGenerationResult
    private let presenter: TestResultsPresenter

    init(result: TestGenerationResult, presenter: TestResultsPresenter? = nil) {
        self.result = result
        self.presenter = presenter ?? TestResultsPresenter(result: result)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Generated Tests")
                            .font(.headline)
                        Spacer()
                        Text(self.presenter.coverageDisplay)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(self.presenter.frameworkLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(self.presenter.languageLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                Text(self.presenter.codeSnippet)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct TestResultsPresenter {
    private let result: TestGenerationResult

    init(result: TestGenerationResult) {
        self.result = result
    }

    var coverageDisplay: String {
        "Est. Coverage: \(Int(self.result.estimatedCoverage))%"
    }

    var frameworkLabel: String {
        "Framework: \(self.result.testFramework)"
    }

    var languageLabel: String {
        "Language: \(self.result.language)"
    }

    var codeSnippet: String {
        self.result.testCode
    }
}
