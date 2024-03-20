//
//  DefaultIndexer.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 16/3/24.
//

import Foundation

struct DefaultIndexer: Indexing {
    
    private let parallelProcessingDependencyThreshold: UInt
    
    public init(parallelProcessingDependencyThreshold: UInt = 1_000) {
        self.parallelProcessingDependencyThreshold = parallelProcessingDependencyThreshold
    }
    
    @inlinable
    public func index(
        dependencies: DependenciesRegistrar,
        coordinator: IndexingCoordinator,
        completion: @escaping (DependencyRegistrarIndex) -> Void
    ) -> any CancellableTask {
        
        let plainIndexer = PlainIndexer()
        let parallelIndexer = ParallelIndexer()
        
        if ParallelIndexer.parallelTaskCount < 2 || dependencies.count < parallelProcessingDependencyThreshold {
            return plainIndexer.index(
                dependencies: dependencies,
                coordinator: coordinator,
                completion: completion
            )
        }
        
        return parallelIndexer.index(
            dependencies: dependencies,
            coordinator: coordinator,
            completion: completion
        )
    }
}
