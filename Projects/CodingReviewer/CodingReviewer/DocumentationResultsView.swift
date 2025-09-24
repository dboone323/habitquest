//
//  DocumentationResultsView.swift
//  CodingReviewer
//
//  View for displaying generated documentation
//

import SwiftUI

public struct DocumentationResultsView: View {
    let result: DocumentationResult

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(self.result.documentation)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                HStack {
                    Text("Language: \(self.result.language)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if self.result.includesExamples {
                        Text("Includes examples")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
