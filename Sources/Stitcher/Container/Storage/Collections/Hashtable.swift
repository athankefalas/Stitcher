//
// MIT License
//
// Copyright (c) 2022 Athanasios Kefalas
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//
//  Hashtable.swift
//  
//
//  Created by Athanasios Kefalas on 5/3/22.
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
