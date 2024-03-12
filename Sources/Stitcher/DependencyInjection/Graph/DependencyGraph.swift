//
//  DependencyGraph.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 13/2/24.
//

import Foundation
import OrderedCollections

/// A type that contains all active `DependencyContainers` and can be used to inject dependencies.
public enum DependencyGraph {
    
    @Atomic
    private static var activeContainers: OrderedDictionary<AnyHashable, IndexedDependencyContainer> = [:]
    
    @Atomic
    private static var instanceStorage: [InstanceStorageKey : AnyInstanceStorage] = [:]
    
    @Atomic
    private static var subscriptions: [AnyHashable : AnyCancellable] = [:]
    
    private static let graphChangedSubject = PassthroughSubject<Void, Never>()
    
    /// A publisher that fires when the dependeny graph changes
    public static var graphChangedPublisher: AnyPublisher<Void, Never> {
        graphChangedSubject.eraseToAnyPublisher()
    }
    
    private static let storageCleaner = StorageCleaner {
        releaseUnusedStorage()
    }
    
    // MARK: DependencyContainer Activation - Deactivation
    
    /// Activates the given dependency container
    /// - Parameter container: The dependency container to activate
    public static func activate(
        _ container: DependencyContainer
    ) {
        
        let id = container.id
        subscriptions[id] = container.dependenciesRegistrarChangesPublisher
            .sink { changes in
                dependencyContainer(
                    id: id,
                    changedWith: changes
                )
            }
        
        activeContainers[id] = IndexedDependencyContainer(
            container: container,
            lazyInitializationHandler: initializeLazyDependency(registration:)
        )
        
        graphChangedSubject.send()
        storageCleaner.didInstantiateDependency()
    }
    
    /// Activates the given dependency container
    /// - Parameter container: The dependency container to activate
    public static func activate(
        _ container: DependencyContainer
    ) async {
        
        let id = container.id
        subscriptions[id] = container.dependenciesRegistrarChangesPublisher
            .sink { changes in
                dependencyContainer(
                    id: id,
                    changedWith: changes
                )
            }
        
        activeContainers[id] = await IndexedDependencyContainer(
            container: container,
            lazyInitializationHandler: initializeLazyDependency(registration:)
        )
        
        graphChangedSubject.send()
        storageCleaner.didInstantiateDependency()
    }
    
    /// Deactivates the given dependency container
    /// - Parameter container: The dependency container to deactivate
    public static func deactivate(
        _ container: DependencyContainer
    ) {
        
        guard activeContainers.keys.contains(container.id) else {
            return
        }
        
        subscriptions[container.id]?.cancel()
        subscriptions.removeValue(forKey: container.id)
        
        activeContainers[container.id]?.deactivate()
        activeContainers.removeValue(forKey: container.id)
        
        for dependencyRegistration in container.registrar {
            removeInstanceStorage(for: dependencyRegistration)
        }
        
        graphChangedSubject.send()
    }
    
    /// Deactivates all active dependency containers
    public static func deactivateAll() {
        subscriptions.forEach({ $0.value.cancel() })
        subscriptions.removeAll()
        
        activeContainers.forEach({ $0.value.deactivate() })
        activeContainers.removeAll()
        
        instanceStorage.removeAll()
        graphChangedSubject.send()
    }
    
    public static func releaseUnusedStorage() {
        Task {
            let keys = Set(instanceStorage.keys)
            
            for key in keys {
                guard let storage = instanceStorage[key],
                      storage.isEmpty else {
                    continue
                }
                
                instanceStorage.removeValue(forKey: key)
            }
        }
    }
    
    private static func dependencyContainer(
        id: DependencyContainer.ID,
        changedWith changes: DependencyContainer.ChangeSet
    ) {
                
        for dependencyRegistration in changes.removedDependencies {
            removeInstanceStorage(for: dependencyRegistration)
        }
        
        graphChangedSubject.send()
    }
    
    private static func initializeLazyDependency(
        registration: RawDependencyRegistration
    ) {
        guard registration.canInstantiateEagerly else {
            return
        }
        
        do {
            try instantiateDependency(from: registration)
        } catch { /* Ignored Error */ }
    }
    
    private static func removeInstanceStorage(
        for registration: RawDependencyRegistration
    ) {
        let storageKey = InstanceStorageKey(
            instanceType: registration.factory.type,
            instanceLocator: registration.locator
        )
        
        instanceStorage.removeValue(forKey: storageKey)
    }
    
    static func dependencyRegistrations() -> [RawDependencyRegistration] {
        return activeContainers
            .values
            .map({ $0.container.registrar })
            .reduce(OrderedSet<RawDependencyRegistration>()) { partialResult, containerRegistrar in
                partialResult.union(containerRegistrar)
            }
            .map({ $0 })
    }
    
    static func dependencyRegistrations(
        matching locator: DependencyLocator.MatchProposal
    ) -> OrderedSet<RawDependencyRegistration> {
        
        let matchingRegistrations = activeContainers.values
            .flatMap({ $0.dependecyRegistrations(matching: locator) })
        
        return OrderedSet(matchingRegistrations)
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
        
        if let existingInstance = instanceStorage[storageKey]?.value {
            return existingInstance
        }
        
        defer {
            storageCleaner.didInstantiateDependency()
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
            
            if !instanceStorage.isEmpty {
                self.instanceStorage[storageKey] = instanceStorage
            }
            
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
