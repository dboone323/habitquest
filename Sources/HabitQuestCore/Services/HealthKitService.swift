import Combine
import Foundation
import HealthKit
import SwiftData

/// Snapshot of today's movement and sleep metrics read from HealthKit.
public struct HealthMetricsSnapshot: Sendable, Equatable {
    public let steps: Int
    public let activeEnergy: Double
    public let sleepHours: Double

    public init(steps: Int = 0, activeEnergy: Double = 0.0, sleepHours: Double = 0.0) {
        self.steps = steps
        self.activeEnergy = activeEnergy
        self.sleepHours = sleepHours
    }

    public func value(for metric: HealthMetricType) -> Double {
        switch metric {
        case .steps: Double(steps)
        case .activeEnergy: activeEnergy
        case .sleepHours: sleepHours
        }
    }
}

/// Centralized service for HealthKit synchronization and data management (movement + sleep reads only)
@MainActor
public class HealthKitService: ObservableObject {
    public static let shared = HealthKitService()
    private let healthStore = HKHealthStore()

    @Published public var isAuthorized = false
    @Published public var stepCount: Int = 0
    @Published public var activeEnergy: Double = 0.0
    @Published public var sleepHours: Double = 0.0
    @Published public var statusMessage: String?

    public var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    public var currentSnapshot: HealthMetricsSnapshot {
        HealthMetricsSnapshot(steps: stepCount, activeEnergy: activeEnergy, sleepHours: sleepHours)
    }

    private init() {
        checkAuthorizationStatus()
    }

    /// Request authorization to read health data (movement + sleep only; no writes)
    public func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            statusMessage = HealthKitError.healthDataNotAvailable.errorDescription
            throw HealthKitError.healthDataNotAvailable
        }

        var readTypes: Set<HKObjectType> = []
        if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            readTypes.insert(stepType)
        }
        if let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            readTypes.insert(energyType)
        }
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            readTypes.insert(sleepType)
        }

        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
        checkAuthorizationStatus()
    }

    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            isAuthorized = false
            return
        }

        guard
            let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
            let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        else {
            isAuthorized = false
            return
        }

        let stepStatus = healthStore.authorizationStatus(for: stepType)
        let energyStatus = healthStore.authorizationStatus(for: energyType)
        let sleepStatus = healthStore.authorizationStatus(for: sleepType)

        // Note: HealthKit hides read-only authorization status by design (.notDetermined or .sharingDenied)
        // when no write permission is requested, so we treat non-denied as ready to query safely.
        let anyAuthorized = stepStatus != .sharingDenied || energyStatus != .sharingDenied || sleepStatus != .sharingDenied
        Task { @MainActor in
            isAuthorized = anyAuthorized
            if isAuthorized {
                await fetchTodayStats()
            }
        }
    }

    /// Fetch today's health statistics from HealthKit (movement + sleep only)
    public func fetchTodayStats() async {
        guard HKHealthStore.isHealthDataAvailable(), isAuthorized else { return }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        do {
            if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
                let stepSamples = try await queryQuantitySamples(type: stepType, predicate: predicate)
                let totalSteps = stepSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.count()) }
                stepCount = Int(totalSteps)
            }

            if let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
                let energySamples = try await queryQuantitySamples(type: energyType, predicate: predicate)
                let totalEnergy = energySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
                activeEnergy = totalEnergy
            }

            if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
                let sleepSamples = try await querySleepSamples(type: sleepType, predicate: predicate)
                let totalSleepHours = sleepSamples.reduce(0.0) { $0 + ($1.endDate.timeIntervalSince($1.startDate) / 3600.0) }
                sleepHours = totalSleepHours
            }
            statusMessage = nil
        } catch {
            statusMessage = "Unable to read Apple Health data: \(error.localizedDescription)"
        }
    }

    /// Automatically logs completion and awards XP for movement/sleep habits when thresholds are met.
    /// Degrades gracefully when HealthKit is unavailable or unauthorized (no crash, no fabricated data).
    @discardableResult
    public func autoFillHabits(
        _ habits: [Habit],
        in context: ModelContext,
        snapshot: HealthMetricsSnapshot? = nil,
        on date: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let metrics: HealthMetricsSnapshot
        if let snapshot {
            metrics = snapshot
        } else if isHealthDataAvailable && isAuthorized {
            metrics = currentSnapshot
        } else {
            return 0
        }

        let gamificationService = GamificationService()
        let profile = (try? context.fetch(FetchDescriptor<PlayerProfile>()))?.first
        var completedCount = 0

        for habit in habits where habit.isActive {
            guard gamificationService.isHabitDueToday(habit, on: date, calendar: calendar) else { continue }
            guard let metric = habit.healthMetric else { continue }
            guard !habit.isCompletedToday else { continue }

            let threshold = habit.targetValue ?? metric.defaultTarget
            let measuredValue = metrics.value(for: metric)
            guard measuredValue >= threshold else { continue }

            let log = HabitLog(
                habit: habit,
                completionDate: date,
                notes: "Auto-logged from Apple Health (\(metric.formatValue(measuredValue)))"
            )
            context.insert(log)
            if let profile {
                _ = gamificationService.processHabitCompletion(habit: habit, profile: profile)
            }
            completedCount += 1
        }

        if completedCount > 0 {
            try? context.save()
        }
        return completedCount
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
