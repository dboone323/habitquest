//
//  EncryptionService.swift
//  PlannerApp
//
//  Secure encryption service for sensitive planner data using AES-256-GCM
//  with Keychain Services integration for CloudKit sync security
//

import CryptoKit
import Foundation
import OSLog
import Security

public final class EncryptionService: @unchecked Sendable {
    // MARK: - Singleton

    public static let shared = EncryptionService()

    // MARK: - Properties

    private let logger: OSLog
    private let keychainService = "com.plannerapp.encryption"
    private let keychainAccount = "encryption_key"
    private var cachedKey: SymmetricKey?
    private let keyLock = NSLock()

    // MARK: - Initialization

    private init() {
        self.logger = OSLog(subsystem: "com.plannerapp", category: "EncryptionService")
        setupEncryptionKey()
    }

    // MARK: - Public Methods

    /// Encrypt data using AES-256-GCM
    public func encrypt(data: Data) throws -> Data {
        let key = try getEncryptionKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined ?? Data()
    }

    /// Decrypt data using AES-256-GCM
    public func decrypt(data: Data) throws -> Data {
        let key = try getEncryptionKey()
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    /// Encrypt string data
    public func encrypt(string: String) throws -> Data {
        guard let data = string.data(using: .utf8) else {
            throw EncryptionError.invalidData
        }
        return try encrypt(data: data)
    }

    /// Decrypt to string
    public func decryptToString(data: Data) throws -> String {
        let decryptedData = try decrypt(data: data)
        guard let string = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.invalidData
        }
        return string
    }

    /// Generate and store new encryption key
    public func rotateEncryptionKey() throws {
        let newKey = SymmetricKey(size: .bits256)
        try storeKeyInKeychain(newKey)

        keyLock.lock()
        cachedKey = newKey
        keyLock.unlock()

        os_log("Encryption key rotated successfully", log: logger, type: .info)
    }

    /// Validate encryption service health
    public func validateEncryption() -> Bool {
        do {
            let testData = "encryption_test".data(using: .utf8)!
            let encrypted = try encrypt(data: testData)
            let decrypted = try decrypt(data: encrypted)
            return decrypted == testData
        } catch {
            os_log("Encryption validation failed: %{public}@", log: logger, type: .error, error.localizedDescription)
            return false
        }
    }

    /// Encrypt sensitive CloudKit record fields
    public func encryptRecordFields(_ fields: [String: Any]) throws -> [String: Any] {
        var encryptedFields = fields

        // Define sensitive field patterns
        let sensitivePatterns = [
            "title", "description", "notes", "content",
            "personal", "private", "confidential",
        ]

        for (key, value) in fields {
            let keyLower = key.lowercased()
            let isSensitive = sensitivePatterns.contains { keyLower.contains($0) }

            if isSensitive, let stringValue = value as? String {
                do {
                    let encryptedData = try encrypt(string: stringValue)
                    encryptedFields[key] = encryptedData.base64EncodedString()
                    encryptedFields["\(key)_encrypted"] = true
                } catch {
                    os_log("Failed to encrypt field '%{public}@': %{public}@", log: logger, type: .error, key, error.localizedDescription)
                }
            }
        }

        return encryptedFields
    }

    /// Decrypt sensitive CloudKit record fields
    public func decryptRecordFields(_ fields: [String: Any]) throws -> [String: Any] {
        var decryptedFields = fields

        for (key, value) in fields {
            if key.hasSuffix("_encrypted"), let isEncrypted = value as? Bool, isEncrypted {
                let originalKey = String(key.dropLast(10)) // Remove "_encrypted"
                if let encryptedString = fields[originalKey] as? String,
                   let encryptedData = Data(base64Encoded: encryptedString)
                {
                    do {
                        let decryptedString = try decryptToString(data: encryptedData)
                        decryptedFields[originalKey] = decryptedString
                    } catch {
                        os_log("Failed to decrypt field '%{public}@': %{public}@", log: logger, type: .error, originalKey, error.localizedDescription)
                    }
                }
            }
        }

        return decryptedFields
    }

    // MARK: - Private Methods

    private func setupEncryptionKey() {
        do {
            _ = try getEncryptionKey()
        } catch {
            os_log("Failed to setup encryption key: %{public}@", log: logger, type: .error, error.localizedDescription)
            // Try to create a new key
            do {
                try rotateEncryptionKey()
            } catch {
                os_log("Failed to create new encryption key: %{public}@", log: logger, type: .error, error.localizedDescription)
            }
        }
    }

    private func getEncryptionKey() throws -> SymmetricKey {
        keyLock.lock()
        if let cachedKey {
            keyLock.unlock()
            return cachedKey
        }
        keyLock.unlock()

        if let keyData = try loadKeyFromKeychain() {
            let key = SymmetricKey(data: keyData)
            keyLock.lock()
            cachedKey = key
            keyLock.unlock()
            return key
        }

        throw EncryptionError.keyNotFound
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

        if status == errSecSuccess, let data = result as? Data {
            return data
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw EncryptionError.keychainError(status)
        }
    }

    private func storeKeyInKeychain(_ key: SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data($0) }

        // Delete existing key if it exists
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Store new key
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status != errSecSuccess {
            throw EncryptionError.keychainError(status)
        }
    }

    // MARK: - Error Types

    public enum EncryptionError: LocalizedError {
        case invalidData
        case keyNotFound
        case keychainError(OSStatus)
        case decryptionFailed
        case encryptionFailed

        public var errorDescription: String? {
            switch self {
            case .invalidData:
                return "Invalid data for encryption/decryption"
            case .keyNotFound:
                return "Encryption key not found"
            case let .keychainError(status):
                return "Keychain error: \(status)"
            case .decryptionFailed:
                return "Decryption failed"
            case .encryptionFailed:
                return "Encryption failed"
            }
        }
    }
}
