//
//  SingletonInstanceStorage.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 5/2/24.
//

import Foundation

class SingletonInstanceStorage<Value: AnyObject>: InstanceStorage {
    
    let key: Key
    
    private let _storedValue: Value
    
    var value: Any? {
        _storedValue
    }
    
    init(key: Key, value: Value) {
        self.key = key
        self._storedValue = value
    }
    
    @_disfavoredOverload
    init<V>(key: Key, value: V) where Value == Wrapper<V> {
        self.key = key
        self._storedValue = Wrapper(wrappedValue: value)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: SingletonInstanceStorage<Value>, rhs: SingletonInstanceStorage<Value>) -> Bool {
        lhs.key == rhs.key && lhs._storedValue === rhs._storedValue
    }
}
