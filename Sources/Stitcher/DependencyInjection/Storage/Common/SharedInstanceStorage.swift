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
    
    var value: Any? {
        _storedValue.pointee
    }
    
    init(key: Key, value: Value) {
        self.key = key
        self._storedValue = WeakReference(value)
    }
    
    @_disfavoredOverload
    init<V>(key: Key, value: V) where Value == Wrapper<V> {
        self.key = key
        self._storedValue = WeakReference(Wrapper(wrappedValue: value))
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: SharedInstanceStorage<Value>, rhs: SharedInstanceStorage<Value>) -> Bool {
        lhs.key == rhs.key && lhs._storedValue.pointee === rhs._storedValue.pointee
    }
}
