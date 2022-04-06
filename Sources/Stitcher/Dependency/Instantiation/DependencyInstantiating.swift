//
//  DependencyInstantiating.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/3/22.
//

import Foundation

/// A type that can be used to instantiate a dependency
public protocol DependencyInstantiating: Hashable {
    associatedtype Instance
    
    /// An array of the types required as parameters when instantiating the dependency stored as Strings
    var parameterTypes: [String] { get }
    /// The count of the parameters required when instantiating the dependency
    var parameterCount: UInt { get }
    
    /// Creates a new instance of the dependency by using the given parameters
    /// - Parameter parameters: An array of type erased parameters
    /// - Returns: An instance of the dependency
    func instantiate(parameters: [Any?]) throws -> Instance
}

public extension DependencyInstantiating {
    
    var parameterCount: UInt {
        UInt(parameterTypes.count)
    }
    
}
