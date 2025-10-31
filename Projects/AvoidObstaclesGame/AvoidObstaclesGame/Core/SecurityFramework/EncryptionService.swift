//
// EncryptionService.swift
// AvoidObstaclesGame
//
// AES-256-GCM encryption service for game data protection using CryptoKit.
// Handles encryption/decryption of sensitive game data with Keychain integration.
//

import CryptoKit
import Foundation
import Security

/// AES-256-GCM encryption service for game data
public class EncryptionService: @unchecked Sendable {
    // MARK: - Properties

    /// Shared instance
    public static let shared = EncryptionService()

    /// Thread-safe lock for encryption operations
    private let encryptionLock = NSLock()

    /// Cached encryption key
    private var cachedKey: SymmetricKey?

    /// Keychain service identifier
    private let keychainService = "com.avoidobstacles.game.encryption"

    /// Keychain account identifier
    private let keychainAccount = "game_encryption_key"

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Interface

    /// Encrypts data using AES-256-GCM
    /// - Parameter data: The data to encrypt
    /// - Returns: Encrypted data
    /// - Throws: EncryptionError if encryption fails
    public func encrypt(data: Data) throws -> Data {
        encryptionLock.lock()
        defer { encryptionLock.unlock() }

        let key = try getOrCreateKey()

        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            let combined = sealedBox.combined
            return combined ?? Data()
        } catch {
            throw EncryptionError.encryptionFailed(error.localizedDescription)
        }
    }

    /// Decrypts data using AES-256-GCM
    /// - Parameter data: The encrypted data to decrypt
    /// - Returns: Decrypted data
    /// - Throws: EncryptionError if decryption fails
    public func decrypt(data: Data) throws -> Data {
        encryptionLock.lock()
        defer { encryptionLock.unlock() }

        let key = try getOrCreateKey()

        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return decryptedData
        } catch {
            throw EncryptionError.decryptionFailed(error.localizedDescription)
        }
    }

    /// Encrypts a string using AES-256-GCM
    /// - Parameter string: The string to encrypt
    /// - Returns: Base64-encoded encrypted string
    /// - Throws: EncryptionError if encryption fails
    public func encrypt(string: String) throws -> String {
        let data = Data(string.utf8)
        let encryptedData = try encrypt(data: data)
        return encryptedData.base64EncodedString()
    }

    /// Decrypts a Base64-encoded encrypted string
    /// - Parameter encryptedString: The encrypted string to decrypt
    /// - Returns: Decrypted string
    /// - Throws: EncryptionError if decryption fails
    public func decrypt(string: String) throws -> String {
        guard let encryptedData = Data(base64Encoded: string) else {
            throw EncryptionError.invalidData("Invalid base64 string")
        }

        let decryptedData = try decrypt(data: encryptedData)
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.invalidData("Invalid UTF-8 data")
        }

        return decryptedString
    }

    /// Rotates the encryption key for security
    /// - Throws: EncryptionError if key rotation fails
    public func rotateKey() throws {
        encryptionLock.lock()
        defer { encryptionLock.unlock() }

        // Generate new key
        let newKey = SymmetricKey(size: .bits256)

        // Store new key in Keychain
        try storeKeyInKeychain(newKey)

        // Clear cached key to force reload
        cachedKey = nil

        // Log key rotation
        AuditLogger.shared.logSecurityEvent(.encryptionKeyRotated, details: [
            "reason": "security_rotation",
            "keySize": "256_bits",
        ])
    }

    // MARK: - Private Methods

    private func getOrCreateKey() throws -> SymmetricKey {
        if let cachedKey {
            return cachedKey
        }

        // Try to load from Keychain
        if let keyData = try loadKeyFromKeychain() {
            let key = SymmetricKey(data: keyData)
            cachedKey = key
            return key
        }

        // Create new key if none exists
        let newKey = SymmetricKey(size: .bits256)
        try storeKeyInKeychain(newKey)
        cachedKey = newKey

        AuditLogger.shared.logSecurityEvent(.encryptionKeyRotated, details: [
            "reason": "initial_creation",
            "keySize": "256_bits",
        ])

        return newKey
    }

    private func storeKeyInKeychain(_ key: SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        // Delete existing key if it exists
        SecItemDelete(query as CFDictionary)

        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw EncryptionError.keychainError("Failed to store key: \(status)")
        }
    }

    private func loadKeyFromKeychain() throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw EncryptionError.keychainError("Failed to load key: \(status)")
        }

        return result as? Data
    }
}

// MARK: - Supporting Types

/// Encryption-related errors
public enum EncryptionError: Error {
    case encryptionFailed(String)
    case decryptionFailed(String)
    case invalidData(String)
    case keychainError(String)

    public var localizedDescription: String {
        switch self {
        case let .encryptionFailed(reason):
            return "Encryption failed: \(reason)"
        case let .decryptionFailed(reason):
            return "Decryption failed: \(reason)"
        case let .invalidData(reason):
            return "Invalid data: \(reason)"
        case let .keychainError(reason):
            return "Keychain error: \(reason)"
        }
    }
}
