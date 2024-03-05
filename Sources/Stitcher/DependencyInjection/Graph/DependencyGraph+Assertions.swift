//
//  DependencyGraph+Assertions.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/24.
//

import Foundation

public extension DependencyGraph {
    
    struct DependencyRegistrationProjection {
        public let locator: DependencyLocator
        public let scope: DependencyScope
        public let eagerness: DependencyEagerness
        
        init(
            _ registration: RawDependencyRegistration
        ) {
            self.locator = registration.locator
            self.scope = registration.scope
            self.eagerness = registration.eagerness
        }
        
        public func isLocatedBy(name: String) -> Bool {
            return locator == DependencyLocator.MatchProposal(byName: name)
        }
        
        public func isLocatedBy<T>(type: T.Type) -> Bool {
            return locator == DependencyLocator.MatchProposal(byType: type)
        }
        
        public func isLocatedBy<V: Hashable>(value: V) -> Bool {
            return locator == DependencyLocator.MatchProposal(byValue: value)
        }
    }
    
    struct DependencyRegistrarProjection {
        
        public let registrations: [DependencyRegistrationProjection]
        
        public var count: Int {
            registrations.count
        }
        
        public var isEmpty: Bool {
            registrations.isEmpty
        }
        
        init(registrations: [RawDependencyRegistration]) {
            self.registrations = registrations.map({ DependencyRegistrationProjection($0) })
        }
        
        public func matches(
            where predicate: (DependencyRegistrationProjection) -> Bool
        ) -> [DependencyRegistrationProjection] {
            registrations.filter(predicate)
        }
        
        public func withMatches(
            where predicate: (DependencyRegistrationProjection) -> Bool,
            perform validation: ([DependencyRegistrationProjection]) throws -> Void
        ) rethrows {
            try validation(matches(where: predicate))
        }
        
        public func withFirstMatch(
            where predicate: (DependencyRegistrationProjection) -> Bool,
            perform validation: (DependencyRegistrationProjection?) throws -> Void
        ) rethrows {
            try validation(matches(where: predicate).first)
        }
    }
    
    static func validate(
        using validator: (DependencyRegistrarProjection) throws -> Void
    ) rethrows {
        try validator(
            DependencyRegistrarProjection(
                registrations: dependencyRegistrations()
            )
        )
    }
}
