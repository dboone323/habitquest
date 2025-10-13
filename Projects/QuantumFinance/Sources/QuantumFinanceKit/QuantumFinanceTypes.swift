//
//  QuantumFinanceTypes.swift
//  QuantumFinanceKit
//
//  Quantum Financial Modeling Types and Data Structures
//  Implements quantum advantage for portfolio optimization and risk analysis
//

import Foundation

// MARK: - Core Financial Types

/// Represents a financial asset with quantum-enhanced properties
public struct Asset: Sendable, Codable {
    public let symbol: String
    public let name: String
    public let expectedReturn: Double  // Expected annual return
    public let volatility: Double      // Annual volatility (standard deviation)
    public let currentPrice: Double
    public let marketCap: Double?

    public init(symbol: String, name: String, expectedReturn: Double,
                volatility: Double, currentPrice: Double, marketCap: Double? = nil) {
        self.symbol = symbol
        self.name = name
        self.expectedReturn = expectedReturn
        self.volatility = volatility
        self.currentPrice = currentPrice
        self.marketCap = marketCap
    }
}

/// Portfolio allocation weights
public struct PortfolioWeights: Sendable, Codable {
    public let weights: [String: Double]  // Symbol -> Weight mapping

    public var totalWeight: Double {
        weights.values.reduce(0, +)
    }

    public var isNormalized: Bool {
        abs(totalWeight - 1.0) < 1e-10
    }

    public init(weights: [String: Double]) {
        self.weights = weights
    }

    public func normalized() -> PortfolioWeights {
        let total = totalWeight
        guard total > 0 else { return self }
        let normalizedWeights = weights.mapValues { $0 / total }
        return PortfolioWeights(weights: normalizedWeights)
    }
}

/// Risk metrics for portfolio analysis
public struct RiskMetrics: Sendable, Codable {
    public let expectedReturn: Double
    public let volatility: Double
    public let sharpeRatio: Double
    public let maxDrawdown: Double
    public let valueAtRisk: Double  // 95% VaR
    public let conditionalVaR: Double  // Expected shortfall

    public init(expectedReturn: Double, volatility: Double, sharpeRatio: Double,
                maxDrawdown: Double, valueAtRisk: Double, conditionalVaR: Double) {
        self.expectedReturn = expectedReturn
        self.volatility = volatility
        self.sharpeRatio = sharpeRatio
        self.maxDrawdown = maxDrawdown
        self.valueAtRisk = valueAtRisk
        self.conditionalVaR = conditionalVaR
    }
}

/// Quantum optimization result
public struct QuantumOptimizationResult: Sendable, Codable {
    public let optimalWeights: PortfolioWeights
    public let riskMetrics: RiskMetrics
    public let quantumAdvantage: Double  // Speedup factor over classical methods
    public let convergenceTime: TimeInterval
    public let iterations: Int

    public init(optimalWeights: PortfolioWeights, riskMetrics: RiskMetrics,
                quantumAdvantage: Double, convergenceTime: TimeInterval, iterations: Int) {
        self.optimalWeights = optimalWeights
        self.riskMetrics = riskMetrics
        self.quantumAdvantage = quantumAdvantage
        self.convergenceTime = convergenceTime
        self.iterations = iterations
    }
}

/// Market conditions and constraints
public struct MarketConstraints: Sendable, Codable {
    public let maxWeightPerAsset: Double  // Maximum allocation per asset (e.g., 0.2 = 20%)
    public let minWeightPerAsset: Double  // Minimum allocation per asset
    public let maxVolatility: Double      // Maximum portfolio volatility
    public let minReturn: Double          // Minimum required return
    public let riskFreeRate: Double       // Risk-free rate for Sharpe ratio

    public init(maxWeightPerAsset: Double = 0.3, minWeightPerAsset: Double = 0.0,
                maxVolatility: Double = 0.4, minReturn: Double = 0.0, riskFreeRate: Double = 0.02) {
        self.maxWeightPerAsset = maxWeightPerAsset
        self.minWeightPerAsset = minWeightPerAsset
        self.maxVolatility = maxVolatility
        self.minReturn = minReturn
        self.riskFreeRate = riskFreeRate
    }
}

// MARK: - Quantum-Specific Types

/// Quantum state representation for portfolio optimization
public struct QuantumPortfolioState: Sendable {
    public var amplitudes: [ComplexNumber]  // Quantum amplitudes for each portfolio configuration
    public var phase: Double         // Global phase
    public var entanglement: Double  // Measure of quantum entanglement in the portfolio

    public init(amplitudes: [ComplexNumber], phase: Double = 0.0, entanglement: Double = 0.0) {
        self.amplitudes = amplitudes
        self.phase = phase
        self.entanglement = entanglement
    }
}

