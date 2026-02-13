import Foundation

enum NetworkSecurityPolicy {
    static let pinnedDomains: Set<String> = [
        "api.habitquest.app",
    ]

    static func makeSecureSession(delegate: URLSessionDelegate? = nil) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = true
        if #available(iOS 15.0, macOS 12.0, *) {
            configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        }
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}
