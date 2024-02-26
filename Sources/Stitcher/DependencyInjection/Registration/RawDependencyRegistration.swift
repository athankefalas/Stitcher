//
//  RawDependencyRegistration.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/2/24.
//

import Foundation

public struct RawDependencyRegistration: Hashable {
    
    let locator: DependencyLocator
    let factory: DependencyFactory
    let scope: DependencyScope
    let eagerness: DependencyEagerness
    
    init(
        locator: DependencyLocator,
        factory: DependencyFactory,
        scope: DependencyScope,
        eagerness: DependencyEagerness
    ) {
        self.locator = locator
        self.factory = factory
        self.scope = scope
        self.eagerness = eagerness
    }
    
    init<T, Trait: DependencyLocatorTrait>(
        _ dependency: Dependency<T, Trait>
    ) {
        self.locator = dependency.locator
        self.factory = dependency.factory
        self.scope = dependency.scope
        self.eagerness = dependency.eagerness
    }
}
