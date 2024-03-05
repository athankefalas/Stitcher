//
//  Injected+Init.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 17/2/24.
//

import Foundation

// MARK: By Name

public extension Injected {
    
    /// Injects a dependency registered by the given name.
    /// - Parameters:
    ///   - name: The name of the dependency.
    ///   - parameters: The parameters used to instantiate the dependency.
    init<each Parameter: Hashable>(
        name: String,
        _ parameters: repeat each Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        self.init(locatorMatch: .init(byName: name)) {
            try DependencyGraph.inject(
                byName: name,
                parameters: repeat each parameters
            )
        } unexpectedFailure: {
            fatal($0, file: file, line: line)
        }
    }
    
    /// Injects a dependency registered by the given name.
    /// - Parameters:
    ///   - name: A type that can be converted to the name of the dependency.
    ///   - parameters: The parameters used to instantiate the dependency.
    @_disfavoredOverload
    init<Name: CustomStringConvertible, each Parameter: Hashable>(
        name: Name,
        _ parameters: repeat each Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let name = name.description
        self.init(locatorMatch: .init(byName: name)) {
            try DependencyGraph.inject(
                byName: name,
                parameters: repeat each parameters
            )
        } unexpectedFailure: {
            fatal($0, file: file, line: line)
        }
    }
    
    /// Injects a dependency registered by the given name.
    /// - Parameters:
    ///   - name: A type that represents the name of the dependency.
    ///   - parameters: The parameters used to instantiate the dependency.
    init<Name: RawRepresentable, each Parameter: Hashable>(
        name: Name,
        _ parameters: repeat each Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) where Name.RawValue == String {
        
        let name = name.rawValue
        self.init(locatorMatch: .init(byName: name)) {
            try DependencyGraph.inject(
                byName: name,
                parameters: repeat each parameters
            )
        } unexpectedFailure: {
            fatal($0, file: file, line: line)
        }
    }
}



// MARK: By Type

public extension Injected {
    
    /// Injects a dependency registered by the given type.
    /// - Parameters:
    ///   - type: The type of the dependency.
    ///   - parameters: The parameters used to instantiate the dependency.
    @_disfavoredOverload
    init<each Parameter: Hashable>(
        type: Value.Type = Value.self,
        _ parameters: repeat each Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        self.init(locatorMatch: .init(byType: type)) {
            try DependencyGraph.inject(
                parameters: repeat each parameters
            )
        } unexpectedFailure: {
            fatal($0, file: file, line: line)
        }
    }
}

// MARK: By Collection Type

public extension Injected where Value: DependencyContainingCollection {

    /// Injects all dependencies registered by the given type.
    /// - Parameters:
    ///   - type: The type of the dependency.
    ///   - parameters: The parameters used to instantiate the dependency.
    init<SomeDependency, each Parameter: Hashable>(
        type: Value.Type = Value.self,
        _ parameters: repeat each Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) where Value.Element == SomeDependency {
        
        self.init(locatorMatch: .init(byType: SomeDependency.self)) {
            try DependencyGraph.inject(
                parameters: repeat each parameters
            )
        } unexpectedFailure: {
            fatal($0, file: file, line: line)
        }
    }
}



// MARK: By Optional Type

public extension Injected {
    
    /// Injects a dependency registered by the given type or nil if no such dependency exists.
    /// - Parameters:
    ///   - type: The type of the dependency.
    ///   - parameters: The parameters used to instantiate the dependency.
    init<SomeDependency, each Parameter: Hashable>(
        type: Value.Type = Value.self,
        _ parameters: repeat each Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) where Value == Optional<SomeDependency> {
        
        self.init(locatorMatch: .init(byType: SomeDependency.self)) {
            try DependencyGraph.inject(
                parameters: repeat each parameters
            )
        } unexpectedFailure: {
            fatal($0, file: file, line: line)
        }
    }
    
    /// Injects all dependencies registered by the given type.
    /// - Parameters:
    ///   - collectionType: The type of the dependency.
    ///   - parameters: The parameters used to instantiate the dependency.
    @available(*, deprecated, message: "Optional collection dependencies are deprecated. Please use an empty collection instead.")
    init<SomeCollection: DependencyContainingCollection, each Parameter: Hashable>(
        collectionType: Value.Type = Value.self,
        _ parameters: repeat each Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) where Value == Optional<SomeCollection> {
        
        self.init(locatorMatch: .init(byType: SomeCollection.Element.self)) {
            try DependencyGraph.inject(
                byType: Optional<SomeCollection>.self,
                parameters: repeat each parameters
            )
        } unexpectedFailure: {
            fatal($0, file: file, line: line)
        }
    }
}

// MARK: By Value

public extension Injected {
    
    /// Injects a dependency registered by the given value.
    /// - Parameters:
    ///   - value: The value associated with the dependency.
    ///   - parameters: The parameters used to instantiate the dependency.
    @_disfavoredOverload
    init<V: Hashable, each Parameter: Hashable>(
        value: V,
        _ parameters: repeat each Parameter,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        self.init(locatorMatch: .init(byValue: value)) {
            try DependencyGraph.inject(
                byValue: value,
                parameters: repeat each parameters
            )
        } unexpectedFailure: {
            fatal($0, file: file, line: line)
        }
    }
}
