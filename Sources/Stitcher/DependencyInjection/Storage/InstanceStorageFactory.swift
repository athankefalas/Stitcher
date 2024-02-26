//
//  InstanceStorageFactory.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 5/2/24.
//

import Foundation

enum InstanceStorageFactory {
    
    @_disfavoredOverload
    static func makeInstanceStorage<T>(
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
        case .tracking(let publisher):
            return TrackingSharedInstanceStorage(key: key, value: instance, tracking: publisher).erased()
        }
    }
    
    static func makeInstanceStorage<T: AnyObject>(
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
        case .tracking(let publisher):
            return TrackingSharedInstanceStorage(key: key, value: instance, tracking: publisher).erased()
        }
    }
}
