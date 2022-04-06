//
//  Injected.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/22.
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
