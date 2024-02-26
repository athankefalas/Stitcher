//
//  Dependency.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/2/24.
//

import Foundation

/// A type that represents a dependency registration.
/// The registration of a dependency must be added to a dependency container.
///
/// Dependencies can be located by a name, by their type or by an associated value.
/// Create a dependency registration in a `DependencyContainer` using the following API:
///
/// ``` swift
///
/// // Registers a dependency, located by it's name.
///
/// Dependency {
///   SomeService()
/// }
/// .named("some_service")
///
/// // Registers a dependency, located by it's type.
///
/// SomeService()
///
/// Dependency {
///   SomeService()
/// }
///
/// Dependency {
///   SomeService()
/// }
/// .conforms(to: SomeServiceProtocol.self)
///
/// Dependency {
///   SomeService()
/// }
/// .inherits(from: SomeServiceSuperclass.self)
///
/// // Registers a dependency, located by an associated value.
///
/// Dependency {
///   SomeService()
/// }
/// .associated(with: someHashableValue)
///
/// ```
public struct Dependency<T, LocatorTrait: DependencyLocatorTrait>: Hashable {
    
    private(set) var locator: DependencyLocator
    private(set) var factory: DependencyFactory
    private(set) var scope: DependencyScope
    private(set) var eagerness: DependencyEagerness
    
    init(
        locator: DependencyLocator,
        factory: DependencyFactory,
        scope: DependencyScope,
        eagerness: DependencyEagerness
    ) {
        self.locator = locator
        self.factory = factory
        self.scope = scope
        self.eagerness = eagerness
    }
    
    /// Modifes the scope of the registered dependency
    /// - Parameter scope: The desired scope
    /// - Returns: A modified dependency registration
    public func scope(_ scope: DependencyScope) -> Self {
        var mutableSelf = self
        mutableSelf.scope = scope
        
        return mutableSelf
    }
    
    /// Modifes the eagerness of the registered dependency
    /// - Parameter eagerness: The desired eagerness
    /// - Returns: A modified dependency registration
    public func eagerness(_ eagerness: DependencyEagerness) -> Self {
        var mutableSelf = self
        mutableSelf.eagerness = eagerness
        
        return mutableSelf
    }
}


// MARK: Register By Name

public extension Dependency where LocatorTrait == NameLocatedDependency {
    
    /// Initalizes a dependency registration located by an associated name.
    /// - Parameters:
    ///   - name: The name associated with the dependency.
    ///   - provider: A function that provides an instance of the dependency.
    init<each Parameter: Hashable>(
        named name: String,
        dependecy provider: @Sendable @escaping (repeat each Parameter) -> T
    ) {
        
        self.init(
            locator: .name(name),
            factory: .from(function: provider),
            scope: .automatic(for: T.self),
            eagerness: .lazy
        )
    }
    
    /// Initalizes a dependency registration located by an associated name.
    /// - Parameters:
    ///   - nameRepresentation: A representation of the dependency name.
    ///   - provider: A function that provides an instance of the dependency.
    init<NameRepresentation: CustomStringConvertible, each Parameter: Hashable>(
        named nameRepresentation: NameRepresentation,
        dependecy provider: @Sendable @escaping (repeat each Parameter) -> T
    ) {
        
        self.init(
            locator: .name(nameRepresentation.description),
            factory: .from(function: provider),
            scope: .automatic(for: T.self),
            eagerness: .lazy
        )
    }
    
    /// Initalizes a dependency registration located by an associated name.
    /// - Parameters:
    ///   - nameRepresentation: A representation of the dependency name.
    ///   - provider: A function that provides an instance of the dependency.
    init<NameRepresentation: RawRepresentable, each Parameter: Hashable>(
        named nameRepresentation: NameRepresentation,
        dependecy provider: @Sendable @escaping (repeat each Parameter) -> T
    ) where NameRepresentation.RawValue == String {
        
        self.init(
            locator: .name(nameRepresentation.rawValue),
            factory: .from(function: provider),
            scope: .automatic(for: T.self),
            eagerness: .lazy
        )
    }
}

// MARK: Register By Type

public extension Dependency where LocatorTrait == MaybeTypeLocatedDependency {
    
    /// Initalizes a dependency registration located by it's type.
    /// - Parameter provider: A function that provides an instance of the dependency.
    init<each Parameter: Hashable>(
        dependecy provider: @Sendable @escaping (repeat each Parameter) -> T
    ) {
        
        self.init(
            locator: .type(T.self),
            factory: .from(function: provider),
            scope: .automatic(for: T.self),
            eagerness: .lazy
        )
    }
    
    /// Modifies the dependency registration so the dependency can be located by name.
    /// - Parameter name: The name associated with the dependency
    /// - Returns: A modified dependency registration
    func named(
        _ name: String
    ) -> Dependency<T, NameLocatedDependency> {
        Dependency<T, NameLocatedDependency>(
            locator: .name(name),
            factory: factory,
            scope: scope,
            eagerness: eagerness
        )
    }
    
