//
//  ThreadIdentifierThreadValuesKey.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

struct ThreadIdentifierThreadValuesKey: ThreadValuesKey {
    static let rawThreadKey = RawThreadKey<Int>()
    
    static var defaultValue: Int {
        UUID().hashValue
    }
}

extension ThreadValuesKey where Self == ThreadIdentifierThreadValuesKey {
    
    static var threadIdentifier: ThreadIdentifierThreadValuesKey {
        ThreadIdentifierThreadValuesKey()
    }
}

extension ThreadValues {
    
    static var threadIdentifier: ThreadIdentifierThreadValuesKey.Value {
        get { self[ThreadIdentifierThreadValuesKey.self] }
    }
}
