//
//  DependencyInstantiator.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/22.
//

import Foundation

/// A type that can be used to instantiate a dependency of type `DependencyInstance`.
public struct DependencyInstantiator<DependencyInstance>: DependencyInstantiating {
    public typealias Instantiator = ([Any?]) throws -> DependencyInstance
    
    public let parameterCount: UInt
    public let parameterTypes: [String]
    
    private let instantiator: Instantiator
    
    public init(parameterTypes: [Any.Type], _ instantiator: @escaping Instantiator) {
        self.parameterTypes = parameterTypes.map({ "\($0)" })
        self.parameterCount = UInt(parameterTypes.count)
        self.instantiator = instantiator
    }
    
    public func instantiate(parameters: [Any?]) throws -> DependencyInstance {
        guard parameters.count == parameterCount else {
            throw InstantiationError.incorrectParameterCount
        }
        
        do {
            let instance = try instantiator(parameters)
            
            if let postInstantiationNotified = instance as? PostInstantiationNotified {
                postInstantiationNotified.didInstantiate()
            }
            
            return instance
        } catch {
            
            if let instantiationError = error as? InstantiationError {
                throw instantiationError
            }
            
            throw InstantiationError.instantiationFailed
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(parameterCount)
        hasher.combine(parameterTypes)
    }
    
    public static func == (lhs: DependencyInstantiator, rhs: DependencyInstantiator) -> Bool {
        return lhs.parameterCount == rhs.parameterCount
            && lhs.parameterTypes == rhs.parameterTypes
    }
}
