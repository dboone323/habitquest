//
//  TestResultsView.swift
//  CodingReviewer
//
//  View for displaying generated test code
//

import SwiftUI

struct TestResultsView: View {
    let result: TestGenerationResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Generated Tests")
                            .font(.headline)
                        Spacer()
                        Text("Est. Coverage: \(Int(result.estimatedCoverage))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("Framework: \(result.testFramework)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Language: \(result.language)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                Text(result.testCode)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
