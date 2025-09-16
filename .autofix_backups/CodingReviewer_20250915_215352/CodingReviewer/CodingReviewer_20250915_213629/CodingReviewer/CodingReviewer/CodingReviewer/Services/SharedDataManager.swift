import Foundation
import Combine
import SwiftUI

// MARK: - Shared Data Manager

/// Singleton manager to share file data and services across all views in the app.
///
/// Use `SharedDataManager.shared` to access the shared file manager and trigger view refreshes.

@MainActor
final class SharedDataManager: ObservableObject {
    /// The shared singleton instance for global access.
    static let shared = SharedDataManager()

    // Shared FileManagerService instance
    /// The shared file manager service instance.
    @Published var fileManager: FileManagerService

    /// Private initializer to enforce singleton usage.
    private init() {
        self.fileManager = FileManagerService()
    }

    // Method to get the shared file manager
    /// Returns the shared file manager service instance.
    func getFileManager() -> FileManagerService {
        fileManager
    }

    // Method to explicitly refresh all views
    /// Explicitly triggers a refresh for all views and the file manager.
    func refreshAllViews() {
        objectWillChange.send()
        fileManager.objectWillChange.send()
    }
}

// MARK: - View Extensions for Shared Data

extension View {
    /// Access the shared file manager service from any SwiftUI view.
    var sharedFileManager: FileManagerService {
        SharedDataManager.shared.fileManager
    }
}

// MARK: - Environment Key for File Manager

/// Environment key for injecting the shared file manager into SwiftUI environment values.
private struct FileManagerKey: EnvironmentKey {
    typealias Value = FileManagerService?
    /// Use lazy initialization to avoid MainActor isolation issues in environment values.
    static let defaultValue: FileManagerService? = nil
}

extension EnvironmentValues {
    /// Access or set the shared file manager in the SwiftUI environment.
    var fileManager: FileManagerService? {
        get { self[FileManagerKey.self] }
        set { self[FileManagerKey.self] = newValue }
    }
}
