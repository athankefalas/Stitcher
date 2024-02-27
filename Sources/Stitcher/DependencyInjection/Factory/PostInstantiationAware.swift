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

