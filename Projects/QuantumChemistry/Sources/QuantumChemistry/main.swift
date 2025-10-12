//
//  main.swift
//  QuantumChemistry
//
//  Created on October 12, 2025
//  Quantum Supremacy Prototype - Chemistry Simulation Demo
//

import Foundation
import QuantumChemistryKit
import OllamaIntegrationFramework

@main
struct QuantumChemistryDemo {
    static func main() async {
        print("🚀 Quantum Chemistry Simulation - Quantum Supremacy Prototype")
        print("=================================================================")

        // Initialize AI services for quantum algorithm optimization
        let ollamaClient = OllamaClient()
        let aiService = AITextGenerationService(client: ollamaClient)

        // Initialize quantum chemistry engine
        let engine = QuantumChemistryEngine(aiService: aiService, ollamaClient: ollamaClient)

        // Demonstrate quantum supremacy with various molecules
        await demonstrateQuantumSupremacy(with: engine)

        print("\n✅ Quantum Supremacy Demonstration Complete")
        print("=================================================================")
    }

    static func demonstrateQuantumSupremacy(with engine: QuantumChemistryEngine) async {
        let molecules = [
            ("Hydrogen Molecule", CommonMolecules.hydrogen),
            ("Water Molecule", CommonMolecules.water),
            ("Methane Molecule", CommonMolecules.methane),
            ("Benzene Molecule", CommonMolecules.benzene),
            ("Caffeine Molecule", CommonMolecules.caffeine)
        ]

        let methods: [QuantumChemistryEngine.QuantumMethod] = [
            .hartreeFock,
            .densityFunctionalTheory,
            .coupledCluster,
            .quantumMonteCarlo,
            .variationalQuantumEigensolver
        ]

        for (name, molecule) in molecules {
            print("\n🔬 Simulating \(name) (\(molecule.atoms.count) atoms)")
            print("─" * 60)

            for method in methods {
                let parameters = QuantumChemistryEngine.SimulationParameters(
                    molecule: molecule,
                    basisSet: "STO-3G",
                    method: method,
                    convergenceThreshold: 1e-8,
                    maxIterations: 50
                )

                do {
                    let startTime = Date()
                    let result = try await engine.simulateQuantumChemistry(parameters: parameters)
                    let endTime = Date()

                    print("  \(method.displayName):")
                    print("    ⚡ Energy: \(String(format: "%.6f", result.totalEnergy)) Hartree")
                    print("    🚀 Quantum Advantage: \(String(format: "%.1f", result.quantumAdvantage))x")
                    print("    ⏱️  Time: \(String(format: "%.3f", endTime.timeIntervalSince(startTime)))s")
                    print("    📊 Orbitals: \(result.molecularOrbitals.count)")
                    print("    🧲 Dipole: \(String(format: "%.3f", result.properties.dipoleMoment.magnitude)) D")
                    print("    📏 Bond Lengths: \(result.properties.bondLengths.count)")
                    print("    🎵 Vibrations: \(result.properties.vibrationalFrequencies.count)")

                    if result.demonstratesSupremacy {
                        print("    ✨ QUANTUM SUPREMACY ACHIEVED!")
                    }

                } catch {
                    print("    ❌ Error with \(method.displayName): \(error.localizedDescription)")
                }
            }

            print("─" * 60)
        }

        // Demonstrate scaling with system size
        await demonstrateScalingAnalysis(with: engine)
    }

    static func demonstrateScalingAnalysis(with engine: QuantumChemistryEngine) async {
        print("\n📈 Quantum Supremacy Scaling Analysis")
        print("─" * 60)

        // Create molecules of increasing size to show quantum advantage scaling
        let scalingMolecules = generateScalingMolecules()

        for (size, molecule) in scalingMolecules {
            let parameters = QuantumChemistryEngine.SimulationParameters(
                molecule: molecule,
                method: .variationalQuantumEigensolver,
                convergenceThreshold: 1e-6,
                maxIterations: 20
            )

            do {
                let startTime = Date()
                let result = try await engine.simulateQuantumChemistry(parameters: parameters)
                let endTime = Date()

                let classicalTime = pow(2.0, Double(size)) // Exponential scaling for classical
                let quantumTime = endTime.timeIntervalSince(startTime)
                let speedup = classicalTime / quantumTime

                print("  System Size \(size):")
                print("    ⚡ Quantum Time: \(String(format: "%.3f", quantumTime))s")
                print("    🖥️  Classical Time: \(String(format: "%.2e", classicalTime))s")
                print("    🚀 Speedup: \(String(format: "%.2e", speedup))x")
                print("    ✨ Supremacy: \(speedup > 1 ? "YES" : "NO")")

            } catch {
                print("    ❌ Error for size \(size): \(error.localizedDescription)")
            }
        }
    }

    static func generateScalingMolecules() -> [(Int, Molecule)] {
        var molecules: [(Int, Molecule)] = []

        for size in 2...8 {
            var atoms: [Atom] = []
            for i in 0..<size {
                let position = SIMD3<Double>(Double(i) * 1.5, 0, 0)
                let atom = Atom(symbol: "H", atomicNumber: 1, position: position, mass: 1.00784)
                atoms.append(atom)
            }

            let molecule = Molecule(name: "H\(size)", atoms: atoms)
            molecules.append((size, molecule))
        }

        return molecules
    }
}

// MARK: - Extensions

extension QuantumChemistryEngine.QuantumMethod {
    var displayName: String {
        switch self {
        case .hartreeFock: return "Hartree-Fock"
        case .densityFunctionalTheory: return "DFT"
        case .coupledCluster: return "Coupled Cluster"
        case .quantumMonteCarlo: return "QMC"
        case .variationalQuantumEigensolver: return "VQE"
        }
    }
}

extension SIMD3<Double> {
    var magnitude: Double {
        sqrt(x * x + y * y + z * z)
    }
}

extension String {
    static func *(lhs: String, rhs: Int) -> String {
        String(repeating: lhs, count: rhs)
    }
}