//
//  IndexingKey.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 1/3/24.
//

import Foundation

/// A key used to index dependencies in order to decrease lookup time.
///
/// A set of indexing keys can be retrieved from a `DependencyLocator`, or a `RawDependencyRegistration`.
public struct IndexingKey: Hashable {
    
    private let signature: Int
    
    init(consuming data: AnyHashable...) {
        var hasher = Hasher()
        
        for datum in data {
            hasher.combine(datum)
        }
        
        self.signature = hasher.finalize()
    }
}
