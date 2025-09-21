//
//  SidebarView.swift
//  CodingReviewer
//
//  Sidebar with file browser and analysis tools
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedFileURL: URL?
    @Binding var showFilePicker: Bool
    @Binding var selectedAnalysisType: AnalysisType
    @Binding var currentView: ContentViewType

    var body: some View {
        List {
            Section("Files") {
                Button(action: { showFilePicker = true }) {
                    Label("Open File", systemImage: "doc")
                }
                .buttonStyle(.borderless)

                if selectedFileURL != nil {
                    Text(selectedFileURL!.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section("Analysis Type") {
                Picker("Type", selection: $selectedAnalysisType) {
                    ForEach(AnalysisType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Tools") {
                Button(action: { currentView = .analysis }) {
                    Label("Code Analysis", systemImage: "magnifyingglass")
                }
                .buttonStyle(.borderless)

                Button(action: { currentView = .documentation }) {
                    Label("Documentation", systemImage: "doc.text")
                }
                .buttonStyle(.borderless)

                Button(action: { currentView = .tests }) {
                    Label("Generate Tests", systemImage: "testtube.2")
                }
                .buttonStyle(.borderless)
            }

            Section("Settings") {
                Button(action: { /* TODO: Show settings */ }) {
                    Label("Preferences", systemImage: "gear")
                }
                .buttonStyle(.borderless)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
    }
}