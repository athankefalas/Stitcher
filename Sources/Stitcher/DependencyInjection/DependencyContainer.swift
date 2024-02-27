//
//  DependencyContainer.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/2/24.
//

import Foundation
import Combine

#if canImport(Observation)
import Observation
#endif

/// A container that contains the registrations for a group of dependencies.
/// 
/// Containers accept a closure that when invoke provides the container's dependency registrations.
/// In order to evaluate the closure after first initialization, either use `@Observable` objects or
/// manually attach an invalidation publisher by using the `invalidated(tracking: somePublisher)` method
/// on the container. 
///
/// A container *does not* need to be reactivated for the new dependencies defined in the provider closure
/// to be registred in the `DependencyGraph`.
///
/// Containers that are managed manually must be **activated / deactivated** by invoking the appropriate method in the `DependencyGraph`.
/// For example:
/// ``` swift
///  let someContainer = DependencyContainer {
///
///      SomeService()
///
///      Dependency {
///          SomeOtherService()
///      }
///  }
///
///  // Activate container
///  DependencyGraph.activate(someContainer)
///
///  // Deactivate container
///  DependencyGraph.deactivate(someContainer)
///
/// ```
///
public final class DependencyContainer: Identifiable {
    /// A set of raw dependency registrations
    public typealias DependenciesRegistrar = Set<RawDependencyRegistration>
    
    struct ChangeSet {
        let containerId: AnyHashable
        let oldValue: DependenciesRegistrar
        let newValue: DependenciesRegistrar
        
        let insertedDependencies: DependenciesRegistrar
        let removedDependencies: DependenciesRegistrar
        let updatedDependencies: DependenciesRegistrar
        
        init(
            containerId: AnyHashable,
            oldValue: DependenciesRegistrar,
            newValue: DependenciesRegistrar
        ) {
            self.containerId = containerId
            self.oldValue = oldValue
            self.newValue = newValue
            
            self.insertedDependencies = newValue.subtracting(oldValue)
            self.removedDependencies = oldValue.subtracting(newValue)
            self.updatedDependencies = oldValue.intersection(newValue)
        }
    }
    
    private let semaphore = DispatchSemaphore(value: 1)
    private var dependenciesRegistrar: DependenciesRegistrar
    private var dependenciesRegistrarProvider: () -> DependenciesRegistrar
    private let invalidateDependenciesSubject = PassthroughSubject<Void, Never>()
    
    private let dependenciesRegistrarChangesSubject = PassthroughSubject<ChangeSet, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    /// The identity of this dependency container instance.
    public var id: AnyHashable {
        ObjectIdentifier(self)
    }
    
    var registrar: DependenciesRegistrar {
        semaphore.wait()
        let registrar = dependenciesRegistrar
        semaphore.signal()
        
        return registrar
    }
    
    var dependenciesRegistrarChangesPublisher: AnyPublisher<ChangeSet, Never> {
        dependenciesRegistrarChangesSubject.eraseToAnyPublisher()
    }
    
    /// Initializes a dependency container with the given dependency registrations provider closure.
    /// - Parameter dependencies: A closure that when invalidated returns a set of dependency registrations.
    public init(
        @DependencyRegistrarBuilder dependencies: @escaping () -> DependenciesRegistrar
    ) {
        self.dependenciesRegistrar = dependencies()
        self.dependenciesRegistrarProvider = { dependencies() }
        
        postInit()
        startObservingChanges()
    }
    
    /// Initializes a dependency container merging all the given containers.
    /// - Parameter containers: A sequence of child dependency containers to merge.
    public init<SomeSequence: Sequence>(
        merging containers: SomeSequence
    ) where SomeSequence.Element == DependencyContainer {
        let dependencies: () -> DependenciesRegistrar = {
            containers.reduce(DependenciesRegistrar()) { partialResult, container in
                partialResult.union(container.dependenciesRegistrar)
            }
        }
        
        self.dependenciesRegistrar = dependencies()
        self.dependenciesRegistrarProvider = { dependencies() }
        
        postInit()
        subscribeForChanges(in: containers)
    }
    
