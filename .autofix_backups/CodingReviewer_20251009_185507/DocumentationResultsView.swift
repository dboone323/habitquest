//
//  DocumentationResultsView.swift
//  CodingReviewer
//
//  View for displaying generated documentation
//

import SwiftUI

public struct DocumentationResultsView: View {
    let result: DocumentationResult
    private let presenter: DocumentationResultsPresenter

    init(result: DocumentationResult, presenter: DocumentationResultsPresenter? = nil) {
        self.result = result
        self.presenter = presenter ?? DocumentationResultsPresenter(result: result)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(self.presenter.documentation)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                HStack {
                    Text(self.presenter.languageLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if let badge = presenter.examplesBadge {
                        Text(badge)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct DocumentationResultsPresenter {
    private let result: DocumentationResult

    init(result: DocumentationResult) {
        self.result = result
    }

    var documentation: String {
        self.result.documentation
    }

    var languageLabel: String {
        "Language: \(self.result.language)"
    }

    var examplesBadge: String? {
        self.result.includesExamples ? "Includes examples" : nil
    }
}
