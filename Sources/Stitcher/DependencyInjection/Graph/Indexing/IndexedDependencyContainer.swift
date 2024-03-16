//
//  IndexedDependencyContainer.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 1/3/24.
//

import Foundation
import OrderedCollections

/// A wrapper that holds a `DependencyContainer` and indexes it's registrar asynchronously
class IndexedDependencyContainer {
    
    @Atomic
    private(set) var indexingTask: CancellableTask?
    
    @Atomic
    private var registrationIndex: DependencyRegistrarIndex
    
    let container: DependencyContainer
    let lazyInitializationHandler: (RawDependencyRegistration) -> Void
    
    var indexing: Bool {
        indexingTask != nil
    }
    
    private let configuration: StitcherConfiguration.Snapshot
    private var subscriptions: Set<AnyPipelineCancellable> = []
    
    init(
        container: DependencyContainer,
        lazyInitializationHandler: @escaping (RawDependencyRegistration) -> Void,
        completion: @escaping () -> Void
    ) {
        
        let configuration = StitcherConfiguration.Snapshot()
        
        self.container = container
        self.configuration = configuration
        self.registrationIndex = configuration.isIndexingEnabled ? DependencyRegistrarIndex(
            minimumCapacity: max(configuration.approximateDependencyCount, container.registrar.count)
        ) : [:]
        
        self.lazyInitializationHandler = lazyInitializationHandler
        
        postInit(completion: completion)
    }
    
    deinit {
        deactivate()
    }
    
    private func postInit(completion: @escaping () -> Void) {
        
        guard configuration.isIndexingEnabled else {
            return initializeEagerDependenciesWithoutIndexing(completion: completion)
        }
        
        self.observeContainerChanges()
        self.startIndexing(completion: completion)
    }
    
    private func initializeEagerDependenciesWithoutIndexing(completion: @escaping () -> Void) {
        let registrar = container.registrar
        
        for registration in registrar {
            guard registration.canInstantiateEagerly else {
                continue
            }
            
            self.lazyInitializationHandler(registration)
        }
        
        completion()
    }
    
    private func observeContainerChanges() {
        container.dependenciesRegistrarChangesPublisher
            .erasedToAnyPipeline()
            .debounce(for: 0.0, schedulerQos: .background)
            .sink { [weak self] changeSet in
                self?.containerDidChange(changeSet)
            }
            .store(in: &subscriptions)
    }
    
    private func startIndexing(completion: @escaping () -> Void = {}) {
        registrationIndex.removeAll(keepingCapacity: true)
        let emptyRegistrationIndex = registrationIndex
        let coordinator = IndexingCoordinator {
            emptyRegistrationIndex
        } didIndexDependency: { [weak self] registration in
            guard registration.canInstantiateEagerly else {
                return
            }
            
            self?.lazyInitializationHandler(registration)
        }
        
        self.indexingTask = configuration.indexer.index(
            dependencies: container.registrar,
            coordinator: coordinator
        ) { [weak self] registrationIndex in
            self?.registrationIndex = registrationIndex
            self?.indexingTask = nil
            completion()
        }
    }
    
    private func containerDidChange(_ changes: DependencyContainer.ChangeSet) {
        let reindex = indexing
        let shouldAttemptIncrementalReindexing = !reindex && !registrationIndex.isEmpty
        
        guard shouldAttemptIncrementalReindexing else {
            cancelIndexing()
            startIndexing()
            return
        }
        
        indexingTask = AsyncTask(priority: .high) { [weak self] in
            guard let self = self else { return }
            self.indexIncrementally(changes: changes)
        }
    }
    
    private func indexIncrementally(changes: DependencyContainer.ChangeSet) {
        var registrationIndex = registrationIndex
        
        for removed in changes.removedDependencies {
            
            if AsyncTask.isCancelled {
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
        
        if AsyncTask.isCancelled {
            self.registrationIndex.removeAll(keepingCapacity: true)
            return
        }
        
        self.registrationIndex = registrationIndex
        let coordinator = IndexingCoordinator {
            DependencyRegistrarIndex(minimumCapacity: changes.insertedDependencies.count)
        } didIndexDependency: { [weak self] registration in
            guard registration.canInstantiateEagerly else {
                return
            }
            
            self?.lazyInitializationHandler(registration)
        }
        
        self.indexingTask = configuration.indexer.index(
            dependencies: changes.insertedDependencies,
            coordinator: coordinator
        ) { [weak self] registrationIndex in
            self?.registrationIndex = registrationIndex
            self?.indexingTask = nil
        }
    }
    
    private func cancelIndexing() {
        indexingTask?.cancel()
        indexingTask = nil
    }
    
    /// Cancels any pending indexing operations and prepares the container for deactivation
    @inlinable func deactivate() {
        cancelIndexing()
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
    @inlinable func dependecyRegistrations(
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
        
        return registrationIndex[proposal.indexingKey] ?? []
    }
}
