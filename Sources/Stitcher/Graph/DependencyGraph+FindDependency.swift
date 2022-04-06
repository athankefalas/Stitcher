//
//  DependencyGraph+FindDependency.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 5/4/22.
//

import Foundation

public extension DependencyGraph {
    /// Finds all dependencies that match the given dependency locator
    /// - Parameter locator: A locator to use as a query to find matching dependencies
    /// - Returns: A list of distinct dependencies that match the query created by the given dependency locator
    func findDependencies(locator: DependencyLocator) -> [Dependency] {
        return storage.find(matching: [.find(locator)])
    }
    
    /// Finds all dependencies that match the given dependency locator query
    /// - Parameter query: A query that can be used as a predicate to search for dependencies
    /// - Returns: A list of distinct dependencies that match the given dependency locator query
    func findDependencies(matching query: DependencyLocatorQuery) -> [Dependency] {
        return storage.find(matching: [query])
    }
    
    /// Finds all dependencies that match the given dependency locator queries
    /// - Parameter queries: An array of queries that can be used as a predicate to search for dependencies
    /// - Returns: A list of distinct dependencies that match the given dependency locator queries
    /// - Note: For a dependency to be considered a match all the given queries must be satisfied by the dependency. In other words,
    /// the queries are concatenated using a logical *AND* operation.
    func findDependencies(matching queries: [DependencyLocatorQuery]) -> [Dependency] {
        return storage.find(matching: queries)
    }
}


extension DependencyGraph {
    
    func findDependencies(named name: String) -> [Dependency] {
        return storage.find(matching: [.findByName(name)])
    }
    
    func findDependencies(typed type: String) -> [Dependency] {
        return storage.find(matching: [.findByType(type)])
    }
    
    func findProperty(named name: String, type: String) -> [Dependency] {
        return storage.find(matching: [
            .findByName(name),
            .findByType(type)
        ])
    }
    
    func findFunction(named name: String, parameters: [String], result: String) -> [Dependency] {
        return storage.find(matching: [
            .findByName(name),
            .findByParameters(parameters),
            .findByResult(result)
        ])
    }
}
