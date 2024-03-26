//
//  GeneratedDependencyRegistration.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 26/3/24.
//

import Foundation

public struct GeneratedDependencyRegistration<T>: DependencyRepresenting {
    
    /// The locator used to query the represented dependency in a dependency container.
    public let locator: DependencyLocator
    
    /// The scope of the represented dependency.
    public let scope: DependencyScope
    
    /// The eagerness of the represented dependency.
    public let eagerness: DependencyEagerness
    
    /// A provider type that is used to instantiate the represented dependency.
    public let dependencyProvider: DependencyFactory.Provider<T>
    
    public init<each Parameter: Hashable>(
        locator: DependencyLocator,
        scope: DependencyScope,
        eagerness: DependencyEagerness,
        dependencyProvider: @Sendable @escaping (repeat each Parameter) throws -> T
    ) {
        self.locator = locator
        self.scope = scope
        self.eagerness = eagerness
        self.dependencyProvider = DependencyFactory.Provider(function: dependencyProvider)
    }
}
