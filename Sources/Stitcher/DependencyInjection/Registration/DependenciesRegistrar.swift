//
//  DependenciesRegistrar.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 29/2/24.
//

import Foundation
import OrderedCollections

/// A set of raw dependency registrations
public typealias DependenciesRegistrar = Set<RawDependencyRegistration>

extension Set<RawDependencyRegistration> {
    
    public init<Registrars: Sequence>(
        reducing sequence: Registrars
    ) where Registrars.Element == Self {
        self.init(sequence.flatMap({ $0 }))
    }
    
    func registrations(
        matching proposal: DependencyLocator.MatchProposal
    ) -> Set<Element> {
        
        return Set(self.filter({ $0.locator == proposal }))
    }
    
    func toArray() -> [Element] {
        Array(self)
    }
}
