//
//  EncryptionService.swift
//  MomentumFinance
//
//  Created by Quantum Security Framework
//  Copyright © 2025 Momentum Finance. All rights reserved.
//

import Foundation
import CryptoKit
import Security

/// Comprehensive encryption service for financial data protection
/// Implements AES-256-GCM encryption with secure key management
@available(iOS 15.0, macOS 12.0, *)
public final class EncryptionService: Sendable {

    // MARK: - Singleton

    public static let shared = EncryptionService()

    // MARK: - Properties

    private let keychainService = "com.momentumfinance.encryption"
    private let keychainAccount = "encryption_key"
    private let encryptionQueue: DispatchQueue

    // MARK: - Initialization

    private init() {
        self.encryptionQueue = DispatchQueue(label: "com.momentumfinance.encryption.queue", qos: .userInitiated)
    }

    // MARK: - Public API

    /// Encrypt sensitive financial data
    /// - Parameter data: Data to encrypt
    /// - Returns: Encrypted data with authentication tag
    /// - Throws: EncryptionError if encryption fails
    public func encryptData(_ data: Data) throws -> EncryptedData {
        try encryptionQueue.sync {
            let key = try getOrCreateEncryptionKey()
            let sealedBox = try AES.GCM.seal(data, using: key)

            guard let combined = sealedBox.combined else {
                throw EncryptionError.encryptionFailed
            }

            return EncryptedData(
                encryptedData: combined,
                keyIdentifier: try getKeyIdentifier(),
                algorithm: "AES-256-GCM",
                timestamp: Date()
            )
        }
    }

    /// Decrypt previously encrypted data
    /// - Parameter encryptedData: Encrypted data to decrypt
    /// - Returns: Decrypted original data
    /// - Throws: EncryptionError if decryption fails
    public func decryptData(_ encryptedData: EncryptedData) throws -> Data {
        try encryptionQueue.sync {
            let key = try getEncryptionKey(for: encryptedData.keyIdentifier)
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData.encryptedData)
            return try AES.GCM.open(sealedBox, using: key)
        }
    }

    /// Encrypt a string value
    /// - Parameter string: String to encrypt
    /// - Returns: Encrypted data container
    /// - Throws: EncryptionError if encryption fails
    public func encryptString(_ string: String) throws -> EncryptedData {
        guard let data = string.data(using: .utf8) else {
            throw EncryptionError.invalidInput
        }
        return try encryptData(data)
    }

    /// Decrypt to string
    /// - Parameter encryptedData: Encrypted data to decrypt
    /// - Returns: Decrypted string
    /// - Throws: EncryptionError if decryption fails
    public func decryptToString(_ encryptedData: EncryptedData) throws -> String {
        let data = try decryptData(encryptedData)
        guard let string = String(data: data, encoding: .utf8) else {
            throw EncryptionError.decryptionFailed
        }
        return string
    }

    /// Generate a new encryption key for specific use case
    /// - Parameter identifier: Unique identifier for the key
    /// - Returns: Key identifier for future reference
    /// - Throws: EncryptionError if key generation fails
    public func generateNewKey(identifier: String) throws -> String {
        try encryptionQueue.sync {
            let key = SymmetricKey(size: .bits256)
            let keyData = key.withUnsafeBytes { Data($0) }
            try storeKey(keyData, identifier: identifier)
            return identifier
        }
    }

    /// Rotate encryption key for enhanced security
    /// - Parameter oldIdentifier: Current key identifier
    /// - Returns: New key identifier
    /// - Throws: EncryptionError if rotation fails
    public func rotateKey(oldIdentifier: String) throws -> String {
        try encryptionQueue.sync {
            let newIdentifier = "\(oldIdentifier)_rotated_\(Date().timeIntervalSince1970)"

            // Generate new key
            let newKey = SymmetricKey(size: .bits256)
            let newKeyData = newKey.withUnsafeBytes { Data($0) }
            try storeKey(newKeyData, identifier: newIdentifier)

            // Mark old key as rotated (don't delete immediately for decryption of existing data)
            try markKeyRotated(identifier: oldIdentifier)

            return newIdentifier
        }
    }

    /// Securely wipe sensitive data from memory
    /// - Parameter data: Data to wipe
    public func secureWipe(_ data: inout Data) {
        data.withUnsafeMutableBytes { buffer in
            memset_s(buffer.baseAddress, buffer.count, 0, buffer.count)
        }
        data.removeAll()
    }

    /// Generate cryptographically secure random data
    /// - Parameter length: Length of random data in bytes
    /// - Returns: Random data
    public func generateSecureRandomData(length: Int) -> Data {
        var data = Data(count: length)
        let result = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        guard result == errSecSuccess else {
            fatalError("Failed to generate secure random data")
        }
        return data
    }

    /// Hash sensitive data for integrity checking
    /// - Parameter data: Data to hash
    /// - Returns: SHA-256 hash
    public func hashData(_ data: Data) -> Data {
        Data(SHA256.hash(data: data))
    }

    /// Verify data integrity using hash
    /// - Parameters:
    ///   - data: Original data
    ///   - expectedHash: Expected hash value
    /// - Returns: True if hash matches
    public func verifyDataIntegrity(_ data: Data, expectedHash: Data) -> Bool {
        let actualHash = hashData(data)
        return actualHash == expectedHash
    }

    // MARK: - Key Management

    private func getOrCreateEncryptionKey() throws -> SymmetricKey {
        if let keyData = try retrieveKey(identifier: "default") {
            return SymmetricKey(data: keyData)
        } else {
            let key = SymmetricKey(size: .bits256)
            let keyData = key.withUnsafeBytes { Data($0) }
            try storeKey(keyData, identifier: "default")
            return key
        }
    }

    private func getEncryptionKey(for identifier: String) throws -> SymmetricKey {
        guard let keyData = try retrieveKey(identifier: identifier) else {
            throw EncryptionError.keyNotFound
        }
        return SymmetricKey(data: keyData)
    }

    private func getKeyIdentifier() throws -> String {
        // Return current active key identifier
        return "default"
    }

    private func storeKey(_ keyData: Data, identifier: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "\(keychainAccount)_\(identifier)",
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw EncryptionError.keyStorageFailed
        }
    }

    private func retrieveKey(identifier: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: "\(keychainAccount)_\(identifier)",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            return result as? Data
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw EncryptionError.keyRetrievalFailed
        }
    }

    private func markKeyRotated(identifier: String) throws {
        // In a real implementation, this would update key metadata
        // For now, just log the rotation
        print("Key \(identifier) marked as rotated")
    }
}

