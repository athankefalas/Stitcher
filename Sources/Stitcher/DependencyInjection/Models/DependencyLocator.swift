//
//  DependencyLocator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/2/24.
//

import Foundation

/// A type that can be used as a query to locate a dependency.
public struct DependencyLocator: Hashable {
    typealias Predicate = (MatchProposal) -> Bool
    
    struct MatchProposal: Hashable {
        let kind: Kind
        let wrappedValue: AnyHashable
        let indexingKey: IndexingKey
        
        private init(
            kind: Kind,
            wrappedValue: AnyHashable
        ) {
            self.kind = kind
            self.wrappedValue = wrappedValue
            self.indexingKey = IndexingKey(consuming: kind, wrappedValue)
        }
        
        init(
            byName name: String
        ) {
            self = MatchProposal(
                kind: .nameLocator,
                wrappedValue: name
            )
        }
        
        init<T>(
            byType type: T.Type
        ) {
            self = MatchProposal(
                kind: .typeLocator,
                wrappedValue: TypeName(
                    of: type
                )
            )
        }
        
        init<V: Hashable>(
            byValue value: V
        ) {
            self = MatchProposal(
                kind: .valueLocator,
                wrappedValue: value
            )
        }
    }
    
    enum Kind: Int, Hashable {
        case nameLocator
        case typeLocator
        case valueLocator
    }
    
    private let kind: Kind
    private let signature: AnyHashable
    private let indexingkeys: Set<IndexingKey>
    
    private init(
        kind: Kind,
        signature: AnyHashable
    ) {
        self.kind = kind
        self.signature = signature
        
        if kind == .typeLocator,
           let types = signature as? [TypeName] {
            
            self.indexingkeys = Set(types.map({ IndexingKey(consuming: kind, $0) }))
        } else {
            self.indexingkeys = [IndexingKey(consuming: kind, signature)]
        }
    }
    
    func addingSupertype<Supertype>(_ supertype: Supertype.Type) -> DependencyLocator? {
        
        guard kind == .typeLocator,
              var typeNames = signature as? [TypeName] else {
            return nil
        }
        
        let typeName = TypeName(of: Supertype.self)
        typeNames.append(typeName)
        
        return DependencyLocator(kind: .typeLocator, signature: typeNames)
    }
    
    func dependencyContext() -> InjectionError.DependencyContext {
        switch kind {
        case .nameLocator:
            let name = signature as? String ?? ""
            return .name(name)
        case .typeLocator:
            let types = (signature as? [TypeName]) ?? []
            return .type(types.first?.canonicalValue ?? "")
        case .valueLocator:
            return .value(signature)
        }
    }
    
    /// A set of keys that the dependency can be indexed by
    /// - Returns: A set of distinct indexing keys
    public func indexingKeys() -> Set<IndexingKey> {
        return indexingkeys
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
        hasher.combine(signature)
    }
    
    // MARK: Factory Methods
    
    /// A dependency locator that can be used to query dependencies by a name.
    /// - Parameter name: The name of the dependency.
    /// - Returns: A dependency locator.
    public static func name(
        _ name: String
    ) -> DependencyLocator {
        DependencyLocator(kind: .nameLocator, signature: name)
    }
    
    /// A dependency locator that can be used to query dependencies by a type.
    /// - Parameter primaryType: The primary `Swift` type of the dependency.
    /// - Returns: A dependency locator
    public static func type<PrimaryType>(
        _ primaryType: PrimaryType.Type
    ) -> DependencyLocator {
        let typeName = TypeName(of: primaryType)
        return DependencyLocator(kind: .typeLocator, signature: [typeName])
    }
    
    /// A dependency locator that can be used to query dependencies by a type and a subtype.
    /// - Parameters:
    ///   - primaryType: The primary `Swift` type of the dependency.
    ///   - secondaryType: The secondary `Swift` type of the dependency such as a superclass or a protocol.
    /// - Returns: A dependency locator
    public static func type<PrimaryType, SecondaryType>(
        _ primaryType: PrimaryType.Type,
        _ secondaryType: SecondaryType.Type
    ) -> DependencyLocator {
        let typeNames = [TypeName(of: primaryType), TypeName(of: secondaryType)]
        return DependencyLocator(kind: .typeLocator, signature: typeNames)
    }
    
    /// A dependency locator that can be used to query dependencies by a type and multiple subtypes..
    /// - Parameters:
    ///   - primaryType: The primary `Swift` type of the dependency.
    ///   - secondaryType: The secondary `Swift` type of the dependency, such as a superclass or a protocol.
    ///   - tertiaryType: The tertiary `Swift` type of the dependency, such as a superclass or a protocol.
    /// - Returns: A dependency locator
    public static func type<PrimaryType, SecondaryType, TertiaryType>(
        _ primaryType: PrimaryType.Type,
        _ secondaryType: SecondaryType.Type,
        _ tertiaryType: TertiaryType.Type
    ) -> DependencyLocator {
        let typeNames = [TypeName(of: primaryType), TypeName(of: secondaryType), TypeName(of: tertiaryType)]
        return DependencyLocator(kind: .typeLocator, signature: typeNames)
    }
    
    /// A dependency locator that can be used to query dependencies by an associated value.
    /// - Parameter value: The value associated with the dependency.
    /// - Returns: A dependency locator
    public static func value<V: Hashable>(
        _ value: V
    ) -> DependencyLocator {
        DependencyLocator(kind: .valueLocator, signature: value)
    }
    
    // MARK: Equatable
    
    public static func == (lhs: DependencyLocator, rhs: DependencyLocator) -> Bool {
        lhs.kind == rhs.kind && lhs.signature == rhs.signature
    }
    
    static func == (lhs: DependencyLocator, rhs: DependencyLocator.MatchProposal) -> Bool {
        lhs.indexingkeys.contains(rhs.indexingKey)
    }
    
    static func == (lhs: DependencyLocator.MatchProposal, rhs: DependencyLocator) -> Bool {
        rhs.indexingkeys.contains(lhs.indexingKey)
    }
}
