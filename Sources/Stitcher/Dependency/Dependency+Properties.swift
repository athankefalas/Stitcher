//
//  Dependency+Properties.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 20/3/22.
//

import Foundation

public extension Dependency {
    
    init<T>(property propertyName: String, get getter: @escaping () -> T, set setter: @escaping (T) -> Void) {
        let property = PropertyImplementation(get: getter, set: setter)
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return property
        }
        
        self.init(.property(propertyName, type: T.self), dependencyInstantiator)
    }
    
    init<T>(property propertyName: String, _ property: PropertyImplementation<T>) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return property
        }
        
        self.init(.property(propertyName, type: T.self), dependencyInstantiator)
    }
}

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Dependency {
    
    init<T>(property propertyName: String, _ binding: Binding<T>) {
        let property = PropertyImplementation {
            binding.wrappedValue
        } set: { newValue in
            binding.wrappedValue = newValue
        }

        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return property
        }
        
        self.init(.property(propertyName, type: T.self), dependencyInstantiator)
    }
    
}

#endif
