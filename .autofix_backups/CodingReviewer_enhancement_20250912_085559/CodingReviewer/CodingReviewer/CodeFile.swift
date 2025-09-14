import CryptoKit
import Foundation

struct CodeFile: Identifiable, Hashable, Codable, Equatable {
    let id: UUID
    let name: String
    let path: String
    let content: String
    let language: CodeLanguage
    let size: Int
    let lastModified: Date
    let checksum: String

    init(name: String, path: String, content: String, language: CodeLanguage) {
        self.id = UUID()
        self.name = name
        self.path = path
        self.content = content
        self.language = language
        self.size = content.utf8.count
        self.lastModified = Date()
        self.checksum = content.data(using: .utf8)?.sha256 ?? ""
    }

    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }

    var fileExtension: String {
        URL(fileURLWithPath: name).pathExtension
    }
}

extension Data {
    var sha256: String {
        let hash = SHA256.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
