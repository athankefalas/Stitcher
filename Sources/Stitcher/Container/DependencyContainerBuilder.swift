//
//  DependencyContainerBuilder.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 6/3/22.
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
