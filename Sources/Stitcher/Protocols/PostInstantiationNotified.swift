//
//  PostInstantiationNotified.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/22.
//

import Foundation

/// A type that should be notified after instances of it are created from a dependency graph, but before they are injected.
public protocol PostInstantiationNotified {
    
    func didInstantiate()
}
