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
//  Dependency.swift
//  
//
//  Created by Athanasios Kefalas on 27/2/22.
//

import Foundation

/// A type that represents a dependency.
public struct Dependency: Equatable, Hashable {
    /// The dependency locator used to identify the dependency
    public let locator: DependencyLocator
    /// The instantiator to use in order to create new instances of the dependency
    public private(set) var instantiator: AnyDependencyInstantiating
    /// The priority of the dependency
    public private(set) var priority: Priority
    
    /// Creates a new dependency.
    /// - Parameters:
    ///   - locator: The locator used to identify the dependency
    ///   - instantiator: The instantiator used to create new instances of the dependency
    public init<SomeDependencyInstantiating: DependencyInstantiating>(
        _ locator: DependencyLocator,
        _ instantiator: SomeDependencyInstantiating) {
            
        self.locator = locator
        self.instantiator = AnyDependencyInstantiating(erasing: instantiator)
        self.priority = .required
    }
    
    /// Creates a new dependency using the given `DependencyDefinition`.
    /// - Parameter dependencyDefinition: A definition of the dependency
    public init<SomeDependencyDefinition: DependencyDefinition>(_ dependencyDefinition: SomeDependencyDefinition) {
        self.locator = dependencyDefinition.locator
        self.instantiator = AnyDependencyInstantiating(erasing: dependencyDefinition.instantiator)
        self.priority = dependencyDefinition.priority
    }
    
    /// Changes the priority of a dependency to the given value
    /// - Parameter priority: The new priority to assign to the dependency
    /// - Returns: A dependency with the same definition and the given priority
    public func priority(_ priority: Priority) -> Dependency {
        var mutableSelf = self
        mutableSelf.priority = priority
        
        return mutableSelf
    }
}
