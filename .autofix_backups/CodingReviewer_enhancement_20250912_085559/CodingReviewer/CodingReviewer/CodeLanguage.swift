import Foundation

enum CodeLanguage: String, CaseIterable, Codable {
    case swift, python, javascript, typescript, java, cpp, go, rust, html, css, xml, json, yaml,
        markdown, kotlin, csharp, c, php, ruby, unknown
}

extension CodeLanguage {
    var displayName: String {
        switch self {
        case .swift: return "Swift"
        case .python: return "Python"
        case .javascript: return "JavaScript"
        case .typescript: return "TypeScript"
        case .java: return "Java"
        case .kotlin: return "Kotlin"
        case .csharp: return "C#"
        case .cpp: return "C++"
        case .c: return "C"
        case .go: return "Go"
        case .rust: return "Rust"
        case .php: return "PHP"
        case .ruby: return "Ruby"
        case .html: return "HTML"
        case .css: return "CSS"
        case .xml: return "XML"
        case .json: return "JSON"
        case .yaml: return "YAML"
        case .markdown: return "Markdown"
        case .unknown: return "Unknown"
        }
    }
    var iconName: String {
        switch self {
        case .swift: return "swift"
        case .python: return "snake.circle"
        case .javascript, .typescript: return "js.circle"
        case .java, .kotlin: return "cup.and.saucer"
        case .csharp: return "sharp.circle"
        case .cpp, .c: return "c.circle"
        case .go: return "goforward"
        case .rust: return "gear"
        case .php: return "network"
        case .ruby: return "gem"
        case .html: return "globe"
        case .css: return "paintbrush"
        case .xml: return "doc.text"
        case .json: return "curlybraces"
        case .yaml: return "list.bullet"
        case .markdown: return "doc.richtext"
        case .unknown: return "questionmark.circle"
        }
    }
}
