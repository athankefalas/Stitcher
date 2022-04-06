//
//  PropertyImplementation.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/22.
//

import Foundation

/// A type that encapsulates the implementation of a property's getter and setter.
public struct PropertyImplementation<T> {
    private let getter: () -> T
    private let setter: (T) -> Void
    
    /// The value of the encapsulated property
    public var value: T {
        get {
            getter()
        }
        
        set {
            setter(newValue)
        }
    }
    
    /// Creates a new property implementation with the given getter and setter functions
    /// - Parameters:
    ///   - getter: The property's getter function
    ///   - setter: The property's setter function
    public init(get getter: @escaping () -> T, set setter: @escaping (T) -> Void) {
        self.getter = getter
        self.setter = setter
    }
}
