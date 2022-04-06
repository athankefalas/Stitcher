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
//  Injected.swift
//  
//
//  Created by Athanasios Kefalas on 12/3/22.
//

import Foundation

/// A property wrapper that injects an instance of the required dependency by type or by name, from the currently active `DependencyGraph`.
@propertyWrapper
public struct Injected<Value> {
    
    private let dependency: Value
    
    public var wrappedValue: Value {
        get {
            dependency
        }
    }
    
    /// Create a new Injected property wrapper with the injected dependency as it's wrappedValue.
    /// The dependency is located by type.
    public init() {
        self.dependency = try! DependencyGraph.active.inject()
    }
    
    /// Create a new Injected property wrapper with an array of all matching dependencies as it's wrappedValue
    /// The dependencies is located by type.
    public init<E>() where Value == Array<E> {
        self.dependency = try! DependencyGraph.active.injectAll()
    }
    
    /// Create a new Injected property wrapper with the injected dependency as it's wrappedValue.
    /// The dependency is located by type.
    /// - Parameter parameters: The parameters required, if any, to instantiate the dependency
    public init(parameters: Any...) {
        self.dependency = try! DependencyGraph.active.inject(parameters: Array(parameters))
    }
    
    /// Create a new Injected property wrapper with an array of all matching dependencies as it's wrappedValue
    /// The dependencies is located by type.
    /// - Parameter parameters: The parameters required, if any, to instantiate the dependency
    public init<E>(parameters: Any...) where Value == Array<E> {
        self.dependency = try! DependencyGraph.active.injectAll(parameters: Array(parameters))
    }
    
    /// Create a new Injected property wrapper with an array of all matching dependencies as it's wrappedValue
    /// The dependencies is located by name.
    /// - Parameters:
    ///   - name: The name of the dependency to use
    ///   - parameters: The parameters required, if any, to instantiate the dependency
    public init(_ name: String, parameters: Any...) {
        self.dependency = try! DependencyGraph.active.inject(named: name, parameters: Array(parameters))
    }
}

struct SomeDependency{}

class PropertyInjectionExample {
    
    @Injected
    var dependency: SomeDependency
    
    init() {
        
    }
    
}

class ArgumentInjectionExample {
    var dependency: SomeDependency
    
    init(dependency: SomeDependency) {
        self.dependency = dependency
    }
    
    func someMethod(dependency: SomeDependency) {
        fatalError("Not implemented.")
    }
    
}

extension ArgumentInjectionExample {
    
    convenience init() {
        @Injected
        var dependency: SomeDependency
        
        self.init(dependency: dependency)
    }
    
    func someMethod() {
        @Injected
        var dependency: SomeDependency
        
        someMethod(dependency: dependency)
    }
    
}
