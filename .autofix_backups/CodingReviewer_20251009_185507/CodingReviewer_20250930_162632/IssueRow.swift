//
//  IssueRow.swift
//  CodingReviewer
//
//  View for displaying individual code issues
//

import SwiftUI

public struct IssueRow: View {
    let issue: CodeIssue
    private var presenter: IssueRowPresenter { IssueRowPresenter(issue: self.issue) }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: self.presenter.iconName)
                .foregroundColor(self.presenter.iconColor)

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
                        .foregroundColor(self.presenter.severityColor)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct IssueRowPresenter {
    struct Diagnostics {
        let iconName: String
        let iconColorIdentifier: String
        let severityColorIdentifier: String
    }

    let issue: CodeIssue

    private struct Palette {
        let iconName: String
        let iconColor: Color
        let severityColor: Color
        let colorIdentifier: String
    }

    private static let palette: [IssueSeverity: Palette] = [
        .low: Palette(iconName: "info.circle.fill", iconColor: .blue, severityColor: .blue, colorIdentifier: "blue"),
        .medium: Palette(iconName: "exclamationmark.triangle.fill", iconColor: .orange, severityColor: .orange, colorIdentifier: "orange"),
        .high: Palette(iconName: "exclamationmark.triangle.fill", iconColor: .red, severityColor: .red, colorIdentifier: "red"),
        .critical: Palette(iconName: "xmark.circle.fill", iconColor: .red, severityColor: .red, colorIdentifier: "red"),
    ]

    private var paletteForIssue: Palette {
        Self.palette[self.issue.severity] ?? Self.palette[.low]!
    }

    var iconName: String { self.paletteForIssue.iconName }

    var iconColor: Color { self.paletteForIssue.iconColor }

    var severityColor: Color { self.paletteForIssue.severityColor }

    var diagnostics: Diagnostics {
        Diagnostics(
            iconName: self.paletteForIssue.iconName,
            iconColorIdentifier: self.paletteForIssue.colorIdentifier,
            severityColorIdentifier: self.paletteForIssue.colorIdentifier
        )
    }
}
