//
//  NeverInstanceStorage.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 5/2/24.
//

import Foundation

class NeverInstanceStorage: InstanceStorage {
    
    let key: Key
    let value: Any? = nil
    
    init(key: Key) {
        self.key = key
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: NeverInstanceStorage, rhs: NeverInstanceStorage) -> Bool {
        lhs.key == rhs.key
    }
}
