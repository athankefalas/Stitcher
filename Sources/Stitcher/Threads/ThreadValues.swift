//
//  ThreadValues.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

enum ThreadValues {
    
    static subscript<Key: ThreadValuesKey>(key: Key.Type) -> Key.Value {
        get {
            if let value = key.rawThreadKey.read() {
                return value
            }
            
            let value = key.defaultValue
            
            do {
                try key.rawThreadKey.write(value)
            } catch {
                print("ThreadValues failed to write value \(value) for key '\(Key.self)'.")
            }
            
            return value
        }
        
        set {
            do {
                try key.rawThreadKey.write(newValue)
            } catch {
                print("ThreadValues failed to write value \(newValue) for key '\(Key.self)'.")
            }
        }
    }
}
