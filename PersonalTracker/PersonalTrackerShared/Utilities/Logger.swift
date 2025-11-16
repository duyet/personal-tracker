import Foundation
import OSLog

// MARK: - Logger

/// Centralized logging system for the Personal Tracker app
@available(iOS 14.0, macOS 11.0, *)
struct AppLogger {
    private let logger: Logger

    init(subsystem: String = "com.personaltracker.app", category: String) {
        logger = Logger(subsystem: subsystem, category: category)
    }

    /// Log debug message
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.debug("\(formatLocation(file, function, line)): \(message)")
    }

    /// Log info message
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.info("\(formatLocation(file, function, line)): \(message)")
    }

    /// Log warning message
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.warning("\(formatLocation(file, function, line)): \(message)")
    }

    /// Log error message
    func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        if let error = error {
            logger.error("\(formatLocation(file, function, line)): \(message) - Error: \(error.localizedDescription)")
        } else {
            logger.error("\(formatLocation(file, function, line)): \(message)")
        }
    }

    /// Log critical message
    func critical(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        if let error = error {
            logger.critical("\(formatLocation(file, function, line)): \(message) - Error: \(error.localizedDescription)")
        } else {
            logger.critical("\(formatLocation(file, function, line)): \(message)")
        }
    }

    private func formatLocation(_ file: String, _ function: String, _ line: Int) -> String {
        let fileName = (file as NSString).lastPathComponent
        return "[\(fileName):\(line)] \(function)"
    }
}

// MARK: - Predefined Loggers

extension AppLogger {
    static let location = AppLogger(category: "Location")
    static let calendar = AppLogger(category: "Calendar")
    static let media = AppLogger(category: "Media")
    static let device = AppLogger(category: "Device")
    static let privacy = AppLogger(category: "Privacy")
    static let export = AppLogger(category: "Export")
    static let ui = AppLogger(category: "UI")
    static let general = AppLogger(category: "General")
}
