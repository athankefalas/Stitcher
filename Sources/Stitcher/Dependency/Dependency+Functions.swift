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
//  Dependency+Functions.swift
//  
//
//  Created by Athanasios Kefalas on 19/3/22.
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
