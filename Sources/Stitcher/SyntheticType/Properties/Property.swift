//
//  Property.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/22.
//

import Foundation

/// A type that locates a property from the active dependency graph and provides it's underlying implementation.
open class Property<T>: UnsafeSyntheticMember {
    private let propertyImplementation: PropertyImplementation<T>
    
    public init(_ name: String) {
        warnUnsafeSynthticUsage(property: name)
        
        let implementation: PropertyImplementation<T> = try! DependencyGraph.active.injectProperty(named: name)
        self.propertyImplementation = implementation
    }
    
    open func implementation() -> PropertyImplementation<T> {
        return propertyImplementation
    }
}
