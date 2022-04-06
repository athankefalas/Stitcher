//
//  DependenciesBuilder.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 23/12/21.
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
