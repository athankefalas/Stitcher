//
//  ErrorThrowingMergePolicy.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 2/3/22.
//

import Foundation

/// A DependencyContainer merge policy, that throws an error encountering a container merge conflict
public struct ErrorThrowingMergePolicy: DependencyContainerMergePolicy {
    
    public init() {}
    
    public func resolveConflict(between first: (container: DependencyContainer, dependency: Dependency), and second: (container: DependencyContainer, dependency: Dependency)) throws -> DependencyConflictResolution {
        throw DependencyContainerError.containerMergeFailed
    }
}