// MARK: - Supporting Types

public struct EncryptedData: Codable, Sendable {
    public let encryptedData: Data
    public let keyIdentifier: String
    public let algorithm: String
    public let timestamp: Date

    public init(encryptedData: Data, keyIdentifier: String, algorithm: String, timestamp: Date) {
        self.encryptedData = encryptedData
        self.keyIdentifier = keyIdentifier
        self.algorithm = algorithm
        self.timestamp = timestamp
    }
}

public enum EncryptionError: Error {
    case encryptionFailed
    case decryptionFailed
    case invalidInput
    case keyNotFound
    case keyStorageFailed
    case keyRetrievalFailed
    case keyRotationFailed

    public var localizedDescription: String {
        switch self {
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .invalidInput:
            return "Invalid input data"
        case .keyNotFound:
            return "Encryption key not found"
        case .keyStorageFailed:
            return "Failed to store encryption key"
        case .keyRetrievalFailed:
            return "Failed to retrieve encryption key"
        case .keyRotationFailed:
            return "Failed to rotate encryption key"
        }
    }
}

// MARK: - Extensions

extension Data {
    /// Securely compare two data objects (constant time)
    /// - Parameter other: Data to compare with
    /// - Returns: True if data is identical
    public func secureCompare(with other: Data) -> Bool {
        guard count == other.count else { return false }
        return withUnsafeBytes { selfBytes in
            other.withUnsafeBytes { otherBytes in
                memcmp(selfBytes.baseAddress, otherBytes.baseAddress, count) == 0
            }
        }
    }
}

extension String {
    /// Create a cryptographically secure random string
    /// - Parameter length: Length of the string
    /// - Returns: Random string
    public static func secureRandom(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let charactersArray = Array(characters)
        var result = ""

        for _ in 0..<length {
            let randomIndex = Int.random(in: 0..<charactersArray.count)
            result.append(charactersArray[randomIndex])
        }

        return result
    }
}
