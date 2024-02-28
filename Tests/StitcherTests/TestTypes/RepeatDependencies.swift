//
//  RepeatDependencies.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import Foundation
@testable import Stitcher

struct RepeatDependencies: DependencyGroupRepresenting {
    
    private let dependenciesRegistrarProvider: () -> DependencyContainer.DependenciesRegistrar
    
    init<S: Sequence>(
        for sequence: S,
        @DependencyRegistrarBuilder dependencies: @escaping (S.Element) -> DependencyContainer.DependenciesRegistrar
    ) {
        self.dependenciesRegistrarProvider = {
            var registrar = DependencyContainer.DependenciesRegistrar()
            
            for element in sequence {
                let dependencies = dependencies(element)
                registrar.formUnion(dependencies)
            }
            
            return registrar
        }
    }
    
    func dependencies() -> Stitcher.DependencyContainer.DependenciesRegistrar {
        dependenciesRegistrarProvider()
    }
}
