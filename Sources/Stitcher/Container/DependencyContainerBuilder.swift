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
//  DependencyContainerBuilder.swift
//  
//
//  Created by Athanasios Kefalas on 6/3/22.
//

import Foundation

// MARK: Declarative Building Utils

/// A type that represents a single dependency container
public protocol DependencyContainerRepresenting {
    /// Creates and returns the dependency container instance represented by this type
    /// - Returns: The dependency container instance
    func dependencyContainer() -> DependencyContainer
}

/// A type that represents a collection of dependency container instances
public protocol DependencyContainerCollectionRepresenting {
    /// Creates and returns an array of dependency container instances represented by this type
    /// - Returns: The dependency container instances
    func dependencyContainers() -> [DependencyContainer]
}

// MARK: Builder

@resultBuilder
public enum DependencyContainerBuilder {
    
    public static func buildBlock() -> [DependencyContainer] {
        return []
    }
    
    public static func buildBlock(_ components: [DependencyContainer]...) -> [DependencyContainer] {
        return components.flatMap({ $0 })
    }
    
    public static func buildOptional(_ component: [DependencyContainer]?) -> [DependencyContainer] {
        return component ?? []
    }
    
    public static func buildEither(first component: [DependencyContainer]) -> [DependencyContainer] {
        return component
    }
    
    public static func buildEither(second component: [DependencyContainer]) -> [DependencyContainer] {
        return component
    }
    
    public static func buildExpression(_ expression: DependencyContainer) -> [DependencyContainer] {
        return [expression]
    }
    
    public static func buildExpression(_ expression: DependencyContainerRepresenting) -> [DependencyContainer] {
        return [expression.dependencyContainer()]
    }
    
    public static func buildExpression(_ expression: DependencyContainerCollectionRepresenting) -> [DependencyContainer] {
        return expression.dependencyContainers()
    }
    
    public static func buildExpression(_ expression: Void) -> [DependencyContainer] {
        return []
    }
    
    public static func buildArray(_ components: [[DependencyContainer]]) -> [DependencyContainer] {
        return components.flatMap({ $0 })
    }
}
