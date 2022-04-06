//
//  RequirementsBuilder.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 2/3/22.
//

import Foundation

// MARK: Declarative Building Utils

/// A type that represents a single requirement
public protocol RequirementRepresenting {
    /// Creates and returns the requirement instance represented by this type
    /// - Returns: The requirement instance
    func requirement() -> Requirement
}

/// A type that represents a collection of requirement instances
public protocol RequirementCollectionRepresenting {
    /// Creates and returns an array of requirement instances represented by this type
    /// - Returns: The requirement instances
    func requirements() -> [Requirement]
}

// MARK: Builder

@resultBuilder
public enum RequirementsBuilder {
    
    public static func buildBlock() -> [Requirement] {
        return []
    }
    
    public static func buildBlock(_ components: [Requirement]...) -> [Requirement] {
        return components.flatMap({ $0 })
    }
    
    public static func buildOptional(_ component: [Requirement]?) -> [Requirement] {
        return component ?? []
    }
    
    public static func buildEither(first component: [Requirement]) -> [Requirement] {
        return component
    }
    
    public static func buildEither(second component: [Requirement]) -> [Requirement] {
        return component
    }
    
    public static func buildExpression(_ expression: Requirement) -> [Requirement] {
        return [expression]
    }
    
    public static func buildExpression(_ expression: RequirementRepresenting) -> [Requirement] {
        return [expression.requirement()]
    }
    
    public static func buildExpression(_ expression: RequirementCollectionRepresenting) -> [Requirement] {
        return expression.requirements()
    }
    
    public static func buildExpression(_ expression: Void) -> [Requirement] {
        return []
    }
    
    public static func buildArray(_ components: [[Requirement]]) -> [Requirement] {
        return components.flatMap({ $0 })
    }
}
