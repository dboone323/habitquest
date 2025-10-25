//
//  StatePreserver.swift
//  Hot Reload System
//
//  Preserves and restores application state during hot reload operations.
//  Manages object state, UI state, and application context.
//

import Foundation

/// State preservation and restoration for hot reload
@available(macOS 12.0, *)
public class StatePreserver {

    // MARK: - Properties

    private var preservedState: [StateIdentifier: Any] = [:]
    private var stateObservers: [StateObserver] = []
    private var preservationQueue = DispatchQueue(
        label: "com.quantum.state-preserver", qos: .userInitiated
    )

    /// Configuration for state preservation
    public struct Configuration {
        public var maxPreservedStates: Int = 10
        public var autoCleanupEnabled: Bool = true
        public var preserveUIState: Bool = true
        public var preserveObjectState: Bool = true
        public var compressionEnabled: Bool = false

        public init() {}
    }

    private var config: Configuration

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration
        setupDefaultObservers()
    }

    // MARK: - Public API

    /// Capture current application state
    public func captureState() async throws {
        try await preservationQueue.sync {
            print("📦 Capturing application state...")

            var capturedStates: [StateIdentifier: Any] = [:]

            // Capture state from all observers
            for observer in stateObservers {
                do {
                    let state = try observer.captureState()
                    capturedStates[observer.identifier] = state
                } catch {
                    print("Failed to capture state for \(observer.identifier): \(error)")
                }
            }

            // Store captured state
            preservedState = capturedStates

            // Cleanup old states if needed
            if config.autoCleanupEnabled && preservedState.count > config.maxPreservedStates {
                cleanupOldStates()
            }

            print("📦 State captured successfully (\(preservedState.count) components)")
        }
    }

    /// Restore preserved application state
    public func restoreState() async throws {
        try await preservationQueue.sync {
            print("🔄 Restoring application state...")

            var restoreErrors: [Error] = []

            // Restore state to all observers
            for observer in stateObservers {
                if let state = preservedState[observer.identifier] {
                    do {
                        try observer.restoreState(state)
                    } catch {
                        restoreErrors.append(error)
                        print("Failed to restore state for \(observer.identifier): \(error)")
                    }
                }
            }

            // Clear preserved state after successful restore
            if restoreErrors.isEmpty {
                preservedState.removeAll()
                print("🔄 State restored successfully")
            } else {
                print("🔄 State restoration completed with \(restoreErrors.count) errors")
                throw StateError.restoreFailed(restoreErrors)
            }
        }
    }

    /// Register a custom state observer
    public func registerObserver(_ observer: StateObserver) {
        preservationQueue.sync {
            // Remove existing observer with same identifier if present
            stateObservers.removeAll { $0.identifier == observer.identifier }
            stateObservers.append(observer)
        }
    }

    /// Unregister a state observer
    public func unregisterObserver(withIdentifier identifier: StateIdentifier) {
        preservationQueue.sync {
            stateObservers.removeAll { $0.identifier == identifier }
        }
    }

    /// Get current preserved state information
    public func getPreservedStateInfo() -> [StateInfo] {
        preservationQueue.sync {
            stateObservers.map { observer in
                StateInfo(
                    identifier: observer.identifier,
                    hasPreservedState: preservedState[observer.identifier] != nil,
                    stateType: observer.stateType,
                    lastCaptureTime: nil // Would need to track this
                )
            }
        }
    }

    /// Clear all preserved state
    public func clearPreservedState() {
        preservationQueue.sync {
            preservedState.removeAll()
        }
    }

    /// Export preserved state for debugging
    public func exportState() throws -> Data {
        preservationQueue.sync {
            let exportData = StateExportData(
                timestamp: Date(),
                preservedStates: preservedState.map { identifier, state in
                    ExportedState(identifier: identifier, state: state)
                }
            )

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            // Convert state objects to encodable format
            let encodableStates = exportData.preservedStates.map { exportedState -> [String: Any] in
                [
                    "identifier": [
                        "category": exportedState.identifier.category,
                        "name": exportedState.identifier.name,
                    ],
                    "stateType": exportedState.stateType.rawValue,
                    "stateData": String(describing: exportedState.state),
                ]
            }

            let encodableData: [String: Any] = [
                "timestamp": exportData.timestamp,
                "states": encodableStates,
            ]

            return try JSONSerialization.data(
                withJSONObject: encodableData, options: .prettyPrinted
            )
        }
    }

    // MARK: - Private Methods

    private func setupDefaultObservers() {
        // Register default observers for common state types

        // UserDefaults observer
        registerObserver(UserDefaultsStateObserver())

        // Application state observer
        registerObserver(ApplicationStateObserver())

        // View controller state observer (if UIKit/AppKit available)
        #if canImport(UIKit)
            registerObserver(UIViewControllerStateObserver())
        #elseif canImport(AppKit)
            registerObserver(NSViewControllerStateObserver())
        #endif

        // Custom object state observer
        registerObserver(CustomObjectStateObserver())
    }

    private func cleanupOldStates() {
        // Simple cleanup - remove oldest states
        // In a real implementation, this would use timestamps
        let statesToRemove = preservedState.count - config.maxPreservedStates
        if statesToRemove > 0 {
            let keysToRemove = Array(preservedState.keys.prefix(statesToRemove))
            for key in keysToRemove {
                preservedState.removeValue(forKey: key)
            }
        }
    }
}

