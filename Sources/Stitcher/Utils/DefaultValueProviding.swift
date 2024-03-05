//
//  DefaultValueProviding.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import Foundation

protocol DefaultValueProviding {
    
    static var defaultValue: Any { get }
    
    static func isDefault(value: Any) -> Bool
}

extension Optional: DefaultValueProviding {
    
    static var defaultValue: Any {
        return Self.none as Any
    }
    
    static func isDefault(value: Any) -> Bool {
        guard let typedValue = value as? Self else {
            return false
        }
        
        return typedValue == nil
    }
}

extension Array: DefaultValueProviding {
    
    static var defaultValue: Any { [] }
    
    static func isDefault(value: Any) -> Bool {
        guard let typedValue = value as? Self else {
            return false
        }
        
        return typedValue.isEmpty
    }
}

extension Set: DefaultValueProviding {
    
    static var defaultValue: Any { [] }
    
    static func isDefault(value: Any) -> Bool {
        guard let typedValue = value as? Self else {
            return false
        }
        
        return typedValue.isEmpty
    }
}

extension Dictionary: DefaultValueProviding {
    
    static var defaultValue: Any { [:] }
    
    static func isDefault(value: Any) -> Bool {
        guard let typedValue = value as? Self else {
            return false
        }
        
        return typedValue.isEmpty
    }
}

struct DefaultValueProvider<T> {
    
    let providesDefaultValue: Bool
    let defaultValue: () -> T
    let isDefaulValue: (T) -> Bool
    
    init(
        type: T.Type = T.self
    ) {
        
        guard let type = T.self as? DefaultValueProviding.Type,
            let defaultValue = type.defaultValue as? T else {
            self = .init(providesDefaultValue: false)
            
            return
        }
        
        self = .init(
            providesDefaultValue: true,
            defaultValue: { defaultValue },
            isDefaulValue: { type.isDefault(value: $0) }
        )
    }
    
    private init(
        providesDefaultValue: Bool,
        defaultValue: @escaping () -> T = { fatalError() },
        isDefaulValue: @escaping (T) -> Bool = {_ in false}
    ) {
        self.providesDefaultValue = providesDefaultValue
        self.defaultValue = defaultValue
        self.isDefaulValue = isDefaulValue
    }
    
    func isDefault(value: T) -> Bool {
        
        guard providesDefaultValue else {
            return false
        }
        
        return isDefaulValue(value)
    }
}
