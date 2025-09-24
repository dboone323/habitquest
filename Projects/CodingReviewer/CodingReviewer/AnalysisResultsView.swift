//
//  AnalysisResultsView.swift
//  CodingReviewer
//
//  View for displaying code analysis results
//

import SwiftUI

public struct AnalysisResultsView: View {
    let result: CodeAnalysisResult

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(self.result.issues) { issue in
                IssueRow(issue: issue)
            }

            if self.result.issues.isEmpty {
                Text("No issues found")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}
