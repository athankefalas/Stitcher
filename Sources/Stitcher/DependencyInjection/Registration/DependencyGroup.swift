//
//  DependencyGroup.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import Foundation

public struct DependencyGroup: DependencyGroupRepresenting {
    
    private var enabled: Bool = true
    private let dependenciesRegistrarProvider: () -> DependencyContainer.DependenciesRegistrar
    
    public init(
        @DependencyRegistrarBuilder dependencies: @escaping () -> DependencyContainer.DependenciesRegistrar
    ) {
        self.dependenciesRegistrarProvider = { dependencies() }
    }
    
    public func dependencies() -> DependencyContainer.DependenciesRegistrar {
        
        guard enabled else {
            return []
        }
        
        return dependenciesRegistrarProvider()
    }
    
    func enabled(_ enabled: Bool) -> DependencyGroup {
        var mutableSelf = self
        mutableSelf.enabled = enabled
        
        return mutableSelf
    }
}
