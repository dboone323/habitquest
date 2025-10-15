import SwiftUI
import UniformTypeIdentifiers

//
//  SidebarView.swift
//  CodingReviewer
//
//  Sidebar component for file browser and analysis tools
//

public struct SidebarView: View {
    @Binding var selectedFileURL: URL?
    @Binding var showFilePicker: Bool
    @Binding var selectedAnalysisType: AnalysisType
    @Binding var currentView: ContentViewType

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("CodingReviewer")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("AI-Powered Code Analysis")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.windowBackgroundColor))

            Divider()

            // File Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("File Selection")
                    .font(.headline)
                    .padding(.horizontal)

                if let fileURL = selectedFileURL {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected File:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(fileURL.lastPathComponent)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .padding(.horizontal)
                }

                Button(action: { showFilePicker = true }) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text(selectedFileURL == nil ? "Select File" : "Change File")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }

            Divider()

            // Analysis Type Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Analysis Type")
                    .font(.headline)
                    .padding(.horizontal)

                Picker("Analysis Type", selection: $selectedAnalysisType) {
                    Text("Comprehensive").tag(AnalysisType.comprehensive)
                    Text("Security").tag(AnalysisType.security)
                    Text("Performance").tag(AnalysisType.performance)
                    Text("Bugs").tag(AnalysisType.bugs)
                }
                .pickerStyle(.radioGroup)
                .padding(.horizontal)
            }

            Divider()

            // View Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("View")
                    .font(.headline)
                    .padding(.horizontal)

                Picker("Current View", selection: $currentView) {
                    Text("Analysis").tag(ContentViewType.analysis)
                    Text("Documentation").tag(ContentViewType.documentation)
                    Text("Tests").tag(ContentViewType.tests)
                }
                .pickerStyle(.radioGroup)
                .padding(.horizontal)
            }

            Spacer()

            // Footer
            VStack(spacing: 8) {
                Text("Ready for analysis")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if selectedFileURL != nil {
                    Text("File loaded successfully")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding()
        }
        .frame(minWidth: 250, maxWidth: 300)
        .background(Color(.windowBackgroundColor).opacity(0.5))
    }
}

// MARK: - Preview

public struct SidebarView_Previews: PreviewProvider {
    public static var previews: some View {
        SidebarView(
            selectedFileURL: .constant(URL(fileURLWithPath: "/example/file.swift")),
            showFilePicker: .constant(false),
            selectedAnalysisType: .constant(.comprehensive),
            currentView: .constant(.analysis)
        )
    }
}
