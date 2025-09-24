//
//  IssueRow.swift
//  CodingReviewer
//
//  View for displaying individual code issues
//

import SwiftUI

public struct IssueRow: View {
    let issue: CodeIssue

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: self.iconName)
                .foregroundColor(self.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(self.issue.description)
                    .font(.body)

                HStack {
                    if let line = issue.line {
                        Text("Line \(line)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("•")
                        .foregroundColor(.secondary)
                    Text(self.issue.category.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)
                    Text(self.issue.severity.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(self.severityColor)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch self.issue.severity {
        case .low: "info.circle.fill"
        case .medium: "exclamationmark.triangle.fill"
        case .high: "exclamationmark.triangle.fill"
        case .critical: "xmark.circle.fill"
        }
    }

    private var color: Color {
        switch self.issue.severity {
        case .low: .blue
        case .medium: .orange
        case .high: .red
        case .critical: .red
        }
    }

    private var severityColor: Color {
        switch self.issue.severity {
        case .low: .blue
        case .medium: .orange
        case .high: .red
        case .critical: .red
        }
    }
}
