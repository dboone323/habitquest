//
//  AnalysisResultsView.swift
//  CodingReviewer
//
//  View for displaying code analysis results
//

import SwiftUI

struct AnalysisResultsView: View {
    let result: CodeAnalysisResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(result.issues) { issue in
                IssueRow(issue: issue)
            }

            if result.issues.isEmpty {
                Text("No issues found")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}
