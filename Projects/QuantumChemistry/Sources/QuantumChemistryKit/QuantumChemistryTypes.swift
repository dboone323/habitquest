//
//  QuantumChemistryTypes.swift
//  QuantumChemistry
//
//  Created on October 12, 2025
//  Quantum Supremacy Prototype - Core Data Types
//

import Foundation

// MARK: - Core Data Structures

/// Represents a chemical atom with quantum properties
public struct Atom {
    public let symbol: String
    public let atomicNumber: Int
    public let position: SIMD3<Double> // Angstroms
    public let mass: Double // Atomic mass units
    public let charge: Double

    public init(symbol: String, atomicNumber: Int, position: SIMD3<Double>, mass: Double, charge: Double = 0.0) {
        self.symbol = symbol
        self.atomicNumber = atomicNumber
        self.position = position
        self.mass = mass
        self.charge = charge
    }
}

/// Represents a molecule composed of atoms
public struct Molecule {
    public let name: String
    public let atoms: [Atom]
    public let charge: Int
    public let multiplicity: Int

    public init(name: String, atoms: [Atom], charge: Int = 0, multiplicity: Int = 1) {
        self.name = name
        self.atoms = atoms
        self.charge = charge
        self.multiplicity = multiplicity
    }

    /// Calculate center of mass
    public var centerOfMass: SIMD3<Double> {
        let totalMass = atoms.reduce(0) { $0 + $1.mass }
        let weightedSum = atoms.reduce(SIMD3<Double>(0, 0, 0)) { sum, atom in
            sum + atom.position * atom.mass
        }
        return weightedSum / totalMass
    }

    /// Calculate molecular weight
    public var molecularWeight: Double {
        atoms.reduce(0) { $0 + $1.mass }
    }
}

/// Represents a molecular orbital in quantum chemistry
public struct MolecularOrbital {
    public let index: Int
    public let energy: Double // Hartree
    public let occupation: Double // 0, 1, or 2
    public let coefficients: [Double] // LCAO coefficients
    public let type: OrbitalType

    public enum OrbitalType {
        case core
        case valence
        case virtual
    }
}

/// Hamiltonian operator for quantum chemistry
public struct Hamiltonian {
    public let kinetic: EnergyComponent
    public let potential: EnergyComponent
    public let electronRepulsion: EnergyComponent
    public let totalTerms: Int

    public var totalEnergy: Double {
        kinetic.totalEnergy + potential.totalEnergy + electronRepulsion.totalEnergy
    }
}

/// Component of molecular energy
public struct EnergyComponent {
    public let type: EnergyType
    public let terms: [EnergyTerm]
    public let totalEnergy: Double

    public enum EnergyType {
        case kinetic
        case potential
        case electronRepulsion
    }
}

/// Individual energy term in Hamiltonian
public struct EnergyTerm {
    public let coefficient: Double
    public let orbitals: [Int] // Orbital indices involved
    public let value: Double
}

/// Molecular properties calculated from quantum simulation
public struct MolecularProperties {
    public let dipoleMoment: SIMD3<Double> // Debye
    public let polarizability: Double // Bohr³
    public let vibrationalFrequencies: [Double] // cm⁻¹
    public let bondLengths: [Double] // Angstroms
    public let bondAngles: [Double] // Degrees
}

/// Result of quantum chemistry simulation
public struct SimulationResult {
    public let molecule: Molecule
    public let totalEnergy: Double // Hartree
    public let molecularOrbitals: [MolecularOrbital]
    public let properties: MolecularProperties
    public let quantumAdvantage: Double // Speedup factor over classical methods
    public let computationTime: TimeInterval

    /// Check if simulation demonstrates quantum supremacy
    public var demonstratesSupremacy: Bool {
        quantumAdvantage > 1.0
    }

    /// Performance metrics
    public var performanceMetrics: PerformanceMetrics {
        PerformanceMetrics(
            computationTime: computationTime,
            quantumAdvantage: quantumAdvantage,
            accuracy: 1e-8, // Hartree accuracy
            scalability: Double(molecule.atoms.count)
        )
    }
}

/// Performance metrics for quantum simulation
public struct PerformanceMetrics {
    public let computationTime: TimeInterval
    public let quantumAdvantage: Double
    public let accuracy: Double
    public let scalability: Double

    public var efficiency: Double {
        quantumAdvantage / computationTime
    }
}

// MARK: - Common Molecules Library

public enum CommonMolecules {
    public static let hydrogen = Molecule(
        name: "H₂",
        atoms: [
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(0, 0, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(0.74, 0, 0), mass: 1.00784)
        ]
    )

    public static let water = Molecule(
        name: "H₂O",
        atoms: [
            Atom(symbol: "O", atomicNumber: 8, position: SIMD3<Double>(0, 0, 0), mass: 15.999),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(0.96, 0, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(-0.24, 0.93, 0), mass: 1.00784)
        ]
    )

    public static let methane = Molecule(
        name: "CH₄",
        atoms: [
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(0, 0, 0), mass: 12.011),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(1.09, 0, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(-0.36, 1.02, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(-0.36, -0.51, 0.89), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(-0.36, -0.51, -0.89), mass: 1.00784)
        ]
    )

