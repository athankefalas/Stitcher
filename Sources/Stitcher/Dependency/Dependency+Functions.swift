//
//  Dependency+Functions.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 19/3/22.
//

import Foundation

public extension Dependency {
    
    init<R>(function functionName: String, _ function: @escaping () -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, R>(function functionName: String, _ function: @escaping (P1) -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, R>(function functionName: String, _ function: @escaping (P1, P2) -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, R>(function functionName: String, _ function: @escaping (P1, P2, P3) -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4) -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5) -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5, P6) -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, P7, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5, P6, P7) -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, P7.self, returning: R.self), dependencyInstantiator)
    }
    
    // Throwing Variants
    
    init<R>(function functionName: String, _ function: @escaping () throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, R>(function functionName: String, _ function: @escaping (P1) throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, R>(function functionName: String, _ function: @escaping (P1, P2) throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, R>(function functionName: String, _ function: @escaping (P1, P2, P3) throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4) throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5) throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5, P6) throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, P7, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5, P6, P7) throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, P7.self, returning: R.self), dependencyInstantiator)
    }
    
    // Async Variants
    
    init<R>(function functionName: String, _ function: @escaping () async -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, R>(function functionName: String, _ function: @escaping (P1) async -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, R>(function functionName: String, _ function: @escaping (P1, P2) async -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, R>(function functionName: String, _ function: @escaping (P1, P2, P3) async -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4) async -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5) async -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5, P6) async -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, P7, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5, P6, P7) async -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, P7.self, returning: R.self), dependencyInstantiator)
    }
    
    // Async Throwing Variants
    
    init<R>(function functionName: String, _ function: @escaping () async throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, R>(function functionName: String, _ function: @escaping (P1) async throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, R>(function functionName: String, _ function: @escaping (P1, P2) async throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, R>(function functionName: String, _ function: @escaping (P1, P2, P3) async throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4) async throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5) async throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5, P6) async throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, returning: R.self), dependencyInstantiator)
    }
    
    init<P1, P2, P3, P4, P5, P6, P7, R>(function functionName: String, _ function: @escaping (P1, P2, P3, P4, P5, P6, P7) async throws -> R) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return function
        }
        
        self.init(.function(functionName, accepting: P1.self, P2.self, P3.self, P4.self, P5.self, P6.self, P7.self, returning: R.self), dependencyInstantiator)
    }
}