    deinit {
        subscriptions.forEach({ $0.cancel() })
        subscriptions.removeAll()
        
        dependenciesRegistrar.removeAll()
        dependenciesRegistrarProvider = {[]}
    }
    
    private func postInit() {
        invalidateDependenciesSubject
            .debounce(
                for: 0.001,
                scheduler: DispatchQueue.global(qos: .background)
            )
            .sink { [weak self] _ in
                self?.invalidateDependenciesRegistrar()
            }
            .store(in: &subscriptions)
    }
    
    private func startObservingChanges() {
#if canImport(Observation)
        
        if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
            let undecoratedDependenciesRegistrarProvider = dependenciesRegistrarProvider
            self.dependenciesRegistrarProvider = {
                withObservationTracking {
                    undecoratedDependenciesRegistrarProvider()
                } onChange: { [weak self] in
                    self?.invalidateDependenciesSubject.send()
                }
            }
            
            invalidateDependenciesRegistrar(publishChanges: false)
        }
#endif
    }
    
    private func subscribeForChanges<SomeSequence: Sequence>(
        in containers: SomeSequence
    ) where SomeSequence.Element == DependencyContainer {
        for container in containers {
            _ = invalidated(tracking: container.dependenciesRegistrarChangesPublisher)
        }
    }
    
    func dependecyRegistrations(
        matching proposal: DependencyLocator.MatchProposal
    ) -> [RawDependencyRegistration] {
        
        semaphore.wait()
        let registrar = dependenciesRegistrar
        semaphore.signal()
        
        return registrar.filter({ $0.locator == proposal })
    }
    
    /// Modifies this container so that it dependency registrations provider closure will be invalidated when the given publisher fires.
    /// - Parameter publisher: A publisher that notifies this dependency container that it's dependency registrations have been invalidated.
    /// - Returns: This dependency container instance with an added invalidation observation.
    public func invalidated<SomePublisher: Publisher>(
        tracking publisher: SomePublisher
    ) -> DependencyContainer
    where SomePublisher.Failure == Never {
        
        publisher
            .debounce(for: 0.0, scheduler: DispatchQueue.global(qos: .background))
            .sink { [weak self] _ in
                self?.invalidateDependenciesSubject.send()
            }
            .store(in: &subscriptions)
        
        return self
    }
    
    private func invalidateDependenciesRegistrar(publishChanges: Bool = true) {
        let newValue = dependenciesRegistrarProvider()
        
        semaphore.wait()
        
        let oldValue = dependenciesRegistrar
        self.dependenciesRegistrar = newValue
        
        semaphore.signal()
        
        guard publishChanges else {
            return
        }
        
        dependenciesRegistrarChangesSubject.send(
            ChangeSet(
                containerId: id,
                oldValue: oldValue,
                newValue: newValue
            )
        )
    }
}

public extension DependencyContainer {
    
    /// Initializes a dependency container with no dependencies.
    convenience init() {
        self.init(merging: [])
    }
    
    /// Initializes a dependency container by merging the given sequence of other dependency containers.
    /// - Parameters:
    ///   - first: The first dependency container to merge.
    ///   - second: The second dependency container to merge.
    ///   - others: The rest of the dependency containers to merge.
    ///
    ///   - Note: Any invalidation observations of the given containers will be carried to the resulting dependency container.
    convenience init(merging first: DependencyContainer, _ second: DependencyContainer, _ others: DependencyContainer...) {
        self.init(merging: [first, second] + others)
    }
    
    /// Modifies this container so that it dependency registrations provider closure will be invalidated when the given object changes.
    /// - Parameter object: The observable object to track
    /// - Returns: This dependency container instance with an added invalidation observation.
    func invalidated<SomeObject: ObservableObject>(
        tracking object: SomeObject
    ) -> DependencyContainer {
        return self.invalidated(
            tracking: object.objectWillChange
        )
    }
    
    /// An empty dependency container.
    static var empty: DependencyContainer {
        DependencyContainer()
    }
}
