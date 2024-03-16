//
//  DependencyGraph+NameInjection.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import Foundation

public extension DependencyGraph {
    
    /// Injects the dependency registered by the given name
    /// - Parameters:
    ///   - name: The name of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be found or instantiated
    static func inject<SomeDependecy, each Parameter: Hashable>(
        byName name: String,
        parameters: repeat each Parameter
    ) throws -> SomeDependecy {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byName: name
        )
        
        let registrations = dependencyRegistrations(
            matching: locatorMatchProposal,
            parameters: parameters
        )
        
        guard let registration = registrations.first else {
            throw InjectionError.missingDependency(.name(name))
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.name(name))
        }
        
        return try instantiateDependency(
            as: SomeDependecy.self,
            from: registration,
            parameters
        )
    }
    
    /// Injects the dependency registered by the given name
    /// - Parameters:
    ///   - name: The name of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be found or instantiated
    @_disfavoredOverload
    static func inject<Name: CustomStringConvertible, SomeDependecy, each Parameter: Hashable>(
        byName name: Name,
        parameters: repeat each Parameter
    ) throws -> SomeDependecy {
        let name = name.description
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byName: name
        )
        
        let registrations = dependencyRegistrations(
            matching: locatorMatchProposal,
            parameters: parameters
        )
        
        guard let registration = registrations.first else {
            throw InjectionError.missingDependency(.name(name))
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.name(name))
        }
        
        return try instantiateDependency(
            as: SomeDependecy.self,
            from: registration,
            parameters
        )
    }
    
    /// Injects the dependency registered by the given name
    /// - Parameters:
    ///   - name: The name of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be found or instantiated
    static func inject<Name: RawRepresentable, SomeDependecy, each Parameter: Hashable>(
        byName name: Name,
        parameters: repeat each Parameter
    ) throws -> SomeDependecy
    where Name.RawValue == String {
        let name = name.rawValue
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byName: name
        )
        
        let registrations = dependencyRegistrations(
            matching: locatorMatchProposal,
            parameters: parameters
        )
        
        guard let registration = registrations.first else {
            throw InjectionError.missingDependency(.name(name))
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.name(name))
        }
        
        return try instantiateDependency(
            as: SomeDependecy.self,
            from: registration,
            parameters
        )
    }
    
}
