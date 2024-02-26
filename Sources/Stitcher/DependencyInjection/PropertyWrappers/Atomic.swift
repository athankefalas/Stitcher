//
//  Atomic.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 13/2/24.
//

import Foundation

@propertyWrapper
final class Atomic<Value> {
    
    private var value: Value
    private let semaphore = DispatchSemaphore(value: 1)
    
    var wrappedValue: Value {
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
    
    init(wrappedValue value: Value) {
        self.value = value
    }
    
    init(initialValue value: Value) {
        self.value = value
    }
}
