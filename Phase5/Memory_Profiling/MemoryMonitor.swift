//
//  MemoryMonitor.swift
//  Memory Profiling System
//
//  This file implements the memory monitoring component that provides real-time
//  memory usage tracking and snapshot capabilities.
//

import Combine
import Foundation

/// Memory monitoring engine with real-time tracking
@available(macOS 12.0, *)
public class MemoryMonitor {

    // MARK: - Properties

    private let monitoringInterval: TimeInterval
    private var timer: Timer?
    private var snapshots: [MemorySnapshot] = []
    private let maxSnapshots: Int

    private let memoryUsageSubject = PassthroughSubject<MemorySnapshot, Never>()
    public var memoryUsagePublisher: AnyPublisher<MemorySnapshot, Never> {
        memoryUsageSubject.eraseToAnyPublisher()
    }

    private var isMonitoring = false

    // MARK: - Initialization

    public init(interval: TimeInterval = 0.1, maxSnapshots: Int = 1000) {
        self.monitoringInterval = interval
        self.maxSnapshots = maxSnapshots
    }

    // MARK: - Public API

    /// Start memory monitoring
    public func startMonitoring() throws {
        guard !isMonitoring else { return }

        // Verify we can access memory information
        guard canAccessMemoryInfo() else {
            throw MemoryMonitorError.accessDenied
        }

        isMonitoring = true

        // Start timer for periodic monitoring
        timer = Timer.scheduledTimer(withTimeInterval: monitoringInterval, repeats: true) {
            [weak self] _ in
            self?.captureSnapshot()
        }

        // Take initial snapshot
        captureSnapshot()
    }

    /// Stop memory monitoring
    public func stopMonitoring() {
        guard isMonitoring else { return }

        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }

    /// Take a manual memory snapshot
    public func takeSnapshot() -> MemorySnapshot {
        captureSnapshot()
    }

    /// Get all stored snapshots
    public func getSnapshots() -> [MemorySnapshot] {
        snapshots
    }

    /// Clear all stored snapshots
    public func clearSnapshots() {
        snapshots.removeAll()
    }

    /// Get memory usage trend over time
    public func getMemoryTrend() -> MemoryTrend {
        guard snapshots.count >= 2 else { return .insufficientData }

        let recentSnapshots = snapshots.suffix(10) // Last 10 snapshots
        let usages = recentSnapshots.map { Double($0.usedMemory) }

        let first = usages.first!
        let last = usages.last!

        let change = last - first
        let changePercent = abs(change / first)

        if changePercent < 0.05 {
            return .stable
        } else if change > 0 {
            return changePercent > 0.2 ? .rapidlyIncreasing : .graduallyIncreasing
        } else {
            return changePercent > 0.2 ? .rapidlyDecreasing : .graduallyDecreasing
        }
    }

    // MARK: - Private Methods

    private func captureSnapshot() {
        let snapshot = createMemorySnapshot()
        snapshots.append(snapshot)

        // Maintain max snapshots limit
        if snapshots.count > maxSnapshots {
            snapshots.removeFirst()
        }

        // Publish to subscribers
        memoryUsageSubject.send(snapshot)
    }

    private func createMemorySnapshot() -> MemorySnapshot {
        let processInfo = ProcessInfo.processInfo

        // Get system memory information
        let systemMemory = getSystemMemoryInfo()

        // Get process memory information
        let processMemory = getProcessMemoryInfo()

        return MemorySnapshot(
            timestamp: Date(),
            totalMemory: systemMemory.total,
            usedMemory: systemMemory.used,
            freeMemory: systemMemory.free,
            residentSize: processMemory.residentSize,
            virtualSize: processMemory.virtualSize,
            pageIns: processMemory.pageIns,
            pageOuts: processMemory.pageOuts,
            pageFaults: processMemory.pageFaults
        )
    }

    private func getSystemMemoryInfo() -> (total: UInt64, used: UInt64, free: UInt64) {
        var stats = vm_statistics64()
        var size = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

        let hostPort = mach_host_self()
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &size)
            }
        }

        guard result == KERN_SUCCESS else {
            return (0, 0, 0)
        }

        let pageSize = UInt64(vm_kernel_page_size)
        let total =
            UInt64(
                stats.free_count + stats.active_count + stats.inactive_count + stats.wire_count
                    + stats.compressor_page_count) * pageSize
        let free = UInt64(stats.free_count) * pageSize
        let used = total - free

        return (total, used, free)
    }

    private func getProcessMemoryInfo() -> (
        residentSize: UInt64, virtualSize: UInt64, pageIns: UInt64, pageOuts: UInt64,
        pageFaults: UInt64
    ) {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<task_vm_info>.size / MemoryLayout<natural_t>.size)

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return (0, 0, 0, 0, 0)
        }

        return (
            residentSize: UInt64(info.resident_size),
            virtualSize: UInt64(info.virtual_size),
            pageIns: UInt64(info.pageins),
            pageOuts: UInt64(info.pageouts),
            pageFaults: UInt64(info.faults)
        )
    }

    private func canAccessMemoryInfo() -> Bool {
        // Check if we can access basic memory information
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<task_vm_info>.size / MemoryLayout<natural_t>.size)

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }

        return result == KERN_SUCCESS
    }
}

// MARK: - Supporting Types

/// Memory usage trend
public enum MemoryTrend {
    case insufficientData
    case stable
    case graduallyIncreasing
    case rapidlyIncreasing
    case graduallyDecreasing
    case rapidlyDecreasing
}

/// Memory monitor error
public enum MemoryMonitorError: Error {
    case accessDenied
    case monitoringFailed
    case invalidConfiguration
}

// MARK: - Mach Kernel Interfaces

// These are low-level macOS system calls for memory information
// They require proper imports and error handling in production code

private let HOST_VM_INFO64 = host_flavor_t(HOST_VM_INFO64)
private let TASK_VM_INFO = task_flavor_t(TASK_VM_INFO)

// Mach kernel functions (simplified for this implementation)
// In a real implementation, these would be properly imported from system frameworks
