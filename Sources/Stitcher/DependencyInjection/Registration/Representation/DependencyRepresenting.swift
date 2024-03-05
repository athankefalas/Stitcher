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
    
    /// The locator used to query the represented dependency in a dependency container.
    var locator: DependencyLocator { get }
    
    /// The scope of the represented dependency.
    var scope: DependencyScope { get }
    
    /// The eagerness of the represented dependency.
    var eagerness: DependencyEagerness { get }
    
    /// A provider type that is used to instantiate the represented dependency.
    var dependencyProvider: DependencyFactory.Provider<T> { get }
}

public extension DependencyRepresenting {
    
    var scope: DependencyScope {
        .automatic(for: T.self)
    }
    
    var eagerness: DependencyEagerness {
        .lazy
    }
    
    var locator: DependencyLocator {
        .type(T.self)
    }
}
