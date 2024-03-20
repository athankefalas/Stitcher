//
//  Common.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 20/3/24.
//

import Foundation
import OrderedCollections

@inlinable
func taskIndexing<S: Sequence>(
    dependencies: S,
    coordinator: IndexingCoordinator,
    completion: @escaping (DependencyRegistrarIndex) -> Void
) -> AsyncTask
where S.Element == RawDependencyRegistration {
    
    AsyncTask(priority: .high) {
        var dependencyRegistrarIndex = coordinator.emptyIndex()
        
        for registration in dependencies {
            
            guard !AsyncTask.isCancelled else {
                return
            }
            
            for key in registration.indexingKeys {
                var values = dependencyRegistrarIndex[key] ?? OrderedSet()
                values.append(registration)
                
                dependencyRegistrarIndex[key] = values
            }
            
            coordinator.didIndex(dependency: registration)
        }
        
        completion(dependencyRegistrarIndex)
    }
}