/// Quantum circuit parameters for financial optimization
public struct QuantumCircuitParameters: Sendable {
    public let numQubits: Int
    public let depth: Int
    public let ansatzType: String  // Type of variational ansatz
    public let entanglementPattern: String

    public init(numQubits: Int, depth: Int, ansatzType: String = "EfficientSU2",
                entanglementPattern: String = "full") {
        self.numQubits = numQubits
        self.depth = depth
        self.ansatzType = ansatzType
        self.entanglementPattern = entanglementPattern
    }
}

// MARK: - Common Financial Assets

public enum CommonAssets {
    public static let techStocks: [Asset] = [
        Asset(symbol: "AAPL", name: "Apple Inc.", expectedReturn: 0.12, volatility: 0.25, currentPrice: 150.0, marketCap: 2.5e12),
        Asset(symbol: "MSFT", name: "Microsoft Corporation", expectedReturn: 0.15, volatility: 0.22, currentPrice: 300.0, marketCap: 2.2e12),
        Asset(symbol: "GOOGL", name: "Alphabet Inc.", expectedReturn: 0.14, volatility: 0.24, currentPrice: 2800.0, marketCap: 1.8e12),
        Asset(symbol: "AMZN", name: "Amazon.com Inc.", expectedReturn: 0.16, volatility: 0.28, currentPrice: 3300.0, marketCap: 1.6e12),
        Asset(symbol: "NVDA", name: "NVIDIA Corporation", expectedReturn: 0.25, volatility: 0.35, currentPrice: 450.0, marketCap: 1.1e12)
    ]

    public static let bonds: [Asset] = [
        Asset(symbol: "US10Y", name: "10-Year US Treasury", expectedReturn: 0.04, volatility: 0.08, currentPrice: 100.0),
        Asset(symbol: "US30Y", name: "30-Year US Treasury", expectedReturn: 0.045, volatility: 0.10, currentPrice: 100.0),
        Asset(symbol: "CORP", name: "Corporate Bond ETF", expectedReturn: 0.055, volatility: 0.12, currentPrice: 85.0, marketCap: 5e10)
    ]

    public static let commodities: [Asset] = [
        Asset(symbol: "GLD", name: "SPDR Gold Shares", expectedReturn: 0.06, volatility: 0.15, currentPrice: 180.0, marketCap: 6e10),
        Asset(symbol: "SLV", name: "iShares Silver Trust", expectedReturn: 0.08, volatility: 0.22, currentPrice: 22.0, marketCap: 8e9),
        Asset(symbol: "USO", name: "United States Oil Fund", expectedReturn: 0.10, volatility: 0.30, currentPrice: 75.0, marketCap: 3e9)
    ]

    public static let allAssets: [Asset] = techStocks + bonds + commodities
}

// MARK: - Option Pricing Types

/// European option types
public enum OptionType: String, Sendable {
    case call = "Call"
    case put = "Put"
}

/// Result of quantum option pricing
public struct OptionPriceResult: Sendable {
    public let price: Double
    public let delta: Double
    public let gamma: Double
    public let theta: Double
    public let vega: Double
    public let rho: Double
    public let computationTime: TimeInterval
    public let quantumAdvantage: Double
    public let confidenceInterval: (lower: Double, upper: Double)

    public init(price: Double, delta: Double, gamma: Double, theta: Double, vega: Double, rho: Double,
                computationTime: TimeInterval, quantumAdvantage: Double, confidenceInterval: (lower: Double, upper: Double)) {
        self.price = price
        self.delta = delta
        self.gamma = gamma
        self.theta = theta
        self.vega = vega
        self.rho = rho
        self.computationTime = computationTime
        self.quantumAdvantage = quantumAdvantage
        self.confidenceInterval = confidenceInterval
    }
}

// MARK: - Quantum Risk Estimation Types

/// Result of quantum risk estimation using amplitude estimation
public struct QuantumRiskEstimationResult: Sendable {
    public let valueAtRisk: Double
    public let conditionalVaR: Double
    public let confidenceLevel: Double
    public let precision: Double
    public let computationTime: TimeInterval
    public let quantumAdvantage: Double

    public init(valueAtRisk: Double, conditionalVaR: Double, confidenceLevel: Double, precision: Double,
                computationTime: TimeInterval, quantumAdvantage: Double) {
        self.valueAtRisk = valueAtRisk
        self.conditionalVaR = conditionalVaR
        self.confidenceLevel = confidenceLevel
        self.precision = precision
        self.computationTime = computationTime
        self.quantumAdvantage = quantumAdvantage
    }
}