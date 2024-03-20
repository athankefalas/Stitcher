//
//  PlainIndexer.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import Foundation
import OrderedCollections

/// A type that can be used to naively index dependencies.
public struct PlainIndexer: Indexing {
    
    public init() {}
    
    public func index(
        dependencies: DependenciesRegistrar,
        coordinator: IndexingCoordinator,
        completion: @escaping (DependencyRegistrarIndex) -> Void
    ) -> any CancellableTask {
        
        return taskIndexing(
            dependencies: dependencies,
            coordinator: coordinator,
            completion: completion
        )
    }
    
    
}
