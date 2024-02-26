//
//  DependencyGraph+Injection.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/2/24.
//

import Foundation

// MARK: DependencyGraph+Injection

public extension DependencyGraph {
    
    /// Injects the dependency registered by the given name
    /// - Parameters:
    ///   - name: The name of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be found or instantiated
    static func injectDependency<SomeDependecy, each Parameter: Hashable>(
        byName name: String,
        parameters: repeat each Parameter
    ) throws -> SomeDependecy {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byName: name
        )
        
        let registrations = dependencyRegistrations(matching: locatorMatchProposal)
            .filter( { $0.factory.parameters.isSatisfied(by: parameters) })
        
        guard let registration = registrations.first else {
            throw InjectionError.missingDependency(.name(name))
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.name(name))
        }
        
        guard let dependency = try instantiateDependency(from: registration, parameters) as? SomeDependecy else {
            throw InjectionError.mismatchedDependencyType
        }
        
        return dependency
    }
    
    /// Injects the dependency registered by the given name
    /// - Parameters:
    ///   - name: The name of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be found or instantiated
    @_disfavoredOverload
    static func injectDependency<Name: CustomStringConvertible, SomeDependecy, each Parameter: Hashable>(
        byName name: Name,
        parameters: repeat each Parameter
    ) throws -> SomeDependecy {
        let name = name.description
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byName: name
        )
        
        let registrations = dependencyRegistrations(matching: locatorMatchProposal)
            .filter( { $0.factory.parameters.isSatisfied(by: parameters) })
        
        guard let registration = registrations.first else {
            throw InjectionError.missingDependency(.name(name))
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.name(name))
        }
        
        guard let dependency = try instantiateDependency(from: registration, parameters) as? SomeDependecy else {
            throw InjectionError.mismatchedDependencyType
        }
        
        return dependency
    }
    
    /// Injects the dependency registered by the given name
    /// - Parameters:
    ///   - name: The name of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be found or instantiated
    static func injectDependency<Name: RawRepresentable, SomeDependecy, each Parameter: Hashable>(
        byName name: Name,
        parameters: repeat each Parameter
    ) throws -> SomeDependecy
    where Name.RawValue == String {
        let name = name.rawValue
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byName: name
        )
        
        let registrations = dependencyRegistrations(matching: locatorMatchProposal)
            .filter( { $0.factory.parameters.isSatisfied(by: parameters) })
        
        guard let registration = registrations.first else {
            throw InjectionError.missingDependency(.name(name))
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.name(name))
        }
        
        guard let dependency = try instantiateDependency(from: registration, parameters) as? SomeDependecy else {
            throw InjectionError.mismatchedDependencyType
        }
        
        return dependency
    }
    
    
    
    /// Injects the dependency registered by the given type
    /// - Parameters:
    ///   - type: The type of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be found or instantiated
    @_disfavoredOverload
    static func injectDependency<SomeDependecy, each Parameter: Hashable>(
        byType type: SomeDependecy.Type = SomeDependecy.self,
        parameters: repeat each Parameter
    ) throws -> SomeDependecy {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byType: SomeDependecy.self
        )
        
        let registrations = dependencyRegistrations(matching: locatorMatchProposal)
            .filter( { $0.factory.parameters.isSatisfied(by: parameters) })
        
        guard let registration = registrations.first else {
            throw InjectionError.missingDependency(.type("\(type)"))
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.type("\(type)"))
        }
        
        guard let dependency = try instantiateDependency(from: registration, parameters) as? SomeDependecy else {
            throw InjectionError.mismatchedDependencyType
        }
        
        return dependency
    }
    
    /// Injects all dependencies registered by the given type
    /// - Parameters:
    ///   - type: The type of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: A collection with every matching registred instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be instantiated
    static func injectDependency<Container: DependencyContainingCollection, SomeDependecy, each Parameter: Hashable>(
        byType type: Container.Type = Container.self,
        parameters: repeat each Parameter
    ) throws -> Container where Container.Element == SomeDependecy {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byType: SomeDependecy.self
        )
        
        let registrations = dependencyRegistrations(matching: locatorMatchProposal)
            .filter( { $0.factory.parameters.isSatisfied(by: parameters) })
        
        let dependencies = try registrations.map { registration in
            guard let dependency = try instantiateDependency(from: registration, parameters) as? SomeDependecy else {
                throw InjectionError.mismatchedDependencyType
            }
            
            return dependency
        }
        
        return Container(dependencies)
    }
    
    /// Injects the dependency registered by the given type or nil if it is not found
    /// - Parameters:
    ///   - type: The type of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency or `nil`
    /// - Throws: An `InjectionError` if the dependency cannot be instantiated
    static func injectDependency<SomeDependecy, each Parameter: Hashable>(
        byType type: SomeDependecy.Type = SomeDependecy.self,
        parameters: repeat each Parameter
    ) throws -> Optional<SomeDependecy> {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byType: SomeDependecy.self
        )
        
        let registrations = dependencyRegistrations(matching: locatorMatchProposal)
            .filter( { $0.factory.parameters.isSatisfied(by: parameters) })
        
        guard let registration = registrations.first else {
            return nil
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.type("\(type)"))
        }
        
        guard let dependency = try instantiateDependency(from: registration, parameters) as? SomeDependecy else {
            throw InjectionError.mismatchedDependencyType
        }
        
        return dependency
    }
    
    
    /// Injects all dependencies registered by the given type
    /// - Parameters:
    ///   - type: The type of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: A collection with every matching registred instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be instantiated
    @available(*, deprecated, message: "Optional collection dependencies are deprecated. Please use an empty collection instead.")
    static func injectDependency<Container: DependencyContainingCollection, SomeDependecy, each Parameter: Hashable>(
        byType type: Optional<Container>.Type = Optional<Container>.self,
        parameters: repeat each Parameter
    ) throws -> Optional<Container> where Container.Element == SomeDependecy {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byType: SomeDependecy.self
        )
        
        let registrations = dependencyRegistrations(matching: locatorMatchProposal)
            .filter( { $0.factory.parameters.isSatisfied(by: parameters) })
        
        let dependencies = try registrations.map { registration in
            guard let dependency = try instantiateDependency(from: registration, parameters) as? SomeDependecy else {
                throw InjectionError.mismatchedDependencyType
            }
            
            return dependency
        }
        
        return Container(dependencies)
    }
    
    /// Injects the dependency registered by the given value
    /// - Parameters:
    ///   - value: The value of the dependency
    ///   - parameters: The parameters used to instantiate the dependency
    /// - Returns: An instance of the dependency
    /// - Throws: An `InjectionError` if the dependency cannot be found or instantiated
    static func injectDependency<Value: Hashable, SomeDependecy, each Parameter: Hashable>(
        byValue value: Value,
        parameters: repeat each Parameter
    ) throws -> SomeDependecy {
        let parameters = DependencyParameters(repeat each parameters)
        let locatorMatchProposal = DependencyLocator.MatchProposal(
            byValue: value
        )
        
        let registrations = dependencyRegistrations(matching: locatorMatchProposal)
            .filter( { $0.factory.parameters.isSatisfied(by: parameters) })
        
        guard let registration = registrations.first else {
            throw InjectionError.missingDependency(.value(value))
        }
        
        guard registrations.count <= 1 else {
            throw InjectionError.multipleDependencies(.value(value))
        }
        
        guard let dependency = try instantiateDependency(from: registration, parameters) as? SomeDependecy else {
            throw InjectionError.mismatchedDependencyType
        }
        
        return dependency
    }
}
