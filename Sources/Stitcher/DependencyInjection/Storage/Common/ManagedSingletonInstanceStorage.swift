//
//  ManagedSingletonInstanceStorage.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 5/2/24.
//

import Foundation

class ManagedSingletonInstanceStorage<Value: AnyObject>: InstanceStorage {
    
    let key: Key
    
    @Atomic
    private var _storedValue: Value?
    private let _value_getter: (Value?) -> Any?
    
    var value: Any? {
        _value_getter(_storedValue)
    }
    
    private var subscription: ManagedDependencyScopeReceipt?
    
    init(key: Key, value: Value, tracking scope: ManagedDependencyScopeProviding) {
        self.key = key
        self._storedValue = value
        self._value_getter = { $0 }
        
        self.subscription = scope.onScopeInvalidated { [weak self] in
            self?.clear()
        }
    }
    
    @_disfavoredOverload
    init<V>(key: Key, value: V, tracking scope: ManagedDependencyScopeProviding) where Value == Reference<V> {
        self.key = key
        self._storedValue = Reference(wrappedValue: value)
        self._value_getter = { $0?.wrappedValue }
        
        self.subscription = scope.onScopeInvalidated { [weak self] in
            self?.clear()
        }
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
    
    private func clear() {
        _storedValue = nil
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: ManagedSingletonInstanceStorage<Value>, rhs: ManagedSingletonInstanceStorage<Value>) -> Bool {
        lhs.key == rhs.key && lhs._storedValue === rhs._storedValue
    }
}
