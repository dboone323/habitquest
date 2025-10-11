//
//  CloudKitZoneExtensions.swift
//  PlannerApp
//
//  CloudKit zone management extensions
//

import CloudKit

// MARK: - CloudKit Zones Extensions

extension CloudKitManager {
    /// Create a custom zone for more efficient organization
    func createCustomZone() async throws {
        let customZone = CKRecordZone(zoneName: "PlannerAppData")
        try await database.save(customZone)
        print("Custom zone created: PlannerAppData")
    }

    /// Fetch record zones
    func fetchZones() async throws -> [CKRecordZone] {
        let zones = try await database.allRecordZones()
        return zones
    }

    /// Delete a zone and all its records
    func deleteZone(named zoneName: String) async throws {
        let zoneID = CKRecordZone.ID(zoneName: zoneName)
        try await self.database.deleteRecordZone(withID: zoneID)
        print("Zone deleted: \(zoneName)")
    }
}
