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
    
    var value: Any? {
        _storedValue.pointee
    }
    
    private var subscription: AnyCancellable?
    
    init(key: Key, value: Value, tracking publisher: AnyPublisher<Void, Never>) {
        self.key = key
        self._storedValue = WeakReference(value)
        self.subscription = publisher.sink { [weak self] in
            self?.clear()
        }
    }
    
    @_disfavoredOverload
    init<V>(key: Key, value: V, tracking publisher: AnyPublisher<Void, Never>) where Value == Wrapper<V> {
        self.key = key
        self._storedValue = WeakReference(Wrapper(wrappedValue: value))
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
