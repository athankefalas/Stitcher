//
//  DependencyContainingCollection.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 14/2/24.
//

import Foundation

/// A collection such as an `Array` or `Set` that can contain multiple instances of dependencies
/// - Note: When using a `Set` as a container collection the dependency type must conform to `Hashable`
public protocol DependencyContainingCollection: Collection {
    
    init<S: Sequence>(_ sequence: S) where S.Element == Self.Element
}

extension Array: DependencyContainingCollection {}

extension Set: DependencyContainingCollection {}
