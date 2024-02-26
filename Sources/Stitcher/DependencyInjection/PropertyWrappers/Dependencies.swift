//
//  Dependencies.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 19/2/24.
//

import Foundation

/// A property wrapper that is used to register dependencies.
/// 
/// The dependency container is managed by the property wrapper and is activated when a new container is set.
/// Setting an `.empty` dependency container will remove all previously registered dependencies.
///
/// Defining a container with the `@Dependencies` property wrapper can be done as follows:
/// ``` swift
/// @Dependencies
/// var container = DependencyContainer {
///
///     SomeService()
///
///     Dependency {
///        SomeOtherService()
///     }
/// }
/// ```
///
/// - Note: This property wrapper should normally be used in your App struct or UIApplicationDelegate,
/// which ties the defined dependencies to the lifetime of the app. However, the underlying container's lifetime
/// can also be manually managed by using the `DependencyGraph` activate and deactivate methods.
@propertyWrapper
public struct Dependencies {
    
    private var container: DependencyContainer
    
    public var wrappedValue: DependencyContainer {
        get {
            container
        }
        
        set {
            guard newValue !== container else {
                return
            }
            
            DependencyGraph.deactivate(container)
            
            defer {
                DependencyGraph.activate(container)
            }
            
            container = newValue
        }
    }
    
    public init(wrappedValue: DependencyContainer = .empty) {
        self.container = wrappedValue
        DependencyGraph.activate(wrappedValue)
    }
}
