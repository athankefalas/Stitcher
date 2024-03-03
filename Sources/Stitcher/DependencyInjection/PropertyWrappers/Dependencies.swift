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
/// - Note: This property wrapper should normally be used near an application's or feature's
/// entry point, such as the App struct or UIApplicationDelegate, and tie the defined dependencies
/// to the lifetime of the app. However, the underlying container's lifetime can also be manually managed
/// by using the `DependencyGraph` activate and deactivate methods.
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
            
            container = newValue
            DependencyGraph.activate(container)
        }
    }
    
    /// Sets the managed dependency container waiting for activation **and** indexing.
    /// - Parameter newValue: The new dependency container to activate.
    public mutating func setContainer(_ newValue: DependencyContainer) async {
        guard newValue !== container else {
            return
        }
        
        DependencyGraph.deactivate(container)
        container = newValue
        
        await DependencyGraph.activate(container)
    }
    
    public init(wrappedValue: DependencyContainer = .empty) {
        self.container = wrappedValue
        DependencyGraph.activate(wrappedValue)
    }
}
