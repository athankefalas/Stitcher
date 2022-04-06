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
//  DependencyStorage.swift
//  
//
//  Created by Athanasios Kefalas on 5/3/22.
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
