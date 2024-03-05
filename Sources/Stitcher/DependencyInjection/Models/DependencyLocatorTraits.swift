//
//  DependencyLocatorTraits.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/2/24.
//

import Foundation

/// A type used to define traits to a `Dependency` instance based on the locator query used internally.
public protocol DependencyLocatorTrait {}

public struct MaybeTypeLocatedDependency: DependencyLocatorTrait {}

public struct NameLocatedDependency: DependencyLocatorTrait {}
public struct TypeLocatedDependency: DependencyLocatorTrait {}
public struct ValueLocatedDependency: DependencyLocatorTrait {}

