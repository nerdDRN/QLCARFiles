//
//  AppLogger.swift
//  QLCARFilesApp
//
//  Created by Cagan on 14.11.2025.
//

import Foundation
import OSLog

/// A lightweight wrapper around OSLog for application logging
public struct AppLogger {
    private let logger: Logger

    /// Subsystem identifier for the application logs
    private static let subsystem = Bundle.main.bundleIdentifier ?? "org.cgn.QLCARFilesApp"

    /// Creates a logger for a specific category
    /// - Parameter category: The category name for this logger (e.g., "Networking", "UI", "Parser")
    public init(category: String) {
        self.logger = Logger(subsystem: Self.subsystem, category: category)
    }

    // MARK: - Logging Methods

    /// Log a debug message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called (default: #file)
    ///   - function: The function where the log was called (default: #function)
    ///   - line: The line where the log was called (default: #line)
    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logger.debug("\(message, privacy: .public) [\(file):\(line) \(function)]")
    }

    /// Log an info message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called (default: #file)
    ///   - function: The function where the log was called (default: #function)
    ///   - line: The line where the log was called (default: #line)
    public func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logger.info("\(message, privacy: .public)")
    }

    /// Log a warning message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called (default: #file)
    ///   - function: The function where the log was called (default: #function)
    ///   - line: The line where the log was called (default: #line)
    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logger.warning("\(message, privacy: .public) [\(file):\(line)]")
    }

    /// Log an error message
    /// - Parameters:
    ///   - message: The message to log
    ///   - error: Optional error object to include
    ///   - file: The file where the log was called (default: #file)
    ///   - function: The function where the log was called (default: #function)
    ///   - line: The line where the log was called (default: #line)
    public func error(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        if let error = error {
            logger.error("\(message, privacy: .public): \(error.localizedDescription, privacy: .public) [\(file):\(line)]")
        } else {
            logger.error("\(message, privacy: .public) [\(file):\(line)]")
        }
    }

    /// Log a critical/fault message
    /// - Parameters:
    ///   - message: The message to log
    ///   - error: Optional error object to include
    ///   - file: The file where the log was called (default: #file)
    ///   - function: The function where the log was called (default: #function)
    ///   - line: The line where the log was called (default: #line)
    public func critical(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        if let error = error {
            logger.critical("\(message, privacy: .public): \(error.localizedDescription, privacy: .public) [\(file):\(line)]")
        } else {
            logger.critical("\(message, privacy: .public) [\(file):\(line)]")
        }
    }
}

// MARK: - Common Loggers

extension AppLogger {
    /// Logger for general application events
    public nonisolated(unsafe) static let app = AppLogger(category: "App")

    /// Logger for UI-related events
    public nonisolated(unsafe) static let ui = AppLogger(category: "UI")

    /// Logger for CAR file parsing
    public nonisolated(unsafe) static let parser = AppLogger(category: "Parser")

    /// Logger for export operations
    public nonisolated(unsafe) static let export = AppLogger(category: "Export")
}
