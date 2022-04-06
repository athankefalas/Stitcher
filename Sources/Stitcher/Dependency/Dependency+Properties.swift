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
//  Dependency+Properties.swift
//  
//
//  Created by Athanasios Kefalas on 20/3/22.
//

import Foundation

public extension Dependency {
    
    init<T>(property propertyName: String, get getter: @escaping () -> T, set setter: @escaping (T) -> Void) {
        let property = PropertyImplementation(get: getter, set: setter)
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return property
        }
        
        self.init(.property(propertyName, type: T.self), dependencyInstantiator)
    }
    
    init<T>(property propertyName: String, _ property: PropertyImplementation<T>) {
        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return property
        }
        
        self.init(.property(propertyName, type: T.self), dependencyInstantiator)
    }
}

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Dependency {
    
    init<T>(property propertyName: String, _ binding: Binding<T>) {
        let property = PropertyImplementation {
            binding.wrappedValue
        } set: { newValue in
            binding.wrappedValue = newValue
        }

        let dependencyInstantiator = DependencyInstantiator(parameterTypes: []) { _ in
            return property
        }
        
        self.init(.property(propertyName, type: T.self), dependencyInstantiator)
    }
    
}

#endif
