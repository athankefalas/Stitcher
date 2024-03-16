//
//  DependencyGraph+TypeInjection.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/2/24.
//

import Foundation

public extension DependencyGraph {
    
    /// Injects the dependency registered by the given type
    /// - Parameters:
    ///   - type: The type of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be found or instantiated
    @_disfavoredOverload
    static func inject<SomeDependecy, each Parameter: Hashable>(
        byType type: SomeDependecy.Type = SomeDependecy.self,
        parameters: repeat each Parameter
    ) throws -> SomeDependecy {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byType: SomeDependecy.self
        )
        
        let registrations = dependencyRegistrations(
            matching: locatorMatchProposal,
            parameters: parameters
        )
        
        guard let registration = registrations.first else {
            throw InjectionError.missingDependency(.type("\(type)"))
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.type("\(type)"))
        }
        
        return try instantiateDependency(
            as: SomeDependecy.self,
            from: registration,
            parameters
        )
    }
    
    /// Injects all dependencies registered by the given type
    /// - Parameters:
    ///   - type: The type of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: A collection with every matching registred instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be instantiated
    static func inject<Container: DependencyContainingCollection, SomeDependecy, each Parameter: Hashable>(
        byType type: Container.Type = Container.self,
        parameters: repeat each Parameter
    ) throws -> Container where Container.Element == SomeDependecy {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byType: SomeDependecy.self
        )
        
        let registrations = dependencyRegistrations(
            matching: locatorMatchProposal,
            parameters: parameters
        )
        
        let dependencies = try registrations.map { registration in
            return try instantiateDependency(
                as: SomeDependecy.self,
                from: registration,
                parameters
            )
        }
        
        return Container(dependencies)
    }
    
    /// Injects the dependency registered by the given type or nil if it is not found
    /// - Parameters:
    ///   - type: The type of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency or `nil`
    /// - Throws: An `InjectionError` if the dependency cannot be instantiated
    static func inject<SomeDependecy, each Parameter: Hashable>(
        byType type: SomeDependecy.Type = SomeDependecy.self,
        parameters: repeat each Parameter
    ) throws -> Optional<SomeDependecy> {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byType: SomeDependecy.self
        )
        
        let registrations = dependencyRegistrations(
            matching: locatorMatchProposal,
            parameters: parameters
        )
        
        guard let registration = registrations.first else {
            return nil
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.type("\(type)"))
        }
        
        return try instantiateDependency(
            as: SomeDependecy.self,
            from: registration,
            parameters
        )
    }
    
    
    /// Injects all dependencies registered by the given type
    /// - Parameters:
    ///   - type: The type of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: A collection with every matching registred instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be instantiated
    @available(*, deprecated, message: "Optional collection dependencies are deprecated. Please use an empty collection instead.")
    static func inject<Container: DependencyContainingCollection, SomeDependecy, each Parameter: Hashable>(
        byType type: Optional<Container>.Type = Optional<Container>.self,
        parameters: repeat each Parameter
    ) throws -> Optional<Container> where Container.Element == SomeDependecy {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byType: SomeDependecy.self
        )
        
        let registrations = dependencyRegistrations(
            matching: locatorMatchProposal,
            parameters: parameters
        )
        
        let dependencies = try registrations.map { registration in
            return try instantiateDependency(
                as: SomeDependecy.self,
                from: registration,
                parameters
            )
        }
        
        return Container(dependencies)
    }
    
    
}
