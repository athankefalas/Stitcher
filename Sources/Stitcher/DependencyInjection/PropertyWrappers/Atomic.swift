//
//  Atomic.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 13/2/24.
//

import Foundation

@propertyWrapper
public final class Atomic<Value> {
    
    private var value: Value
    private let semaphore = DispatchSemaphore(value: 1)
    
    public var wrappedValue: Value {
        get {
            semaphore.wait()
            
            defer {
                semaphore.signal()
            }
            
            return value
        }
        
        set {
            semaphore.wait()
            
            defer {
                semaphore.signal()
            }
            
            value = newValue
        }
    }
    
    public init(wrappedValue value: Value) {
        self.value = value
    }
    
    public init(initialValue value: Value) {
        self.value = value
    }
    
    @discardableResult
    public func lock() -> Value {
        semaphore.wait()
        return value
    }
    
    public func unlock() {
        semaphore.signal()
    }
    
    public func unlock(with value: Value) {
        self.value = value
        semaphore.signal()
    }
}
