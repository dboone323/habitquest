//
//  IssueRow.swift
//  CodingReviewer
//
//  View for displaying individual code issues
//

import SwiftUI

struct IssueRow: View {
    let issue: CodeIssue

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: iconName)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(issue.description)
                    .font(.body)

                HStack {
                    if let line = issue.line {
                        Text("Line \(line)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("•")
                        .foregroundColor(.secondary)
                    Text(issue.category.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)
                    Text(issue.severity.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(severityColor)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch issue.severity {
        case .low: return "info.circle.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        }
    }

    private var color: Color {
        switch issue.severity {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        case .critical: return .red
        }
    }

    private var severityColor: Color {
        switch issue.severity {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        case .critical: return .red
        }
    }
}
