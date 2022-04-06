//
//  DependencyStorage.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 5/3/22.
//

import Foundation

/// A type that can be used to store `Dependency` instances, and retrieve them based on a `DependencyLocatorQuery`.
public protocol DependencyStorage {
    
    /// Add a `Dependency` to the underlying storage
    /// - Parameter dependency: The dependency to store
    mutating func append(_ dependency: Dependency)
    
    /// Remove a `Dependency` from the underlying storage
    /// - Parameter dependency: The dependency to remove
    mutating func remove(_ dependency: Dependency)
    
    /// Returns a boolean value indicating whether the underlying storage contains the given `Dependency`.
    /// - Parameter dependency: The `Dependency` to try and find in the underlying storage
    /// - Returns: A boolean value, indicating whether the dependency is found or not
    func contains(_ dependency: Dependency) -> Bool
    
    /// Finds all dependencies that match the given queries
    /// - Parameter queries: The dependency locator queries to use
    /// - Returns: An array of distinct dependencies that match the given queries
    func find(matching queries: [DependencyLocatorQuery]) -> [Dependency]
}

public extension DependencyStorage {
    
    /// Adds the dependencies of the given sequence to theunderlying storage
    /// - Parameter dependencies: A sequence of dependencies
    @inlinable
    mutating func append<SomeSequence: Sequence>(contentsOf dependencies: SomeSequence) where SomeSequence.Element == Dependency {
        for dependency in dependencies {
            self.append(dependency)
        }
    }
}
