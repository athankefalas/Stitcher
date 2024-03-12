//
//  InstanceStorageFactory.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 5/2/24.
//

import Foundation

enum InstanceStorageFactory {
    
    static func makeInstanceStorage<T>(
        for key: InstanceStorageKey,
        value instance: T,
        scope: DependencyScope
    ) -> AnyInstanceStorage {
        
        let mirror = Mirror(reflecting: instance)
        let isReferenceType = mirror.displayStyle == .class
        
        guard isReferenceType else {
            return _makeInstanceStorage(
                for: key,
                value: instance,
                scope: scope
            )
        }
        
        return _makeReferenceInstanceStorage(
            for: key,
            value: instance as AnyObject,
            scope: scope
        )
    }
    
    private static func _makeInstanceStorage<T>(
        for key: InstanceStorageKey,
        value instance: T,
        scope: DependencyScope
    ) -> AnyInstanceStorage {
        
        switch scope {
        case .instance:
            return NeverInstanceStorage(key: key).erased()
        case .shared:
            return SharedInstanceStorage(key: key, value: instance).erased()
        case .singleton:
            return SingletonInstanceStorage(key: key, value: instance).erased()
        case .managed(let scope):
            return ManagedSingletonInstanceStorage(key: key, value: instance, tracking: scope).erased()
        }
    }
    
    private static func _makeReferenceInstanceStorage<T: AnyObject>(
        for key: InstanceStorageKey,
        value instance: T,
        scope: DependencyScope
    ) -> AnyInstanceStorage {
        
        switch scope {
        case .instance:
            return NeverInstanceStorage(key: key).erased()
        case .shared:
            return SharedInstanceStorage(key: key, value: instance).erased()
        case .singleton:
            return SingletonInstanceStorage(key: key, value: instance).erased()
        case .managed(let scope):
            return ManagedSingletonInstanceStorage(key: key, value: instance, tracking: scope).erased()
        }
    }
}
