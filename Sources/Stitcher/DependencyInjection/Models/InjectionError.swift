//
//  InjectionError.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 13/2/24.
//

import Foundation

/// A type that describes an error that occured while attempting to inject a dependency.
public enum InjectionError: Error {
    
    /// The context used to locate the dependency.
    public enum DependencyContext: Equatable {
        case name(String)
        case type(String)
        case value(AnyHashable)
    }
    
    /// The context of a parameter used to instantiate a dependency.
    public enum DependencyParameterContext: Equatable {
        case mismatchedCount(Int, expected: Int)
        case mismatchedType(String, expected: String, position: Int)
    }
    
    case unknown(Error)
    case unsupportedOperation
    case mismatchedDependencyType
    case missingDependency(DependencyContext)
    case multipleDependencies(DependencyContext)
    case cyclicDependencyReference(DependencyContext)
    case invalidDependencyParameters(DependencyContext, DependencyParameterContext, parameters: [AnyHashable])
    
    static func wrapping(_ error: Error) -> InjectionError {
        if let injectionError = error as? InjectionError {
            return injectionError
        }
        
        return .unknown(error)
    }
}