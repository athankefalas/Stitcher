//
//  DependencyScope.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 4/2/24.
//

import Foundation
import Combine

/// The scope or lifetime of a dependency instance.
public enum DependencyScope: Hashable {
    /// A new instance of the dependency will be created each time.
    case instance
    
    /// A shared instance of the dependency will be created, and used while there are references to it.
    /// - Note: For value types this is equivalent to the `.instance` scope because they cannot be reference counted.
    case shared
    
    /// A singleton instance of the dependency will be created, and used throughout the lifetime of the application.
    case singleton
    
    /// A singleton instance of the dependency will be created, and used until the given publisher fires.
    case managed(AnyPublisher<Void, Never>)
    
    private var caseIdentifier: Int {
        switch self {
        case .instance:
            return 1
        case .shared:
            return 2
        case .singleton:
            return 3
        case .managed:
            return 4
        }
    }
    
    var invalidationPublisher: AnyPublisher<Void, Never>? {
        switch self {
        case .managed(let publisher):
            return publisher
        default:
            return nil
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(caseIdentifier)
    }
    
    /// Automatically determines an appropriate scope for the given type.
    /// - Parameter type: The type of a dependency.
    /// - Returns: Based of the semantics of the type, a `shared` scope is returned for reference types and `instance` for value types.
    public static func automatic<T>(for type: T.Type) -> DependencyScope {
        return (type is AnyObject.Type) ? .shared : .instance
    }
    
    @_disfavoredOverload
    public static func managed<P: Publisher>(
        by publisher: P
    ) -> Self
    where P.Failure == Never {
        return .managed(
            publisher
                .map({_ in () })
                .eraseToAnyPublisher()
        )
    }
    
    public static func == (lhs: DependencyScope, rhs: DependencyScope) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