// MARK: - State Observer Protocol

/// Protocol for state observers
public protocol StateObserver {
    var identifier: StateIdentifier { get }
    var stateType: StateType { get }

    func captureState() throws -> Any
    func restoreState(_ state: Any) throws
}

/// State identifier
public struct StateIdentifier: Hashable {
    public let category: String
    public let name: String

    public init(category: String, name: String) {
        self.category = category
        self.name = name
    }
}

/// State type enumeration
public enum StateType {
    case userDefaults
    case application
    case viewController
    case customObject
    case uiState
    case dataModel
}

/// State information
public struct StateInfo {
    public let identifier: StateIdentifier
    public let hasPreservedState: Bool
    public let stateType: StateType
    public let lastCaptureTime: Date?
}

// MARK: - Default State Observers

/// UserDefaults state observer
private class UserDefaultsStateObserver: StateObserver {
    let identifier = StateIdentifier(category: "System", name: "UserDefaults")
    let stateType: StateType = .userDefaults

    func captureState() throws -> Any {
        // Capture all UserDefaults (simplified - would need filtering)
        UserDefaults.standard.dictionaryRepresentation()
    }

    func restoreState(_ state: Any) throws {
        guard let defaults = state as? [String: Any] else {
            throw StateError.invalidStateType
        }

        // Restore UserDefaults (careful not to overwrite system defaults)
        for (key, value) in defaults where !key.hasPrefix("NS") {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
}

/// Application state observer
private class ApplicationStateObserver: StateObserver {
    let identifier = StateIdentifier(category: "Application", name: "General")
    let stateType: StateType = .application

    func captureState() throws -> Any {
        ApplicationState(
            launchDate: Date(),
            uptime: ProcessInfo.processInfo.systemUptime,
            memoryUsage: getMemoryUsage()
        )
    }

    func restoreState(_ state: Any) throws {
        // Application state is generally not restored
        // This is mainly for informational purposes
    }

    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), intPtr, &count)
            }
        }

        return kerr == KERN_SUCCESS ? info.resident_size : 0
    }
}

/// UIViewController state observer (iOS)
#if canImport(UIKit)
    private class UIViewControllerStateObserver: StateObserver {
        let identifier = StateIdentifier(category: "UI", name: "ViewControllers")
        let stateType: StateType = .viewController

        func captureState() throws -> Any {
            // This would capture the view controller hierarchy
            // Simplified implementation
            ["viewControllers": []]
        }

        func restoreState(_ state: Any) throws {
            // Restore view controller state
            // This is complex and would require careful implementation
        }
    }
#endif

/// NSViewController state observer (macOS)
#if canImport(AppKit)
    private class NSViewControllerStateObserver: StateObserver {
        let identifier = StateIdentifier(category: "UI", name: "ViewControllers")
        let stateType: StateType = .viewController

        func captureState() throws -> Any {
            // Similar to UIViewController but for macOS
            ["viewControllers": []]
        }

        func restoreState(_ state: Any) throws {
            // Restore view controller state
        }
    }
#endif

/// Custom object state observer
private class CustomObjectStateObserver: StateObserver {
    let identifier = StateIdentifier(category: "Objects", name: "Custom")
    let stateType: StateType = .customObject

    func captureState() throws -> Any {
        // This would capture state of registered custom objects
        // Requires a registration system for objects that want state preservation
        ["customObjects": []]
    }

    func restoreState(_ state: Any) throws {
        // Restore custom object states
    }
}

// MARK: - Supporting Types

/// Application state data
private struct ApplicationState {
    let launchDate: Date
    let uptime: TimeInterval
    let memoryUsage: UInt64
}

/// State export data
private struct StateExportData {
    let timestamp: Date
    let preservedStates: [ExportedState]
}

/// Exported state
private struct ExportedState {
    let identifier: StateIdentifier
    let state: Any
    let stateType: StateType

    init(identifier: StateIdentifier, state: Any) {
        self.identifier = StateIdentifier(category: identifier.category, name: identifier.name)
        self.state = state
        self.stateType = .customObject // Default, would need to be passed
    }
}

/// State error types
public enum StateError: Error, LocalizedError {
    case captureFailed(String)
    case restoreFailed([Error])
    case invalidStateType
    case observerNotFound(StateIdentifier)

    public var errorDescription: String? {
        switch self {
        case let .captureFailed(reason):
            return "State capture failed: \(reason)"
        case let .restoreFailed(errors):
            return "State restore failed with \(errors.count) errors"
        case .invalidStateType:
            return "Invalid state type for restoration"
        case let .observerNotFound(identifier):
            return "State observer not found: \(identifier.category).\(identifier.name)"
        }
    }
}
