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
//  DependenciesBuilder.swift
//  
//
//  Created by Athanasios Kefalas on 23/12/21.
//

import Foundation

// MARK: Declarative Building Utils

/// A type that represents a single dependency
public protocol DependencyRepresenting {
    /// Creates and returns the dependency instance represented by this type
    /// - Returns: The dependency instance
    func dependency() -> Dependency
}

/// A type that represents a collection of dependency instances
public protocol DependencyCollectionRepresenting {
    /// Creates and returns an array of dependency instances represented by this type
    /// - Returns: The dependency instances
    func dependencies() -> [Dependency]
}

// MARK: Builder

@resultBuilder
public enum DependenciesBuilder {
    
    public static func buildBlock() -> [Dependency] {
        return []
    }
    
    public static func buildBlock(_ components: [Dependency]...) -> [Dependency] {
        return components.flatMap({ $0 })
    }
    
    public static func buildOptional(_ component: [Dependency]?) -> [Dependency] {
        return component ?? []
    }
    
    public static func buildEither(first component: [Dependency]) -> [Dependency] {
        return component
    }
    
    public static func buildEither(second component: [Dependency]) -> [Dependency] {
        return component
    }
    
    public static func buildExpression(_ expression: Dependency) -> [Dependency] {
        return [expression]
    }
    
    public static func buildExpression<SomeDependencyDefinition: DependencyDefinition>(_ expression: SomeDependencyDefinition) -> [Dependency] {
        return [Dependency(expression)]
    }
    
    public static func buildExpression(_ expression: DependencyRepresenting) -> [Dependency] {
        return [expression.dependency()]
    }
    
    public static func buildExpression(_ expression: DependencyCollectionRepresenting) -> [Dependency] {
        return expression.dependencies()
    }
    
    public static func buildExpression(_ expression: Void) -> [Dependency] {
        return []
    }
    
    public static func buildArray(_ components: [[Dependency]]) -> [Dependency] {
        return components.flatMap({ $0 })
    }
}
