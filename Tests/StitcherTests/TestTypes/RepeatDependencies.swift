//
//  RepeatDependencies.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import Foundation
@testable import Stitcher

struct RepeatDependencies: DependencyGroupRepresenting {
    
    private let dependenciesRegistrar: DependenciesRegistrar
    
    init<S: Sequence>(
        for sequence: S,
        @DependencyRegistrarBuilder dependencies: @escaping (S.Element) -> DependenciesRegistrar
    ) {
        self.dependenciesRegistrar = DependenciesRegistrar(
            reducing: sequence.map({ dependencies($0) })
        )
    }
    
    func dependencies() -> DependenciesRegistrar {
        dependenciesRegistrar
    }
}
