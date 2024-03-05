//
//  Wrapper.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import Foundation

class Wrapper<T> {
    
    var wrappedValue: T
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}
