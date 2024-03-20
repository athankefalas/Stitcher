//
//  PostInstantiationAware.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/24.
//

import Foundation

/// A type that should be notified after instances of it are created from a dependency graph, but before they are injected.
public protocol PostInstantiationAware {
    
    func didInstantiate()
}

struct AnyPostInstantiationAware: PostInstantiationAware {
    
    private let _didInstantiate: () -> Void
    
    init<Instance: PostInstantiationAware>(_ instance: Instance) {
        self._didInstantiate = { instance.didInstantiate() }
    }
    
    func didInstantiate() {
        _didInstantiate()
    }
}
