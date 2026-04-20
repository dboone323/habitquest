import Combine
import Foundation
import HealthKit

/// Centralized service for HealthKit synchronization and data management
@MainActor
public class HealthKitService: ObservableObject {
    public static let shared = HealthKitService()
    private let healthStore = HKHealthStore()

    @Published public var isAuthorized = false
    @Published public var stepCount: Int = 0
    @Published public var activeEnergyBurned: Double = 0.0
    @Published public var exerciseMinutes: Int = 0

    private init() {
        checkAuthorizationStatus()
    }

    /// Request authorization to read and write health data
    public func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.healthDataNotAvailable
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!
        ]

        let writeTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.workoutType()
        ]

        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        checkAuthorizationStatus()
    }

    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let status = healthStore.authorizationStatus(for: stepType)

        Task { @MainActor in
            isAuthorized = (status == .sharingAuthorized)
            if isAuthorized {
                await fetchTodayStats()
            }
        }
    }

    /// Fetch today's health statistics from HealthKit
    public func fetchTodayStats() async {
        guard isAuthorized else { return }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        do {
            // Fetch step count
            if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
                let stepSamples = try await queryQuantitySamples(type: stepType, predicate: predicate)
                let totalSteps = stepSamples.reduce(0) { $0 + $1.quantity.doubleValue(for: HKUnit.count()) }
                await MainActor.run { stepCount = Int(totalSteps) }
            }

            // Fetch active energy
            if let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
                let energySamples = try await queryQuantitySamples(type: energyType, predicate: predicate)
                let totalEnergy = energySamples.reduce(0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
                await MainActor.run { activeEnergyBurned = totalEnergy }
            }

            // Fetch exercise minutes
            if let exerciseType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) {
                let exerciseSamples = try await queryQuantitySamples(type: exerciseType, predicate: predicate)
                let totalMinutes = exerciseSamples.reduce(0) { $0 + $1.quantity.doubleValue(for: HKUnit.minute()) }
                await MainActor.run { exerciseMinutes = Int(totalMinutes) }
            }
        } catch {
            print("Error fetching health data: \(error)")
        }
    }

    private func queryQuantitySamples(type: HKQuantityType, predicate: NSPredicate) async throws -> [HKQuantitySample] {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let quantitySamples = samples as? [HKQuantitySample] {
                    continuation.resume(returning: quantitySamples)
                } else {
                    continuation.resume(returning: [])
                }
            }
            healthStore.execute(query)
        }
    }

    /// Log a workout to HealthKit
    public func logWorkout(
        type: HKWorkoutActivityType,
        startDate: Date,
        endDate: Date,
        energyBurned: Double? = nil
    ) async throws {
        guard isAuthorized else { throw HealthKitError.notAuthorized }

        let workout = HKWorkout(
            activityType: type,
            start: startDate,
            end: endDate,
            duration: endDate.timeIntervalSince(startDate),
            totalEnergyBurned: energyBurned != nil
                ? HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: energyBurned!)
                : nil,
            totalDistance: nil,
            metadata: nil
        )

        try await healthStore.save(workout)
    }
}

public enum HealthKitError: LocalizedError {
    case healthDataNotAvailable
    case notAuthorized

    public var errorDescription: String? {
        switch self {
        case .healthDataNotAvailable:
            "Health data is not available on this device"
        case .notAuthorized:
            "HealthKit access not authorized"
        }
    }
}
