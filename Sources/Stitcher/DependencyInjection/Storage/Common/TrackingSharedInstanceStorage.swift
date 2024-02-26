//
//  TrackingSharedInstanceStorage.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 5/2/24.
//

import Foundation
import Combine

class TrackingSharedInstanceStorage<Value: AnyObject>: InstanceStorage {
    
    let key: Key
    
    private let _storedValue: WeakReference<Value>
    private let _value_getter: (WeakReference<Value>) -> Any?
    
    var value: Any? {
        _value_getter(_storedValue)
    }
    
    private var subscription: AnyCancellable?
    
    init(key: Key, value: Value, tracking publisher: AnyPublisher<Void, Never>) {
        self.key = key
        self._storedValue = WeakReference(value)
        self._value_getter = { $0.pointee }
        
        self.subscription = publisher.sink { [weak self] in
            self?.clear()
        }
    }
    
    @_disfavoredOverload
    init<V>(key: Key, value: V, tracking publisher: AnyPublisher<Void, Never>) where Value == Wrapper<V> {
        self.key = key
        self._storedValue = WeakReference(Wrapper(wrappedValue: value))
        self._value_getter = { $0.pointee?.wrappedValue }
        
        self.subscription = publisher.sink { [weak self] in
            self?.clear()
        }
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
    
    private func clear() {
        _storedValue.release()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: TrackingSharedInstanceStorage<Value>, rhs: TrackingSharedInstanceStorage<Value>) -> Bool {
        lhs.key == rhs.key && lhs._storedValue.pointee === rhs._storedValue.pointee
    }
}