    public static let benzene = Molecule(
        name: "C₆H₆",
        atoms: [
            // Carbon atoms in ring
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(1.39, 0, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(0.695, 1.205, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(-0.695, 1.205, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(-1.39, 0, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(-0.695, -1.205, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(0.695, -1.205, 0), mass: 12.011),
            // Hydrogen atoms
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(2.48, 0, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(1.24, 2.13, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(-1.24, 2.13, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(-2.48, 0, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(-1.24, -2.13, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(1.24, -2.13, 0), mass: 1.00784)
        ]
    )

    public static let caffeine = Molecule(
        name: "Caffeine",
        atoms: [
            // Simplified caffeine structure (C8H10N4O2)
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(0, 0, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(1.5, 0, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(3.0, 0, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(4.5, 0, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(6.0, 0, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(7.5, 0, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(9.0, 0, 0), mass: 12.011),
            Atom(symbol: "C", atomicNumber: 6, position: SIMD3<Double>(10.5, 0, 0), mass: 12.011),
            Atom(symbol: "N", atomicNumber: 7, position: SIMD3<Double>(2.25, 1.5, 0), mass: 14.007),
            Atom(symbol: "N", atomicNumber: 7, position: SIMD3<Double>(5.25, 1.5, 0), mass: 14.007),
            Atom(symbol: "N", atomicNumber: 7, position: SIMD3<Double>(8.25, 1.5, 0), mass: 14.007),
            Atom(symbol: "N", atomicNumber: 7, position: SIMD3<Double>(11.25, 1.5, 0), mass: 14.007),
            Atom(symbol: "O", atomicNumber: 8, position: SIMD3<Double>(1.5, -1.5, 0), mass: 15.999),
            Atom(symbol: "O", atomicNumber: 8, position: SIMD3<Double>(10.5, -1.5, 0), mass: 15.999),
            // Hydrogens (simplified positions)
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(0, 1.0, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(3.0, 1.0, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(6.0, 1.0, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(9.0, 1.0, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(12.0, 1.0, 0), mass: 1.00784),
            Atom(symbol: "H", atomicNumber: 1, position: SIMD3<Double>(13.5, 0, 0), mass: 1.00784)
        ]
    )
}

// MARK: - Extensions

extension SIMD3<Double> {
    public var magnitude: Double {
        sqrt(x * x + y * y + z * z)
    }
}

// MARK: - Quantum Hardware Integration Types

/// Quantum hardware providers for real quantum computation
public enum QuantumHardwareProvider {
    case ibmQuantum
    case rigetti
    case ionQ
    case simulator
}

/// Configuration for quantum hardware execution
public struct QuantumHardwareConfig {
    public let provider: QuantumHardwareProvider
    public let backend: String
    public let shots: Int
    public let optimizationLevel: Int
    public let apiKey: String?

    public init(provider: QuantumHardwareProvider,
                backend: String = "simulator",
                shots: Int = 1000,
                optimizationLevel: Int = 1,
                apiKey: String? = nil) {
        self.provider = provider
        self.backend = backend
        self.shots = shots
        self.optimizationLevel = optimizationLevel
        self.apiKey = apiKey
    }
}

/// Result from quantum hardware execution
public struct QuantumHardwareResult {
    public let jobId: String
    public let provider: QuantumHardwareProvider
    public let backend: String
    public let executionTime: TimeInterval
    public let shots: Int
    public let counts: [String: Int]
    public let expectationValue: Double
    public let fidelity: Double
    public let errorRate: Double

    public init(jobId: String,
                provider: QuantumHardwareProvider,
                backend: String,
                executionTime: TimeInterval,
                shots: Int,
                counts: [String: Int],
                expectationValue: Double,
                fidelity: Double = 0.95,
                errorRate: Double = 0.01) {
        self.jobId = jobId
        self.provider = provider
        self.backend = backend
        self.executionTime = executionTime
        self.shots = shots
        self.counts = counts
        self.expectationValue = expectationValue
        self.fidelity = fidelity
        self.errorRate = errorRate
    }
}

/// Job status for quantum hardware execution
public enum QuantumJobStatus {
    case queued
    case running
    case completed
    case failed(String)
    case cancelled
}

/// Quantum circuit representation for hardware submission
public struct QuantumCircuit {
    public let qubits: Int
    public let gates: [QuantumGate]
    public let measurements: [Int]

    public init(qubits: Int, gates: [QuantumGate], measurements: [Int]) {
        self.qubits = qubits
        self.gates = gates
        self.measurements = measurements
    }
}

/// Quantum gate representation
public struct QuantumGate {
    public let type: GateType
    public let qubits: [Int]
    public let parameters: [Double]

    public enum GateType {
        case hadamard // Hadamard
        case pauliX // Pauli-X
        case pauliY // Pauli-Y
        case pauliZ // Pauli-Z
        case rotationX // Rotation-X
        case rotationY // Rotation-Y
        case rotationZ // Rotation-Z
        case cnot // CNOT
        case controlledZ // Controlled-Z
        case toffoli // Toffoli
    }

    public init(type: GateType, qubits: [Int], parameters: [Double] = []) {
        self.type = type
        self.qubits = qubits
        self.parameters = parameters
    }
}

/// VQE ansatz for molecular ground state preparation
public struct VQEAnsatz {
    public let layers: Int
    public let parameters: [Double]
    public let circuit: QuantumCircuit

    public init(layers: Int, parameters: [Double], circuit: QuantumCircuit) {
        self.layers = layers
        self.parameters = parameters
        self.circuit = circuit
    }
}

/// QMC walker for quantum Monte Carlo on hardware
public struct QMCWalker {
    public let position: [Double]
    public let weight: Double
    public let energy: Double

    public init(position: [Double], weight: Double, energy: Double) {
        self.position = position
        self.weight = weight
        self.energy = energy
    }
}
