//
//  IndexingCoordinator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import Foundation

/// A type that acts as a coordinator between a dependency indexing implementation and the dependency container.
public struct IndexingCoordinator {
    
    private let semaphore = DispatchSemaphore(value: 1)
    private var _emptyIndex: () -> DependencyRegistrarIndex
    private let _didIndexDependency: (RawDependencyRegistration) -> Void
    
    init(
        emptyIndex: @escaping () -> DependencyRegistrarIndex,
        didIndexDependency: @escaping (RawDependencyRegistration) -> Void
    ) {
        self._emptyIndex = emptyIndex
        self._didIndexDependency = didIndexDependency
    }
    
    /// Creates an empty `DependencyRegistrarIndex` that is preinitialized with an optimized minimum capacity.
    /// - Returns: An empty instance of a dependency registrar index
    public func emptyIndex() -> DependencyRegistrarIndex {
        _emptyIndex()
    }
    
    /// A callback to notify the dependency container that the indexing provider has completed indexing of a specific dependency.
    /// - Parameter dependency: The indexed dependency.
    public func didIndex(dependency: RawDependencyRegistration) {
        _didIndexDependency(dependency)
    }
    
    func withEmptyIndex(by emptyIndex: @escaping () -> DependencyRegistrarIndex) -> Self {
        var mutableSelf = self
        mutableSelf._emptyIndex = emptyIndex
        
        return mutableSelf
    }
}
