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
//  DependencyContainer.swift
//  
//
//  Created by Athanasios Kefalas on 2/3/22.
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
