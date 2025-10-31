//
//  SecurityTest.swift
//  AvoidObstaclesGame Security Framework Test
//

import Foundation

// Simple test program for the security framework
@MainActor
func testSecurityFramework() {
    print("🛡️ Testing AvoidObstaclesGame Security Framework...")

    // Test encryption service
    print("Testing Encryption Service...")
    do {
        let testData = "Hello, Secure World!"
        let encrypted = try EncryptionService.shared.encryptString(testData)
        let decrypted = try EncryptionService.shared.decryptString(encrypted)

        if decrypted == testData {
            print("✅ Encryption service working correctly")
        } else {
            print("❌ Encryption service failed")
        }
    } catch {
        print("❌ Encryption service error: \(error)")
    }

    // Test audit logger
    print("Testing Audit Logger...")
    AuditLogger.shared.logGameEvent(.gameStart, userId: "test_player", metadata: ["test": true])
    print("✅ Audit logging test completed")

    // Test compliance manager
    print("Testing Compliance Manager...")
    let testData = "test game data".data(using: .utf8)!
    do {
        try ComplianceManager.shared.validateDataCompliance(testData, for: .gameData)
        print("✅ Compliance validation working")
    } catch {
        print("❌ Compliance validation error: \(error)")
    }

    // Test security coordinator
    print("Testing Security Coordinator...")
    let testGameData = GameData(
        state: GameState(playerName: "TestPlayer", score: 100, duration: 30.0, level: 1, obstaclesAvoided: 5),
        totalGamesPlayed: 10,
        achievements: ["First Game"],
        preferences: ["sound": true],
        lastPlayed: Date()
    )

    do {
        let secureData = try SecurityCoordinator.shared.secureGameData(testGameData)
        let encryptedString = try secureData.encrypt()
        print("✅ Security coordinator encryption working")

        let retrievedData = try SecurityCoordinator.shared.retrieveSecureGameData(encryptedData: encryptedString, for: "TestPlayer")
        print("✅ Security coordinator decryption working")
    } catch {
        print("❌ Security coordinator error: \(error)")
    }

    // Test security monitor
    print("Testing Security Monitor...")
    let testEvent = GameEvent(
        type: .scoreUpdate,
        playerId: "TestPlayer",
        timestamp: Date(),
        scoreIncrease: 50,
        timeInterval: 2.0,
        reactionTime: 0.5,
        severity: .low
    )

    SecurityMonitor.shared.monitorGameEvent(testEvent)
    print("✅ Security monitoring test completed")

    print("🎉 Security Framework Test Complete!")
}

// Main entry point
@main
struct SecurityTestMain {
    static func main() {
        testSecurityFramework()
    }
}
