//
// MIT License
//
// Copyright (c) 2022 Athanasios Kefalas
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//
//  DependencyGraph.swift
//  
//
//  Created by Athanasios Kefalas on 6/3/22.
//

import Foundation

/// A graph of dependencies created from a dependency container, that can be used to find, instantiate and inject dependencies.
public final class DependencyGraph {
    
    /// The currently active dependency graph.
    /// - Note: The dependency graph stored by this property is the most recently activated dependency graph.
    /// All automatic injection supporting types use the value of this property to inject dependencies.
    public static var active: DependencyGraph {
        // This will block the current queue until the semaphore is signaled.
        // If this runs on the main queue, then this will freeze the app until completion.
        // This will only wait when there is a concurrent activation
        // of another DependencyGraph taking place.
        synchronized(with: dispatchSemaphore) {
            activeDependencyGraphStorage
        }
    }
    
    private static let dispatchSemaphore = DispatchSemaphore(value: 1)
    private static var activeDependencyGraphStorage = DependencyGraph()
    
    private(set) var storage: DependencyStorage
    
    private init() {
        self.storage = ArrayDependencyStorage()
    }
    
    private init<SomeDependencyContainer: DependencyContaining>(
        container: SomeDependencyContainer,
        storage: DependencyStorage)
    throws {
        self.storage = storage
        try install(dependencies: container.dependencies, requirements: container.requirements)
    }
    
    private func install(dependencies: [Dependency], requirements: [Requirement]) throws {
        storage.append(contentsOf: dependencies)
        try validateRequirements(requirements)
        
        // This will block the current queue until the semaphore is signaled.
        // If this runs on the main queue, then this will freeze the app until completion.
        // However, because this is an atomic assignment of a reference the wait time
        // for releasing the lock should me minimal.
        synchronized(with: DependencyGraph.dispatchSemaphore) {
            DependencyGraph.activeDependencyGraphStorage = self
        }
    }
    
    private func validateRequirements(_ requirements: [Requirement]) throws {
        guard Stitcher.configuration.validateDependencyGraph else {
            return
        }
        
        for requirement in requirements {
            let matchingDependencies = findDependencies(locator: requirement.locator)
            
            guard matchingDependencies.isNotEmpty else {
                throw DependencyContainerError.unsatisfiableRequirement(requirement)
            }
            
            guard matchingDependencies.count == 1 else {
                continue
            }
            
            if determineDependencyByPriority(in: matchingDependencies) == nil {
                throw DependencyContainerError.ambiguousDependencyDetected(requirement)
            }
        }
    }
    
    // MARK: Static Initializers
    
    /// Creates and immediately activates a new dependency graph
    /// - Parameter container: The container to use to create the dependency graph
    /// - Returns: The activated dependency graph
    /// - Throws: An error if the container's requirements can not be satisfied by the dependencies contained in the created graph.
    /// - Note: The activation of a dependency graph is a destructive operation that completely invalidates the value of the `DependencyGraph.active`
    /// property. If there is a need for multiple active dependency containers, they must be retained in a custom structure and injetion should
    /// be performed manually, by invoking injection functions directly from the desired graph.
    @discardableResult
    public static func activate<SomeContainer: DependencyContaining>(container: SomeContainer) throws -> DependencyGraph {
        return try .init(container: container, storage: Stitcher.configuration.storageFactory())
    }
    
    /// Creates and immediately activates a new dependency graph
    /// - Parameter container: The container to use to create the dependency graph. Can be defined declaratively.
    /// - Returns: The activated dependency graph
    /// - Throws: An error if the container's requirements can not be satisfied by the dependencies contained in the created graph.
    /// - Note: The activation of a dependency graph is a destructive operation that completely invalidates the value of the `DependencyGraph.active`
    /// property. If there is a need for multiple active dependency containers, they must be retained in a custom structure and injetion should
    /// be performed manually, by invoking injection functions directly from the desired graph.
    @discardableResult
    public static func activate(_ container: () throws -> DependencyContainer) throws -> DependencyGraph {
        return try .init(container: try container(), storage: Stitcher.configuration.storageFactory())
    }
}
