//
//  Dependency.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/22.
//

import Foundation

/// A type that represents a dependency.
public struct Dependency: Equatable, Hashable {
    /// The dependency locator used to identify the dependency
    public let locator: DependencyLocator
    /// The instantiator to use in order to create new instances of the dependency
    public private(set) var instantiator: AnyDependencyInstantiating
    /// The priority of the dependency
    public private(set) var priority: Priority
    
    /// Creates a new dependency.
    /// - Parameters:
    ///   - locator: The locator used to identify the dependency
    ///   - instantiator: The instantiator used to create new instances of the dependency
    public init<SomeDependencyInstantiating: DependencyInstantiating>(
        _ locator: DependencyLocator,
        _ instantiator: SomeDependencyInstantiating) {
            
        self.locator = locator
        self.instantiator = AnyDependencyInstantiating(erasing: instantiator)
        self.priority = .required
    }
    
    /// Creates a new dependency using the given `DependencyDefinition`.
    /// - Parameter dependencyDefinition: A definition of the dependency
    public init<SomeDependencyDefinition: DependencyDefinition>(_ dependencyDefinition: SomeDependencyDefinition) {
        self.locator = dependencyDefinition.locator
        self.instantiator = AnyDependencyInstantiating(erasing: dependencyDefinition.instantiator)
        self.priority = dependencyDefinition.priority
    }
    
    /// Changes the priority of a dependency to the given value
    /// - Parameter priority: The new priority to assign to the dependency
    /// - Returns: A dependency with the same definition and the given priority
    public func priority(_ priority: Priority) -> Dependency {
        var mutableSelf = self
        mutableSelf.priority = priority
        
        return mutableSelf
    }
}
