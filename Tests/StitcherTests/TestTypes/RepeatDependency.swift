//
//  RepeatDependencies.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import Foundation
@testable import Stitcher

struct RepeatDependency: DependencyGroupRepresenting {
    
    private let dependenciesRegistrar: DependenciesRegistrar
    
    init<S: Sequence, T, Trait: DependencyLocatorTrait>(
        for sequence: S,
        dependency: @escaping (S.Element) -> Dependency<T, Trait>
    ) {
        var dependenciesRegistrar = DependenciesRegistrar(
            minimumCapacity: StitcherConfiguration.approximateDependencyCount
        )
        
        for element in sequence {
            let dependency = dependency(element)
            let registration = RawDependencyRegistration(dependency)
            dependenciesRegistrar.insert(registration)
        }
        
        self.dependenciesRegistrar = dependenciesRegistrar
    }
    
    func dependencies() -> DependenciesRegistrar {
        dependenciesRegistrar
    }
}
