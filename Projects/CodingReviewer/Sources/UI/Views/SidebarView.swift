import SharedKit
import SwiftUI

@MainActor
struct SidebarView: View {
    @StateObject private var viewModel = SidebarViewModel()

    var body: some View {
        NavigationSplitView {
            List(selection: $viewModel.selectedItem) {
                Section(header: Text("Project Structure")) {
                    ForEach(viewModel.projectItems) { item in
                        NavigationLink(value: item) {
                            Label(item.name, systemImage: item.icon)
                                .foregroundColor(.primary)
                        }
                    }
                }

                Section(header: Text("Analysis Results")) {
                    ForEach(viewModel.analysisItems) { item in
                        NavigationLink(value: item) {
                            Label(item.name, systemImage: item.icon)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("Settings")) {
                    ForEach(viewModel.settingsItems) { item in
                        NavigationLink(value: item) {
                            Label(item.name, systemImage: item.icon)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Code Reviewer")
            .listStyle(.sidebar)
        } detail: {
            if let selectedItem = viewModel.selectedItem {
                DetailView(item: selectedItem)
            } else {
                WelcomeView(showFilePicker: .constant(false))
            }
        }
        .background(.background)
    }
}

@MainActor
private struct DetailView: View {
    let item: SidebarItem

    var body: some View {
        VStack {
            Text(item.name)
                .font(.largeTitle)
                .padding()

            Text("Detail view for \(item.name)")
                .foregroundColor(.secondary)

            Spacer()
        }
    }
}

@MainActor
class SidebarViewModel: ObservableObject, BaseViewModel {
    // MARK: - State and Action Types

    struct State {
        var selectedItem: SidebarItem?
        var projectItems: [SidebarItem] = []
        var analysisItems: [SidebarItem] = []
        var settingsItems: [SidebarItem] = []
    }

    enum Action {
        case selectItem(SidebarItem?)
        case loadItems
        case resetSelection
    }

    // MARK: - BaseViewModel Properties

    var state = State()
    var isLoading = false
    var errorMessage: String?

    // MARK: - BaseViewModel Protocol

    func handle(_ action: Action) async {
        switch action {
        case let .selectItem(item):
            state.selectedItem = item
        case .loadItems:
            loadItems()
        case .resetSelection:
            state.selectedItem = nil
        }
    }

    func resetError() {
        errorMessage = nil
    }

    func validateState() -> Bool {
        true
    }

    // MARK: - Legacy Properties (for backward compatibility)

    var selectedItem: SidebarItem? {
        get { state.selectedItem }
        set { state.selectedItem = newValue }
    }

    var projectItems: [SidebarItem] {
        get { state.projectItems }
        set { state.projectItems = newValue }
    }

    var analysisItems: [SidebarItem] {
        get { state.analysisItems }
        set { state.analysisItems = newValue }
    }

    var settingsItems: [SidebarItem] {
        get { state.settingsItems }
        set { state.settingsItems = newValue }
    }

    // MARK: - Initialization

    init() {
        // Kick off async state loading from a non-async initializer
        Task { [weak self] in
            await self?.handle(.loadItems)
        }
    }

    private func setupItems() {
        state.projectItems = [
            SidebarItem(id: "files", name: "Source Files", icon: "folder"),
            SidebarItem(id: "structure", name: "Project Structure", icon: "list.bullet"),
            SidebarItem(id: "dependencies", name: "Dependencies", icon: "link"),
        ]

        state.analysisItems = [
            SidebarItem(id: "issues", name: "Code Issues", icon: "exclamationmark.triangle"),
            SidebarItem(id: "metrics", name: "Quality Metrics", icon: "chart.bar"),
            SidebarItem(id: "coverage", name: "Test Coverage", icon: "checkmark.circle"),
        ]

        state.settingsItems = [
            SidebarItem(id: "preferences", name: "Preferences", icon: "gear"),
            SidebarItem(id: "rules", name: "Analysis Rules", icon: "ruler"),
            SidebarItem(id: "integrations", name: "Integrations", icon: "puzzlepiece"),
        ]
    }

    private func loadItems() {
        setupItems()
    }
}

struct SidebarItem: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
}
