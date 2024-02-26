//
//  Injected.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/2/24.
//

import Foundation

/// A property wrapper that injects the desired dependency in it's wrapped value when it is first requested.
///
/// If a dependency injection error occurs such as a mismatched type or a missing dependency
/// the property wrapper will cause a `preconditionFailure`. 
///
/// In cases where the error must be
/// handled please consider using the inject functions in the `DependencyGraph` instead
/// to manually inject dependencies.
@propertyWrapper
public struct Injected<Value> {
    
    private class Storage {
        
        private var _value: Value?
        private let provider: @Sendable () throws -> Value
        private let semaphore = DispatchSemaphore(value: 1)
        
        var isLoaded: Bool {
            semaphore.wait()
            
            defer {
                semaphore.signal()
            }
            
            return _value != nil
        }
        
        var value: Value {
            get throws {
                semaphore.wait()
                
                defer {
                    semaphore.signal()
                }
                
                if let _value {
                    return _value
                }
                
                let value = try provider()
                _value = value
                
                return value
            }
        }
        
        init(provider: @Sendable @escaping () throws -> Value) {
            self.provider = provider
        }
        
        func clear() {
            semaphore.wait()
            
            defer {
                semaphore.signal()
            }
            
            _value = nil
        }
    }
    
    private let storage: Storage
    private let unexpectedFailure: (InjectionError) -> Never
    
    public var wrappedValue: Value {
        get {
            do {
                return try storage.value
            } catch {
                unexpectedFailure(.wrapping(error))
            }
        }
    }
    
    init(
        locatorMatch: DependencyLocator.MatchProposal,
        provider: @escaping @Sendable () throws -> Value,
        unexpectedFailure: @escaping (InjectionError) -> Never
    ) {
        self.storage = Storage(provider: provider)
        self.unexpectedFailure = unexpectedFailure
    }
    
    @_disfavoredOverload
    public init(
        file: StaticString = #file,
        line: UInt = #line
    ) {
        self.init(type: Value.self, file: file, line: line)
    }
    
    public init<V>(
        file: StaticString = #file,
        line: UInt = #line
    ) where Value: DependencyContainingCollection, Value.Element == V {
        self.init(type: Value.self, file: file, line: line)
    }
    
    public init<V>(
        file: StaticString = #file,
        line: UInt = #line
    ) where Value == Optional<V> {
        self.init(type: Value.self, file: file, line: line)
    }
    
    @available(*, deprecated, message: "Optional collection dependencies are deprecated. Please use an empty collection instead.")
    public init<C: DependencyContainingCollection>(
        file: StaticString = #file,
        line: UInt = #line
    ) where Value == Optional<C> {
        self.init(collectionType: Value.self, file: file, line: line)
    }
    
    /// Loads the dependency if an instance of it is not present.
    /// - Throws: An injection error.
    public func loadIfNeeded() throws {
        guard !storage.isLoaded else {
            return
        }
        
        try reloadDependency()
    }
    
    /// Removes the previously injected instance and retrieves a new one from the dependency graph.
    /// - Throws: An injection error.
    public func reloadDependency() throws {
        storage.clear()
        let _ = try storage.value
    }
}


