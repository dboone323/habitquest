//
//  ServiceLocator.swift
//  MomentumFinance
//
//  Created by AI Enhancement System
//  Copyright © 2024 Quantum Workspace. All rights reserved.
//

import Foundation
import SwiftData

/// Service locator for dependency injection in MomentumFinance
@MainActor
public final class ServiceLocator {
    // MARK: - Singleton

    public static let shared = ServiceLocator()

    private init() {}

    // MARK: - Services

    private var services: [String: Any] = [:]
    private var serviceFactories: [String: () -> Any] = [:]

    // MARK: - Service Registration

    /// Register a service instance
    public func register<T>(_ service: T, for type: T.Type) {
        let key = String(describing: type)
        services[key] = service
    }

    /// Register a service factory
    public func registerFactory<T>(_ factory: @escaping () -> T, for type: T.Type) {
        let key = String(describing: type)
        serviceFactories[key] = factory
    }

    // MARK: - Service Resolution

    /// Resolve a service instance
    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)

        // Try to get existing instance
        if let service = services[key] as? T {
            return service
        }

        // Try to create from factory
        if let factory = serviceFactories[key] {
            let service = factory() as? T
            if let service = service {
                services[key] = service
                return service
            }
        }

        return nil
    }

    /// Resolve a service instance with fatal error if not found
    public func resolve<T>(_ type: T.Type) -> T {
        guard let service = resolve(type) else {
            fatalError("Service \(String(describing: type)) not registered")
        }
        return service
    }

    // MARK: - Setup

    /// Setup all services with the provided model context
    public func setup(with modelContext: ModelContext) {
        // Register FinancialInsightsService
        registerFactory({
            FinancialInsightsService(modelContext: modelContext)
        }, for: FinancialInsightsService.self)

        // Register other services as needed
        // TODO: Add other services like AnalyticsService, etc.
    }

    /// Reset all services (useful for testing)
    public func reset() {
        services.removeAll()
        serviceFactories.removeAll()
    }
}

// MARK: - Convenience Extensions

public extension ServiceLocator {
    /// Get the FinancialInsightsService
    var financialInsightsService: FinancialInsightsService {
        resolve(FinancialInsightsService.self)
    }
}
