import Foundation

class FileManagerLogger {
    func log(_ message: String, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        AppLogger.shared.debug("[\(timestamp)] [\(fileName):\(line)] \(message)")
    }
}

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    static let reportFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy 'at' HH:mm:ss"
        return formatter
    }()
}

struct SimpleLogger {
    func log(_ message: String) {
        AppLogger.shared.debug("FileManagerService: \(message)")
    }
}
