//
//  SharedInstanceStorage.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 5/2/24.
//

import Foundation

class SharedInstanceStorage<Value: AnyObject>: InstanceStorage {
    
    let key: Key
    
    private let _storedValue: WeakReference<Value>
    private let _value_getter: (WeakReference<Value>) -> Any?
    
    var value: Any? {
        _value_getter(_storedValue)
    }
    
    init(key: Key, value: Value) {
        self.key = key
        self._storedValue = WeakReference(value)
        self._value_getter = { $0.pointee }
    }
    
    @_disfavoredOverload
    init<V>(key: Key, value: V) where Value == Reference<V> {
        self.key = key
        self._storedValue = WeakReference(Reference(wrappedValue: value))
        self._value_getter = { $0.pointee?.wrappedValue }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: SharedInstanceStorage<Value>, rhs: SharedInstanceStorage<Value>) -> Bool {
        lhs.key == rhs.key && lhs._storedValue.pointee === rhs._storedValue.pointee
    }
}
