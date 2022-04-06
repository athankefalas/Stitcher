//
//  Functions.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 6/3/22.
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
