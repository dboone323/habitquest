import Foundation

/// Backwards compatibility shim that forwards legacy `OllamaIntegrationFramework` usages
/// to the consolidated `OllamaIntegrationManager` implementation.
@available(*, deprecated, renamed: "OllamaIntegrationManager")
public typealias OllamaIntegrationFramework = OllamaIntegrationManager

/// Namespace helpers for quickly accessing and configuring a shared integration manager.
public enum OllamaIntegration {
    /// Shared manager instance used by simplified helper methods.
    private static var _shared: OllamaIntegrationManager?

    public static var shared: OllamaIntegrationManager {
        get async {
            if let existing = _shared {
                return existing
            }
            let manager = try! await OllamaIntegrationManager()
            _shared = manager
            return manager
        }
    }

    /// Replace the shared manager with a custom configuration.
    public static func configureShared(config: OllamaConfig) async {
        self._shared = try! await OllamaIntegrationManager(config: config)
    }

    /// Perform a quick service health check using the shared manager.
    public static func healthCheck() async -> ServiceHealth {
        await self.shared.checkServiceHealth()
    }
}
