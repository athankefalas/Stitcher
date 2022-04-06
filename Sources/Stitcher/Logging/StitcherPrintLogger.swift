//
//  StitcherPrintLogger.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 22/12/21.
//

import Foundation

public struct StitcherPrintLogger: StitcherLogger {
    
    public enum Style {
        case simple
        case emojis
    }
    
    var logLevel: LogLevel
    var style: Style = .simple
    
    public init() {
        #if DEBUG
        logLevel = .debug
        #else
        logLevel = .warn
        #endif
    }
    
    public init(logLevel: LogLevel, style: StitcherPrintLogger.Style = .simple) {
        self.logLevel = logLevel
        self.style = style
    }
    
    public func write(at level: LogLevel, message: String) {
        guard level >= logLevel else {
            return
        }
        
        let components = [
            prefix(for: level),
            "STITCHER",
            Date().description,
            ">",
            message
        ]
        
        print(components.joined(separator: " "))
    }
    
    private func prefix(for logLevel: LogLevel) -> String {
        switch style {
        case .simple:
            return simplePrefix(for: logLevel)
        case .emojis:
            return emojiPrefix(for: logLevel)
        }
    }
    
    
    private func simplePrefix(for logLevel: LogLevel) -> String {
        switch logLevel {
        case .debug:
            return "[-]"
        case .info:
            return "[i]"
        case .warn:
            return "[!]"
        case .error:
            return "[X]"
        case .fatal:
            return "!!!"
        }
    }
    
    private func emojiPrefix(for logLevel: LogLevel) -> String {
        switch logLevel {
        case .debug:
            return "🪲"
        case .info:
            return "ℹ️"
        case .warn:
            return "⚠️"
        case .error:
            return "❌"
        case .fatal:
            return "☠️"
        }
    }
    
}
