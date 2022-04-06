//
//  CollectionsExtensions.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 6/3/22.
//

import Foundation

// MARK: Array Utils

extension Collection {
    
    var isNotEmpty: Bool {
        !isEmpty
    }
    
}

extension Array {
    
    @inlinable
    internal func anySatisfies(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        try reduce(false, { try predicate($1) || $0 })
    }
    
}

extension Array where Element: Hashable {
    
    internal var containsDuplicates: Bool {
        Set(self).count != self.count
    }
    
    internal func distinct() -> [Element] {
        reduce([]) { collector, element in
            guard !collector.contains(element) else {
                return collector
            }
            
            var mutableCollector = collector
            mutableCollector.append(element)
            
            return mutableCollector
        }
    }
}

extension Array {
    
    internal func parameterAt<T>(_ index: Index, as type: T.Type = T.self) throws -> T {
        if index < 0 || index >= count {
            throw InstantiationError.incorrectParameterCount
        }
        
        do {
            let parameter = self[index]
            return try cast(parameter)
        } catch {
            guard let error = error as? TypeCastingError else {
                throw error
            }
            
            throw InstantiationError.incorrectParameterType(error)
        }
    }
    
}

