//
//  IndexedDependencyContainer.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 1/3/24.
//

import Foundation
import Combine
import OrderedCollections

/// A wrapper that holds a `DependencyContainer` and indexes it's registrar asynchronously
class IndexedDependencyContainer {
    
    @Atomic
    private(set) var indexing: Bool
    
    @Atomic
    private var updateTime: Date
    
    @Atomic
    private var registrationIndex: Dictionary<AnyHashable, OrderedSet<RawDependencyRegistration>>
    
    let container: DependencyContainer
    let lazyInitializationHandler: (RawDependencyRegistration) -> Void
    
    private let configuration: StitcherConfiguration.Snapshot
    private var subscriptions: Set<AnyCancellable> = []
    
    init(
        container: DependencyContainer,
        lazyInitializationHandler: @escaping (RawDependencyRegistration) -> Void
    ) {
        
        let configuration = StitcherConfiguration.Snapshot()
        
        self.updateTime = Date()
        self.indexing = configuration.isIndexingEnabled
        self.container = container
        self.configuration = configuration
        self.registrationIndex = configuration.isIndexingEnabled ? Dictionary(
            minimumCapacity: max(configuration.approximateDependencyCount, container.registrar.count)
        ) : [:]
        
        self.lazyInitializationHandler = lazyInitializationHandler
        
        postInit()
    }
    
    init(
        container: DependencyContainer,
        lazyInitializationHandler: @escaping (RawDependencyRegistration) -> Void
    ) async {
        
        let configuration = StitcherConfiguration.Snapshot()
        
        self.updateTime = Date()
        self.indexing = configuration.isIndexingEnabled
        self.container = container
        self.configuration = configuration
        self.registrationIndex = configuration.isIndexingEnabled ? Dictionary(
            minimumCapacity: max(configuration.approximateDependencyCount, container.registrar.count)
        ) : [:]
        
        self.lazyInitializationHandler = lazyInitializationHandler
        
        await postInit()
    }
    
    deinit {
        deactivate()
    }
    
    private func postInit() {
        Task(priority: .high) {
            await postInit()
        }
    }
    
    private func postInit() async {
        
        guard configuration.isIndexingEnabled else {
            return initializeEagerDependenciesWithoutIndexing()
        }
        
        observeContainerChanges()
        await startIndexing(at: updateTime)
    }
    
    private func initializeEagerDependenciesWithoutIndexing() {
        let registrar = container.registrar
        
        for registration in registrar {
            guard registration.canInstantiateEagerly else {
                continue
            }
            
            self.lazyInitializationHandler(registration)
        }
    }
    
    private func observeContainerChanges() {
        container.dependenciesRegistrarChangesPublisher
            .debounce(for: 0.0, scheduler: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] changeSet in
                self?.containerDidChange(changeSet)
            }
            .store(in: &subscriptions)
    }
    
    private func startIndexing(at time: Date) async {
        indexing = true
        
        defer {
            indexing = false
        }
        
        registrationIndex.removeAll(keepingCapacity: true)
        let registrar = container.registrar
        var registrationIndex = registrationIndex
        
        for registration in registrar {
            
            if updateTime > time {
                return
            }
            
            for key in registration.locator.indexingKeys() {
                var values = registrationIndex[key] ?? OrderedSet()
                values.append(registration)
                
                registrationIndex[key] = values
            }
            
            guard registration.canInstantiateEagerly else {
                continue
            }
            
            self.lazyInitializationHandler(registration)
        }
        
        self.registrationIndex = registrationIndex
    }
    
    private func containerDidChange(_ changes: DependencyContainer.ChangeSet) {
        let reindex = indexing
        updateTime = Date()
        
        let shouldAttemptIncrementalReindexing = !reindex && !registrationIndex.isEmpty
        
        guard shouldAttemptIncrementalReindexing else {
            Task(priority: .high) {
                await startIndexing(at: updateTime)
            }
            
            return
        }
        
        Task(priority: .high) {
            await indexIncrementally(at: updateTime, changes: changes)
        }
    }
    
    private func indexIncrementally(at time: Date, changes: DependencyContainer.ChangeSet) async {
        indexing = true
        
        defer {
            indexing = false
        }
        
        var registrationIndex = registrationIndex
        
        for removed in changes.removedDependencies {
            
            if updateTime > time {
                break
            }
            
            for key in removed.locator.indexingKeys() {
                guard var values = registrationIndex[key] else {
                    continue
                }
                
                values.remove(removed)
                registrationIndex[key] = values
            }
        }
        
        if updateTime > time {
            self.registrationIndex.removeAll(keepingCapacity: true)
            return
        }
        
        for registration in changes.insertedDependencies {
            
            if updateTime > time {
                break
            }
            
            for key in registration.locator.indexingKeys() {
                var values = registrationIndex[key] ?? OrderedSet()
                
                values.append(registration)
                registrationIndex[key] = values
            }
            
            guard registration.canInstantiateEagerly else {
                continue
            }
            
            self.lazyInitializationHandler(registration)
        }
        
        if updateTime > time {
            self.registrationIndex.removeAll(keepingCapacity: true)
            return
        }
        
        self.registrationIndex = registrationIndex
    }
    
    /// Cancels any pending indexing operations and prepares the container for deactivation
    func deactivate() {
        updateTime = Date()
        subscriptions.forEach({ $0.cancel() })
        subscriptions.removeAll()
        registrationIndex.removeAll()
    }
    
    // MARK: Find Registrations
    
    /// Finds the dependency registrations for a given match proposal.
    /// - Complexity: When the container is indexed is on average *O(1)*. If the container is not fully indexed
    ///  yet, the complexity is *O(n)*, where n is the size of the container registrar.
    /// - Parameter proposal: The proposed locator to match.
    /// - Returns: A set of matching dependency registrations.
    func dependecyRegistrations(
        matching proposal: DependencyLocator.MatchProposal
    ) -> OrderedSet<RawDependencyRegistration> {
        
        guard configuration.isIndexingEnabled,
              !indexing, !registrationIndex.isEmpty else {
            return findDependecyRegistrations(matching: proposal)
        }
        
        return findIndexedDependecyRegistrations(matching: proposal)
    }
    
    private func findDependecyRegistrations(
        matching proposal: DependencyLocator.MatchProposal
    ) -> OrderedSet<RawDependencyRegistration> {
        
        return OrderedSet(
            container.dependecyRegistrations(
                matching: proposal
            )
        )
    }
    
    private func findIndexedDependecyRegistrations(
        matching proposal: DependencyLocator.MatchProposal
    ) -> OrderedSet<RawDependencyRegistration> {
        
        return registrationIndex[proposal.indexingKey()] ?? []
    }
}
