//
//  DependencyContainer.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 2/3/22.
//

import Foundation

/// A type that holds all the dependencies and requirements of a specific scope.
public struct DependencyContainer: DependencyContaining {
    
    /// The container name
    private(set) var name: String
    /// The container priority
    private(set) var priority: Priority
    /// An array of dependencies defined within the container
    public private(set) var dependencies: [Dependency]
    /// An array of dependency requirements defined within the container
    public private(set) var requirements: [Requirement]
    
    /// Creates a new dependency container
    /// - Parameters:
    ///   - name: The name of the container
    ///   - priority: The priority of the container
    ///   - defines: The dependencies of the container. Can be defined declaratively.
    ///   - requires: The dependency requirements of the container. Can be defined declaratively.
    public init(_ name: String,
                priority: Priority = .`required`,
                @DependenciesBuilder defines: () -> [Dependency] = {[]},
                @RequirementsBuilder requires: () -> [Requirement] = {[]}) {
        
        self.name = name
        self.priority = priority
        self.dependencies = defines()
        self.requirements = requires()
        
        checkIntegrity()
    }
    
    /// Creates a new dependency container
    /// - Parameters:
    ///   - name: The name of the container
    ///   - priority: The priority of the container
    ///   - dependencies: The dependencies of the container
    ///   - requirements: The dependency requirements of the container
    public init(name: String,
                priority: Priority = .`required`,
                dependencies: [Dependency],
                requirements: [Requirement]) {
        
        self.name = name
        self.priority = priority
        self.dependencies = dependencies
        self.requirements = requirements
        
        checkIntegrity()
    }
    
    /// Creates a new dependency container
    /// - Parameters:
    ///   - name: The name of the container
    ///   - containers: A list of containers to be merged, and the result assigned to this container
    ///   - mergePolicy: The merge policy to use, by default the `ErrorThrowingMergePolicy` is used.
    public init(name: String,
                merging containers: [DependencyContainer],
                using mergePolicy: DependencyContainerMergePolicy = ErrorThrowingMergePolicy()) throws {
        
        self = try mergePolicy.mergeContainers(containers)
        self.name = name
        
        checkIntegrity()
    }
    
    private mutating func checkIntegrity() {
        self.requirements = requirements.distinct()
        
        if dependencies.containsDuplicates {
            warn("Duplicate dependencies found in container '\(name)'. Conflicts will be resolved by removing duplicates.")
            self.dependencies = dependencies.distinct()
        }
    }
    
    /// Creates a new dependency container, by merging other containers
    /// - Parameters:
    ///   - name: The name of the container
    ///   - mergePolicy: The merge policy to use, by default the `ErrorThrowingMergePolicy` is used.
    ///   - containers: The containers to use in order to compose the new container. Can be defined declaratively.
    /// - Returns: A dependency container that is the result of the merge.
    public static func compose(name: String,
                               mergePolicy: DependencyContainerMergePolicy = ErrorThrowingMergePolicy(),
                               @DependencyContainerBuilder containers: () -> [DependencyContainer]
    ) throws -> DependencyContainer {
        return try .init(name: name, merging: containers(), using: mergePolicy)
    }
}
