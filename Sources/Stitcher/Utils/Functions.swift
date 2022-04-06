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
//  Functions.swift
//  
//
//  Created by Athanasios Kefalas on 6/3/22.
//

import Foundation

// MARK: Helpers

internal func synchronized<T>(with semaphore: DispatchSemaphore, _ block: () -> T) -> T {
    semaphore.wait()
    
    defer {
        semaphore.signal()
    }
    
    return block()
}

internal func cast<T>(_ instance: Any?, as type: T.Type = T.self) throws -> T {
    guard let instance = instance as? T else {
        throw TypeCastingError(of: instance, toType: type)
    }
    
    return instance
}

internal func clamp<T: Comparable>(_ value: T, in range: ClosedRange<T>) -> T {
    return min(max(value, range.lowerBound), range.upperBound)
}

// MARK: Members

/// Creates a normalized name string of a function that belongs to a specific type
/// - Parameters:
///   - name: The name of member function
///   - type: The name of the type
/// - Returns: The name string of a function that belongs to a specific type
public func memberFunction(_ name: String, of type: String) -> String {
    return "\(type).\(name)"
}

/// Creates a normalized name string of a property that belongs to a specific type
/// - Parameters:
///   - name: The name of member property
///   - type: The name of the type
/// - Returns: The name string of a property that belongs to a specific type
public func memberProperty(_ name: String, of type: String) -> String {
    return "\(type).\(name)"
}
