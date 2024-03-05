//
//  ManagedSingletonInstanceStorage.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 5/2/24.
//

import Foundation
import Combine

class ManagedSingletonInstanceStorage<Value: AnyObject>: InstanceStorage {
    
    let key: Key
    
    @Atomic
    private var _storedValue: Value?
    private let _value_getter: (Value?) -> Any?
    
    var value: Any? {
        _value_getter(_storedValue)
    }
    
    private var subscription: AnyCancellable?
    
    init(key: Key, value: Value, tracking publisher: AnyPublisher<Void, Never>) {
        self.key = key
        self._storedValue = value
        self._value_getter = { $0 }
        
        self.subscription = publisher.sink { [weak self] in
            self?.clear()
        }
    }
    
    @_disfavoredOverload
    init<V>(key: Key, value: V, tracking publisher: AnyPublisher<Void, Never>) where Value == Wrapper<V> {
        self.key = key
        self._storedValue = Wrapper(wrappedValue: value)
        self._value_getter = { $0?.wrappedValue }
        
        self.subscription = publisher.sink { [weak self] in
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
