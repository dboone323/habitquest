//
// LocationReminders.swift
// HabitQuest
//
// Step 38: Location-based habit reminders.
//

import Combine
import CoreLocation
import Foundation
import UserNotifications

/// Location-based reminder configuration.
public struct LocationReminder: Codable, Identifiable {
    public var id: UUID
    public var habitId: UUID
    public var habitName: String
    public var latitude: Double
    public var longitude: Double
    public var radius: Double // meters
    public var locationName: String
    public var triggerOnEntry: Bool
    public var triggerOnExit: Bool
    public var isEnabled: Bool

    public init(
        id: UUID = UUID(),
        habitId: UUID,
        habitName: String,
        latitude: Double,
        longitude: Double,
        radius: Double = 100,
        locationName: String,
        triggerOnEntry: Bool = true,
        triggerOnExit: Bool = false,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.habitId = habitId
        self.habitName = habitName
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.locationName = locationName
        self.triggerOnEntry = triggerOnEntry
        self.triggerOnExit = triggerOnExit
        self.isEnabled = isEnabled
    }

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public var region: CLCircularRegion {
        let region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: id.uuidString
        )
        region.notifyOnEntry = triggerOnEntry
        region.notifyOnExit = triggerOnExit
        return region
    }
}

/// Manager for location-based habit reminders.
public final class LocationReminderManager: NSObject, ObservableObject {
    public static let shared = LocationReminderManager()

    @Published public var reminders: [LocationReminder] = []
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var monitoringEnabled = false

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()

    private let userDefaults = UserDefaults.standard
    private let remindersKey = "locationReminders"

    override private init() {
        super.init()
        loadReminders()
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Authorization

    public func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - Reminder Management

    public func addReminder(_ reminder: LocationReminder) {
        reminders.append(reminder)
        saveReminders()

        if reminder.isEnabled {
            startMonitoring(reminder)
        }
    }

    public func updateReminder(_ reminder: LocationReminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            let oldReminder = reminders[index]
            stopMonitoring(oldReminder)

            reminders[index] = reminder
            saveReminders()

            if reminder.isEnabled {
                startMonitoring(reminder)
            }
        }
    }

    public func removeReminder(id: UUID) {
        if let reminder = reminders.first(where: { $0.id == id }) {
            stopMonitoring(reminder)
        }
        reminders.removeAll { $0.id == id }
        saveReminders()
    }

    // MARK: - Region Monitoring

    private func startMonitoring(_ reminder: LocationReminder) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("[LocationReminder] Region monitoring not available")
            return
        }

        locationManager.startMonitoring(for: reminder.region)
        print("[LocationReminder] Started monitoring: \(reminder.locationName)")
    }

    private func stopMonitoring(_ reminder: LocationReminder) {
        locationManager.stopMonitoring(for: reminder.region)
        print("[LocationReminder] Stopped monitoring: \(reminder.locationName)")
    }

    public func startAllMonitoring() {
        for reminder in reminders where reminder.isEnabled {
            startMonitoring(reminder)
        }
        monitoringEnabled = true
    }

    public func stopAllMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        monitoringEnabled = false
    }

    // MARK: - Notifications

    private func sendNotification(for reminder: LocationReminder, isEntry: Bool) {
        let content = UNMutableNotificationContent()
        content.title =
            isEntry ? "Time for \(reminder.habitName)!" : "Leaving \(reminder.locationName)"
        content.body =
            isEntry
            ? "You've arrived at \(reminder.locationName). Don't forget your habit!"
            : "Did you complete \(reminder.habitName) before leaving?"
        content.sound = .default
        content.categoryIdentifier = "HABIT_LOCATION"
        content.userInfo = ["habitId": reminder.habitId.uuidString]

        let request = UNNotificationRequest(
            identifier: "location_\(reminder.id.uuidString)_\(isEntry ? "entry" : "exit")",
            content: content,
            trigger: nil // Immediate
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[LocationReminder] Notification error: \(error)")
            }
        }
    }

    // MARK: - Persistence

    private func saveReminders() {
        if let data = try? JSONEncoder().encode(reminders) {
            userDefaults.set(data, forKey: remindersKey)
        }
    }

    private func loadReminders() {
        if let data = userDefaults.data(forKey: remindersKey),
           let loaded = try? JSONDecoder().decode([LocationReminder].self, from: data) {
            reminders = loaded
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationReminderManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if authorizationStatus == .authorizedAlways {
            startAllMonitoring()
        }
    }

    public func locationManager(_: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let reminder = reminders.first(where: { $0.id.uuidString == region.identifier })
        else { return }
        print("[LocationReminder] Entered: \(reminder.locationName)")
        sendNotification(for: reminder, isEntry: true)
    }

    public func locationManager(_: CLLocationManager, didExitRegion region: CLRegion) {
        guard let reminder = reminders.first(where: { $0.id.uuidString == region.identifier })
        else { return }
        print("[LocationReminder] Exited: \(reminder.locationName)")
        sendNotification(for: reminder, isEntry: false)
    }

    public func locationManager(
        _: CLLocationManager, monitoringDidFailFor _: CLRegion?, withError error: Error
    ) {
        print("[LocationReminder] Monitoring failed: \(error.localizedDescription)")
    }
}
