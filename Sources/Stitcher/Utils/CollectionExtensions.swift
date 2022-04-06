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
//  CollectionsExtensions.swift
//  
//
//  Created by Athanasios Kefalas on 6/3/22.
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

