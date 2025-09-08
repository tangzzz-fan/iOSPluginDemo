//
//  Logger.swift
//  iOSPluginDemo
//
//  Created by 小苹果 on 2025/8/25.
//

import Foundation
import SwiftyBeaver

// MARK: - Log Level
enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case fatal = "FATAL"
    
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .fatal: return "💀"
        }
    }
}

// MARK: - Logger Protocol
protocol Loggable {
    var log: Logger { get }
}

// MARK: - Logger Implementation
struct Logger {
    
    private let context: String
    
    init(context: String = "") {
        self.context = context
    }
    
    // MARK: - Public Methods
    
    func debug(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(level: .debug, message: message, file: file, line: line, function: function)
    }
    
    func info(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(level: .info, message: message, file: file, line: line, function: function)
    }
    
    func warning(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(level: .warning, message: message, file: file, line: line, function: function)
    }
    
    func error(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(level: .error, message: message, file: file, line: line, function: function)
    }
    
    func fatal(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(level: .fatal, message: message, file: file, line: line, function: function)
    }
    
    func auth(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        Logger(context: "Auth").info(message, file: file, line: line, function: function)
    }
    
    func navigation(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        Logger(context: "Navigation").info(message, file: file, line: line, function: function)
    }
    
    func network(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        Logger(context: "Network").info(message, file: file, line: line, function: function)
    }
    
    func ui(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        Logger(context: "UI").info(message, file: file, line: line, function: function)
    }
    
    func di(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        Logger(context: "DI").info(message, file: file, line: line, function: function)
    }
    
    // MARK: - Private Methods
    
    private func log(level: LogLevel, message: String, file: String, line: Int, function: String) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let contextPrefix = context.isEmpty ? "" : "[\(context)] "
        let formattedMessage = "\(level.emoji) \(contextPrefix)\(message)"
        
        switch level {
        case .debug:
            SwiftyBeaver.debug(formattedMessage, file: fileName, function: function, line: line)
        case .info:
            SwiftyBeaver.info(formattedMessage, file: fileName, function: function, line: line)
        case .warning:
            SwiftyBeaver.warning(formattedMessage, file: fileName, function: function, line: line)
        case .error:
            SwiftyBeaver.error(formattedMessage, file: fileName, function: function, line: line)
        case .fatal:
            SwiftyBeaver.error("💀 FATAL: \(contextPrefix)\(message)", file: fileName, function: function, line: line)
            #if DEBUG
            fatalError("Fatal error: \(message)")
            #endif
        }
    }
}

// MARK: - Default Implementation for Loggable
extension Loggable {
    var log: Logger {
        return Logger(context: String(describing: type(of: self)))
    }
}
