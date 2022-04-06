//
//  SyntheticProperty.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 6/3/22.
//

import Foundation

/// A property wrapper that synthesizes a property from the active `DependencyGraph`.
@propertyWrapper
public struct SyntheticProperty<T>: UnsafeSyntheticMember {
    
    private var propertyImplementation: PropertyImplementation<T>
    
    public var wrappedValue: T {
        get {
            return propertyImplementation.value
        }
        
        set {
            propertyImplementation.value = newValue
        }
    }
    
    /// Creates a new property wrapper synthesizing the property
    /// - Parameter property: The name of the property dependencyThe name of the property dependency.
    public init(_ property: String) {
        self.propertyImplementation = Property(property).implementation()
    }
    
    /// Creates a new property wrapper synthesizing the property, and immediately sets the given initial value
    /// - Parameters:
    ///   - wrappedValue: The initial value to apply to the property
    ///   - property: The name of the property dependency
    public init(wrappedValue: T, _ property: String) {
        self.init(property)
        self.wrappedValue = wrappedValue
    }
}
