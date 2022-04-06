//
// MIT License
//
// Copyright (c) 2022 Athanasios Kefalas
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//
//  StitcherPrintLogger.swift
//  
//
//  Created by Athanasios Kefalas on 22/12/21.
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
