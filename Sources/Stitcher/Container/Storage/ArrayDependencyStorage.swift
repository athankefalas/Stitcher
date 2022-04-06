//
//  ArrayDependencyStorage.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 5/3/22.
//

import Foundation

/// A `DependencyStorage` that uses an array as the underlying storage.
public final class ArrayDependencyStorage: DependencyStorage {
    
    private var dependencies: [Dependency] = []
    
    public func append(_ dependency: Dependency) {
        dependencies.append(dependency)
    }
    
    public func remove(_ dependency: Dependency) {
        dependencies.removeAll(where: { $0 == dependency })
    }
    
    public func contains(_ dependency: Dependency) -> Bool {
        return dependencies.contains(dependency)
    }
    
    public func find(matching queries: [DependencyLocatorQuery]) -> [Dependency] {
        
        guard queries.isNotEmpty else {
            return []
        }
        
        var queries = queries
        var globalMatches = Set(findAll(matching: queries.removeFirst()))
        
        for query in queries {
            let matches = Set(findAll(matching: query))
            
            guard globalMatches.isNotEmpty else {
                globalMatches = matches
                continue
            }
            
            globalMatches = globalMatches.intersection(matches)
        }
        
        return Array(globalMatches)
    }
    
    private func findAll(matching query: DependencyLocatorQuery) -> [Dependency] {
        return dependencies
            .filter({ query.isSatisfied(by: $0.locator) })
    }
}
