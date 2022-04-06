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
//  RequirementsBuilder.swift
//  
//
//  Created by Athanasios Kefalas on 2/3/22.
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
