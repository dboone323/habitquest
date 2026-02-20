import CryptoKit
import Foundation

public actor CryptoManager {
    public static let shared = CryptoManager()
    private let key: SymmetricKey

    private init() {
        // Fixed key for development to ensure persistence works across sessions during verification
        // In production this should be in Keychain
        let keyData = "HabitQuestSecureKey2025".data(using: .utf8) ?? Data()
        let padding =
            String(repeating: "0", count: max(0, 32 - keyData.count)).data(using: .utf8) ?? Data()
        self.key = SymmetricKey(data: keyData + padding)
    }

    public func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    public func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
