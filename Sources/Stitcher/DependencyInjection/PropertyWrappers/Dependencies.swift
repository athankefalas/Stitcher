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
    
    private class Storage {
        
        var container: DependencyContainer
        
        init(container: DependencyContainer) {
            self.container = container
        }
        
        deinit {
            DependencyGraph.deactivate(container)
        }
    }
    
    private var storage: Storage
    
    public var wrappedValue: DependencyContainer {
        get {
            storage.container
        }
        
        set {
            guard newValue !== storage.container else {
                return
            }
            
            DependencyGraph.deactivate(storage.container)
            
            storage.container = newValue
            DependencyGraph.activate(storage.container)
        }
    }
    
    /// Sets the managed dependency container waiting for activation **and** indexing.
    /// - Parameters:
    ///   - newValue: The new dependency container to activate.
    ///   - completion: The completion closure to call when the container is activated and indexed.
    public mutating func setContainer(
        _ newValue: DependencyContainer,
        completion: @escaping () -> Void
    ) {
        guard newValue !== storage.container else {
            return
        }
        
        DependencyGraph.deactivate(storage.container)
        storage.container = newValue
        
        DependencyGraph.activate(
            storage.container,
            completion: completion
        )
    }
    
    public init(wrappedValue: DependencyContainer = .empty) {
        self.storage = Storage(container: wrappedValue)
        DependencyGraph.activate(wrappedValue)
    }
}

// MARK: Dependencies + Concurrency

public extension Dependencies {
    
    /// Sets the managed dependency container waiting for activation **and** indexing.
    /// - Parameter newValue: The new dependency container to activate.
    @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    mutating func setContainer(_ newValue: DependencyContainer) async {
        guard newValue !== storage.container else {
            return
        }
        
        DependencyGraph.deactivate(storage.container)
        storage.container = newValue
        
        await DependencyGraph.activate(storage.container)
    }
}
