//
//  Hashtable.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 5/3/22.
//

import Foundation

final class Hashtable<Key: Hashable, Value: Equatable> {
    
    private struct Index: RawRepresentable, Hashable {
        let rawValue: UInt
        
        init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
    
    private let capacity: UInt
    private var buckets: [Index : [Value]] = [:]
    
    init(capacity: UInt) {
        self.capacity = capacity
    }
    
    private subscript(_ index: Index) -> [Value] {
        get {
            buckets[index, default: []]
        }
        
        set {
            buckets[index] = newValue
        }
    }
    
    subscript(_ key: Key) -> [Value] {
        get {
            let index = index(of: key)
            return self[index]
        }
        
        set {
            let index = index(of: key)
            self[index] = newValue
        }
    }
    
    // MARK: Collection
    
    func add(_ value: Value, for key: Key) {
        self[key].append(value)
    }
    
    func add<KeySequence: Sequence>(_ value: Value, for keys: KeySequence) where KeySequence.Element == Key {
        keys.forEach { key in
            add(value, for: key)
        }
    }
    
    func remove(_ value: Value, for key: Key) {
        self[key].removeAll(where: { $0 == value })
    }
    
    func remove<KeySequence: Sequence>(_ value: Value, for keys: KeySequence) where KeySequence.Element == Key {
        keys.forEach { key in
            remove(value, for: key)
        }
    }
    
    func contains(_ value: Value, at key: Key) -> Bool {
        return self[key].contains(value)
    }
    
    func contains<KeySequence: Sequence>(_ value: Value, at keys: KeySequence) -> Bool where KeySequence.Element == Key {
        for key in keys {
            if contains(value, at: key) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: Indices
    
    private func index(of key: Key) -> Index {
        let hashValue = UInt(abs(key.hashValue))
        let rawIndex = hashValue % capacity
        
        return Index(rawValue: rawIndex)
    }
}
