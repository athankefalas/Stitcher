//
//  AnyDependencyInstantiating.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/3/22.
//

import Foundation

public struct AnyDependencyInstantiating: DependencyInstantiating, Equatable, Hashable {
    public let parameterTypes: [String]
    public let parameterCount: UInt
    
    private var _instantiate: ([Any?]) throws -> Any
    
    public init<SomeDependencyInstantiating: DependencyInstantiating>(erasing instantiator: SomeDependencyInstantiating) {
        self.parameterTypes = instantiator.parameterTypes
        self.parameterCount = instantiator.parameterCount
        self._instantiate = { parameters in
            try instantiator.instantiate(parameters: parameters)
        }
    }
    
    public func instantiate(parameters: [Any?]) throws -> Any {
        return try _instantiate(parameters)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(parameterCount)
        hasher.combine(parameterTypes)
    }
    
    public static func == (lhs: AnyDependencyInstantiating, rhs: AnyDependencyInstantiating) -> Bool {
        return lhs.parameterCount == rhs.parameterCount
            && lhs.parameterTypes == rhs.parameterTypes
    }
}
