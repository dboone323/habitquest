//
//  AnalysisResultsView.swift
//  CodingReviewer
//
//  View for displaying code analysis results
//

import SwiftUI

public struct AnalysisResultsView: View {
    let result: CodeAnalysisResult
    private var viewModel: AnalysisResultsViewModel { AnalysisResultsViewModel(result: result) }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            let viewModel = viewModel

            ForEach(viewModel.issues) { issue in
                IssueRow(issue: issue)
            }

            if viewModel.shouldShowEmptyState {
                Text(viewModel.emptyStateMessage)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

struct AnalysisResultsViewModel {
    let result: CodeAnalysisResult

    var issues: [CodeIssue] { result.issues }

    var shouldShowEmptyState: Bool { result.issues.isEmpty }

    var emptyStateMessage: String { "No issues found" }
}
