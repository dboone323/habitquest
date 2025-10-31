import SharedKit
import SwiftUI

@MainActor
public struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showFilePicker = false

    public init() {}

    public var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            ZStack {
                Color.clear
                    .ignoresSafeArea()

                VStack {
                    switch viewModel.currentView {
                    case .welcome:
                        WelcomeView(showFilePicker: $showFilePicker)
                    case .codeReview:
                        CodeReviewView()
                    case .settings:
                        SettingsView()
                    }
                }
            }
        }
        .background(.background)
    }
}

@MainActor
class ContentViewModel: ObservableObject, BaseViewModel {
    typealias State = ContentState
    typealias Action = ContentAction

    @Published var state: State = .idle
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentView: ContentViewType = .welcome

    func handle(_ action: ContentAction) async {
        switch action {
        case let .switchView(viewType):
            currentView = viewType
        case .showFilePicker:
            // Handle file picker logic
            break
        }
    }

    func resetError() {
        errorMessage = nil
    }

    func validateState() -> Bool {
        true
    }
}

enum ContentState {
    case idle
    case loading
    case loaded
    case error(String)
}

enum ContentAction {
    case switchView(ContentViewType)
    case showFilePicker
}

enum ContentViewType {
    case welcome
    case codeReview
    case settings
}

@MainActor
struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .foregroundColor(.primary)

            Text("Application settings will be implemented here")
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .background(.background)
    }
}
