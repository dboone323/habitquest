import Combine
import Foundation
import HealthKit
import SwiftData

/// Centralized service for HealthKit synchronization and data management
@MainActor
public class HealthKitService: ObservableObject {
    public static let shared = HealthKitService()
    private let healthStore = HKHealthStore()

    @Published public var isAuthorized = false
    @Published public var stepCount: Int = 0
    @Published public var sleepHours: Double = 0.0

    private init() {
        checkAuthorizationStatus()
    }

    /// Request authorization to read health data (movement + sleep only)
    public func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.healthDataNotAvailable
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
        checkAuthorizationStatus()
    }

    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let stepStatus = healthStore.authorizationStatus(for: stepType)
        let sleepStatus = healthStore.authorizationStatus(for: sleepType)

        Task { @MainActor in
            isAuthorized = (stepStatus == .sharingAuthorized) && (sleepStatus == .sharingAuthorized)
            if isAuthorized {
                await fetchTodayStats()
            }
        }
    }

    /// Fetch today's health statistics from HealthKit (movement + sleep only)
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
                let totalSteps = stepSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.count()) }
                await MainActor.run { stepCount = Int(totalSteps) }
            }

            // Fetch sleep hours
            if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
                let sleepSamples = try await querySleepSamples(type: sleepType, predicate: predicate)
                let totalSleepHours = sleepSamples.reduce(0.0) { $0 + ($1.endDate.timeIntervalSince($1.startDate) / 3600.0) }
                await MainActor.run { sleepHours = totalSleepHours }
            }
        } catch {
            print("Error fetching health data: \(error)")
        }
    }

    /// Automatically logs completion for movement/sleep habits if health thresholds are met.
    public func autoFillHabits(_ habits: [Habit], in context: ModelContext) {
        let calendar = Calendar.current
        let today = Date()
        for habit in habits {
            if habit.name.localizedCaseInsensitiveContains("step") && stepCount >= 10000 {
                let alreadyLogged = habit.logs.contains { calendar.isDate($0.completionDate, inSameDayAs: today) }
                if !alreadyLogged {
                    let log = HabitLog(habit: habit, completionDate: today, notes: "Auto-logged from HealthKit (\(stepCount) steps)")
                    context.insert(log)
                }
            } else if habit.name.localizedCaseInsensitiveContains("sleep") && sleepHours >= 7.0 {
                let alreadyLogged = habit.logs.contains { calendar.isDate($0.completionDate, inSameDayAs: today) }
                if !alreadyLogged {
                    let log = HabitLog(habit: habit, completionDate: today, notes: "Auto-logged from HealthKit (\(String(format: "%.1f", sleepHours)) hours)")
                    context.insert(log)
                }
            }
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

    private func querySleepSamples(type: HKCategoryType, predicate: NSPredicate) async throws -> [HKCategorySample] {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let categorySamples = samples as? [HKCategorySample] {
                    continuation.resume(returning: categorySamples)
                } else {
                    continuation.resume(returning: [])
                }
            }
            healthStore.execute(query)
        }
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
