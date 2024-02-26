//
//  DependencyFactory.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/2/24.
//

import Foundation

struct DependencyFactory: Hashable {
    
    let type: TypeName
    let parameters: DependencyParameters.Requirement
    let instanceFactory: @Sendable (DependencyParameters) throws -> Any
    let instanceStorageFactory: @Sendable (InstanceStorageKey, Any, DependencyScope) -> AnyInstanceStorage
    
    init(
        type: TypeName,
        parameters: DependencyParameters.Requirement,
        instanceFactory: @Sendable @escaping (DependencyParameters) throws -> Any,
        instanceStorageFactory: @Sendable @escaping (InstanceStorageKey, Any, DependencyScope) -> AnyInstanceStorage
    ) {
        self.type = type
        self.parameters = parameters
        self.instanceFactory = instanceFactory
        self.instanceStorageFactory = instanceStorageFactory
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(parameters)
    }
    
    func makeInstance(
        _ parameters: DependencyParameters = .none
    ) throws -> Any {
        return try instanceFactory(parameters)
    }
    
    func makeInstanceStorage(
        key: InstanceStorageKey,
        instance: Any,
        scope: DependencyScope
    ) -> AnyInstanceStorage {
        return instanceStorageFactory(key, instance, scope)
    }
    
    static func == (lhs: DependencyFactory, rhs: DependencyFactory) -> Bool {
        lhs.type == rhs.type && lhs.parameters == rhs.parameters
    }
}
