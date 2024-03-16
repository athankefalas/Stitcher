//
//  DependencyGraph+ValueInjection.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import Foundation

public extension DependencyGraph {
    
    /// Injects the dependency registered by the given value
    /// - Parameters:
    ///   - value: The value of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be found or instantiated
    @_disfavoredOverload
    static func inject<Value: Hashable, SomeDependecy, each Parameter: Hashable>(
        byValue value: Value,
        parameters: repeat each Parameter
    ) throws -> SomeDependecy {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byValue: value
        )
        
        let registrations = dependencyRegistrations(
            matching: locatorMatchProposal,
            parameters: parameters
        )
        
        guard let registration = registrations.first else {
            throw InjectionError.missingDependency(.value(value))
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.value(value))
        }
        
        return try instantiateDependency(
            as: SomeDependecy.self,
            from: registration,
            parameters
        )
    }
}
