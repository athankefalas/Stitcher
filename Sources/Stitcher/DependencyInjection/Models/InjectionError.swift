//
//  InjectionError.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 13/2/24.
//

import Foundation

/// A type that describes an error that occured while attempting to inject a dependency.
public enum InjectionError: Error, CustomStringConvertible, LocalizedError {
    
    /// The context used to locate the dependency.
    public enum DependencyContext: Equatable, CustomStringConvertible {
        case name(String)
        case type(String)
        case value(AnyHashable)
        
        public var description: String {
            switch self {
            case .name(let name):
                "Name[\(name)]"
            case .type(let type):
                "Type[\(type)]"
            case .value(let value):
                "Value[\(value)]"
            }
        }
    }
    
    /// The context of a parameter used to instantiate a dependency.
    public enum DependencyParameterContext: Equatable, CustomStringConvertible {
        case mismatchedCount(Int, expected: Int)
        case mismatchedType(String, expected: String, position: Int)
        
        public var description: String {
            switch self {
            case .mismatchedCount(let count, let expectedCount):
                return "Expected \(expectedCount) parameter(s) instead of \(count)."
            case .mismatchedType(let type, let expectedType, let position):
                return "Expected parameter at position \(position) to be of type '\(expectedType)' instead of received type '\(type)'."
            }
        }
    }
    
    case unknown(Error)
    case unsupportedOperation
    case mismatchedDependencyType(String, expected: String)
    case missingDependency(DependencyContext)
    case multipleDependencies(DependencyContext)
    case cyclicDependencyReference(DependencyCycleInstantationBacktrace)
    case invalidDependencyParameters(DependencyContext, DependencyParameterContext, parameters: [AnyHashable])
    
    public var description: String {
        switch self {
        case .unknown(let error):
            
            if let injectionError = error as? InjectionError {
                return injectionError.description
            }
            
            let errorMessage = "\(error), \(error.localizedDescription)"
            return "Unknown error. Details: \(errorMessage)"
        case .unsupportedOperation:
            return "This operation is not supported."
        case .mismatchedDependencyType(let type, expected: let expectedType):
            return "Mismatched dependency type, expected '\(expectedType)' instead of '\(type)'."
        case .missingDependency(let dependencyContext):
            return "No dependency could be found for \(dependencyContext)."
        case .multipleDependencies(let dependencyContext):
            return "Multiple dependencies found for \(dependencyContext)."
        case .cyclicDependencyReference(let backtrace):
            return "Dependency cycle detected, \(backtrace)."
        case .invalidDependencyParameters(let dependencyContext, let parameterContext, let parameters):
            let parameters = parameters.map({ "\($0.description)" }).joined(separator: ", ")
            return "Invalid instantiation parameter(s) [\(parameters)] for \(dependencyContext). \(parameterContext)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .mismatchedDependencyType:
            return "Please consider checking that the registered dependency has the required type."
        case .missingDependency(let context):
            return "Please consider registering a dependency that matches \(context) in an active dependency container."
        case .multipleDependencies(let context):
            return "Please consider checking whether multiple dependencies are registered for \(context)."
                 + "Maybe the dependency is registered in multiple active dependency containers."
        case .cyclicDependencyReference:
            return "Please consider using lazy injection to break the cycle, by using the '@Injected' property wrapper."
        case .invalidDependencyParameters(let context, _, let parameters):
            let parameters = parameters.map({ "\($0.description)" }).joined(separator: ", ")
            return "Please consider checking the number and types of the parameters required to instantiate \(context) match the received parameters [\(parameters)]."
        default:
            return nil
        }
    }
    
    static func wrapping(_ error: Error) -> InjectionError {
        if let injectionError = error as? InjectionError {
            return injectionError
        }
        
        return .unknown(error)
    }
}
