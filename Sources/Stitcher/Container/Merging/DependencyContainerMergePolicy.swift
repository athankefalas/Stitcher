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
//  DependencyContainerMergePolicy.swift
//
//
//  Created by Athanasios Kefalas on 2/3/22.
//

import Foundation

/// A type that dictates the way to resolve dependency definition conflicts
public enum DependencyConflictResolution {
    case useNeither
    case use(Dependency)
    case useBoth(Dependency, Dependency)
}

/// A type that is used to merge two `DependencyContainer` instances.
public protocol DependencyContainerMergePolicy {
    
    /// Merges two `DependencyContainer` instances.
    /// - Parameters:
    ///   - lhsContainer: The first `DependencyContainer` instance
    ///   - rhsContainer: The second `DependencyContainer` instance
    /// - Returns: A merged `DependencyContainer` instance containing the dependencies and requirements of both dependency containers used as inputs
    /// - Throws: A container merge failed error if the containers could not be merged
    func mergeContainers(_ lhsContainer: DependencyContainer, _ rhsContainer: DependencyContainer) throws -> DependencyContainer
    
    /// Resolves a conflict between two dependencies defined in the containers being merged
    /// - Parameters:
    ///   - first: A tuple of the `DependencyContainer` and the `Dependency` that are in conflict with the second parameter
    ///   - second: A tuple of the `DependencyContainer` and the `Dependency` that are in conflict with the first parameter
    /// - Returns: A case of the `DependencyConflictResolution` enum that instructs the merge policy on how to resolve the conflict
    /// - Throws: An error that marks the conflict as not resolvable, and the container merge is aborted with an error
    func resolveConflict(between first: (container: DependencyContainer, dependency: Dependency),
                         and second: (container: DependencyContainer, dependency: Dependency)) throws -> DependencyConflictResolution
}

public extension DependencyContainerMergePolicy {
    
    /// Merges an array of `DependencyContainer` instances in sequence
    /// - Parameter containers: The containers to merge
    /// - Returns: A `DependencyContainer` instance that is the result of the merge
    /// - Throws: A containerMergeFailed error if the merge failed
    func mergeContainers(_ containers: [DependencyContainer]) throws -> DependencyContainer {
        
        guard containers.isNotEmpty else {
            return DependencyContainer(name: "Container_EMPTY",
                                       priority: .required,
                                       dependencies: [],
                                       requirements: [])
        }
        
        var containers = containers
        let firstContainer = containers.removeFirst()
        
        return try containers.reduce(firstContainer) { accumulator, container in
            try mergeContainers(accumulator, container)
        }
    }
    
    func mergeContainers(_ lhsContainer: DependencyContainer, _ rhsContainer: DependencyContainer) throws -> DependencyContainer {
        let lhs = lhsContainer.dependencies
        let rhs = rhsContainer.dependencies
        let lhsDependencies = Set(lhs)
        let rhsDependencies = Set(rhs)
        
        if lhsDependencies.isDisjoint(with: rhsDependencies) {
            let mergedName = "Container_\(lhsContainer.name)+\(rhsContainer.name)"
            let mergedPriority = max(lhsContainer.priority, rhsContainer.priority)
            let mergedDependencies = lhs + rhs
            let mergedRequirements = lhsContainer.requirements + rhsContainer.requirements
            
            return DependencyContainer(name: mergedName,
                                       priority: mergedPriority,
                                       dependencies: mergedDependencies,
                                       requirements: mergedRequirements)
        }
        
        var mergedDependencies = Array(lhsDependencies.symmetricDifference(rhsDependencies))
        let conflicts = lhsDependencies.union(rhsDependencies)
        
        for conflict in conflicts {
            
            guard let lhsDependency = lhs.first(where: { $0.hashValue == conflict.hashValue }),
                  let rhsDependency = rhs.first(where: { $0.hashValue == conflict.hashValue }) else {
                      assertionFailure("SanityCheckFailure: Dependencies are expecte to be in the array they were retrived from.")
                      throw DependencyContainerError.containerMergeFailed
                  }
            
            let conflictResolution: DependencyConflictResolution
            
            do {
                
                guard lhsContainer.priority == rhsContainer.priority else {
                    let resolvedDependency = lhsContainer.priority > rhsContainer.priority ? lhsDependency : rhsDependency
                    mergedDependencies.append(resolvedDependency)
                    
                    continue
                }
                
                conflictResolution = try resolveConflict(between: (lhsContainer, lhsDependency), and: (rhsContainer, rhsDependency))
            } catch _ {
                error("Failed to resolve dependency conflicts between container '\(lhsContainer.name)' and '\(rhsContainer.name)'.")
                throw DependencyContainerError.containerMergeFailed
            }
            
            switch conflictResolution {
            case .useNeither:
                continue
            case .use(let dependency):
                mergedDependencies.append(dependency)
            case .useBoth(let firstDependency, let secondDependency):
                
                guard firstDependency.hashValue != secondDependency.hashValue else {
                    error("Dependency conflict was resolved using 'useBoth' directive but the given dependencies do not have altered priorities.")
                    error("Failed to resolve dependency conflicts between container '\(lhsContainer.name)' and '\(rhsContainer.name)'.")
                    throw DependencyContainerError.containerMergeFailed
                }
                
                mergedDependencies.append(firstDependency)
                mergedDependencies.append(secondDependency)
            }
        }
        
        let mergedName = "Container_\(lhsContainer.name)+\(rhsContainer.name)"
        let mergedPriority = max(lhsContainer.priority, rhsContainer.priority)
        let mergedRequirements = lhsContainer.requirements + rhsContainer.requirements
        
        return DependencyContainer(name: mergedName,
                                   priority: mergedPriority,
                                   dependencies: mergedDependencies,
                                   requirements: mergedRequirements)
    }
}
