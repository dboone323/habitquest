// NetworkMonitor.swift
// A utility class to monitor network connectivity status

import Foundation
import Network

// Add the extension to define the notification name
extension NSNotification.Name {
    static let networkStatusChanged = NSNotification.Name("networkStatusChanged")
}

@MainActor
class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private(set) var isConnected = true
    private(set) var connectionType: ConnectionType = .wifi

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        self.startMonitoring()
    }

    func startMonitoring() {
        self.monitor.start(queue: self.queue)

        self.monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.getConnectionType(path)

                // Post notification of status change
                NotificationCenter.default.post(
                    name: .networkStatusChanged,
                    object: nil,
                    userInfo: ["isConnected": self?.isConnected ?? false]
                )
            }
        }
    }

    func stopMonitoring() {
        self.monitor.cancel()
    }

    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            self.connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            self.connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            self.connectionType = .ethernet
        } else {
            self.connectionType = .unknown
        }
    }
}
