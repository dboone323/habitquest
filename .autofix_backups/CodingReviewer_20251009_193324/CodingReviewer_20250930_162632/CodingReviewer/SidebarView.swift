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
    private let presenter: SidebarViewPresenter

    init(
        selectedFileURL: Binding<URL?>,
        showFilePicker: Binding<Bool>,
        selectedAnalysisType: Binding<AnalysisType>,
        currentView: Binding<ContentViewType>,
        presenter: SidebarViewPresenter = SidebarViewPresenter()
    ) {
        _selectedFileURL = selectedFileURL
        _showFilePicker = showFilePicker
        _selectedAnalysisType = selectedAnalysisType
        _currentView = currentView
        self.presenter = presenter
    }

    public var body: some View {
        List {
            Section("Files") {
                Button(action: self.presenter.openFileAction(binding: self.$showFilePicker)) {
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
                Button(action: self.presenter.setViewAction(binding: self.$currentView, target: .analysis)) {
                    Label("Code Analysis", systemImage: "magnifyingglass")
                }
                .buttonStyle(.borderless)

                Button(action: self.presenter.setViewAction(binding: self.$currentView, target: .documentation)) {
                    Label("Documentation", systemImage: "doc.text")
                }
                .buttonStyle(.borderless)

                Button(action: self.presenter.setViewAction(binding: self.$currentView, target: .tests)) {
                    Label("Generate Tests", systemImage: "testtube.2")
                }
                .buttonStyle(.borderless)
            }

            Section("Settings") {
                Button(action: self.presenter.preferencesAction()) {
                    Label("Preferences", systemImage: "gear")
                }
                .buttonStyle(.borderless)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
    }
}

struct SidebarViewPresenter {
    func openFileAction(binding: Binding<Bool>) -> () -> Void {
        {
            binding.wrappedValue = true
        }
    }

    func setViewAction(binding: Binding<ContentViewType>, target: ContentViewType) -> () -> Void {
        {
            binding.wrappedValue = target
        }
    }

    func preferencesAction() -> () -> Void {
        {
            // Placeholder for future preferences handling
        }
    }
}
