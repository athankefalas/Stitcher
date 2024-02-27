//
//  DependencyGraph.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 13/2/24.
//

import Foundation
import Combine
import OrderedCollections

/// A type that contains all active `DependencyContainers` and can be used to inject dependencies.
public enum DependencyGraph {
    
    @Atomic
    private static var activeContainers: OrderedDictionary<AnyHashable, DependencyContainer> = [:]
    
    @Atomic
    private static var storage: [InstanceStorageKey : AnyInstanceStorage] = [:]
    
    @Atomic
    private static var registrationCache: [DependencyLocator.MatchProposal : OrderedSet<RawDependencyRegistration>] = [:]
    
    @Atomic
    private static var subscriptions: [AnyHashable : AnyCancellable] = [:]
    
    private static let graphChangedSubject = PassthroughSubject<Void, Never>()
    
    /// A publisher that fires when the dependeny graph changes
    public static var graphChangedPublisher: AnyPublisher<Void, Never> {
        graphChangedSubject.eraseToAnyPublisher()
    }
    
    // MARK: DependencyContainer Activation - Deactivation
    
    /// Activates the given dependency container
    /// - Parameter container: The dependency container to activate
    public static func activate(
        _ container: DependencyContainer
    ) {
        
        registrationCache.removeAll()
        
        let id = container.id
        subscriptions[id] = container.dependenciesRegistrarChangesPublisher
            .sink { changes in
                dependencyContainer(
                    id: id,
                    changedWith: changes
                )
            }
        
        activeContainers[id] = container
        
        initializeEagerDependencies(
            containerId: id,
            registrar: container.registrar
        )
        
        graphChangedSubject.send()
    }
    
    /// Deactivates the given dependency container
    /// - Parameter container: The dependency container to deactivate
    public static func deactivate(
        _ container: DependencyContainer
    ) {
        
        guard activeContainers.keys.contains(container.id) else {
            return
        }
        
        registrationCache.removeAll()
        activeContainers.removeValue(forKey: container.id)
        
        for dependencyRegistration in container.registrar {
            removeInstanceStorage(for: dependencyRegistration)
        }
        
        graphChangedSubject.send()
    }
    
    private static func dependencyContainer(
        id: DependencyContainer.ID,
        changedWith changes: DependencyContainer.ChangeSet
    ) {
        
        registrationCache.removeAll()
        
        for dependencyRegistration in changes.removedDependencies {
            removeInstanceStorage(for: dependencyRegistration)
        }
        
        initializeEagerDependencies(
            containerId: id,
            registrar: changes.insertedDependencies
        )
        
        graphChangedSubject.send()
    }
    
    private static func initializeEagerDependencies(
        containerId: AnyHashable,
        registrar: DependencyContainer.DependenciesRegistrar
    ) {
        
        for dependencyRegistration in registrar {
            
            guard dependencyRegistration.eagerness == .eager,
                  dependencyRegistration.factory.parameters == .none else {
                continue
            }
            
            do {
                try instantiateDependency(from: dependencyRegistration)
            } catch { /* Ignored Error */ }
        }
    }
    
    private static func removeInstanceStorage(
        for registration: RawDependencyRegistration
    ) {
        let storageKey = InstanceStorageKey(
            instanceType: registration.factory.type,
            instanceLocator: registration.locator
        )
        
        storage.removeValue(forKey: storageKey)
    }
    
    static func dependencyRegistrations(
        matching locator: DependencyLocator.MatchProposal
    ) -> OrderedSet<RawDependencyRegistration> {
        
        if let cachedRegistrations = registrationCache[locator] {
            return cachedRegistrations
        }
        
        let matchingRegistrations = activeContainers.values
            .flatMap({ $0.dependecyRegistrations(matching: locator) })
        
        let distinctMatches = OrderedSet(matchingRegistrations)
        registrationCache[locator] = distinctMatches
        
        return distinctMatches
    }
    
    @discardableResult
    static func instantiateDependency(
        from registration: RawDependencyRegistration,
        _ parameters: DependencyParameters = .none
    ) throws -> Any {
        
        let storageKey = InstanceStorageKey(
            instanceType: registration.factory.type,
            instanceLocator: registration.locator
        )
        
        if let existingInstance = storage[storageKey]?.value {
            return existingInstance
        }
        
        do {
            let instance = try withCycleDetection(registration.locator) {
                try registration.factory.makeInstance(parameters)
            }
            
            let instanceStorage = registration.factory.makeInstanceStorage(
                key: storageKey,
                instance: instance,
                scope: registration.scope
            )
            
            self.storage[storageKey] = instanceStorage
            return instance
        } catch {
            
            if let injectionError = error as? InjectionError {
                throw injectionError
            }
            
            guard let parameterError = error as? DependencyParameters.ParameterError else {
                throw InjectionError.unknown(error)
            }
            
            switch parameterError {
            case .mismatchedCount(let expected):
                
                throw InjectionError.invalidDependencyParameters(
                    registration.locator.dependencyContext(),
                    .mismatchedCount(parameters.count, expected: expected),
                    parameters: parameters.parameterValues
                )
            case .mismatchedType(let index):
                
                throw InjectionError.invalidDependencyParameters(
                    registration.locator.dependencyContext(),
                    .mismatchedType(
                        parameters.parameterType(at: index)?.canonicalValue ?? "Undefined",
                        expected: registration.factory.parameters.parameterType(at: index)?.canonicalValue ?? "Undefined",
                        position: index
                    ),
                    parameters: parameters.parameterValues
                )
            }
        }
    }
    
    @discardableResult
    static func instantiateDependency<T>(
        as dependencyType: T.Type,
        from registration: RawDependencyRegistration,
        _ parameters: DependencyParameters
    ) throws -> T {
        let dependency = try instantiateDependency(from: registration, parameters)
        
        guard let typedDependency = dependency as? T else {
            throw InjectionError.mismatchedDependencyType("\(type(of: dependency))", expected: "\(dependencyType)")
        }
        
        return typedDependency
    }
}
