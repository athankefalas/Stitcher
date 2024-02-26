//
//  DependencyRepresenting.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 13/2/24.
//

import Foundation

/// A protocol that allows conforming types to represent dependency registrations.
public protocol DependencyRepresenting {
    associatedtype T
    associatedtype Trait: DependencyLocatorTrait
    
    /// The dependency registration represented by this type
    var dependency: Dependency<T, Trait> { get }
}
