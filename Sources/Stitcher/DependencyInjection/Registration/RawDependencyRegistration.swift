//
//  RawDependencyRegistration.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/2/24.
//

import Foundation

public struct RawDependencyRegistration: Hashable {
    
    /// An optimized storage box to avoid COW operations for immutable instances of `RawDependencyRegistration`
    private class _StorageBox {
        let locator: DependencyLocator
        let factory: DependencyFactory
        let scope: DependencyScope
        let eagerness: DependencyEagerness
        let canInstantiateEagerly: Bool
        
        let signature: AnyHashable
        
        init(locator: DependencyLocator,
             factory: DependencyFactory,
             scope: DependencyScope,
             eagerness: DependencyEagerness
        ) {
            self.locator = locator
            self.factory = factory
            self.scope = scope
            self.eagerness = eagerness
            self.canInstantiateEagerly = eagerness == .eager && scope != .instance && factory.parameters == .none
            
            var hasher = Hasher()
            hasher.combine(locator)
            hasher.combine(factory)
            hasher.combine(scope)
            hasher.combine(eagerness)
            
            self.signature = hasher.finalize()
        }
    }
    
    private let _storageBox: _StorageBox
    
    var locator: DependencyLocator {
        _storageBox.locator
    }
    
    var factory: DependencyFactory {
        _storageBox.factory
    }
    
    var scope: DependencyScope {
        _storageBox.scope
    }
    
    var eagerness: DependencyEagerness {
        _storageBox.eagerness
    }
    
    var canInstantiateEagerly: Bool {
        return _storageBox.canInstantiateEagerly
    }
    
    public var indexingKeys: Set<IndexingKey> {
        _storageBox.locator.indexingKeys()
    }
    
    init(
        locator: DependencyLocator,
        factory: DependencyFactory,
        scope: DependencyScope,
        eagerness: DependencyEagerness
    ) {
        self._storageBox = _StorageBox(
            locator: locator,
            factory: factory,
            scope: scope,
            eagerness: eagerness
        )
    }
    
    init<T, Trait: DependencyLocatorTrait>(
        _ dependency: Dependency<T, Trait>
    ) {
        self._storageBox = _StorageBox(
            locator: dependency.locator,
            factory: dependency.factory,
            scope: dependency.scope,
            eagerness: dependency.eagerness
        )
    }
    
    init<Representation: DependencyRepresenting>(
        _ representation: Representation
    ) {
        self._storageBox = _StorageBox(
            locator: representation.locator,
            factory: representation.dependencyProvider.factory,
            scope: representation.scope,
            eagerness: representation.eagerness
        )
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_storageBox.signature)
    }
    
    public static func == (lhs: RawDependencyRegistration, rhs: RawDependencyRegistration) -> Bool {
        lhs._storageBox.signature == rhs._storageBox.signature
    }
}
