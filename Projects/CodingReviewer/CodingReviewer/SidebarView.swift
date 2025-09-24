//
//  SidebarView.swift
//  CodingReviewer
//
//  Sidebar with file browser and analysis tools
//

import SwiftUI

public struct SidebarView: View {
    @Binding var selectedFileURL: URL?
    @Binding var showFilePicker: Bool
    @Binding var selectedAnalysisType: AnalysisType
    @Binding var currentView: ContentViewType

    public var body: some View {
        List {
            Section("Files") {
                Button(action: { self.showFilePicker = true }) {
                    Label("Open File", systemImage: "doc")
                }
                .buttonStyle(.borderless)

                if self.selectedFileURL != nil {
                    Text(self.selectedFileURL!.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section("Analysis Type") {
                Picker("Type", selection: self.$selectedAnalysisType) {
                    ForEach(AnalysisType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Tools") {
                Button(action: { self.currentView = .analysis }) {
                    Label("Code Analysis", systemImage: "magnifyingglass")
                }
                .buttonStyle(.borderless)

                Button(action: { self.currentView = .documentation }) {
                    Label("Documentation", systemImage: "doc.text")
                }
                .buttonStyle(.borderless)

                Button(action: { self.currentView = .tests }) {
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
