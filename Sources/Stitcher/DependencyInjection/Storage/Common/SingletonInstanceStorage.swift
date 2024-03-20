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
    private let _value_getter: (Value) -> Any?
    
    var value: Any? {
        _value_getter(_storedValue)
    }
    
    init(key: Key, value: Value) {
        self.key = key
        self._storedValue = value
        self._value_getter = { $0 }
    }
    
    @_disfavoredOverload
    init<V>(key: Key, value: V) where Value == Reference<V> {
        self.key = key
        self._storedValue = Reference(wrappedValue: value)
        self._value_getter = { $0.wrappedValue }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: SingletonInstanceStorage<Value>, rhs: SingletonInstanceStorage<Value>) -> Bool {
        lhs.key == rhs.key && lhs._storedValue === rhs._storedValue
    }
}
