//
//  EncryptionService.swift
//  AvoidObstaclesGame
//
//  Security Framework: Data Encryption
//  Provides AES-256-GCM encryption for sensitive game data
//

import CryptoKit
import Foundation

// MARK: - Encryption Service

@MainActor
class EncryptionService {
    static let shared = EncryptionService()

    private let keychainKey = "com.quantumworkspace.avoidobstacles.encryptionKey"
    private let saltKey = "com.quantumworkspace.avoidobstacles.encryptionSalt"

    private var encryptionKey: SymmetricKey?
    private var salt: Data?

    private init() {
        setupEncryptionKey()
    }

    // MARK: - Public Methods

    func encryptData(_ data: Data) throws -> Data {
        guard let key = encryptionKey else {
            throw EncryptionError.keyNotAvailable
        }

        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)

        // Combine nonce and ciphertext for storage
        var combinedData = Data()
        nonce.withUnsafeBytes { combinedData.append(contentsOf: $0) }
        combinedData.append(sealedBox.ciphertext)
        combinedData.append(sealedBox.tag)

        return combinedData
    }

    func decryptData(_ encryptedData: Data) throws -> Data {
        guard let key = encryptionKey else {
            throw EncryptionError.keyNotAvailable
        }

        guard encryptedData.count >= 28 else { // 12 (nonce) + 16 (tag) minimum
            throw EncryptionError.invalidData
        }

        // Extract components
        let nonceData = encryptedData.prefix(12)
        let ciphertext = encryptedData.dropFirst(12).dropLast(16)
        let tag = encryptedData.suffix(16)

        let nonce = try AES.GCM.Nonce(data: nonceData)
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)

        return try AES.GCM.open(sealedBox, using: key)
    }

    func encryptString(_ string: String) throws -> String {
        let data = string.data(using: .utf8)!
        let encryptedData = try encryptData(data)
        return encryptedData.base64EncodedString()
    }

    func decryptString(_ encryptedString: String) throws -> String {
        guard let encryptedData = Data(base64Encoded: encryptedString) else {
            throw EncryptionError.invalidData
        }

        let decryptedData = try decryptData(encryptedData)
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.decryptionFailed
        }

        return decryptedString
    }

    func encryptGameData(_ gameData: [String: Any]) throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: gameData)
        return try encryptString(String(data: jsonData, encoding: .utf8)!)
    }

    func decryptGameData(_ encryptedGameData: String) throws -> [String: Any] {
        let decryptedString = try decryptString(encryptedGameData)
        guard let jsonData = decryptedString.data(using: .utf8),
              let gameData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            throw EncryptionError.decryptionFailed
        }
        return gameData
    }

    // MARK: - Key Management

    private func setupEncryptionKey() {
        // Try to load existing key from secure storage
        if let existingKeyData = loadKeyFromSecureStorage(),
           let existingSalt = loadSaltFromSecureStorage()
        {

            // Derive key from stored data
            encryptionKey = deriveKey(from: existingKeyData, salt: existingSalt)
            salt = existingSalt

        } else {
            // Generate new key
            generateNewEncryptionKey()
        }
    }

    private func generateNewEncryptionKey() {
        // Generate random salt
        salt = Data((0 ..< 32).map { _ in UInt8.random(in: 0 ... 255) })

        // Generate random key data
        let keyData = Data((0 ..< 32).map { _ in UInt8.random(in: 0 ... 255) })

        // Derive encryption key
        encryptionKey = deriveKey(from: keyData, salt: salt!)

        // Store securely
        saveKeyToSecureStorage(keyData)
        saveSaltToSecureStorage(salt!)
    }

    private func deriveKey(from keyData: Data, salt: Data) -> SymmetricKey {
        // Use PBKDF2 for key derivation
        let iterations = 10000

        // Simple key derivation (in production, use proper PBKDF2)
        // For demo purposes, we'll use a basic approach
        // In production, use CryptoKit's proper key derivation when available

        var derivedKey = Data()
        derivedKey.append(keyData)
        derivedKey.append(salt)

        // Hash the combined data multiple times
        for _ in 0 ..< iterations / 1000 {
            derivedKey = Data(SHA256.hash(data: derivedKey))
        }

        // Take first 32 bytes for AES-256
        let keyBytes = derivedKey.prefix(32)
        return SymmetricKey(data: keyBytes)
    }

    // MARK: - Secure Storage (Simplified for Demo)

    private func loadKeyFromSecureStorage() -> Data? {
        // In production, use Keychain Services
        // For demo, use UserDefaults with obfuscation
        let defaults = UserDefaults.standard
        guard let encodedKey = defaults.string(forKey: keychainKey),
              let keyData = Data(base64Encoded: encodedKey)
        else {
            return nil
        }

        // Simple deobfuscation (XOR with fixed pattern)
        let obfuscationKey: [UInt8] = [0x5A, 0x3B, 0x8F, 0x2D, 0x7C, 0x1E, 0x9A, 0x4F]
        var deobfuscated = Data()

        for (index, byte) in keyData.enumerated() {
            let keyByte = obfuscationKey[index % obfuscationKey.count]
            deobfuscated.append(byte ^ keyByte)
        }

        return deobfuscated
    }

    private func saveKeyToSecureStorage(_ keyData: Data) {
        // Simple obfuscation (XOR with fixed pattern)
        let obfuscationKey: [UInt8] = [0x5A, 0x3B, 0x8F, 0x2D, 0x7C, 0x1E, 0x9A, 0x4F]
        var obfuscated = Data()

        for (index, byte) in keyData.enumerated() {
            let keyByte = obfuscationKey[index % obfuscationKey.count]
            obfuscated.append(byte ^ keyByte)
        }

        let encodedKey = obfuscated.base64EncodedString()
        UserDefaults.standard.set(encodedKey, forKey: keychainKey)
    }

    private func loadSaltFromSecureStorage() -> Data? {
        let defaults = UserDefaults.standard
        return defaults.data(forKey: saltKey)
    }

    private func saveSaltToSecureStorage(_ saltData: Data) {
        UserDefaults.standard.set(saltData, forKey: saltKey)
    }

    // MARK: - Utility Methods

    func hashData(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    func validateEncryption() -> Bool {
        do {
            let testString = "encryption_test_data"
            let encrypted = try encryptString(testString)
            let decrypted = try decryptString(encrypted)
            return decrypted == testString
        } catch {
            return false
        }
    }

    func rotateEncryptionKey() {
        // Generate new key and re-encrypt existing data
        // This would require coordination with data storage layer
        generateNewEncryptionKey()

        // Log key rotation
        AuditLogger.shared.logSecurityAlert("Encryption key rotated",
                                            severity: .info,
                                            metadata: ["operation": "key_rotation"])
    }
}

