//
//  DependencyContaining.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/3/22.
//

import Foundation

/// A type the represents a container of dependencies and requirements.
public protocol DependencyContaining {
    /// An array of dependencies defined within the container
    var dependencies: [Dependency] { get }
    /// An array of dependency requirements defined within the container
    var requirements: [Requirement] { get }
}