    /// Modifies the dependency registration so the dependency can be located by name.
    /// - Parameter name: The name associated with the dependency.
    /// - Returns: A modified dependency registration.
    func named<Name: CustomStringConvertible>(
        _ name: Name
    ) -> Dependency<T, NameLocatedDependency> {
        Dependency<T, NameLocatedDependency>(
            locator: .name(name.description),
            factory: factory,
            scope: scope,
            eagerness: eagerness
        )
    }
    
    /// Modifies the dependency registration so the dependency can be located by name.
    /// - Parameter name: The name associated with the dependency.
    /// - Returns: A modified dependency registration.
    func named<Name: RawRepresentable>(
        _ name: Name
    ) -> Dependency<T, NameLocatedDependency>
    where Name.RawValue == String {
        Dependency<T, NameLocatedDependency>(
            locator: .name(name.rawValue),
            factory: factory,
            scope: scope,
            eagerness: eagerness
        )
    }
    
    
    /// Modifies the dependency registration so the dependency can also be located by the given protocol.
    /// - Parameter protocol: The protocol that the dependency conforms to.
    /// - Returns: A modified dependency registration.
    func conforms<P>(
        to protocol: P.Type
    ) -> Dependency<T, TypeLocatedDependency> {
        Dependency<T, TypeLocatedDependency>(
            locator: locator.addingSupertype(P.self) ?? locator,
            factory: factory,
            scope: scope,
            eagerness: eagerness
        )
    }
    
    /// Modifies the dependency registration so the dependency can also be located by the given superclass.
    /// - Parameter superclass: The supercall that the dependency inferits from.
    /// - Returns: A modified dependency registration.
    func inherits<C>(
        from superclass: C.Type
    ) -> Dependency<T, TypeLocatedDependency> {
        Dependency<T, TypeLocatedDependency>(
            locator: locator.addingSupertype(C.self) ?? locator,
            factory: factory,
            scope: scope,
            eagerness: eagerness
        )
    }
    
    /// Modifies the dependency registration so the dependency can be located by an associated value.
    /// - Parameter value: The value associated with the dependency.
    /// - Returns: A modified dependency registration.
    func associated<Value: Hashable>(
        with value: Value
    ) -> Dependency<T, ValueLocatedDependency> {
        Dependency<T, ValueLocatedDependency>(
            locator: .value(value),
            factory: factory,
            scope: scope,
            eagerness: eagerness
        )
    }
}

// MARK: Register By Type + Conformance

public extension Dependency where LocatorTrait == TypeLocatedDependency {
    
    /// Initalizes a dependency registration located by it's type and a protocol it conforms to.
    /// - Parameters:
    ///   - secondaryType: The protocol the dependency conforms to.
    ///   - provider: A function that provides an instance of the dependency.
    init<S, each Parameter: Hashable>(
        conformingTo secondaryType: S.Type,
        dependecy provider: @Sendable @escaping (repeat each Parameter) -> T
    ) {
        
        self.init(
            locator: .type(T.self, secondaryType),
            factory: .from(function: provider),
            scope: .automatic(for: T.self),
            eagerness: .lazy
        )
    }
    
    /// Initalizes a dependency registration located by it's type and a superclass it inherits from.
    /// - Parameters:
    ///   - secondaryType: The superclass the dependency conforms to.
    ///   - provider: A function that provides an instance of the dependency.
    init<S, each Parameter: Hashable>(
        inheritingFrom secondaryType: S.Type,
        dependecy provider: @Sendable @escaping (repeat each Parameter) -> T
    ) {
        
        self.init(
            locator: .type(T.self, secondaryType),
            factory: .from(function: provider),
            scope: .automatic(for: T.self),
            eagerness: .lazy
        )
    }
    
    /// Modifies the dependency registration so the dependency can also be located by the given protocol.
    /// - Parameter protocol: The protocol that the dependency conforms to.
    /// - Returns: A modified dependency registration.
    func conforms<P>(to protocol: P.Type) -> Dependency {
        Dependency(
            locator: locator.addingSupertype(P.self) ?? locator,
            factory: factory,
            scope: scope,
            eagerness: eagerness
        )
    }
    
    /// Modifies the dependency registration so the dependency can also be located by the given superclass.
    /// - Parameter superclass: The supercall that the dependency inferits from.
    /// - Returns: A modified dependency registration.
    func inherits<C>(from superclass: C.Type) -> Dependency {
        Dependency(
            locator: locator.addingSupertype(C.self) ?? locator,
            factory: factory,
            scope: scope,
            eagerness: eagerness
        )
    }
}

// MARK: Register By Value

public extension Dependency where LocatorTrait == ValueLocatedDependency {
    
    /// Initalizes a dependency registration located by an associated value.
    /// - Parameters:
    ///   - value: The value to associate to the dependency.
    ///   - provider: A function that provides an instance of the dependency.
    init<V: Hashable, each Parameter: Hashable>(
        for value: V,
        dependecy provider: @Sendable @escaping (repeat each Parameter) -> T
    ) {
        
        self.init(
            locator: .value(value),
            factory: .from(function: provider),
            scope: .automatic(for: T.self),
            eagerness: .lazy
        )
    }
}
