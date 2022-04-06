//
//  Requirement.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 2/3/22.
//

import Foundation

/// A type that defines a requirement of a specific dependency
public struct Requirement: Hashable {
    /// The locator of the required dependency
    let locator: DependencyLocator
    
    /// Creates a new requirement of a specific dependency, that is identified by the given dependency locator.
    /// - Parameter locator: The locator of the required dependency
    public init(_ locator: DependencyLocator) {
        self.locator = locator
    }
}
