//
//  Indexing.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import Foundation

/// A type that provides an indexing algorithm used to pre index a dependency container
public protocol Indexing {
    
    /// Indexes the given dependencies.
    /// - Parameters:
    ///   - dependencies: A set of dependencies to index
    ///   - coordinator: A coordinator that can be used to communicate with the dependency container
    ///   - completion: A completion handler that must be called after indexing is complete
    /// - Returns: A cancellable task.
    func index(
        dependencies: DependenciesRegistrar,
        coordinator: IndexingCoordinator,
        completion: @escaping (DependencyRegistrarIndex) -> Void
    ) -> CancellableTask
}
