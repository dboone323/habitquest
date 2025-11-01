import CryptoKit
import Foundation
import Security

// MARK: - Encryption Service

@MainActor
final class EncryptionService: Sendable {
    static let shared = EncryptionService()

    private let keychainService = "com.codingreviewer.encryption"
    private let keychainAccount = "analysis-data-key"
    private var cachedKey: SymmetricKey?

    private init() {}

    // MARK: - Key Management

    private func getOrCreateKey() throws -> SymmetricKey {
        if let cached = cachedKey {
            return cached
        }

        // Try to retrieve existing key from Keychain
        if let existingKeyData = try? retrieveKeyFromKeychain() {
            let key = SymmetricKey(data: existingKeyData)
            cachedKey = key
            return key
        }

        // Generate new key
        let key = SymmetricKey(size: .bits256)
        cachedKey = key

        // Store in Keychain
        try storeKeyInKeychain(key)

        return key
    }

    private func retrieveKeyFromKeychain() throws -> Data {
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
            throw EncryptionError.keychainRetrievalFailed(status)
        }

        return keyData
    }

    private func storeKeyInKeychain(_ key: SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        // If key already exists, update it
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: keychainAccount,
            ]
            let updateAttributes: [String: Any] = [
                kSecValueData as String: keyData,
            ]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw EncryptionError.keychainStorageFailed(updateStatus)
            }
        } else if status != errSecSuccess {
            throw EncryptionError.keychainStorageFailed(status)
        }
    }

    // MARK: - Encryption/Decryption

    func encrypt(data: Data) async throws -> Data {
        let key = try getOrCreateKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined ?? Data()
    }

    func decrypt(data: Data) async throws -> Data {
        let key = try getOrCreateKey()
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    func encryptString(_ string: String) async throws -> Data {
        guard let data = string.data(using: .utf8) else {
            throw EncryptionError.stringEncodingFailed
        }
        return try await encrypt(data: data)
    }

    func decryptString(_ data: Data) async throws -> String {
        let decryptedData = try await decrypt(data: data)
        guard let string = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.stringDecodingFailed
        }
        return string
    }

    // MARK: - Secure Storage for Analysis Results

    func encryptAnalysisResult(_ result: Data) async throws -> Data {
        // Add metadata for integrity verification
        let metadata = AnalysisMetadata(
            version: "1.0",
            timestamp: Date(),
            dataType: "analysis_result"
        )

        let metadataData = try JSONEncoder().encode(metadata)
        var metadataLength = UInt32(metadataData.count).bigEndian
        let lengthData = Data(bytes: &metadataLength, count: 4)
        let combinedData = lengthData + metadataData + result

        return try await encrypt(data: combinedData)
    }

    @MainActor func decryptAnalysisResult(_ encryptedData: Data) async throws -> (metadata: AnalysisMetadata, data: Data) {
        let combinedData = try await decrypt(data: encryptedData)

        // Extract length prefix (4 bytes)
        guard combinedData.count >= 4 else {
            throw EncryptionError.invalidEncryptedData
        }

        let lengthData = combinedData.prefix(4)
        let metadataLength = UInt32(bigEndian: lengthData.withUnsafeBytes { $0.load(as: UInt32.self) })

        // Extract metadata
        let metadataStart = 4
        let metadataEnd = metadataStart + Int(metadataLength)
        guard combinedData.count >= metadataEnd else {
            throw EncryptionError.invalidEncryptedData
        }

        let metadataData = combinedData[metadataStart ..< metadataEnd]
        let metadata = try JSONDecoder().decode(AnalysisMetadata.self, from: metadataData)

        // Extract result data
        let resultData = combinedData.suffix(from: metadataEnd)

        return (metadata, resultData)
    }

    // MARK: - Key Rotation

    func rotateEncryptionKey() async throws {
        // Generate new key
        let newKey = SymmetricKey(size: .bits256)

        // Update cached key
        cachedKey = newKey

        // Store new key in Keychain (this will overwrite the old one)
        try storeKeyInKeychain(newKey)

        // In a real implementation, you would need to:
        // 1. Re-encrypt all existing data with the new key
        // 2. Update any external references to the key
        // 3. Maintain backward compatibility during transition

        AuditLogger.shared.logSecurityEvent(
            "Encryption key rotated successfully",
            details: "New AES-256-GCM key generated and stored in Keychain"
        )
    }

    // MARK: - Security Validation

    func validateEncryptionIntegrity() async throws -> Bool {
        let testData = "integrity_test_data".data(using: .utf8)!
        let encrypted = try await encrypt(data: testData)
        let decrypted = try await decrypt(data: encrypted)
        return decrypted == testData
    }
}

// MARK: - Supporting Types

struct AnalysisMetadata: Codable {
    let version: String
    let timestamp: Date
    let dataType: String
}

private enum EncryptionError: LocalizedError {
    case keychainRetrievalFailed(OSStatus)
    case keychainStorageFailed(OSStatus)
    case stringEncodingFailed
    case stringDecodingFailed
    case invalidEncryptedData

    var errorDescription: String? {
        switch self {
        case let .keychainRetrievalFailed(status):
            return "Failed to retrieve encryption key from Keychain (status: \(status))"
        case let .keychainStorageFailed(status):
            return "Failed to store encryption key in Keychain (status: \(status))"
        case .stringEncodingFailed:
            return "Failed to encode string to data"
        case .stringDecodingFailed:
            return "Failed to decode data to string"
        case .invalidEncryptedData:
            return "Invalid encrypted data format"
        }
    }
}

// MARK: - Audit Logger Extension

private extension AuditLogger {
    func logSecurityEvent(_ event: String, details: String) {
        logSecurityViolation(violation: event, details: details)
    }
}