// MARK: - Encryption Errors

enum EncryptionError: Error {
    case keyNotAvailable
    case invalidData
    case decryptionFailed
    case encryptionFailed

    var localizedDescription: String {
        switch self {
        case .keyNotAvailable:
            return "Encryption key is not available"
        case .invalidData:
            return "Invalid encrypted data format"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .encryptionFailed:
            return "Failed to encrypt data"
        }
    }
}

// MARK: - Secure Data Container

struct SecureGameData {
    let highScore: Int
    let totalGamesPlayed: Int
    let achievements: [String]
    let preferences: [String: Any]

    @MainActor
    func encrypt() throws -> String {
        let data: [String: Any] = [
            "high_score": highScore,
            "total_games": totalGamesPlayed,
            "achievements": achievements,
            "preferences": preferences,
            "timestamp": Date().timeIntervalSince1970,
        ]

        return try EncryptionService.shared.encryptGameData(data)
    }

    @MainActor
    static func decrypt(from encryptedData: String) throws -> SecureGameData {
        let data = try EncryptionService.shared.decryptGameData(encryptedData)

        guard let highScore = data["high_score"] as? Int,
              let totalGames = data["total_games"] as? Int,
              let achievements = data["achievements"] as? [String],
              let preferences = data["preferences"] as? [String: Any]
        else {
            throw EncryptionError.invalidData
        }

        return SecureGameData(
            highScore: highScore,
            totalGamesPlayed: totalGames,
            achievements: achievements,
            preferences: preferences
        )
    }
}
