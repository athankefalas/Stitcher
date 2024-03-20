//
//  DependencyGraph.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 13/2/24.
//

import Foundation
import OrderedCollections
import OpenCombine

#if canImport(Combine)
import Combine
#endif

/// A type that contains all active `DependencyContainers` and can be used to inject dependencies.
public enum DependencyGraph {
    
    @Atomic
    private static var initialized = false
    
    @Atomic
    private static var activeContainers: OrderedDictionary<DependencyContainer.ID, IndexedDependencyContainer> = [:]
    
    @Atomic
    private static var instanceStorage: [InstanceStorageKey : AnyInstanceStorage] = [:]
    
    @Atomic
    private static var subscriptions: [DependencyContainer.ID : AnyPipelineCancellable] = [:]
    
    private static let graphChangedSubject = PipelineSubject<Void>()
    
    static var graphChangedPipeline: AnyPipeline<Void> {
        graphChangedSubject.erasedToAnyPipeline()
    }
    
    static let instantionNotificationCenter = InstantionNotificationCenter()
    
    private static let storageCleaner = StorageCleaner {
        releaseUnusedStorage()
    }
    
    private static func prewarm() {
        let initialized = _initialized.lock()
        
        guard !initialized else {
            _initialized.unlock()
            return
        }
        
        _ = instantionNotificationCenter
        _ = storageCleaner
        _initialized.unlock(with: true)
    }
    
    // MARK: DependencyContainer Activation - Deactivation
    
    /// Activates the given dependency container
    /// - Parameter container: The dependency container to activate
    public static func activate(
        _ container: DependencyContainer,
        completion: @escaping () -> Void = {}
    ) {
        prewarm()
        
        let id = container.id
        activeContainers[id] = IndexedDependencyContainer(
            container: container,
            lazyInitializationHandler: initializeLazyDependency(registration:),
            completion: completion
        )
        
        subscriptions[id] = container.dependenciesRegistrarChangesPublisher
            .sink { changes in
                dependencyContainer(
                    id: id,
                    changedWith: changes
                )
            }
        
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
        AsyncTask {
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
        matching locator: DependencyLocator.MatchProposal,
        parameters: DependencyParameters
    ) -> OrderedSet<RawDependencyRegistration> {
        var registrations = OrderedSet<RawDependencyRegistration>(
            minimumCapacity: activeContainers.count
        )
        
        for container in activeContainers.values {
            for registration in container.dependecyRegistrations(matching: locator) {
                guard registration.factory.parameters.isSatisfied(by: parameters) else {
                    continue
                }
                
                registrations.append(registration)
            }
        }
        
        return registrations
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
        
        do {
            let instance: Any
            
            if StitcherConfiguration.runtimeCycleDetectionAvailability.isEnabled {
                instance = try withCycleDetection(registration.locator) {
                    try registration.factory.makeInstance(parameters)
                }
            } else {
                instance = try registration.factory.makeInstance(parameters)
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

// MARK: DependencyGraph + Combine

public extension DependencyGraph {
    
#if canImport(Combine)
    
    /// A publisher that fires when the dependeny graph changes
    @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    static var graphChangedPublisher: Combine.AnyPublisher<Void, Never> {
        guard let provider = graphChangedPipeline.erasedProvider as? Combine.AnyPublisher<Void, Never> else {
            return Empty().eraseToAnyPublisher()
        }
        
        return provider
    }
    

#else
    
    /// A publisher that fires when the dependeny graph changes
    static var graphChangedPublisher: OpenCombine.AnyPublisher<Void, Never> {
        guard let provider = graphChangedPipeline.erasedProvider as? OpenCombine.AnyPublisher<Void, Never> else {
            return Empty().eraseToAnyPublisher()
        }
        
        return provider
    }
    
#endif
}

// MARK: DependencyGraph + Async

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
public extension DependencyGraph {
    
    /// Activates the given dependency container and waits for indexing to complete.
    /// - Parameter container: The dependency container to activate
    static func activate(
        _ container: DependencyContainer
    ) async {
        
        await withUnsafeContinuation { continuation in
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
                lazyInitializationHandler: initializeLazyDependency(registration:),
                completion: {
                    graphChangedSubject.send()                    
                    continuation.resume()
                }
            )
        }
    }
}

