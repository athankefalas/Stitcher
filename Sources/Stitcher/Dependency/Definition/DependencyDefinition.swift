//
//  DependencyDefinition.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 26/3/22.
//

import Foundation

/// A type that encapsulates the definition of a dependency.
public protocol DependencyDefinition {
    associatedtype Instantiator: DependencyInstantiating
    
    /// The dependency locator of the defined dependency that will be used to identify the dependency
    var locator: DependencyLocator { get }
    /// The dependency instantiator of the defined dependency
    var instantiator: Instantiator { get }
    /// The priority of the defined dependency. By default it is set to `Priority.required`.
    var priority: Priority { get }
}

public extension DependencyDefinition {
    
    var priority: Priority {
        .required
    }
}
