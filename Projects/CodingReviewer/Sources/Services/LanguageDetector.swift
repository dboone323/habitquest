import Foundation

@MainActor
final class LanguageDetector: Sendable {
    static let shared = LanguageDetector()

    private init() {}

    func detectLanguage(for fileURL: URL) -> ProgrammingLanguage? {
        let securityMonitor = SecurityMonitor.shared

        // Monitor file access for language detection
        securityMonitor.monitorDataAccess(
            operation: "detect_language",
            dataType: "file_metadata",
            recordCount: 1
        )

        let fileExtension = fileURL.pathExtension.lowercased()

        switch fileExtension {
        case "swift":
            return .swift
        case "py", "python":
            return .python
        case "js", "javascript":
            return .javascript
        case "ts", "typescript":
            return .typescript
        case "java":
            return .java
        case "cpp", "cc", "cxx":
            return .cpp
        case "c":
            return .c
        case "h", "hpp":
            return .objectiveC // Could be C/C++/Obj-C header
        case "m":
            return .objectiveC
        case "kt", "kts":
            return .kotlin
        case "rs":
            return .rust
        case "go":
            return .go
        case "rb":
            return .ruby
        case "php":
            return .php
        case "cs":
            return .csharp
        default:
            return nil
        }
    }

    func detectLanguageFromContent(_ content: String) -> ProgrammingLanguage? {
        let securityMonitor = SecurityMonitor.shared

        // Monitor content analysis
        securityMonitor.monitorDataAccess(
            operation: "analyze_content",
            dataType: "code_content",
            recordCount: 1
        )

        // Simple content-based detection
        // Swift heuristics: 'func ' with return arrow or common Swift imports
        if content.contains("func ") && (content.contains("->") || content.contains("{")) {
            return .swift
        } else if content.contains("def ") && content.contains(":") {
            return .python
        } else if content.contains("function") && content.contains("{") {
            return .javascript
        } else if content.contains("public class") || content.contains("import java") {
            return .java
        } else if content.contains("#include") {
            return .c
        }

        return nil
    }
}

enum ProgrammingLanguage: String, Codable, Sendable {
    case swift
    case python
    case javascript
    case typescript
    case java
    case cpp = "c++"
    case c
    case objectiveC = "objective-c"
    case kotlin
    case rust
    case go
    case ruby
    case php
    case csharp = "c#"

    var displayName: String {
        switch self {
        case .cpp: return "C++"
        case .csharp: return "C#"
        case .objectiveC: return "Objective-C"
        default: return rawValue.capitalized
        }
    }

    var fileExtensions: [String] {
        switch self {
        case .swift: return ["swift"]
        case .python: return ["py", "python"]
        case .javascript: return ["js", "javascript"]
        case .typescript: return ["ts", "typescript"]
        case .java: return ["java"]
        case .cpp: return ["cpp", "cc", "cxx"]
        case .c: return ["c"]
        case .objectiveC: return ["m", "h"]
        case .kotlin: return ["kt", "kts"]
        case .rust: return ["rs"]
        case .go: return ["go"]
        case .ruby: return ["rb"]
        case .php: return ["php"]
        case .csharp: return ["cs"]
        }
    }
}
