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
//  StitcherLogger.swift
//  
//
//  Created by Athanasios Kefalas on 22/12/21.
//

import Foundation

public enum LogLevel: Int, RawRepresentable, Equatable, Comparable {
    case debug
    case info
    case warn
    case error
    case fatal
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public protocol StitcherLogger {
    
    func write(at level: LogLevel, message: String)
}

public extension StitcherLogger {
    
    func debug(_ value: Any?) {
        write(at: .debug, message: message(from: value))
    }
    
    func info(_ value: Any?) {
        write(at: .info, message: message(from: value))
    }
    
    func warn(_ value: Any?) {
        write(at: .warn, message: message(from: value))
    }
    
    func error(_ value: Any?) {
        write(at: .error, message: message(from: value))
    }
    
    func fatal(_ value: Any?) {
        write(at: .fatal, message: message(from: value))
    }
    
    private func message(from value: Any?) -> String {
        guard let value = value else {
            return "null"
        }
        
        return "\(value)"
    }
}


internal func debug(_ value: Any?) {
    Stitcher.configuration.logger.debug(value)
}

internal func info(_ value: Any?) {
    Stitcher.configuration.logger.info(value)
}

internal func warn(_ value: Any?) {
    Stitcher.configuration.logger.warn(value)
}

internal func error(_ value: Any?) {
    Stitcher.configuration.logger.error(value)
}

internal func fatal(_ value: Any?) {
    Stitcher.configuration.logger.fatal(value)
}

// MARK: Common Warnings

internal func warnUnsafeSynthticUsage(function: String) {
    guard Stitcher.configuration.warnUnsafeSyntheticTypeUsage else {
        return
    }
    
    warn("Using UnsafeSyntheticMember feature to synthesize function '\(function)'.")
}

internal func warnUnsafeSynthticUsage(property: String) {
    guard Stitcher.configuration.warnUnsafeSyntheticTypeUsage else {
        return
    }
    
    warn("Using UnsafeSyntheticMember feature to synthesize property '\(property)'.")
}
