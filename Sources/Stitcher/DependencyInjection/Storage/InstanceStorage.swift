//
//  InstanceStorage.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 5/2/24.
//

import Foundation

protocol InstanceStorage: Hashable {
    typealias Key = InstanceStorageKey
    
    var key: Key { get }
    var value: Any? { get }
}

extension InstanceStorage {
    
    var isEmpty: Bool {
        value == nil
    }
    
    func erased() -> AnyInstanceStorage {
        AnyInstanceStorage(erasing: self)
    }
}

class AnyInstanceStorage: InstanceStorage {
    
    private let _storedValue: @Sendable () -> Any?
    private let _hash: @Sendable (inout Hasher) -> Void
    
    var value: Any? {
        _storedValue()
    }
    
    let key: Key
    
    init<Storage: InstanceStorage>(erasing storage: Storage) {
        self._storedValue = { storage.value }
        self._hash = { storage.hash(into: &$0) }
        self.key = storage.key
    }
    
    func hash(into hasher: inout Hasher) {
        _hash(&hasher)
    }
    
    static func == (lhs: AnyInstanceStorage, rhs: AnyInstanceStorage) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
