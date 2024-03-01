//
//  DependencyGroup.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import Foundation

/// A type that represents a group of dependency registrations.
/// The dependency group must be added to a DependencyContainer.
///
/// - Note: A dependency group does not directly observe changes for invalidating the dependencies it contains.
/// When added to a `DependencyContainer` the container must be wired to observe for changes instead.
public struct DependencyGroup: DependencyGroupRepresenting {
    
    private var enabled: Bool = true
    private let dependenciesRegistrarProvider: () -> DependenciesRegistrar
    
    public init(
        @DependencyRegistrarBuilder dependencies: @escaping () -> DependenciesRegistrar
    ) {
        self.dependenciesRegistrarProvider = { dependencies() }
    }
    
    func dependencies() -> DependenciesRegistrar {
        
        guard enabled else {
            return []
        }
        
        return dependenciesRegistrarProvider()
    }
    
    /// Enables or disables the dependency group.
    ///
    /// A disabled dependency group's dependencies will not be added to the `DependencyGraph`.
    /// - Parameter enabled: The enabled state of the group.
    /// - Returns: A modified dependency group
    public func enabled(_ enabled: Bool) -> DependencyGroup {
        var mutableSelf = self
        mutableSelf.enabled = enabled
        
        return mutableSelf
    }
}
