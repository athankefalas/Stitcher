//
//  DependencyEagerness.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 4/2/24.
//

import Foundation

/// The eagerness of a registered dependency. Eager dependencies will be instantiated after being the container they are registered is activated.
public enum DependencyEagerness: Hashable {
    
    /// The dependency will be created when it is first requested.
    case lazy
    
    /// The dependency will be created when the related dependency container is activated.
    /// - Note: If the scope of the dependency is other than `.singleton` the dependency may be immediately deallocated.
    case eager
}
