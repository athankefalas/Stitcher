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
    
    private enum ValueBox {
        case empty
        case loaded(Value)
        
        var isEmpty: Bool {
            switch self {
            case .empty:
                return true
            case .loaded(let value):
                let defaultValueProvider = DefaultValueProvider(type: Value.self)
                
                guard defaultValueProvider.providesDefaultValue else {
                    return true
                }
                
                return defaultValueProvider.isDefault(value: value)
            }
        }
        
        var isLoaded: Bool {
            return !isEmpty
        }
        
        var value: Value? {
            switch self {
            case .empty:
                return nil
            case .loaded(let value):
                return value
            }
        }
    }
    
    private class Storage {
        
        private var _value: ValueBox = .empty
        private let provider: @Sendable () throws -> Value
        private let semaphore = DispatchSemaphore(value: 1)
        private var subscription: AnyPipelineCancellable?
        
        var isLoaded: Bool {
            semaphore.wait()
            
            defer {
                semaphore.signal()
            }
            
            return _value.isLoaded
        }
        
        var value: Value {
            get throws {
                semaphore.wait()
                
                defer {
                    semaphore.signal()
                }
                
                if let loadedValue = _value.value,
                   _value.isLoaded {
                    return loadedValue
                }
                
                let value = try provider()
                _value = .loaded(value)
                
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
            
            _value = .empty
        }
        
        func autoreload(callback: @escaping () -> Void) {
            subscription?.cancel()
            subscription = DependencyGraph.graphChangedPipeline
                .sink { [weak self] in
                    self?.clear()
                    callback()
                }
        }
    }
    
    private let storage: Storage
    private let unexpectedFailure: (InjectionError) -> Never
    private let defaultValueProvider = DefaultValueProvider<Value>()
    
    public var wrappedValue: Value {
        get {
            do {
                return try getStoredValue()
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
    
    private func getStoredValue() throws -> Value {
        do {
            return try storage.value
        } catch {
            return try recoveryValue(for: .wrapping(error))
        }
    }
    
    private func recoveryValue(
        for error: InjectionError
    ) throws -> Value {
        
        guard defaultValueProvider.providesDefaultValue else {
            throw error
        }
        
        switch error {
        case .missingDependency:
            return defaultValueProvider.defaultValue()
        default:
            break
        }
        
        throw error
    }
    
    /// Loads the dependency if an instance of it is not present.
    /// - Throws: An injection error.
    public func loadIfNeeded() throws {
        guard !storage.isLoaded else {
            return
        }
        
        try reload()
    }
    
    /// Removes the previously injected instance and retrieves a new one from the dependency graph.
    /// - Throws: An injection error.
    public func reload() throws {
        storage.clear()
        let _ = try storage.value
    }
    
    /// Enables automatic reloading of the wrapped dependency whenever the graph changes.
    /// - Note: Automatic reloading of injected dependencies can lead to unexpected behaviour. If this function is enabled, any
    /// synchronization of running tasks executed by the dependency during the change must be manually managed.
    public func autoreload() {
        storage.autoreload {
            let _ = wrappedValue
        }
    }
}
