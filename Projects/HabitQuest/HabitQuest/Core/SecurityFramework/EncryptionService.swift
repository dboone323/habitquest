//
//  EncryptionService.swift
//  HabitQuest
//
//  Created by Code Review Agent on 2025-10-30
//  Copyright © 2025 HabitQuest. All rights reserved.
//

import CryptoKit
import Foundation
import Security

/// Encryption service for securing sensitive habit tracking data
/// Uses AES-256-GCM encryption with secure key derivation
@MainActor
public final class EncryptionService: Sendable {
    public static let shared = EncryptionService()

    private let keychainService = "com.habitquest.encryption"
    private let keychainAccount = "encryption_key"
    private let keySize = SymmetricKeySize.bits256

    private init() {}

    // MARK: - Key Management

    /// Generate and store a new encryption key
    private func generateAndStoreKey() throws -> SymmetricKey {
        let key = SymmetricKey(size: keySize)

        // Convert key to data for storage
        let keyData = key.withUnsafeBytes { Data($0) }

        // Store in Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw EncryptionError.keychainError(status)
        }

        return key
    }

    /// Retrieve encryption key from Keychain
    private func retrieveKey() throws -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let keyData = result as? Data
        else {
            throw EncryptionError.keychainError(status)
        }

        return SymmetricKey(data: keyData)
    }

    /// Get or create encryption key
    private func getEncryptionKey() throws -> SymmetricKey {
        do {
            return try retrieveKey()
        } catch {
            return try generateAndStoreKey()
        }
    }

    // MARK: - Encryption Methods

    /// Encrypt data using AES-256-GCM
    public func encrypt(data: Data) async throws -> Data {
        let key = try getEncryptionKey()
        let nonce = AES.GCM.Nonce()

        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
        return sealedBox.combined ?? Data()
    }

    /// Decrypt data using AES-256-GCM
    public func decrypt(encryptedData: Data) async throws -> Data {
        let key = try getEncryptionKey()
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }

    /// Encrypt string data
    public func encrypt(string: String) async throws -> Data {
        guard let data = string.data(using: .utf8) else {
            throw EncryptionError.encodingError
        }
        return try await encrypt(data: data)
    }

    /// Decrypt to string
    public func decryptToString(encryptedData: Data) async throws -> String {
        let decryptedData = try await decrypt(encryptedData: encryptedData)
        guard let string = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.decodingError
        }
        return string
    }

    // MARK: - Secure Data Types

    /// Encrypt sensitive habit data
    public func encryptHabitData(name: String, description: String?, targetFrequency: String) async throws -> EncryptedHabitData {
        let data = HabitData(name: name, description: description, targetFrequency: targetFrequency)
        let jsonData = try JSONEncoder().encode(data)
        let encryptedData = try await encrypt(data: jsonData)

        return EncryptedHabitData(
            id: UUID(),
            encryptedData: encryptedData,
            createdAt: Date(),
            lastModified: Date()
        )
    }

    /// Decrypt habit data
    public func decryptHabitData(_ encryptedHabitData: EncryptedHabitData) async throws -> HabitData {
        let decryptedData = try await decrypt(encryptedData: encryptedHabitData.encryptedData)
        return try JSONDecoder().decode(HabitData.self, from: decryptedData)
    }

    /// Encrypt health metrics data
    public func encryptHealthMetrics(completionRate: Double, streakCount: Int, totalCompletions: Int) async throws -> Data {
        let metrics = HealthMetrics(
            completionRate: completionRate,
            streakCount: streakCount,
            totalCompletions: totalCompletions,
            recordedAt: Date()
        )
        let jsonData = try JSONEncoder().encode(metrics)
        return try await encrypt(data: jsonData)
    }

    /// Decrypt health metrics
    public func decryptHealthMetrics(_ encryptedData: Data) async throws -> HealthMetrics {
        let decryptedData = try await decrypt(encryptedData: encryptedData)
        return try JSONDecoder().decode(HealthMetrics.self, from: decryptedData)
    }

    // MARK: - Key Rotation

    /// Rotate encryption key (for security maintenance)
    public func rotateEncryptionKey() async throws {
        // Generate new key
        let newKey = SymmetricKey(size: keySize)
        let newKeyData = newKey.withUnsafeBytes { Data($0) }

        // Update Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
        ]

        let updateQuery: [String: Any] = [
            kSecValueData as String: newKeyData,
        ]

        let status = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
        guard status == errSecSuccess else {
            throw EncryptionError.keychainError(status)
        }
    }

    // MARK: - Security Validation

    /// Validate encryption functionality
    public func validateEncryption() async throws -> Bool {
        let testString = "HabitQuest encryption test"
        let encrypted = try await encrypt(string: testString)
        let decrypted = try await decryptToString(encryptedData: encrypted)
        return decrypted == testString
    }
}

// MARK: - Data Structures

/// Plain text habit data for encryption
public struct HabitData: Codable, Sendable {
    public let name: String
    public let description: String?
    public let targetFrequency: String

    public init(name: String, description: String?, targetFrequency: String) {
        self.name = name
        self.description = description
        self.targetFrequency = targetFrequency
    }
}

/// Encrypted habit data storage
public struct EncryptedHabitData: Codable, Sendable {
    public let id: UUID
    public let encryptedData: Data
    public let createdAt: Date
    public let lastModified: Date

    public init(id: UUID, encryptedData: Data, createdAt: Date, lastModified: Date) {
        self.id = id
        self.encryptedData = encryptedData
        self.createdAt = createdAt
        self.lastModified = lastModified
    }
}

/// Health metrics data structure
public struct HealthMetrics: Codable, Sendable {
    public let completionRate: Double
    public let streakCount: Int
    public let totalCompletions: Int
    public let recordedAt: Date

    public init(completionRate: Double, streakCount: Int, totalCompletions: Int, recordedAt: Date) {
        self.completionRate = completionRate
        self.streakCount = streakCount
        self.totalCompletions = totalCompletions
        self.recordedAt = recordedAt
    }
}

// MARK: - Error Types

public enum EncryptionError: LocalizedError {
    case keychainError(OSStatus)
    case encryptionFailed
    case decryptionFailed
    case encodingError
    case decodingError
    case keyNotFound

    public var errorDescription: String? {
        switch self {
        case let .keychainError(status):
            return "Keychain error: \(status)"
        case .encryptionFailed:
            return "Encryption operation failed"
        case .decryptionFailed:
            return "Decryption operation failed"
        case .encodingError:
            return "Failed to encode data"
        case .decodingError:
            return "Failed to decode data"
        case .keyNotFound:
            return "Encryption key not found"
        }
    }
}
